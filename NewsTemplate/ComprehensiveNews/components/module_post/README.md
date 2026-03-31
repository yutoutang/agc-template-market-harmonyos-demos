# 发帖组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件支持编辑互动发帖。

| 发表图片&文字                                              | 发表视频&文字                                              |
|------------------------------------------------------|------------------------------------------------------|
| <img src="./screenshots/text_image.jpg" width="300"> | <img src="./screenshots/text_video.jpg" width="300"> |

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 6.0.1 Release及以上
- HarmonyOS SDK版本：HarmonyOS 6.0.1 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）、平板
- 系统版本：HarmonyOS 5.1.1(19)及以上

### 权限

无

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_post、module_imagepreview模块。

   ```
   // 项目根目录下build-profile.json5填写module_post、module_imagepreview路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_post",
       "srcPath": "./XXX/module_post"
     },
     {
       "name": "module_imagepreview",
       "srcPath": "./XXX/module_imagepreview"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5添加依赖。
   ```
   // XXX为组件存放的目录名称
   "dependencies": {
     "module_post": "file:./XXX/module_post"
   }
   ```

2. 引入组件。

    ```
    import { PublishPostComp } from 'module_post';
    ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。
   ```
   PublishPostComp({
     fontRatio: 1,
     onChange: (body: string, mediaList: PostImgVideoItem[]) => {
       this.body = body;
       this.mediaList = mediaList;
     },
   })
   ```

## API参考

### 接口

PublishPostComp(option?: [PublishPostCompOptions](#PublishPostCompOptions对象说明))

发帖组件

**参数：**

| 参数名     | 类型                                                    | 是否必填 | 说明         |
|:--------|:------------------------------------------------------|:-----|:-----------|
| options | [PublishPostCompOptions](#PublishPostCompOptions对象说明) | 否    | 配置发帖组件的参数。 |

### PublishPostCompOptions对象说明

| 参数名         | 类型                                                                                                                                       | 是否必填 | 说明            |
|:------------|:-----------------------------------------------------------------------------------------------------------------------------------------|:-----|:--------------|
| fontRatio   | number                                                                                                                                   | 否    | 字体大小比例        |
| imageParams | [MediaParams](#MediaParams对象说明)                                                                                                          | 否    | 图片参数          |
| videoParams | [MediaParams](#MediaParams对象说明)                                                                                                          | 否    | 视频参数          |
| controller  | [TextAreaController](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-textarea#textareacontroller8) | 否    | TextArea控制器   |
| onChange    | (body: string, mediaList: [PostImgVideoItem](#PostImgVideoItem对象说明)[]) => void                                                           | 否    | 文字、图片、视频变化的回调 |
| isFocus     | (result: boolean) => void                                                                                                                | 否    | 键盘是否被拉起的回调    |

### MediaParams对象说明

| 参数名      | 类型                                                                                                                                                          | 是否必填 | 说明               |
|:---------|:------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----|:-----------------|
| type     | [photoAccessHelper.PhotoViewMIMETypes](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-photoaccesshelper-e#photoviewmimetypes) | 是    | 媒体文件类型           |
| maxLimit | number                                                                                                                                                      | 是    | 限制资源选择最大数量       |
| maxSize  | number                                                                                                                                                      | 否    | 限制资源选择最大大小，单位是MB |

### PostImgVideoItem对象说明

| 参数名         | 类型                                                                                                                                          | 说明           |
|:------------|:--------------------------------------------------------------------------------------------------------------------------------------------|:-------------|
| id          | number                                                                                                                                      | 唯一索引         |
| picVideoUrl | string                                                                                                                                      | 图片/视频媒体文件uri |
| surfaceUrl  | string                                                                                                                                      | 视频封面图沙箱uri   |
| movingPhoto | [photoAccessHelper.MovingPhoto](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-photoaccesshelper-movingphoto) | 动态图片对象       |

## 示例代码

```ts
import { PublishPostComp, PostImgVideoItem } from 'module_post';

@Entry
@ComponentV2
struct Sample1 {
  @Local body: string = '';
  @Local mediaList: PostImgVideoItem[] = [];

  build() {
    NavDestination() {
      this.titleBuilder()

      Column() {
        PublishPostComp({
          fontRatio: 1,
          onChange: (body: string, mediaList: PostImgVideoItem[]) => {
            this.body = body;
            this.mediaList = mediaList;
          },
        })
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .padding(16)
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('发帖页面')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
      Blank()
      Button('发布')
        .width(72)
        .height(40)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(this.enablePublish ? $r('sys.color.font_on_primary') : $r('sys.color.font_tertiary'))
        .backgroundColor(this.enablePublish ? '#5C79D9' :
        $r('sys.color.comp_background_secondary'))
        .enabled(this.enablePublish)
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({
            message: '点击了发布按钮',
          })
        })
    }
    .width('100%')
    .height(56)
  }

  @Computed
  get enablePublish() {
    if (this.body) {
      return true;
    }
    if (this.mediaList.length) {
      return true;
    }
    return false;
  }
}
```
