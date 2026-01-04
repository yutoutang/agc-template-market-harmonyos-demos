# 搜索组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了搜索文本的模板，开发者可以根据业务需要快速搭建搜索页面。

<img src="./screenshot/0012.jpg" width="300">

## 约束与限制

### 环境
* DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
* 设备类型：华为手机（直板机）
* 系统版本：HarmonyOS 5.0.1(13)及以上

### 权限
无
## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加search模块。

    ```
   // 在项目根目录build-profile.json5填写search路径。其中XXX为组件存放的目录名。
   "modules": [
   {
   "name": "search",
   "srcPath": "./XXX/search",
   }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖。
   ```
   // XXX为组件存放的目录名称
   "dependencies": {
      "search": "file:./XXX/search"
     }
   ```

2. 引入搜索组件句柄

   ```
   import { SearchPage } from 'search';
   ```
3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ``` 
   import { SearchPage } from 'search';
   
   @Entry
   @Component
   struct Index {
     build() {
       Column() {
         // 搜索页面
         SearchPage({
           mockSearchValue: "会计",
           searchSourceData: ["2023初级会计-初级会计实务题库", "初级会计实务", "初级会计实务真题", "初级会计实务真题",
             "2024初级会计经济法冲刺"],
           initParam: () => {
             console.info("搜索页面初始化")
           },
           clickSearchItem: (data) => {
             this.getUIContext().getPromptAction().showToast({ message: '点击搜索事件', duration: 2000 });
             console.info("点击搜索按钮")
           },
           back: () => {
             this.getUIContext().getPromptAction().showToast({ message: '返回事件', duration: 2000 });
             console.info("点击返回按钮")
           },
         })
       }
       .width('100%')
       .height('100%')
     }
   }
   ```

## API参考

### 接口

SearchPage(options:SearchOptions)

搜索组件。

**参数：**

| 参数名          | 类型                     | 是否必填 | 说明       |
|:-------------|:-----------------------|:---|:---------|
| options       | [SearchOptions](#SearchOptions对象说明) | 是    | 搜索组件相关参数 |

### SearchOptions对象说明

| 参数名              | 类型       | 必填 | 说明         |
|:-----------------|:---------|:---|:-----------|
| mockSearchValue  | string   | 否  | 标识传入页面的搜索值 | | 否  | 传入页面的搜索值                                                                                                                          |
| searchSourceData | string[] | 否  | 搜索源数据      | | 否  | 搜索源数据                                                                                                                           |

### 事件

支持以下事件：

#### initParam

initParam: () => void = () => {}

初始化搜索页面的事件。

#### clickSearchItem

clickSearchItem: () => void = () => {}

搜索结果的一项的点击事件

#### back

back: () => void = () => {}

回退按钮回调函数。

## 示例代码

``` 
import { SearchPage } from 'search';

@Entry
@Component
struct Index {
  build() {
    Column() {
      // 搜索页面
      SearchPage({
        mockSearchValue: "会计",
        searchSourceData: ["2023初级会计-初级会计实务题库", "初级会计实务", "初级会计实务真题", "初级会计实务真题",
          "2024初级会计经济法冲刺"],
        initParam: () => {
        },
        clickSearchItem: (data) => {
          this.getUIContext().getPromptAction().showToast({ message: '点击搜索事件', duration: 2000 });
          console.info("点击搜索按钮")
        },
        back: () => {
          this.getUIContext().getPromptAction().showToast({ message: '返回事件', duration: 2000 });
          console.info("点击返回按钮")
        },
      })
    }
    .width('100%')
    .height('100%')
  }
}

```
