# 身份证识别组件快速入门

## 目录

- [简介](#简介)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)



## 简介

本组件为身份证识别组件，可进行身份证卡片的识别，并返回身份证正反面文字信息与图片信息。


<img src="snapshots/display.png" width="300">



### 环境

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.5(17)及以上



## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_card_verification模块。

   ```ts
   // 项目根目录下build-profile.json5填写module_card_verification路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_card_verification",
       "srcPath": "./XXX/module_card_verification"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5中添加依赖。

   ```ts
   // 在项目根目录oh-package.json5中添加依赖
   "dependencies": {
     "module_card_verification": "file:./XXX/module_card_verification",
   }
   ```


2. 引入组件和识别的结果数据类型。

   ```ts
   import { IDCardInfo, VerifyCard } from 'module_card_verification'
   ```

3. 调用组件，详见[示例代码](#示例代码)。详细参数配置说明参见[API参考](#API参考)。

     ```ts
   VerifyCard()
   ```



## API参考
### 接口
VerifyCard(options?:[VerifyCallBackOptions](#verifycallbackoptions对象说明))

身份证识别组件。


### VerifyCallBackOptions对象说明

| 名称        | 类型                                                     | 是否必填 | 说明                     |
| ----------- |--------------------------------------------------------| -------- |------------------------|
|  verifyCallBack  | (info: [IDCardInfo](#IDCardInfo回调信息数据说明))=>void        | 是       | 身份证正反面识别信息结果的回调函数      |


###  IDCardInfo回调信息数据说明

| 名称                      | 类型                                                                                                        | 是否必填 | 说明                    |
|-------------------------|-----------------------------------------------------------------------------------------------------------|------|-----------------------|
| name                    | string                                                                                                       | /    | 姓名                    |
| sex                     | string                                                                                                       | /    | 性别                    |
| nationality             | string                                                                                                       | /    | 民族                    |
| birth                   | string                                                                                                       | /    | 出生日期                  |
| address                 | string                                                                                                       | /    | 住址                    |
| idNumber                | string                                                                                                       | /    | 公民身份号码                |
| cardImageUri            | string                                                                                                       | /    | 最后一次识别拍照原图不含背景        |
| originalImageUri        | string                                                                                                       | /    | 最后一次识别拍照原图含背景         |
| frontImageUri           | string                                                                                                       | /    | 身份证人像面照片              |
| backImageUri            | string                                                                                                       | /    | 身份证国徽面照片              |
| authority               | string                                                                                                       | /    | 签发机关                    |
| validPeriod             | string                                                                                                       | /    | 有效期限                    |
| completenessProbability | string                                                                                                       | /    | 完整的概率。取值范围：(0,1)。值越大，完整的概率越大                    |
| reflectionProbability   | string                                                                                                       | /    | 反光的概率。取值范围：(0,1)。值越大，反光的概率越大                 |
| clarityProbability                     | string                                                                                                       | /    | 清晰的概率。取值范围：(0,1)。值越大，清晰的概率越大                    |
| occlusionProbability                       | string                                                                                                       | /    | 遮挡的概率。取值范围：(0,1)。值越大，遮挡的概率越大                    |


## 示例代码

```ts
import { IDCardInfo, VerifyCard } from 'module_card_verification'

@Entry
@ComponentV2
struct Index {
  myCardInfo: IDCardInfo | undefined = undefined

  build() {
    Column() {
      VerifyCard({
        verifyCallBack: (info: IDCardInfo) =>{
          this.myCardInfo = info
          console.log('verifyCallBack----',JSON.stringify( info))
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

