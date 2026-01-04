# 计步数据展示组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#环境)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)
- [开源许可协议](#开源许可协议)

## 简介

本组件提供了展示运动数据的功能，包括三层圆环仪表盘展示卡路里、距离、步数的完成情况，以及最近7天的运动数据总览。

<img src="screenshots/moveRatio.jpeg" width="300">

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机(直板机)
- 系统版本：HarmonyOS 5.0.5(17)及以上

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_moveratio模块。

   ```
   // 项目根目录下build-profile.json5填写module_moveratio路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_moveratio",
       "srcPath": "./XXX/module_moveratio"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5添加依赖。

   ```
   // XXX为组件存放的目录名称
   "dependencies": {
     "module_moveratio": "file:./XXX/module_moveratio"
   }
   ```

2. 引入组件。

   ```
   import { TotalData } from 'module_moveratio'
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   TotalData()
   ```

## API参考

### 接口

TotalData(options?: [TotalDataOptions](#TotalDataOptions对象说明))

### TotalDataOptions对象说明

| 参数名            | 类型                                        | 是否必填 | 说明                |
|----------------|-------------------------------------------|------|-------------------|
| totalCountData | [TotalCountParam](#TotalCountParam对象说明)[] | 是    | 平均步数、平均距离、平均卡路里数据 |            |
| dataClick      | () => void                                | 否    | 点击数据总览区域时的回调函数    |
| isLogin        | boolean                                   | 是    | 用户是否已登录，用于控制数据显示  |

### TotalCountParam对象说明

| 参数名   | 类型     | 是否必填 | 说明     |
|-------|--------|------|--------|
| icon  | string | 是    | 图标资源名称 |
| title | string | 是    | 数据标题   |
| count | string | 是    | 数据数值   |
| uint  | string | 是    | 数据单位   |

### MoveDataModel对象说明

运动数据模型，通过`@Provider`在父组件中提供，子组件通过`@Consumer('homeMoveDataModel')`接收。

| 参数名          | 类型       | 是否必填 | 说明               |
|--------------|----------|------|------------------|
| caloriesData | number[] | 是    | 卡路里数据，[当前值, 目标值] |
| distanceData | number[] | 是    | 距离数据，[当前值, 目标值]  |
| stepData     | number[] | 是    | 步数数据，[当前值, 目标值]  |

### 事件

支持以下事件：

#### dataClick

dataClick: () => void;

点击数据总览区域时触发，用于跳转到详细页面。

## 示例代码

```ts
import { TotalData, MoveDataModel, TotalCountParam } from 'module_moveratio';

@Entry
@ComponentV2
struct Index {
  @Provider('homeMoveDataModel') moveDataModel: MoveDataModel = new MoveDataModel()
  @Local isLogin: boolean = true
  @Local totalCountData: TotalCountParam[] = []

  aboutToAppear() {
    // 初始化运动数据
    this.moveDataModel.caloriesData = [200, 1000]
    this.moveDataModel.distanceData = [500, 2000]
    this.moveDataModel.stepData = [3000, 10000]

    // 初始化最近7天数据
    this.totalCountData = [
      {
        icon: 'step_icon',
        title: '步数',
        count: '5000',
        uint: '步'
      },
      {
        icon: 'distance_icon',
        title: '距离',
        count: '3.5',
        uint: '公里'
      },
      {
        icon: 'calories_icon',
        title: '卡路里',
        count: '150',
        uint: '千卡'
      }
    ]
  }

  build() {
    NavDestination() {
      Column() {
        TotalData({
          totalCountData: this.totalCountData,
          isLogin: this.isLogin,
          dataClick: () => {
            // 点击数据总览区域，跳转到详细页面
            console.info('点击了数据总览区域')
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding(24)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
```

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。
