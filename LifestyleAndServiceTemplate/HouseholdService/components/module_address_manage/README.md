# 地址管理组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供新增、编辑、删除地址相关功能。

| 地址列表                                         | 地址编辑                                         |
|----------------------------------------------|----------------------------------------------|
| <img src="screenshots/list.jpg" width="300"> | <img src="screenshots/edit.jpg" width="300"> |

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.0(12)及以上

### 前提

* 选择地点需要使用地图选点Button，
  参考[开发前提](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_address_manage、module_base、module_form模块。

   ```
   // 项目根目录下build-profile.json5填写module_address_manage、module_base、module_form路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_address_manage",
       "srcPath": "./XXX/module_address_manage"
     },
     {
       "name": "module_base",
       "srcPath": "./XXX/module_base"
     },
     {
       "name": "module_form",
       "srcPath": "./XXX/module_form"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5添加依赖。
   ```
   // XXX为组件存放的目录名称
   "dependencies": {
     "module_base": "file:./XXX/module_base",
     "module_address_manage": "file:./XXX/module_address_manage"
   }
   ```

2. 引入组件。

    ```
    import { RouterMap } from 'module_base';
    ```

3. 选择地点将使用地图服务，所以需[开通地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。

## API参考

### 接口

由于本组件内流程闭环，以页面的方式注册并对外提供，不涉及API介绍。

## 示例代码

```
import { RouterMap } from 'module_base'

@Entry
@ComponentV2
struct AddrSample {
  stack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.stack) {
      Column({ space: 10 }) {
        Text('地址管理').fontSize(20).fontWeight(FontWeight.Bold)
        Button('go').width('100%').onClick(() => {
          this.stack.pushPath({
            name: RouterMap.ADDRESS_MANAGE,
          })
        })
      }
      .padding(10)
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}
```
