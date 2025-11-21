# 修图神器组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [示例代码](#示例代码)

## 简介

本组件提供了滤镜相机、图片拼接、图片编辑的功能。

<img src="./screenshot/photo.png" width="300" >

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.0.5(17)及以上

### 权限

* 获取相机权限：ohos.permission.CAMERA。

## 使用
1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

   b. 在项目根目录build-profile.json5添加photo_editing模块。
   ```
   "modules": [
      {
      "name": "photo_editing",
      "srcPath": "./xxx/photo_editing",
      },
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```
   "dependencies": {
      "photo_editing": "file:./xxx/photo_editing",
   }
   ```

## 示例代码

```
@Entry
@ComponentV2
export struct Index {
   @Local pageStack: NavPathStack = new NavPathStack();

   build() {
      Navigation(this.pageStack) {
         Button('跳转').onClick(() => {
            // PhotoEditing为修图神器路由入口页面名称
            this.pageStack.pushPathByName('PhotoEditing', null);
         });
      }.hideTitleBar(true).mode(NavigationMode.Stack);
   }
}
```




