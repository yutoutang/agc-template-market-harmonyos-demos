# 定位打卡组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了定位打卡，查询打卡记录的功能。

<img src="./screenshot/clockIn.png" width="300">

## 约束与限制
### 环境
* DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.3(15)及以上

### 权限
* 获取位置权限：ohos.permission.APPROXIMATELY_LOCATION、ohos.permission.LOCATION
* 网络权限：ohos.permission.INTERNET
* 震动权限：ohos.permission.VIBRATE

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加clock_in模块。
   ```typescript
   // build-profile.json5
   "modules": [
      {
         "name": "clock_in",
         "srcPath": "./XXX/clock_in",
      }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖。
   ```typescript
       // 在项目根目录oh-package.json5填写clock_in路径。其中XXX为组件存放的目录名
      "dependencies": {
         "clock_in": "file:./XXX/clock_in"
      } 
   ```


2. 引入组件。

```typescript
import { ClockInView } from 'clock_in';
```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

```typescript
 ClockInView({
   latitude:31.978252425174848,
   longitude:118.76696853313138,
   distance: 50,
   onClockInSuccess:(address:AddressParam) => {
      console.log('打卡成功', JSON.stringify(address))
   },
   onFailed:() => {
      console.log('打卡失败')
   }
})
```

## API参考

### 子组件
无

### 接口
ClockInView([param](#param对象说明))

打卡组件

### param对象说明

| 参数名          | 类型     | 是否必填 | 说明        |
|--------------|--------|----|-----------|
| latitude | number | 是  | 打卡中心点纬度坐标 |
| longitude | number | 是 | 打卡中心点经度坐标 |
| distance | number | 是 | 打卡范围半径，单位米 |
| onClockInSuccess | Function | 是 | 打卡成功回调函数 |
## 示例代码
1、在 module.json5 中配置如下权限。
```typescript
 "requestPermissions": [
      {
         "name": "ohos.permission.INTERNET"
      },
      {
         "name": 'ohos.permission.LOCATION',
         "reason": '$string:permission_reason_location',
         "usedScene": {
            "abilities": [
            "EntryAbility"
            ],
            "when": "inuse"
         }
      },
      {
         "name": 'ohos.permission.APPROXIMATELY_LOCATION',
         "reason": '$string:permission_reason_location',
         "usedScene": {
            "abilities": [
            "EntryAbility"
            ],
            "when": "inuse"
         }
      },
      {
         "name": 'ohos.permission.VIBRATE',
         "reason": '$string:permission_reason_vibrate',
         "usedScene": {
            "abilities": [
            "EntryAbility"
            ],
            "when": "inuse"
         }
      }
 ]
```
2、在使用组件的页面添加如下代码。其中，经纬度以及打卡半径（米）请按实际数值填写，不在范围内会提示“打卡不在范围内”。

```typescript
import { ClockInView, AddressParam } from 'clock_in';

@Entry
@ComponentV2
export struct Index {
   @Provider() isPageShow: boolean = false; // 用于打开软件后自动打卡

   onPageShow(): void {
      this.isPageShow = true;
   }

   onPageHide(): void {
      this.isPageShow = false;
   }
   
   build() {
     Column(){
      ClockInView({
        latitude:31.978252425174848,
        longitude:118.76696853313138,
        distance: 50,
        onSuccess:(address:AddressParam) => {
          console.log('打卡成功', JSON.stringify(address))
        },
        onFailed:() => {
          console.log('打卡失败')
        }
      })
     }
     .width('100%')
     .height('100%')
   }
}
```
