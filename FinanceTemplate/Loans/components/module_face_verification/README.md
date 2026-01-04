# 人脸活体检测组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)



## 简介

本组件为人脸活体检测组件，可进行人脸识别，并返回此次识别主体是否为真人活体或者为非活体。



| 检测首页                                               | 检测成功                                          | 检测失败                                 |
|----------------------------------------------------|-----------------------------------------------|---------------------------------------------|
| <img src="snapshots/display_home.png" width="300"> | <img src="snapshots/success.jpeg" width="300"> | <img src="snapshots/failed.png" width="300"> |
                  |



## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.5(17)及以上

### 权限

- 相机权限: ohos.permission.CAMERA




## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_face_verification模块。

   ```ts
   // 项目根目录下build-profile.json5填写module_face_verification路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_face_verification",
       "srcPath": "./XXX/module_face_verification"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5中添加依赖。

   ```ts
   // 在项目根目录oh-package.json5中添加依赖
   "dependencies": {
     "module_face_verification": "file:./XXX/module_face_verification",
   }
   ```


2. 引入组件所需的数据类型
   ```ts
   import { VerifyFace } from 'module_face_verification'
   import { interactiveLiveness } from '@kit.VisionKit'
   ```

3. 调用组件，详见[示例代码](#示例代码)。详细参数配置说明参见[API参考](#API参考)。

     ```ts
   VerifyFace()
   ```



## API参考
### 接口
VerifyFace(options:[VerifyFaceOptions](#verifyfaceoptions对象说明))

人脸检测组件。


### VerifyFaceOptions对象说明

| 名称                    | 类型                                                     | 是否必填 | 说明                |
|-----------------------|--------------------------------------------------------| -------- |-------------------|
| userRealName          | string                                                 | 是       | 人脸验证前的姓名确认        |
| VerifyFaceCallBack | (options:[CallBcakOptions](#CallBcakOptions对象说明)=>void | 是       | 身份证正反面识别信息结果的回调函数 |


###  CallBcakOptions对象说明

| 名称                      | 类型                                                | 是否必填 | 说明                    |
|-------------------------|---------------------------------------------------|------|-----------------------|
| result                    | [interactiveLiveness.InteractiveLivenessResult](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/vision-interactive-liveness#section173751154134515) | /    | 返回人脸活体检测结果的相关参数                    |
| isFaceSuccess                     | boolean                                           | /    | 性别                    |

## 示例代码

```ts

import { VerifyFace } from 'module_face_verification'
import { interactiveLiveness } from '@kit.VisionKit'


@Entry
@ComponentV2
struct Index {

  @Local myResult: interactiveLiveness.InteractiveLivenessResult | undefined = undefined
  @Local isFaceVerifySuccess: boolean = false

  build() {
    Column() {
      VerifyFace({
      userRealName: '张大三',
        VerifyFaceCallBack: (result: interactiveLiveness.InteractiveLivenessResult, isFaceSuccess: boolean) =>{
          console.log('VerifyFaceCallBack----',JSON.stringify( result), isFaceSuccess)
          this.myResult = result
          this.isFaceVerifySuccess = isFaceSuccess
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

