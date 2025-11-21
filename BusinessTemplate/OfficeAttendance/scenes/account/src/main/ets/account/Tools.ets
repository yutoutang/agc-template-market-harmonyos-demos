import { RouterMap, RouterModule } from '@ohos_agcit/office_attendance_common_lib';

@Builder
export function toolsBuilder() {
  Tools();
}

@ComponentV2
struct Tools {
  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Text($r('app.string.protractor')).fontSize(16).fontWeight(FontWeight.Medium).margin({ left: 12 })
            Blank()
            Image($r('app.media.arrow_right')).margin({ right: 12 }).height(24).width(12)
          }.width('100%')
          .height(56)
          .backgroundColor(Color.White)
          .borderRadius(16)
        }
        .onClick(() => {
          RouterModule.push({ 'url': RouterMap.PROTRACTOR })
        })
        .padding({
          left:16,
          right:16
        })
        .width('100%')
        .margin({ top: 20 }).alignItems(HorizontalAlign.Center)

        Column() {
          Row() {
            Text($r('app.string.area_measure')).fontSize(16).fontWeight(FontWeight.Medium).margin({ left: 12 })
            Blank()
            Image($r('app.media.arrow_right')).margin({ right: 12 }).height(24).width(12)
          }.width('100%')
          .height(56)
          .backgroundColor(Color.White)
          .borderRadius(16)
        }
        .onClick(() => {
          RouterModule.replace({ 'url': RouterMap.AREA_CALCULATE })
        })
        .padding({
          left:16,
          right:16
        })
        .width('100%')
        .margin({ top: 12 }).alignItems(HorizontalAlign.Center)

        Column() {
          Row() {
            Text($r('app.string.ruler')).fontSize(16).fontWeight(FontWeight.Medium).margin({ left: 12 })
            Blank()
            Image($r('app.media.arrow_right')).margin({ right: 12 }).height(24).width(12)
          }.width('100%')
          .height(56)
          .backgroundColor(Color.White)
          .borderRadius(16)
        }
        .onClick(() => {
          RouterModule.replace({ 'url': RouterMap.RULER })
        })
        .padding({
          left:16,
          right:16
        })
        .width('100%')
        .margin({ top: 12 }).alignItems(HorizontalAlign.Center)
      }.width('100%').height('100%').backgroundColor($r('app.color.mine_background')).align(Alignment.Top)
    }.title({ builder: this.titleBuilder(), height: 56 })
    .padding({ top: 36, bottom: 28 }).backgroundColor($r('app.color.about_background'))
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.tools'))
        .fontWeight(FontWeight.Bold)
        .fontColor('rgba(0,0,0,0.90)')
        .fontSize(24)
        .margin({ left: 16, top: 36 })
        .height(56)
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Bottom)
  }
}