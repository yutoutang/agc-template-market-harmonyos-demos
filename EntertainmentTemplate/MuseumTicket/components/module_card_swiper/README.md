# 卡片轮播组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了卡片轮播切换、卡片大小样式与对应文字随之切换的能力。

<img src="./screenshot/card_swiper.png" width="300" >

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.0(12)及以上

## 快速入门

1. 安装组件。

   如果是在DevEvo Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_card_swiper模块。

    ```
    // 在项目根目录build-profile.json5填写module_card_swiper路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "module_card_swiper",
        "srcPath": "./XXX/module_card_swiper",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```
    // XXX为组件存放的目录名称
    "dependencies": {
      "module_card_swiper": "file:./XXX/module_card_swiper"
    }
    ```

2. 引入组件。

   ```
   import { CardSwiper, CardItem } from 'module_card_swiper';
   ```

## API参考

### 子组件

无

### 接口

CardSwiper(options?: CardSwiperOptions)

卡片轮播组件。

**参数：**

| 参数名  | 类型                                            | 是否必填 | 说明                     |
| ------- | ----------------------------------------------- | -------- | ------------------------ |
| options | [CardSwiperOptions](#CardSwiperOptions对象说明) | 否       | 配置卡片轮播组件的参数。 |

### CardSwiperOptions对象说明

| 名称         | 类型                            | 是否必填 | 说明                          |
| ------------ | ------------------------------- | -------- | ----------------------------- |
| cardList     | [CardItem](#CardItem对象说明)[] | 否       | 卡片图片、标题文字信息        |
| centerWidth  | number                          | 否       | 中心图片宽度，单位vp默认值94  |
| centerHeight | number                          | 否       | 中心图片高度，单位vp默认值127 |
| smallWidth   | number                          | 否       | 两侧图片宽度，单位vp默认值90  |
| smallHeight  | number                          | 否       | 两侧图片高度，单位vp默认值115 |

### CardItem对象说明

| 名称  | 类型                                                         | 是否必填 | 说明         |
| ----- | ------------------------------------------------------------ | -------- | ------------ |
| img   | [ResourceStr](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-types#resourcestr) | 是       | 轮播图片资源 |
| title | string                                                       | 是       | 卡片标题     |
| label | string                                                       | 是       | 对应文字描述 |

### 事件

支持以下事件：

#### onChange

onChange: (index: number) => void = () => {}

中心卡片改变时触发该事件。

## 示例代码


```
import { CardSwiper, CardItem } from 'module_card_swiper';


@Entry
@ComponentV2
struct Index {
   @Local cardList: CardItem[] = [{ img: $r('app.media.explain_banner1'), label: '描述1', title: '标题1' },
      { img: $r('app.media.explain_banner2'), label: '描述2', title: '标题2' },
      { img: $r('app.media.explain_banner3'), label: '描述3', title: '标题3' },
      { img: $r('app.media.explain_banner4'), label: '描述4', title: '标题4' }
   ];

   build() {
      Column() {
         CardSwiper({
            cardList: this.cardList,
            onChange: (index) => {
               console.log('中心图片改变了');
            },
         });
      }.padding(32)
   }
}

```