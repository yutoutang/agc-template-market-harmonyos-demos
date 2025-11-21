# 停车场地图列表组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了停车场的地图显示和列表显示功能，可通过滑动地图或者设置地图中心来更新附近停车场。

<img src="./screenshots/park_map.jpeg" alt="地图" width="300" >

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.0.0 Release及以上

### 权限

* 位置权限：ohos.permission.LOCATION
* 模糊位置权限：ohos.permission.APPROXIMATELY_LOCATION

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_parking_base和module_parking_map模块。

   ```
   // 项目根目录下build-profile.json5填写module_parking_map路径。其中XXX为组件存放的目录名
   "modules": [
      {
      "name": "module_parking_base",
      "srcPath": "./XXX/module_parking_base"
      },
      {
      "name": "module_parking_map",
      "srcPath": "./XXX/module_parking_map"
      }
   ]
   ```

   c. 在项目根目录oh-package.json5中添加依赖。
   ```
   // XXX为组件存放的目录名
   "dependencies": {
      "module_parking_map": "file:./XXX/module_parking_map"
   }
   ```

2. 引入组件句柄。

   ```
   import { MapController, ParkingMapList } from 'module_parking_map';
   ```

3. 展示地图列表。详细入参配置说明参见[API参考](#API参考)。

   ```
   ParkingMapList({
      detents: ['20%', '50%', '80%'],
      cardClick: (spotItem) => {},
   })
   ```

4. 移动地图中心。详细入参配置说明参见[API参考](#API参考)。

   ```
   MapController.move({ latitude: 39.9, longitude: 116.4 });
   ```

## API参考

### 子组件

无

### 接口 

ParkingMapList(options?: ParkingMapListOptions)

停车场地图列表组件。

**参数：**

| 名称      | 类型                                                  | 是否必填 | 说明              |
|---------|-----------------------------------------------------|------|-----------------|
| options | [ParkingMapListOptions](#ParkingMapListOptions对象说明) | 否    | 配置停车场地图列表组件的参数。 |

### ParkingMapListOptions对象说明

| 名称        | 类型                                              | 是否必填 | 说明                                       |
|-----------|-------------------------------------------------|------|------------------------------------------|
| detents   | [string, string, string]                        | 否    | 列表高度档位，只支持百分比形式。默认为['8%', '50%', '80%']。 |
| cardClick | (item: [BasicParkInfo](#BasicParkInfo)) => void | 否    | 点击回调事件                                   |

### BasicParkInfo

停车场基本信息类型。

| 名称              | 类型                                                                                                                     | 是否必填 | 说明     |
|-----------------|------------------------------------------------------------------------------------------------------------------------|------|--------|
| siteId          | string                                                                                                                 | 是    | ID     |
| name            | string                                                                                                                 | 是    | 简称     |
| addr            | string                                                                                                                 | 是    | 全称     |
| location        | [mapCommon.LatLng](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-common#section20691173773810) | 是    | 经纬度    |
| distance        | number                                                                                                                 | 是    | 距离     |
| totalSpots      | number                                                                                                                 | 是    | 总车位数   |
| leftSpots       | number                                                                                                                 | 是    | 剩余车位数  |
| chargeSpots     | number                                                                                                                 | 是    | 总充电位数  |
| leftChargeSpots | number                                                                                                                 | 是    | 剩余充电位数 |

### move

MapController.move(center: mapCommon.LatLng)

同一进程内，移动地图中心至指定经纬度位置，地图和列表的停车场自动刷新。

| 名称     | 类型                                                                                                                     | 是否必填 | 说明       |
|--------|------------------------------------------------------------------------------------------------------------------------|------|----------|
| center | [mapCommon.LatLng](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-common#section20691173773810) | 是    | 移动后的地图中心 |


## 示例代码

本示例实现停车场的地图以及列表显示，并通过MapController.move方法指定位置切换。

```
import { MapController, ParkingMapList } from 'module_parking_map';

@Entry
@ComponentV2
struct Index {
  build() {
    Column() {
      ParkingMapList({
        detents: ['8%', '50%', '80%'],
        cardClick: (spotItem) => {
          AlertDialog.show({ alignment: DialogAlignment.Center, message: JSON.stringify(spotItem, null, 2) })
        },
      })
      .layoutWeight(1)

      Button('move').onClick(() => {
        MapController.move({ latitude: 39.9, longitude: 116.4 });
      })
    }
    .width('100%')
    .height('100%')
  }
}
```