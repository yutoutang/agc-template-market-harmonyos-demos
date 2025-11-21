# 图片轮播预览组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了图片轮播的功能，点击图片可以打开大图预览页面，可捏合缩放图片，点击预览页面关闭大图预览。

<img src="./screenshots/swiper_show.jpeg" alt="轮播" width="300">


## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.0.0 Release及以上

### 权限

**访问网络图片时需开启**

* 网络权限：ohos.permission.INTERNET

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_swiper_preview模块。

   ```
   // 项目根目录下build-profile.json5填写module_swiper_preview路径。其中XXX为组件存放的目录名
   "modules": [
      {
      "name": "module_swiper_preview",
      "srcPath": "./XXX/module_swiper_preview"
      }
   ]
   ```

   c. 在项目根目录oh-package.json5中添加依赖。
   ```
   // XXX为组件存放的目录名
   "dependencies": {
      "module_swiper_preview": "file:./XXX/module_swiper_preview"
   }
   ```

2. 引入组件句柄。

   ```
   import { SwiperPicsPreview } from 'module_swiper_preview';
   ```

3. 图片轮播展示。详细入参配置说明参见[API参考](#API参考)。

   ```
   SwiperPicsPreview({
      pics: this.pics,
      iHeight: 120,
      pad: 16,
      out: 50,
    })
   ```

## API参考

### 子组件

无

### 接口

SwiperPicsPreview(options?: SwiperPicsPreviewOptions)

图片轮播预览组件。

**参数：**

| 名称      | 类型                                                        | 必填 | 说明             |
|---------|-----------------------------------------------------------|----|----------------|
| options | [SwiperPicsPreviewOptions](#SwiperPicsPreviewOptions对象说明) | 否  | 配置图片轮播预览组件的参数。 |

### SwiperPicsPreviewOptions对象说明

| 名称      | 类型                  | 是否必填 | 说明                         |
|---------|---------------------|------|----------------------------|
| pics    | ResourceStr[]       | 是    | 轮播图片数组                     |
| index   | number              | 否    | 初始图片索引                     |
| iHeight | number              | 否    | 轮播高度                       |
| radius  | Length              | 否    | 轮播图片圆角                     |
| space   | string \| number    | 否    | 轮播图片间隙                     |
| out     | Length              | 否    | 露出前后项宽度                    |
| pad     | number \| undefined | 否    | undefined时轮播居中，设置时代表首尾项的边距 |

## 示例代码

本示例实现图片的轮播展示，点击对应图片可进行大图预览。

```
import { SwiperPicsPreview } from 'module_swiper_preview';

@Entry
@ComponentV2
struct Index {
  @Local pics: ResourceStr[] = [
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/cloud-urahf/ic_park0.jpg?token=a7fb227d-3a1b-44b6-9f8a-51a804a8fffa',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/cloud-urahf/ic_park1.jpg?token=0d21ef96-c1b5-4123-bf48-7a55c3a479d0',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/cloud-urahf/ic_park2.jpg?token=6a616aa4-edbc-417b-8b3f-48053cdaf9ee',
  ]

  build() {
    Column() {
      SwiperPicsPreview({
        pics: this.pics,
        iHeight: 160,
        out: 50,
        pad: 16,
      })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}
```
