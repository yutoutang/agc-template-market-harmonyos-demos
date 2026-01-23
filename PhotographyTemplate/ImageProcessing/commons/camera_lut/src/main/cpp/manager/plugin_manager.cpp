#include "plugin_manager.h"
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <cstdint>
#include <cstdio>
#include <hilog/log.h>
#include <string>
#include "../common/common.h"

namespace NativeXComponentSample {
PluginManager PluginManager::pluginManager_;

PluginManager::~PluginManager() {}

napi_value PluginManager::GetContext(napi_env env, napi_callback_info info) {
    if ((env == nullptr) || (info == nullptr)) {
        return nullptr;
    }

    size_t argCnt = 1;
    napi_value args[1] = {nullptr};
    if (napi_get_cb_info(env, info, &argCnt, args, nullptr, nullptr) != napi_ok) {
    }

    if (argCnt != 1) {
        napi_throw_type_error(env, NULL, "Wrong number of arguments");
        return nullptr;
    }

    napi_valuetype valuetype;
    if (napi_typeof(env, args[0], &valuetype) != napi_ok) {
        napi_throw_type_error(env, NULL, "napi_typeof failed");
        return nullptr;
    }

    if (valuetype != napi_number) {
        napi_throw_type_error(env, NULL, "Wrong type of arguments");
        return nullptr;
    }

    int64_t value;
    if (napi_get_value_int64(env, args[0], &value) != napi_ok) {
        napi_throw_type_error(env, NULL, "napi_get_value_int64 failed");
        return nullptr;
    }

    napi_value exports;
    if (napi_create_object(env, &exports) != napi_ok) {
        napi_throw_type_error(env, NULL, "napi_create_object failed");
        return nullptr;
    }

    return exports;
}

void PluginManager::Export(napi_env env, napi_value exports) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "PluginManager start export");
    if ((env == nullptr) || (exports == nullptr)) {
        return;
    }

    napi_value exportInstance = nullptr;
    if (napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance) != napi_ok) {
        return;
    }

    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent)) != napi_ok) {
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto context = PluginManager::GetInstance();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "PluginManager: id%{public}s", id.c_str());
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "nativeXComponent: id%{public}p", nativeXComponent);
    if ((context != nullptr) && (nativeXComponent != nullptr)) {
        auto render = context->GetRender(id);
        if (render != nullptr) {
            /**
             * 注册生周期、触摸、鼠标等回调函数
             */
            render->RegisterCallback(nativeXComponent);
            /**
             * 将Native侧接口注册为相应的ArkTs侧接口
             */
            render->Export(env, exports);
        }
    }
}

PluginRender *PluginManager::GetRender(std::string &id) {
    PluginRender *instance = PluginRender::GetInstance(id);
    return instance;
}
} // namespace NativeXComponentSample
