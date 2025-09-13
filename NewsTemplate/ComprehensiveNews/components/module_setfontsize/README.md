# 字体大小调节组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件支持实时查看字体大小调整效果。

| 列表页                                            | 详情页                                              |
|------------------------------------------------|--------------------------------------------------|
| <img src="./screenshots/list.jpg" width="300"> | <img src="./screenshots/detail.jpg" width="300"> |

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）、平板
- 系统版本：HarmonyOS 5.0.1(13)及以上

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_setfontsize模块。

   ```
   // 项目根目录下build-profile.json5填写module_setfontsize路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_setfontsize",
       "srcPath": "./XXX/module_setfontsize"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5添加依赖。
   ```
   // XXX为组件存放的目录名称
   "dependencies": {
     "module_setfontsize": "file:./XXX/module_setfontsize"
   }
   ```

2. 引入组件。

    ```
    import { SettingFontCore } from 'module_setfontsize';
    ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。
   ```
   SettingFontCore({
     currentRatio: this.currentRatio,
     confirm: (ratio: number) => {
       this.currentRatio = ratio;
       this.getUIContext().getPromptAction().showToast({
         message: '字号设置已成功'
       });
     },
   })
   ```

## API参考

### 接口

SettingFontCore(option?: [SettingFontCoreOptions](#SettingFontCoreOptions对象说明))

字体大小调节组件。

**参数：**

| 参数名     | 类型                                                    | 是否必填 | 说明             |
|:--------|:------------------------------------------------------|:-----|:---------------|
| options | [SettingFontCoreOptions](#SettingFontCoreOptions对象说明) | 否    | 配置字体大小调节组件的参数。 |

### SettingFontCoreOptions对象说明

| 参数名          | 类型                      | 是否必填 | 说明      |
|:-------------|:------------------------|:-----|:--------|
| currentRatio | number                  | 否    | 字体比例初始值 |
| breakpoint   | string                  | 否    | 应用断点    |
| confirm      | (ratio: number) => void | 否    | 确认调整的回调 |

## 示例代码

```ts
import { SettingFontCore } from 'module_setfontsize'

@Entry
@ComponentV2
struct SettingFont {
  @Local currentRatio: number = 1;

  build() {
    NavDestination() {
      SettingFontCore({
        currentRatio: this.currentRatio,
        confirm: (ratio: number) => {
          this.currentRatio = ratio;
          this.getUIContext().getPromptAction().showToast({
            message: '字号设置已成功'
          });
        },
      })
        .layoutWeight(1)
    }
    .title('字体大小')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
```