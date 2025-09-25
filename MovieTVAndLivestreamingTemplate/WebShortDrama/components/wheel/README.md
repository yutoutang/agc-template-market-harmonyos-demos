# 转盘组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了转盘功能

| 组件控制                                            |
|-------------------------------------------------|
| <img src="./screenshot/Wheel.jpeg" width="300"> |

## 约束与限制
### 软件

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release及以上

### 硬件

* 设备类型：华为手机（直板机）
* HarmonyOS版本：HarmonyOS 5.0.0 Release及以上

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加wheel模块。

   ```
    // 在项目根目录build-profile.json5填写wheel路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "wheel",
        "srcPath": "./XXX/wheel",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```
    // XXX为组件存放的目录名称
    "dependencies": {
      "wheel": "file:./XXX/wheel"
    }
   ```

2. 引入组件。

   ```
   import { Wheel } from 'wheel';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```
   import { Wheel } from 'wheel';
   
   @Entry
   @Component
   struct Index {
     pageInfo: NavPathStack = new NavPathStack()
   
     build() {
       Navigation(this.pageInfo) {
         Wheel({
                textCOIN: ["福利开奖888", "福利开奖124", "福利开奖248", "福利开奖68", "福利开奖268", "福利开奖8"],
                title: "福利大转盘",
                subTitle: "看广告领福利，惊喜多多"
              })
       }
        .hideTitleBar(true)
     }
   }
   ```

## API参考

### 子组件

无

### 接口

Wheel(options?: WheelOptions)

转盘信息组件。

**参数：**

| 参数名  | 类型                                          | 必填 | 说明    |
| ------- | --------------------------------------------- | ---- |-------|
| options | [WheelOptions](#WheelOptions对象说明) | 否   | 转盘组件。 |

### WheelOptions对象说明

| 名称       | 类型                     | 必填 | 说明                     |
| :--------- |:-----------------------| ---- |------------------------|
| textCOIN | string[]               | 否   | 转盘奖项                   |
| title | string                 | 否   | 活动名称                   |
| subTitle | string                 | 否   | 活动提示                   |
| onWheelSuccess | (balance:number)=>void | 否   | 定义回调函数，balance为转盘获得金币数 |

## 示例代码
```
import { Wheel } from 'wheel';
   
   @Entry
   @Component
   struct Index {
     pageInfo: NavPathStack = new NavPathStack()
   
     build() {
       Navigation(this.pageInfo) {
         Wheel({
                textCOIN: ["福利开奖888", "福利开奖124", "福利开奖248", "福利开奖68", "福利开奖268", "福利开奖8"],
                title: "福利大转盘",
                subTitle: "看广告领福利，惊喜多多",
                onWheelSuccess: (balance: number) => this.bonus += balance
              })
       }
        .hideTitleBar(true)
     }
   }
```
