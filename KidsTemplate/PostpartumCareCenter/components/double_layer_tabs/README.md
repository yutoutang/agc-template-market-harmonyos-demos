# 双层嵌套标签页组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件使用系统Tabs组件，提供了双层嵌套标签页的功能。

<img src="./screenshot/double_layer_tabs.jpg" width="300">

## 约束与限制
### 环境
* DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.3(15)及以上


## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加double_layer_tabs模块。
   ```typescript
   // build-profile.json5
   "modules": [
      {
           "name": "double_layer_tabs",
           "srcPath": "./XXX/double_layer_tabs",
      }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖。
   ```typescript
       // 在项目根目录oh-package.json5填写double_layer_tabs路径。其中XXX为组件存放的目录名
      "dependencies": {
         "double_layer_tabs": "file:./XXX/double_layer_tabs"
      } 
   ```


2. 引入组件。

```typescript
import { DoubleLayerTabs } from 'double_layer_tabs';
```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

```typescript
private vm: ActivityEntryVM = ActivityEntryVM.instance

@Local activityList: ActivityCardModel[] = []
@Local currentCityName: string = '全部'
@Local currentType: string = '全部'

build() {
   Column() {
      DoubleLayerTabs({
         cityList: CITY_LIST_ACTIVITY,
         typeList: ACTIVITY_TYPE_LIST,
         activityList: this.activityList,
         currentCity: this.currentCityName,
         currentType: this.currentType,
         onClickOuterTab: (cityName: string) => {
           console.log('current cityName is ' + cityName)
         },
         onClickInnerTab: (type: string) => {
            console.log('current type is ' + cityName)
         },
         onClickCard: (item: Object) => {
            console.log('current item is ' + JSON.stringify(item))
         }
      })
   }
}

```


## API参考

### 子组件
无

### 接口
DoubleLayerTabs([param](#param对象说明))

通过传递param对象，可以构建出二级嵌套列表UI组件

### param对象说明

**DoubleLayerTabs属性：**

| 属性名              | 类型                              | 是否必填 | 说明          |
|------------------|---------------------------------|------|-------------|
| cityList         | string                          | 是    | 一层Tabs列表    |
| typeList         | string                          | 是    | 二层Tabs列表    |
| activityList        | string                          | 是    | 卡片数据        |
| currentCity        | string                          | 是    | 当前选择的一层标签   |
| currentType        | number                          | 是    | 当前选择的二层标签   |
| onClickOuterTab      | Function                          | 否    | 点击一层标签的回调函数 |
| onClickInnerTab       | Function                          | 否    | 点击二层标签的回调函数 |
| onClickCard    | Function                          | 否    | 点击卡片的回调函数   |
## 示例代码
```typescript
import { ActivityCardModel, ActivityTypeItem, CityItem, DoubleLayerTabs } from 'double_layer_tabs';

@Entry
@ComponentV2
export struct Activities {
   activityList: ActivityCardModel[] = []
   cityList: CityItem[] = []
   typeList: ActivityTypeItem[] = []
   @Local currentCityName: string = '全部'
   @Local currentType: string = '全部'

   aboutToAppear() {
      this.activityList = [
         new ActivityCardModel(1, '妈妈最爱品牌展', new Date, new Date, '品牌沙龙', '南京', '南京涵江楼',
            '请您添加活动介绍', $r('app.media.activity_cover_image_1')),

         new ActivityCardModel(1, '儿科专家健康讲堂', new Date, new Date, '专家讲座', '上海', '上海卓美悦',
            '请您添加活动介绍', $r('app.media.activity_cover_image_2')),

         new ActivityCardModel(1, '儿童语言启蒙班', new Date, new Date, '宝贝时光', '广州', '广州华轩府',
            '请您添加活动介绍', $r('app.media.activity_cover_image_3')),

         new ActivityCardModel(1, '妈妈心灵成长营', new Date, new Date, '心灵驿站', '杭州', '杭州涵江楼',
            '请您添加活动介绍', $r('app.media.activity_cover_image_4')),

         new ActivityCardModel(1, '手工编织新手班', new Date, new Date, '巧手工坊', '苏州', '苏州涵江楼',
            '请您添加活动介绍', $r('app.media.activity_cover_image_5')),
      ];

      this.cityList = [
         { id: 0, name: '全部' },
         { id: 1, name: '南京' },
         { id: 2, name: '无锡' },
         { id: 3, name: '杭州' },
         { id: 4, name: '东莞' },
         { id: 5, name: '广州' },
         { id: 6, name: '汕头' },
         { id: 7, name: '北京' },
         { id: 8, name: '常州' },
         { id: 9, name: '苏州' },
         { id: 10, name: '深圳' },
         { id: 11, name: '上海' }
      ]

      this.typeList = [
         { id: 0, name: '全部' },
         { id: 1, name: '品牌沙龙' },
         { id: 2, name: '专家讲座' },
         { id: 3, name: '宝贝时光' },
         { id: 4, name: '心灵驿站' },
         { id: 5, name: '巧手工坊' },
         { id: 6, name: '其他活动' },
      ]
   }

   build() {
      Column() {
         DoubleLayerTabs({
            cityList: this.cityList,
            typeList: this.typeList,
            activityList: this.activityList,
            currentCity: this.currentCityName,
            currentType: this.currentType,
            onClickOuterTab: (cityName: string) => {
               this.currentCityName = cityName;
            },
            onClickInnerTab: (type: string) => {
               this.currentType = type;
            },
            onClickCard: (item: Object) => {
               console.log('current item is ' + JSON.stringify(item))
            }
         })
      }
      .backgroundColor('#F1F3F5')
         .clip(false)
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
   }
}

```
