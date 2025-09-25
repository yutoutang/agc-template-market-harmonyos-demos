# 一键搜题组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了一键搜题页面的模板，本身集成语音输入，拍照识别，粘贴和清除功能，提供搜索和退出回调方法。

<img src="./screenshot/0011.jpg" width="300">

## 约束与限制
### 环境
* DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
* 设备类型：华为手机（直板机）
* 系统版本：HarmonyOS 5.0.1(13)及以上

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加search_question模块。

   ```
   // 在项目根目录build-profile.json5填写search_question路径。其中XXX为组件存放的目录名。
   "modules": [
   {
   "name": "search_question",
   "srcPath": "./XXX/search_question",
   }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖。
   ```
   // XXX为组件存放的目录名称
   "dependencies": {
      "search_question": "file:./XXX/search_question"
     }
   ```

2. 引入一键搜题组件句柄

   ```
   import { SearchQuestionPage } from 'search_question';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)
   ```
   import { SearchQuestionPage } from 'search_question';
   
   @Entry
   @Component
   struct Index {
     build() {
       Column() {
         SearchQuestionPage({
           //返回搜索框中的data值
           search: (data) => {
             console.log("点击搜索按钮")
           },
           back: () => {
             console.log("点击返回按钮回调事件")
           },
         })
       }
       .width('100%')
       .height('100%')
     }
   }
   ```

## API参考

SearchQuestionPage()

一键搜题组件组件。

### 事件

支持以下事件：

#### search

search: () => void = () => {}

点击搜索的事件

#### back

back: () => void = () => {}

点击返回的事件。

## 示例代码

   ```
   import { SearchQuestionPage } from 'search_question';
   
   @Entry
   @Component
   struct Index {
     build() {
       Column() {
         SearchQuestionPage({
           //返回搜索框中的data值
           search: (data) => {
             console.log("点击搜索按钮")
           },
           back: () => {
             console.log("点击返回按钮回调事件")
           },
         })
       }
       .width('100%')
       .height('100%')
     }
   }
   ```
