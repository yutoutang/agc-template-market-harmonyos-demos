#include <js_native_api.h>
#include "manager/plugin_manager.h"

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    /**
     * 方法内检查环境变量是否包含XComponent组件实例，若实例存在注册绘制相关接口
     * 在exports这个ArkTS对象上，挂载native方法
     * 将接口函数NapiDrawPattern注册为ArkTS侧接口drawPattern()，在ArkTS侧调用drawPattern()方法，完成绘制。
     * 将接口函数TestGetXComponentStatus注册为ArkTS侧接口getStatus，在ArkTS侧调用getStatus方法，获取绘制状态。
     * */
    OH_LOG_Print(LOG_APP, LOG_INFO, 0xFF00, "Callback", "主入口 init");
    NativeXComponentSample::PluginManager::GetInstance()->Export(env, exports);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "nativerender",
    .nm_priv = ((void *)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}