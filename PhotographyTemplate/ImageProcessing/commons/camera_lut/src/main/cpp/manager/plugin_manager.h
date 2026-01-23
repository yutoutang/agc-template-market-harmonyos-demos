#ifndef KCOMPONENT_PLUGIN_MANAGER_H
#define KCOMPONENT_PLUGIN_MANAGER_H

#include <ace/xcomponent/native_interface_xcomponent.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <string>
#include <unordered_map>
#include "../render/plugin_render.h"

namespace NativeXComponentSample {
class PluginManager {
public:
    ~PluginManager();

    static PluginManager *GetInstance()
    {
        return &PluginManager::pluginManager_;
    }

    static napi_value GetContext(napi_env env, napi_callback_info info);

    PluginRender *GetRender(std::string &id);
    void Export(napi_env env, napi_value exports);

private:
    static PluginManager pluginManager_;
};
}  // namespace NativeXComponentSample

#endif  // KCOMPONENT_PLUGIN_MANAGER_H
