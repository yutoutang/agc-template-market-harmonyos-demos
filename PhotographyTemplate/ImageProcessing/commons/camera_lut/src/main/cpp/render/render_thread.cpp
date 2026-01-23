#include "render_thread.h"

#include "../common/common.h"
#include <future>
#include <hilog/log.h>

namespace NativeXComponentSample {
namespace Detail {
std::string vertexShader = R"delimiter(
attribute vec3 position;
attribute vec2 texCoord;

varying vec2 vTexCoord;

uniform mat4 matTransform;

void main()
{
    gl_Position = matTransform * vec4(position, 1.0);
    vTexCoord = texCoord;
}
)delimiter";

std::string fragmentShader = R"delimiter(
#extension GL_OES_EGL_image_external : require
precision highp float;
varying vec2 vTexCoord;
uniform samplerExternalOES texture;

void main()
{
    gl_FragColor = texture2D(texture, vTexCoord).rgba;
}
)delimiter";

std::string fragmentShaderBW = R"delimiter(
#extension GL_OES_EGL_image_external : require
precision mediump float;
varying vec2 vTexCoord;
uniform samplerExternalOES texture;
void main()
{
    vec4 tc = texture2D(texture, vTexCoord);
    float color = tc.r * 0.3 + tc.g * 0.59 + tc.b * 0.11;
    gl_FragColor = vec4(color, color, color, 1.0);
}
)delimiter";

// 片元着色器(自定义)
std::string fragmentShaderLut = R"delimiter(
#extension GL_OES_EGL_image_external : require
precision highp float;
varying vec2 vTexCoord;
uniform samplerExternalOES texture;
// 滤镜纹理
uniform sampler2D s_LutTexture;
void main()
{
    //首先原始采样像素的 RGBA 值
    vec4 textureColor = texture2D(texture, vTexCoord);
    //解析点1
    float blueColor = clamp(textureColor.b, 0.0, 1.0) * 63.0;
    //取与 B 分量值最接近的 2 个小方格的坐标
    vec2 quad1; 
    quad1.y = floor(floor(blueColor) / 8.0);   //floor 向下取整 
    quad1.x = floor(blueColor) - (quad1.y * 8.0);
    quad1 = clamp(quad1, 0.0, 7.0);
    vec2 quad2;
    quad2.y = floor(ceil(blueColor) / 7.9999);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);
    quad2 = clamp(quad2, 0.0, 7.0);
    //解析点2
    vec2 texPos1; 
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
    vec2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
    //取目标映射对应的像素值
    vec4 newColor1 = texture2D(s_LutTexture, texPos1);
    vec4 newColor2 = texture2D(s_LutTexture, texPos2);
    //解析点3
    vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
    //解析点4
    //原图0.0和lut1.0
    gl_FragColor = mix(textureColor, vec4(newColor.rgb, textureColor.w), 1.0);
}
)delimiter";

GLfloat vertices[] = {
    // positions       // texture coords
    //     -1.0f, 1.0f,  0.0f, 0.0f, 1.0f, // top left
    //     -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, // bottom left
    //     1.0f, -1.0f, 0.0f, 1.0f, 0.0f, // bottom right
    //     1.0f, 1.0f,  0.0f, 1.0f, 1.0f  // top right

    -1.0f, 1.0f,  0.0f, 1.0f, 1.0f, // top left
    -1.0f, -1.0f, 0.0f, 1.0f, 0.0f, // bottom left
    1.0f,  -1.0f, 0.0f, 0.0f, 0.0f, // bottom right
    1.0f,  1.0f,  0.0f, 0.0f, 1.0f  // top right
};
GLuint indices[] = {
    0, 1, 2, // first triangle
    0, 2, 3  // second triangle
};
} // namespace Detail

RenderThread::RenderThread() { Start(); }

RenderThread::~RenderThread() noexcept { Stop(); }

void RenderThread::Stop() {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "开始RenderThread析构");

    bool expected = false;
    if (!stopping_.compare_exchange_strong(expected, true)) {
        return; // 已经在停或停过，幂等
    }

    // 1) 停主循环
    running_ = false;
    {
        std::lock_guard<std::mutex> lk(wakeUpMutex_);
        wakeUp_ = true;
    }
    wakeUpCond_.notify_all();

    // 2) 解绑回调（防止尾帧继续唤醒）
    if (nativeImage_) {
        (void)OH_NativeImage_UnsetOnFrameAvailableListener(nativeImage_);
    }

    // 3) 等线程自然收尾（线程尾里做：CleanGLResources/DestroyNativeImage/DestroyVsync/DestroyRenderContext）
    if (thread_.joinable()) {
        thread_.join();
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "结束RenderThread析构");
}

bool RenderThread::InitRenderContext() {
    renderContext_ = std::make_unique<EglRenderContext>();
    return renderContext_->Init();
}

void RenderThread::DestroyRenderContext() { renderContext_.reset(); }

void RenderThread::CleanGLResources() {
    glDeleteVertexArrays(1, &vertexArrayObject_);
    glDeleteBuffers(1, &vertexBufferObject_);
    shaderProgram_.reset();
}

bool RenderThread::CreateGLResources() {
    shaderProgram_ = std::make_unique<ShaderProgram>(Detail::vertexShader, Detail::fragmentShader);
    if (!shaderProgram_->Valid()) {
        return false;
    }

    glGenVertexArrays(1, &vertexArrayObject_);
    glGenBuffers(1, &vertexBufferObject_);

    glBindVertexArray(vertexArrayObject_);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObject_);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Detail::vertices), Detail::vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    return true;
}

void RenderThread::UpdateNativeWindow(void *window, uint64_t width, uint64_t height) {
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "UpdateNativeWindow.");
    auto nativeWindow = reinterpret_cast<OHNativeWindow *>(window);
    PostTask([this, nativeWindow, width, height](EglRenderContext &renderContext) {
        if (nativeWindow_ != nativeWindow) {
//            if (nativeWindow_ != nullptr) {
//                (void)OH_NativeWindow_NativeObjectUnreference(nativeWindow_);
//            }
            nativeWindow_ = nativeWindow;
//            if (nativeWindow_ != nullptr) {
//                (void)OH_NativeWindow_NativeObjectReference(nativeWindow_);
//            }

            if (eglSurface_ != EGL_NO_SURFACE) {
                renderContext_->DestroyEglSurface(eglSurface_);
                eglSurface_ = EGL_NO_SURFACE;
                CleanGLResources();
            }
        }
        if (nativeWindow_ != nullptr) {
            (void)OH_NativeWindow_NativeWindowHandleOpt(nativeWindow_, SET_BUFFER_GEOMETRY, static_cast<int>(width),
                                                        static_cast<int>(height));
            if (eglSurface_ == EGL_NO_SURFACE) {
                eglSurface_ = renderContext_->CreateEglSurface(reinterpret_cast<EGLNativeWindowType>(nativeWindow_));
            }
            if (eglSurface_ == EGL_NO_SURFACE) {
                OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "xfl CreateEglSurface failed.");
                return;
            }
            renderContext_->MakeCurrent(eglSurface_);
            CreateGLResources();
        }
    });
}

void RenderThread::CreateEncoderSurface(void *window, int32_t width, int32_t height) {
    if (encoderSurface_ != EGL_NO_SURFACE) {
        renderContext_->DestroyEglSurface(encoderSurface_);
        encoderSurface_ = EGL_NO_SURFACE;
    }

    encoderSurface_ = renderContext_->CreateEglSurface(static_cast<EGLNativeWindowType>(window));
    if (encoderSurface_ == EGL_NO_SURFACE) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "CreateEncoderSurface failed.");
    }

    encoderWidth_ = width;
    encoderHeight_ = height;
}

void RenderThread::DeleteEncoderSurface(void) {
    renderContext_->DestroyEglSurface(encoderSurface_);
    encoderSurface_ = EGL_NO_SURFACE;
}

void RenderThread::AddBW(void) {
    PostTask([this](EglRenderContext &renderContext) {
        shaderProgram_.reset();
        shaderProgram_ = std::make_unique<ShaderProgram>(Detail::vertexShader, Detail::fragmentShaderBW);
    });
}
void RenderThread::DeleteBW(void) {
    PostTask([this](EglRenderContext &renderContext) {
        shaderProgram_.reset();
        shaderProgram_ = std::make_unique<ShaderProgram>(Detail::vertexShader, Detail::fragmentShader);
    });
}
void RenderThread::Lut(void) {
    PostTask([this](EglRenderContext &renderContext) {
        shaderProgram_.reset();
        shaderProgram_ = std::make_unique<ShaderProgram>(Detail::vertexShader, Detail::fragmentShaderLut);
    });
}

void RenderThread::Photo(void) {
    PostTask([this](EglRenderContext &renderContext) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "任务---:%{public}d", 1);
    });
}


void RenderThread::Start() {
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "开始构造 RenderThread.");
    if (running_) {
        return;
    }

    running_ = true;
    thread_ = std::thread([this]() {
        ThreadMainLoop();
        // 确保renderContext的创建和销毁都在渲染线程中执行
        CleanGLResources();
        DestroyNativeImage();
        UpdateNativeWindow(nullptr, 0, 0);
        DestroyNativeVsync();
        DestroyRenderContext();
    });
}

void RenderThread::OnVsync(long long timestamp, void *data) {
//    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "OnVsync %{public}llu.", timestamp);
    auto renderThread = reinterpret_cast<RenderThread *>(data);
    if (!renderThread || !renderThread->running_) {
        return;
    }

    renderThread->vSyncCnt_++;
    renderThread->wakeUpCond_.notify_one();
}

bool RenderThread::InitNativeVsync() {
    nativeVsync_ = OH_NativeVSync_Create(DEMO_NAME, strlen(DEMO_NAME));
    if (nativeVsync_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "Create NativeVSync failed.");
        return false;
    }
    (void)OH_NativeVSync_RequestFrame(nativeVsync_, &RenderThread::OnVsync, this);
    return true;
}

void RenderThread::DestroyNativeVsync() {
    if (nativeVsync_ != nullptr) {
        OH_NativeVSync_Destroy(nativeVsync_);
        nativeVsync_ = nullptr;
    }
}

void RenderThread::OnNativeImageFrameAvailable(void *data) {
    auto renderThread = reinterpret_cast<RenderThread *>(data);
    if (!renderThread || !renderThread->running_) {
        return;
    }
    renderThread->availableFrameCnt_++;
    renderThread->wakeUpCond_.notify_one();
}

bool RenderThread::CreateNativeImage() {
    nativeImage_ = OH_NativeImage_Create(-1, GL_TEXTURE_EXTERNAL_OES);
    if (nativeImage_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "OH_NativeImage_Create failed.");
        return false;
    }
    int ret = 0;
    {
        std::lock_guard<std::mutex> lock(nativeImageSurfaceIdMutex_);
        nativeImageWindow_ = OH_NativeImage_AcquireNativeWindow(nativeImage_);
        ret = OH_NativeImage_GetSurfaceId(nativeImage_, &nativeImageSurfaceId_);
    }
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_GetSurfaceId failed, ret is %{public}d.", ret);
        return false;
    }

    nativeImageFrameAvailableListener_.context = this;
    nativeImageFrameAvailableListener_.onFrameAvailable = &RenderThread::OnNativeImageFrameAvailable;
    ret = OH_NativeImage_SetOnFrameAvailableListener(nativeImage_, nativeImageFrameAvailableListener_);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_SetOnFrameAvailableListener failed, ret is %{public}d.", ret);
        return false;
    }

    return true;
}

void RenderThread::DestroyNativeImage() {
    if (nativeImageTexId_ != 0U) {
        glDeleteTextures(1, &nativeImageTexId_);
        nativeImageTexId_ = 0U;
    }

    if (nativeImage_ != nullptr) {
        (void)OH_NativeImage_UnsetOnFrameAvailableListener(nativeImage_);
        OH_NativeImage_Destroy(&nativeImage_);
        nativeImage_ = nullptr;
    }

    if (nativeImageWindow_ != nullptr) {
        (void)OH_NativeWindow_NativeObjectUnreference(nativeImageWindow_);
        nativeImageWindow_ = nullptr;
    }
}

void RenderThread::ThreadMainLoop() {
    threadId_ = std::this_thread::get_id();
    if (!InitRenderContext()) {
        return;
    }
    if (!InitNativeVsync()) {
        return;
    }
    if (!CreateNativeImage()) {
        return;
    }
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "启动主循环");
    while (running_) {
        {
            std::unique_lock<std::mutex> lock(wakeUpMutex_);
            wakeUpCond_.wait(lock, [this]() {
                // 退出、被显式唤醒、收到了 vsync、或者有可用帧，任一条件成立即继续
                return !running_ || wakeUp_ || vSyncCnt_ > 0 || availableFrameCnt_ > 0;
            });

            // 若析构/Stop 触发了退出，立刻跳出循环
            if (!running_)
                break;

            wakeUp_ = false;
            // 只有在有计数时才递减，避免变负
            if (vSyncCnt_ > 0) {
                vSyncCnt_--;
            }
            // 仅在仍运行时申请下一帧，避免停止后“续命”
            if (running_) {
                (void)OH_NativeVSync_RequestFrame(nativeVsync_, &RenderThread::OnVsync, this);
            }
        }

        std::vector<RenderTask> tasks;
        {
            std::lock_guard<std::mutex> lock(taskMutex_);
            tasks.swap(tasks_);
        }
        for (const auto &task : tasks) {
            task(*renderContext_);
        }

        if (availableFrameCnt_ <= 0) {
            continue;
        }

        DrawImage();
        availableFrameCnt_--;
    }
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "退出主循环");
}

void RenderThread::PostTask(const RenderTask &task) {
    if (!running_) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread",
                     "PostTask failed: RenderThread is not running");
        return;
    }

    {
        std::lock_guard<std::mutex> lock(taskMutex_);
        tasks_.push_back(task);
    }

    if (std::this_thread::get_id() != threadId_) {
        std::lock_guard<std::mutex> lock(wakeUpMutex_);
        wakeUp_ = true;
        wakeUpCond_.notify_one();
    }
}

void ComputeTransformByMatrix(int32_t &transform, float transformMatrix[16]) {
    float transformMatrixR90[16] = {0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixR180[16] = {-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixR270[16] = {0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipH[16] = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipV[16] = {1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipHR90[16] = {0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipVR90[16] = {0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipHR180[16] = {1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipVR180[16] = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipHR270[16] = {1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipVR270[16] = {0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    switch (transform) {
    case 0:
        break;
    case 1:
        memcpy(transformMatrix, transformMatrixR90, sizeof(float) * 16);
        break;
    case 2:
        memcpy(transformMatrix, transformMatrixR180, sizeof(float) * 16);
        break;
    case 3:
        memcpy(transformMatrix, transformMatrixR270, sizeof(float) * 16);
        break;
    case 4:
        memcpy(transformMatrix, transformMatrixFlipH, sizeof(float) * 16);
        break;
    case 5:
        memcpy(transformMatrix, transformMatrixFlipV, sizeof(float) * 16);
        break;
    case 6:
        memcpy(transformMatrix, transformMatrixFlipHR90, sizeof(float) * 16);
        break;
    case 7:
        memcpy(transformMatrix, transformMatrixFlipVR90, sizeof(float) * 16);
        break;
    case 8:
        memcpy(transformMatrix, transformMatrixFlipHR180, sizeof(float) * 16);
        break;
    case 9:
        memcpy(transformMatrix, transformMatrixFlipVR180, sizeof(float) * 16);
        break;
    case 10:
        memcpy(transformMatrix, transformMatrixFlipHR270, sizeof(float) * 16);
        break;
    case 11:
        memcpy(transformMatrix, transformMatrixFlipVR270, sizeof(float) * 16);
        break;
    default:
        break;
    }
}

void RenderThread::DrawImage() {
    if (!running_)
        return;
    if (eglSurface_ == EGL_NO_SURFACE || nativeImage_ == nullptr || shaderProgram_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread", "Skip Draw: invalid state");
        return;
    }
    if (nativeImageTexId_ == 0U) {
        glGenTextures(1, &nativeImageTexId_);
        glBindTexture(GL_TEXTURE_EXTERNAL_OES, nativeImageTexId_);
        // set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_WRAP_T, GL_REPEAT);
        // set texture filtering parameters
        glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }

    if (eglSurface_ == EGL_NO_SURFACE) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread", "eglSurface_ is EGL_NO_SURFACE");
        return;
    }

    int32_t attachRet = OH_NativeImage_AttachContext(nativeImage_, nativeImageTexId_);
    if (attachRet != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_AttachContext failed, ret: %{public}d, texId: %{public}d", attachRet,
                     nativeImageTexId_);
        return;
    }

    int32_t ret = OH_NativeImage_UpdateSurfaceImage(nativeImage_);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_UpdateSurfaceImage failed, ret: %{public}d, texId: %{public}d", ret,
                     nativeImageTexId_);
        return;
    }
//    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "OH_NativeImage_UpdateSurfaceImage succeed.");

    int32_t transformTmp = 0;
    if (nativeImageWindow_ != nullptr) {
        int code = NativeWindowOperation::GET_TRANSFORM;
        OH_NativeWindow_NativeWindowHandleOpt(nativeImageWindow_, code, &transformTmp);
    }
    ret = OH_NativeImage_GetTransformMatrix(nativeImage_, matrix_);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_GetTransformMatrix failed, ret: %{public}d", ret);
        return;
    }

    if (isCameraRotated_) {
        transformTmp = 3;
        ComputeTransformByMatrix(transformTmp, matrix_);
    } else {
        transformTmp = 2;
        ComputeTransformByMatrix(transformTmp, matrix_);
    }

    DrawPreviewImage();
    if (encoderSurface_ != EGL_NO_SURFACE) {
        DrawEncoderImage();
    }
}

void RenderThread::DrawPreviewImage() {
    renderContext_->MakeCurrent(eglSurface_);

    int viewWidth = 0;
    int viewHeight = 0;
    OH_NativeWindow_NativeWindowHandleOpt(nativeWindow_, GET_BUFFER_GEOMETRY, &viewHeight, &viewWidth);

    glViewport(0, 0, viewWidth, viewHeight);

    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    shaderProgram_->Use();
    shaderProgram_->SetInt("texture", 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, nativeImageTexId_);
    if (renderContext_->islut) {
        glGenTextures(1, &lutTexId_);
        // 绑定纹理对象到2D纹理目标
        glBindTexture(GL_TEXTURE_2D, lutTexId_);
        // 为当前绑定的纹理对象设置环绕、过滤方式
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        // 加载并生成纹理
        int width, height;
        void *image;
        width = renderContext_->width;
        height = renderContext_->height;
        image = renderContext_->pixelData;
        char *data = reinterpret_cast<char *>(renderContext_->pixelData);
        // 目标类型，mimmap层级，图像内部格式，宽，高，边框，数据格式，数据类型，数据指针
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image);
        glGenerateMipmap(GL_TEXTURE_2D);
        // lut滤镜纹理
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, lutTexId_);
        shaderProgram_->SetInt("s_LutTexture", 1);
    }
    shaderProgram_->SetMatrix4v("matTransform", matrix_, 16, false);

    glBindVertexArray(vertexArrayObject_);
    glEnable(GL_DEPTH_TEST);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, Detail::indices);
    renderContext_->SwapBuffers(eglSurface_);

    if (renderContext_->isphoto) {
        ReadPixelsAfterRendering();
    }
}

void RenderThread::ReadPixelsAfterRendering() {
    // 相机宽高互换
    size_t width = 1080, height = 1920;
    std::vector<uint8_t> pixelData(width * height * 4);
    glFinish();
    glDisable(GL_FRAMEBUFFER_SRGB_EXT);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    // **左下角读取像素数据**
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixelData.data());

    {
        std::lock_guard<std::mutex> lock(renderContext_->mtx);
        renderContext_->photo_buf = std::move(pixelData); // 移动到持久缓冲
        renderContext_->photosize = width * height * 4;
        renderContext_->isphoto = false;
        renderContext_->isgetphoto = true;
    }
    renderContext_->cv.notify_one();
}

void RenderThread::DrawEncoderImage() {
    renderContext_->MakeCurrent(encoderSurface_);

    int64_t timestamp = OH_NativeImage_GetTimestamp(nativeImage_);
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "OH_NativeImage_GetTimestamp: %{public}ld",
                 timestamp);

    renderContext_->SetPresentationTime(encoderSurface_, static_cast<EGLnsecsANDROID>(timestamp));

    glViewport(0, 0, encoderWidth_, encoderHeight_);

    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    shaderProgram_->Use();
    shaderProgram_->SetInt("texture", 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, nativeImageTexId_);
    shaderProgram_->SetMatrix4v("matTransform", matrix_, 16, false);

    glBindVertexArray(vertexArrayObject_);
    glEnable(GL_DEPTH_TEST);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, Detail::indices);
    renderContext_->SwapBuffers(encoderSurface_);
}
} // namespace NativeXComponentSample
