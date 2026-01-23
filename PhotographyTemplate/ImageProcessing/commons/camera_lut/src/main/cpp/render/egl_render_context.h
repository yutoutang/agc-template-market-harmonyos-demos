#ifndef NATIVEIMAGEDEMO_EGL_RENDER_CONTEXT_H
#define NATIVEIMAGEDEMO_EGL_RENDER_CONTEXT_H

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <GLES2/gl2ext.h>
#include <cstddef>
#include <mutex>

namespace NativeXComponentSample {
class EglRenderContext {
public:
    EglRenderContext();
    ~EglRenderContext() noexcept;

    // disallow copy and move
    EglRenderContext(const EglRenderContext &) = delete;
    EglRenderContext &operator=(const EglRenderContext &) = delete;
    void operator==(const EglRenderContext &) = delete;

    EglRenderContext(const EglRenderContext &&) = delete;
    EglRenderContext &operator=(EglRenderContext &&) = delete;
    void operator==(const EglRenderContext &&) = delete;

    bool Init();
    bool IsEglContextReady() const { return eglContext_ != EGL_NO_CONTEXT; }

    EGLDisplay GetEGLDisplay() const { return eglDisplay_; }
    EGLContext GetEGLContext() const { return eglContext_; }

    EGLSurface CreateEglSurface(EGLNativeWindowType surface, const EGLint *attribList = nullptr);
    void DestroyEglSurface(EGLSurface surface);

    void MakeCurrent(EGLSurface surface) const;
    void SwapBuffers(EGLSurface surface) const;

    // 局部刷新可选接口
    EGLint QueryBufferAge(EGLSurface surface) const;
    void SetDamageRegion(EGLSurface surface, EGLint *damages, EGLint size);
    void SwapBuffersWithDamage(EGLSurface surface, const EGLint *damages, EGLint size);

    bool SetPresentationTime(EGLSurface surface, EGLnsecsANDROID time);

    // 放进渲染内容里面
    void *pixelData;
    size_t bufferLength;
    int width;
    int height;
    bool islut;

    std::vector<uint8_t> photo_buf; // 持久存储
//    void *photo;
    bool isphoto;
    size_t photosize;
    std::mutex mtx;
    std::condition_variable cv;
    bool isgetphoto = false;

protected:
    EGLDisplay eglDisplay_ = EGL_NO_DISPLAY;
    EGLContext eglContext_ = EGL_NO_CONTEXT;
    EGLConfig config_ = nullptr;

    bool hasEglSurfacelessContext_ = false;
    bool hasEglBufferAge_ = false;
    bool hasEglPartialUpdate_ = false;
    PFNEGLSETDAMAGEREGIONKHRPROC eglSetDamageRegionFunc_ = nullptr;
    PFNEGLSWAPBUFFERSWITHDAMAGEKHRPROC eglSwapBuffersWithDamageFunc_ = nullptr;
    PFNEGLCREATEIMAGEKHRPROC eglCreateImageFunc_ = nullptr;
    PFNGLEGLIMAGETARGETTEXTURE2DOESPROC eglImageTargetTexture2DOESFunc_ = nullptr;

private:
    void SetupEglExtensions();
};
} // namespace NativeXComponentSample
#endif // NATIVEIMAGEDEMO_EGL_RENDER_CONTEXT_H
