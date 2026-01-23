#ifndef NATIVEIMAGEDEMO_RENDER_THREAD_H
#define NATIVEIMAGEDEMO_RENDER_THREAD_H

#include <thread>
#include <vector>
#include <native_image/native_image.h>
#include <native_window/external_window.h>
#include <native_vsync/native_vsync.h>
#include "egl_render_context.h"
#include "shader_program.h"

namespace NativeXComponentSample {
using RenderTask = std::function<void(EglRenderContext &renderContext)>;

class RenderThread {
public:
    RenderThread();
    ~RenderThread() noexcept;

    void UpdateNativeWindow(void *window, uint64_t width, uint64_t height);
    void CreateEncoderSurface(void *window, int32_t width, int32_t height);
    void DeleteEncoderSurface(void);
    void AddBW(void);
    void DeleteBW(void);
    void Lut(void);
    void Photo(void);
    // disallow copy and move
    RenderThread(const RenderThread &other) = delete;
    void operator=(const RenderThread &other) = delete;
    RenderThread(RenderThread &&other) = delete;
    void operator=(RenderThread &&other) = delete;

    void PostTask(const RenderTask &task);
    void Stop();
    uint64_t GetNativeImageSurfaceId() const
    {
        std::lock_guard<std::mutex> lock(nativeImageSurfaceIdMutex_);
        return nativeImageSurfaceId_;
    }

    OHNativeWindow *GetNativeImageWindow() const
    {
        std::lock_guard<std::mutex> lock(nativeImageSurfaceIdMutex_);
        return nativeImageWindow_;
    }

    void SetCameraRotation(bool isEnabled)
    {
        isCameraRotated_ = isEnabled;
    }
    std::unique_ptr<EglRenderContext> renderContext_;
private:
    void Start();
    void ThreadMainLoop();

    std::atomic<bool> running_{ false };
    std::atomic<bool> stopping_{false};
    std::thread thread_;
    std::thread::id threadId_;
    
    std::atomic_bool isCapturing_ {false};
    std::mutex captureMutex_;
    std::condition_variable captureCv_;

    // 接收系统发送的Vsync信号，用于控制渲染节奏
    bool InitNativeVsync();
    void DestroyNativeVsync();
    OH_NativeVSync *nativeVsync_ = nullptr;
    static void OnVsync(long long timestamp, void *data);
    std::atomic<int> vSyncCnt_{ 0 };
    mutable std::mutex wakeUpMutex_;
    std::condition_variable wakeUpCond_;
    bool wakeUp_ = false;
    mutable std::mutex taskMutex_;
    std::vector<RenderTask> tasks_;

    // renderContext 初始化和清理
    bool InitRenderContext();
    void DestroyRenderContext();
    
    // 在渲染线程中执行资源的创建与清理
    bool CreateGLResources();
    void CleanGLResources();

    OHNativeWindow *nativeWindow_ = nullptr;
    EGLSurface eglSurface_ = EGL_NO_SURFACE;

    bool CreateNativeImage();
    void DestroyNativeImage();
    void DrawImage();
    void DrawPreviewImage();
    void DrawEncoderImage();
    void ReadPixelsAfterRendering();
    static void OnNativeImageFrameAvailable(void *data);
    OH_OnFrameAvailableListener nativeImageFrameAvailableListener_{};
    OH_NativeImage *nativeImage_ = nullptr;
    GLuint nativeImageTexId_ = 0U;
    GLuint lutTexId_ = 9998U;
    mutable std::mutex nativeImageSurfaceIdMutex_;
    uint64_t nativeImageSurfaceId_ = 0;
    OHNativeWindow *nativeImageWindow_ = nullptr;
    std::atomic<int> availableFrameCnt_{ 0 };
    std::unique_ptr<ShaderProgram> shaderProgram_;

    GLuint vertexArrayObject_ = 0;
    GLuint vertexBufferObject_ = 0;

    EGLSurface encoderSurface_ = EGL_NO_SURFACE;
    int32_t encoderWidth_ = 0;
    int32_t encoderHeight_ = 0;

    bool isCameraRotated_ = true;
    float matrix_[16];
};
}  // namespace NativeXComponentSample
#endif  // NATIVEIMAGEDEMO_RENDER_THREAD_H
