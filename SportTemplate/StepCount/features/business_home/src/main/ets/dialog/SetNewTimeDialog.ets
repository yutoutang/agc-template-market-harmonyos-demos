import { RouterUtils } from 'lib_common';

@Builder
export function setNewTimeDialogBuilder() {
  SetNewTimeDialog()
}

@ComponentV2
export struct SetNewTimeDialog {
  build() {
    NavDestination() {
      Column() {
        Text('提醒时间设置提示')
          .lineHeight(56)
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .height(56)
          .fontWeight(FontWeight.Bolder)
          .align(Alignment.Top)
        Text('此时间已经设置了提醒，请重新设置')
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .margin({ top: 23 })
        Row() {
          Button('暂不')
            .backgroundColor('#fff')
            .width(140)
            .onClick(() => {
              RouterUtils.pop()
            })
            .fontColor($r('sys.color.font_emphasize'))
          Divider().vertical(true).color('#0d000000').height(25).strokeWidth(0.5)
          Button('确认')
            .backgroundColor('#fff')
            .width(140)
            .onClick(() => {
              RouterUtils.pop()
            })
            .fontColor($r('sys.color.warning'))
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 34 })
        .width('100%')
      }
      .padding({ left: 24, right: 24 })
      .borderRadius(32)
      .height(192)
      .width('100%')
      .backgroundColor('#fff')
      .position({
        y: '50%', // 上边缘在屏幕中线
        x: '50%', // 左边缘在屏幕中线
      })
      .translate({ x: '-50%', y: '-50%' }) // 再向左/上平移自身 50%，让几何中心对准屏幕中
    }
    .padding({ left: 16, right: 16 })
    .mode(NavDestinationMode.DIALOG)
    .backgroundColor('#33000000')
    .hideBackButton(true)
  }
}