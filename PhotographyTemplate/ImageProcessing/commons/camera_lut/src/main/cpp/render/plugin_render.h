#ifndef KCOMPONENT_PLUGIN_RENDER_H
#define KCOMPONENT_PLUGIN_RENDER_H

#include <unordered_map>
#include <ace/xcomponent/native_interface_xcomponent.h>
#include "../camera/ndk_camera.h"
#include "render_thread.h"
#include "../common/common.h"

namespace NativeXComponentSample {
class PluginRender {
public:
    PluginRender(std::string &id);
    ~PluginRender()
    {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "RenderThread", 
                 "PluginRender 析构完成.");
    }
    static PluginRender *GetInstance(std::string &id);
    static void Release(std::string &id);
    static napi_value StartCamera(napi_env env, napi_callback_info info);
    static napi_value StopCamera(napi_env env, napi_callback_info info);
    static napi_value RestartCamera(napi_env env, napi_callback_info info);
    static napi_value StartRecorder(napi_env env, napi_callback_info info);
    static napi_value StopRecorder(napi_env env, napi_callback_info info);
    static napi_value StartPlayer(napi_env env, napi_callback_info info);
    static napi_value StopPlayer(napi_env env, napi_callback_info info);
    static napi_value AddBW(napi_env env, napi_callback_info info);
    static napi_value DeleteBW(napi_env env, napi_callback_info info);
    static napi_value Lut(napi_env env, napi_callback_info info);
    static napi_value Photo(napi_env env, napi_callback_info info);
    static napi_value TestGetXComponentStatus(napi_env env, napi_callback_info info);
    static napi_value NativeCallArkTS(napi_env env, napi_callback_info info);
    void Export(napi_env env, napi_value exports);
    void OnSurfaceChanged(OH_NativeXComponent *component, void *window);
    void OnTouchEvent(OH_NativeXComponent *component, void *window);
    void OnMouseEvent(OH_NativeXComponent *component, void *window);
    void OnHoverEvent(OH_NativeXComponent *component, bool isHover);
    void OnFocusEvent(OH_NativeXComponent *component, void *window);
    void OnBlurEvent(OH_NativeXComponent *component, void *window);
    void OnKeyEvent(OH_NativeXComponent *component, void *window);
    void RegisterCallback(OH_NativeXComponent *nativeXComponent);
    void UpdateNativeWindow(void *window, uint64_t width, uint64_t height);

public:
    static std::unordered_map<std::string, PluginRender *> instance_;
    std::string id_;
    static int32_t hasDraw_;
    static int32_t hasChangeColor_;

private:
    void UpdateNativeWindowSize(uint64_t width, uint64_t height);
    void CreateCamera();
    void StopCamera();
    void RestartCamera();
    void StartRecorder();
    void StopRecorder();
    void StartPlayer();
    void StopPlayer();
    void AddBW();
    void DeleteBW();
    void Lut();
    void Photo();
    static PluginRender *GetPluginRender(napi_env env, napi_callback_info info);

    OH_NativeXComponent_Callback renderCallback_;
    OH_NativeXComponent_MouseEvent_Callback mouseCallback_;

    std::unique_ptr<RenderThread> renderThread_;
    std::unique_ptr<OHOS_CAMERA_SAMPLE::NDKCamera> ndkCamera_;
};
}  // namespace NativeXComponentSample
#endif  // KCOMPONENT_PLUGIN_RENDER_H
