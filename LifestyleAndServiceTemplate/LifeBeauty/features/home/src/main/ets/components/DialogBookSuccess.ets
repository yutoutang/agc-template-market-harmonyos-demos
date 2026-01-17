import { CommonConstants, PopViewUtils, RouterMap, RouterModule } from 'foundation'

export class BookSuccessParam {
  title: string = '';
}

@Builder
export function DialogBookSuccessBuilder(param: BookSuccessParam) {
  Column() {
    Column({ space: 10 }) {
      Image($r('app.media.ic_public_success')).width(46).height(46)

      Text($r('app.string.dialog_book_success_title'))
        .fontSize(20)
        .fontColor('#212121')
        .fontWeight(FontWeight.Bold)
      Text($r('app.string.dialog_book_success_content'))
        .fontSize(16)
        .fontColor('#434343')
        .textAlign(TextAlign.Center)
      Text($r('app.string.btn_common_know'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .fontWeight(500)
        .fontColor($r('app.color.common_theme_color'))
        .margin({ top: 8 })
        .onClick(() => {
          PopViewUtils.closePopView();
          RouterModule.popToName(RouterMap.MAIN);
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: 23,
      right: 23,
      top: 20,
      bottom: 22,
    })
    .borderRadius(14)
    .backgroundColor($r('app.color.common_card_bg'))
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({ left: 10, right: 10 })
}