import { PromptActionClass } from '@ohos_agcit/postpartum_care_center_utils';

@Builder
export function callDialog(callPhone:Function) {
  Column() {
    Row() {
      Text('025-0000 0000')
        .fontSize(16)
        .margin({
          top:24,
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    Row() {

      Text('取消')
        .width('50%')
        .height(64)
        .fontSize(16)
        .fontColor('rgba(0,0,0,0.60)')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          PromptActionClass.closeDialog();
        })

      Text('呼叫')
        .onClick(() => {
          callPhone();
          PromptActionClass.closeDialog();
        })
        .width('50%')
        .height(64)
        .fontColor('rgba(0,0,0,0.90)')
        .fontSize(16)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
  }
  .width(328)
  .height(116)
  .borderRadius(32)
  .backgroundColor(Color.White)
}