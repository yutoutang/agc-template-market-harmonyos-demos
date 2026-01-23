#include "plugin_render.h"
#include <cstdint>
#include <hilog/log.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <sys/stat.h>
#include "../common/common.h"
#include "../manager/plugin_manager.h"
#include <fcntl.h>
#include "../common/sample_info.h"
#include "../sample/recorder/Recorder.h"
#include "../player/Player.h"
#include "sstream"
namespace NativeXComponentSample {
namespace {
void OnSurfaceCreatedCB(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "OnSurfaceCreatedCB");
    if ((component == nullptr) || (window == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceCreatedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceCreatedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    uint64_t width;
    uint64_t height;
    int32_t xSize = OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    if ((xSize != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) || (render == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceCreatedCB: Unable to get XComponent size");
        return;
    }
    if (render != nullptr) {
        render->UpdateNativeWindow(window, width, height);
    }
}

void OnSurfaceChangedCB(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "OnSurfaceChangedCB");
    if ((component == nullptr) || (window == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceChangedCB: component or window is null");
        return;
    }
    // 获取XComponent的id
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceChangedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        /**
         * 封装OnSurfaceChanged方法
         */
        render->OnSurfaceChanged(component, window);
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "surface changed");
    }
}

void OnSurfaceDestroyedCB(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "OnSurfaceDestroyedCB");
    if ((component == nullptr) || (window == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceDestroyedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceDestroyedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    PluginRender::Release(id);
}

void DispatchTouchEventCB(OH_NativeXComponent *component, void *window) {
    if ((component == nullptr) || (window == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "DispatchTouchEventCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "DispatchTouchEventCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    PluginRender *render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        render->OnTouchEvent(component, window);
    }
}

void DispatchMouseEventCB(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "DispatchMouseEventCB");
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        render->OnMouseEvent(component, window);
    }
}

void DispatchHoverEventCB(OH_NativeXComponent *component, bool isHover) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "DispatchHoverEventCB");
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        render->OnHoverEvent(component, isHover);
    }
}

void OnFocusEventCB(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "OnFocusEventCB");
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        render->OnFocusEvent(component, window);
    }
}

void OnBlurEventCB(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "OnBlurEventCB");
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        render->OnBlurEvent(component, window);
    }
}

void OnKeyEventCB(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "OnKeyEventCB");
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }
    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        render->OnKeyEvent(component, window);
    }
}
} // namespace

std::unordered_map<std::string, PluginRender *> PluginRender::instance_;
int32_t PluginRender::hasDraw_ = 0;
int32_t PluginRender::hasChangeColor_ = 0;

PluginRender::PluginRender(std::string &id) : renderThread_(std::make_unique<RenderThread>()) { this->id_ = id; }

PluginRender *PluginRender::GetInstance(std::string &id) {
    if (instance_.find(id) == instance_.end()) {
        PluginRender *instance = new PluginRender(id);
        instance_[id] = instance;
        return instance;
    } else {
        return instance_[id];
    }
}

/**
 * Native侧接口注册为相应的ArkTs侧接口
 * @param env
 * @param exports
 */
void PluginRender::Export(napi_env env, napi_value exports) {
    if ((env == nullptr) || (exports == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "Export: env or exports is null");
        return;
    }

    napi_property_descriptor desc[] = {
        {"StartCamera", nullptr, PluginRender::StartCamera, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"StopCamera", nullptr, PluginRender::StopCamera, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"RestartCamera", nullptr, PluginRender::RestartCamera, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"StartRecorder", nullptr, PluginRender::StartRecorder, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"StopRecorder", nullptr, PluginRender::StopRecorder, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"StartPlayer", nullptr, PluginRender::StartPlayer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"StopPlayer", nullptr, PluginRender::StopPlayer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"AddBW", nullptr, PluginRender::AddBW, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"DeleteBW", nullptr, PluginRender::DeleteBW, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"Lut", nullptr, PluginRender::Lut, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"Photo", nullptr, PluginRender::Photo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"NativeCallArkTS", nullptr, PluginRender::NativeCallArkTS, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "Export: napi_define_properties failed");
    }
}

/**
 * 释放相关环境资源方法
 * @param id
 */
void PluginRender::Release(std::string &id) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "开始PluginRender释放");

    PluginRender *render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        render->renderThread_->Stop();
        render->StopRecorder();
        render->StopPlayer();
        instance_.erase(instance_.find(id));
        delete render;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "完成PluginRender释放");
}

PluginRender *PluginRender::GetPluginRender(napi_env env, napi_callback_info info) {
    napi_value thisArg;
    if (napi_get_cb_info(env, info, nullptr, nullptr, &thisArg, nullptr) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "GetPluginRender: napi_get_cb_info fail");
        return nullptr;
    }
    // 获取环境变量中XComponent实例
    napi_value exportInstance;
    if (napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender",
                     "GetPluginRender: napi_get_named_property fail");
        return nullptr;
    }

    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent)) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "GetPluginRender: napi_unwrap fail");
        return nullptr;
    }
    // 获取XComponent实例的id
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender",
                     "GetPluginRender: Unable to get XComponent id");
        return nullptr;
    }

    std::string id(idStr);
    PluginRender *render = PluginRender::GetInstance(id);
    return render;
}

napi_value PluginRender::StartCamera(napi_env env, napi_callback_info info) {
    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        // 等待renderThread把nativeImage创建成功，这里用这种方式并不是很合适
        while (render->renderThread_->GetNativeImageSurfaceId() == 0)
            ;
        render->CreateCamera();
        render->renderThread_->SetCameraRotation(true);
    }
    return nullptr;
}

napi_value PluginRender::StopCamera(napi_env env, napi_callback_info info) {
    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        render->StopCamera();
        render->renderThread_->SetCameraRotation(false);
    }
    return nullptr;
}

napi_value PluginRender::RestartCamera(napi_env env, napi_callback_info info) {
    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        render->RestartCamera();
        render->renderThread_->SetCameraRotation(true);
    }
    return nullptr;
}

void PluginRender::CreateCamera() {
    std::string surfaceIdStr = std::to_string(renderThread_->GetNativeImageSurfaceId());
    // FOCUS_MODE_CONTINUOUS_AUTO 连续自动模式
    ndkCamera_ = std::make_unique<OHOS_CAMERA_SAMPLE::NDKCamera>(surfaceIdStr.c_str(), FOCUS_MODE_CONTINUOUS_AUTO, 0);
}

void PluginRender::StopCamera() {
    if (ndkCamera_)
        ndkCamera_->ReleaseCamera();
}
void PluginRender::RestartCamera() { CreateCamera(); }

napi_value PluginRender::StartRecorder(napi_env env, napi_callback_info info) {
    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        render->StartRecorder();
    }
    return nullptr;
}

napi_value PluginRender::StopRecorder(napi_env env, napi_callback_info info) {
    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        render->StopRecorder();
    }
    return nullptr;
}

napi_value PluginRender::StartPlayer(napi_env env, napi_callback_info info) {
    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        if (render->renderThread_->GetNativeImageWindow() != nullptr) {
            render->StartPlayer();
        }
    }
    return nullptr;
}

napi_value PluginRender::StopPlayer(napi_env env, napi_callback_info info) {
    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        render->StopPlayer();
    }
    return nullptr;
}

napi_value PluginRender::AddBW(napi_env env, napi_callback_info info) {
    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        render->renderThread_->renderContext_->islut = false;
        render->AddBW();
    }
    napi_value num;
    int32_t a = 1;
    napi_create_int32(env, a, &num);
    return num;
}
napi_value PluginRender::DeleteBW(napi_env env, napi_callback_info info) {
    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        render->renderThread_->renderContext_->islut = false;
        render->DeleteBW();
    }
    return nullptr;
}
napi_value PluginRender::Lut(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    // 解析参数：像素数据、宽度、高度
    void *pixelData;
    size_t bufferLength;
    napi_get_arraybuffer_info(env, args[0], &pixelData, &bufferLength);
    int32_t width, height;
    napi_get_value_int32(env, args[1], &width);
    napi_get_value_int32(env, args[2], &height);

    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr && !render->renderThread_->renderContext_->islut) {
        // 传递lut
        render->renderThread_->renderContext_->islut = true;
        render->renderThread_->renderContext_->width = width;
        render->renderThread_->renderContext_->height = height;
        render->renderThread_->renderContext_->pixelData = pixelData;
        render->renderThread_->renderContext_->bufferLength = bufferLength;
        // 切换lut
        render->Lut();
    }
    return nullptr;
}
napi_value PluginRender::Photo(napi_env env, napi_callback_info info) {
    // 检查数据
    std::thread::id threadId = std::this_thread::get_id();
    std::ostringstream oss;
    oss << threadId;
    std::string threadIdStr = oss.str();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Render", "Render::StartCamera---threadId:%{public}s",
                 threadIdStr.c_str());
    PluginRender *render = GetPluginRender(env, info);
    void *data;
    size_t size;
    napi_value arraybuffer;
    if (render != nullptr && render->ndkCamera_->valid_) {
        // 读取获取photo
        render->renderThread_->renderContext_->isphoto = true;
        render->Photo();
        std::unique_lock<std::mutex> lock(render->renderThread_->renderContext_->mtx);
        render->renderThread_->renderContext_->cv.wait(
            lock, [render] { return render->renderThread_->renderContext_->isgetphoto; });
        render->renderThread_->renderContext_->isgetphoto = false;
        size_t width = 1080, height = 1920;
        // void*转vector操作
        std::vector<uint8_t> pixelData(render->renderThread_->renderContext_->photo_buf);

        std::vector<uint8_t> flippedData(width * height * 4);
        // 上下倒转
        for (int y = 0; y < height; ++y) {
            int srcY = height - 1 - y; // 从最后一行开始
            memcpy(&flippedData[y * width * 4], &pixelData.data()[srcY * width * 4], width * 4);
        }
        size = render->renderThread_->renderContext_->photosize;
        napi_create_arraybuffer(env, size, &data, &arraybuffer);
        memcpy(data, flippedData.data(), size);
    }
    return arraybuffer;
}

napi_value PluginRender::NativeCallArkTS(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    // 解析参数：像素数据、宽度、高度
    void *pixelData;
    size_t bufferLength;
    napi_get_arraybuffer_info(env, args[0], &pixelData, &bufferLength);
    int32_t width, height;
    napi_get_value_int32(env, args[1], &width);
    napi_get_value_int32(env, args[2], &height);

    // 检查数据
    char *data = reinterpret_cast<char *>(pixelData);
//    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender",
//    "传入c侧---width:%{public}d---height:%{public}d---pixelData:%{public}p---data:%{public}p---data:%{public}s"
//    ,width,height,pixelData,data,data);

    PluginRender *render = GetPluginRender(env, info);
    if (render != nullptr) {
        // 传递lut
        render->renderThread_->renderContext_->width = width;
        render->renderThread_->renderContext_->height = height;
        render->renderThread_->renderContext_->pixelData = pixelData;
        render->renderThread_->renderContext_->bufferLength = bufferLength;
    }
    void *pixelData2;
    size_t bufferLength2;
    napi_value arraybuffer;
    if (render != nullptr) {
        // 生成arraybuffer
        bufferLength2 =
            render->renderThread_->renderContext_->width * render->renderThread_->renderContext_->height * 4;
        napi_create_arraybuffer(env, bufferLength2, &pixelData2, &arraybuffer);
        memcpy(pixelData2, render->renderThread_->renderContext_->pixelData, bufferLength2);
    }
    return arraybuffer;
}

void PluginRender::StartRecorder(void) {
    const std::string recorderRoot = "/data/storage/el2/base/haps/entry/files/";
    int32_t outputFd = open((recorderRoot + "recorder01.mp4").c_str(), O_RDWR | O_CREAT, 0777);

    SampleInfo sampleInfo;
    sampleInfo.outputFd = outputFd;
    sampleInfo.videoWidth = 1080;
    sampleInfo.videoHeight = 1920;
    sampleInfo.frameRate = 30;
    sampleInfo.isHDRVivid = 0;
    sampleInfo.bitrate = 3000000;
    sampleInfo.codecMime = MIME_VIDEO_HEVC;

    int32_t ret = Recorder::GetInstance().Init(sampleInfo);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        return;
    }

    OHNativeWindow *nativeWindow = sampleInfo.window;
    if (nativeWindow != nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "createNativeWinOK");
    } else {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "createNativeWinNOK");
    }
    renderThread_->CreateEncoderSurface(nativeWindow, sampleInfo.videoWidth, sampleInfo.videoHeight);

    Recorder::GetInstance().Start();
}

void PluginRender::StopRecorder(void) {
    renderThread_->DeleteEncoderSurface();
    Recorder::GetInstance().Stop();
}

void PluginRender::StartPlayer(void) {
    const std::string playerRoot = "/data/storage/el2/base/haps/entry/files/";
    int32_t inputFd = open((playerRoot + "recorder01.mp4").c_str(), O_RDONLY, 0777);

    int64_t fileSize = 0;
    struct stat fileStatus {};
    if (stat((playerRoot + "recorder01.mp4").c_str(), &fileStatus) == 0) {
        fileSize = static_cast<int64_t>(fileStatus.st_size);
    } else {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "StartPlayer: get stat failed");
        return;
    }

    SampleInfo sampleInfo;
    sampleInfo.inputFd = inputFd;
    sampleInfo.inputFileOffset = 0;
    sampleInfo.inputFileSize = fileSize;
    sampleInfo.window = renderThread_->GetNativeImageWindow();

    int32_t ret = Player::GetInstance().Init(sampleInfo);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        return;
    }

    Player::GetInstance().Start();
}

void PluginRender::StopPlayer(void) { Player::GetInstance().StartRelease(); }

void PluginRender::AddBW(void) { renderThread_->AddBW(); }

void PluginRender::DeleteBW(void) { renderThread_->DeleteBW(); }

void PluginRender::Lut(void) { renderThread_->Lut(); }

void PluginRender::Photo(void) { renderThread_->Photo(); }

void PluginRender::OnSurfaceChanged(OH_NativeXComponent *component, void *window) {
    double offsetX;
    double offsetY;
    // 获取XComponent持有的surface相对窗口左上角的偏移量
    OH_NativeXComponent_GetXComponentOffset(component, window, &offsetX, &offsetY);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "OH_NativeXComponent_GetXComponentOffset",
                 "offsetX = %{public}lf, offsetY = %{public}lf", offsetX, offsetY);
    uint64_t width;
    uint64_t height;
    // 获取XComponent持有的surface的大小。
    OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    UpdateNativeWindow(window, width, height);
}

void PluginRender::OnTouchEvent(OH_NativeXComponent *component, void *window) {
    OH_NativeXComponent_TouchEvent touchEvent;
    OH_NativeXComponent_GetTouchEvent(component, window, &touchEvent);
    float tiltX = 0.0f;
    float tiltY = 0.0f;
    OH_NativeXComponent_TouchPointToolType toolType =
        OH_NativeXComponent_TouchPointToolType::OH_NATIVEXCOMPONENT_TOOL_TYPE_UNKNOWN;
    OH_NativeXComponent_GetTouchPointToolType(component, 0, &toolType);
    OH_NativeXComponent_GetTouchPointTiltX(component, 0, &tiltX);
    OH_NativeXComponent_GetTouchPointTiltY(component, 0, &tiltY);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "OnTouchEvent",
                 "touch info: toolType = %{public}d, tiltX = %{public}lf, tiltY = %{public}lf", toolType, tiltX, tiltY);
}

void PluginRender::OnMouseEvent(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginRender", "OnMouseEvent");
    OH_NativeXComponent_MouseEvent mouseEvent;
    int32_t ret = OH_NativeXComponent_GetMouseEvent(component, window, &mouseEvent);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginRender",
                     "MouseEvent Info: x = %{public}f, y = %{public}f, action = %{public}d, button = %{public}d",
                     mouseEvent.x, mouseEvent.y, mouseEvent.action, mouseEvent.button);
    } else {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "GetMouseEvent error");
    }
}

void PluginRender::OnHoverEvent(OH_NativeXComponent *component, bool isHover) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginRender", "OnHoverEvent isHover_ = %{public}d", isHover);
}

void PluginRender::OnFocusEvent(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginRender", "OnFocusEvent");
}

void PluginRender::OnBlurEvent(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginRender", "OnBlurEvent");
}

void PluginRender::OnKeyEvent(OH_NativeXComponent *component, void *window) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginRender", "OnKeyEvent");

    OH_NativeXComponent_KeyEvent *keyEvent = nullptr;
    if (OH_NativeXComponent_GetKeyEvent(component, &keyEvent) >= 0) {
        OH_NativeXComponent_KeyAction action;
        OH_NativeXComponent_GetKeyEventAction(keyEvent, &action);
        OH_NativeXComponent_KeyCode code;
        OH_NativeXComponent_GetKeyEventCode(keyEvent, &code);
        OH_NativeXComponent_EventSourceType sourceType;
        OH_NativeXComponent_GetKeyEventSourceType(keyEvent, &sourceType);
        int64_t deviceId;
        OH_NativeXComponent_GetKeyEventDeviceId(keyEvent, &deviceId);
        int64_t timeStamp;
        OH_NativeXComponent_GetKeyEventTimestamp(keyEvent, &timeStamp);
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginRender",
                     "KeyEvent Info: action=%{public}d, code=%{public}d, sourceType=%{public}d, deviceId=%{public}ld, "
                     "timeStamp=%{public}ld",
                     action, code, sourceType, deviceId, timeStamp);
    } else {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "GetKeyEvent error");
    }
}

void PluginRender::UpdateNativeWindow(void *window, uint64_t width, uint64_t height) {
    renderThread_->UpdateNativeWindow(window, width, height);
}

/**
 * 注册XComponent实例生命周期、触摸事件等的回调
 * @param nativeXComponent
 */
void PluginRender::RegisterCallback(OH_NativeXComponent *nativeXComponent) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "RegisterCallback");
    // XComponenet的surface创建回调
    renderCallback_.OnSurfaceCreated = OnSurfaceCreatedCB;
    // XComponenet的surface改变回调
    renderCallback_.OnSurfaceChanged = OnSurfaceChangedCB;
    // XComponenet的surface销毁回调
    renderCallback_.OnSurfaceDestroyed = OnSurfaceDestroyedCB;
    // 调用触摸事件回调
    renderCallback_.DispatchTouchEvent = DispatchTouchEventCB;
    OH_NativeXComponent_RegisterCallback(nativeXComponent, &renderCallback_);
    // 调用鼠标事件回调
    mouseCallback_.DispatchMouseEvent = DispatchMouseEventCB;
    // 响应鼠标悬停事件回调
    mouseCallback_.DispatchHoverEvent = DispatchHoverEventCB;
    OH_NativeXComponent_RegisterMouseEventCallback(nativeXComponent, &mouseCallback_);
    // 响应获焦事件时触发该回调
    OH_NativeXComponent_RegisterFocusEventCallback(nativeXComponent, OnFocusEventCB);
    // 响应失去焦点事件时触发该回调
    OH_NativeXComponent_RegisterKeyEventCallback(nativeXComponent, OnKeyEventCB);
    // 响应按键事件时触发该回调
    OH_NativeXComponent_RegisterBlurEventCallback(nativeXComponent, OnBlurEventCB);
}

napi_value PluginRender::TestGetXComponentStatus(napi_env env, napi_callback_info info) {
    napi_value hasDraw;
    napi_value hasChangeColor;

    napi_status ret = napi_create_int32(env, hasDraw_, &(hasDraw));
    if (ret != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "TestGetXComponentStatus",
                     "napi_create_int32 hasDraw_ error");
        return nullptr;
    }
    ret = napi_create_int32(env, hasChangeColor_, &(hasChangeColor));
    if (ret != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "TestGetXComponentStatus",
                     "napi_create_int32 hasChangeColor_ error");
        return nullptr;
    }

    napi_value obj;
    ret = napi_create_object(env, &obj);
    if (ret != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "TestGetXComponentStatus", "napi_create_object error");
        return nullptr;
    }
    ret = napi_set_named_property(env, obj, "hasDraw", hasDraw);
    if (ret != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "TestGetXComponentStatus",
                     "napi_set_named_property hasDraw error");
        return nullptr;
    }
    ret = napi_set_named_property(env, obj, "hasChangeColor", hasChangeColor);
    if (ret != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "TestGetXComponentStatus",
                     "napi_set_named_property hasChangeColor error");
        return nullptr;
    }
    return obj;
}
} // namespace NativeXComponentSample
