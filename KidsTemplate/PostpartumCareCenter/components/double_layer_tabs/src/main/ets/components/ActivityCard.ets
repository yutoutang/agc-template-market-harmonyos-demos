import { ActivityCardModel } from '../model/ActivityCardModel';

@ComponentV2
export struct ActivityCard {
  @Param @Require activity: ActivityCardModel;
  @Param onClickAction: () => void = () => {
  };

  build() {
    Column() {
      Image(this.activity.picDescUrl)
        .width('100%')
        .borderRadius({
          topLeft: $r('app.string.border_radius_8'),
          topRight: $r('app.string.border_radius_8'),
        })
        .height('90vp')
        .objectFit(ImageFit.Cover);

      Text(this.activity.name)
        .fontColor('rgba(0,0,0,1.00)')
        .fontSize($r('app.string.font_size_14'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .width('100%')
        .padding({
          top: $r('app.string.margin_xs'),
          bottom: $r('app.string.margin_xs'),
          left: $r('app.string.margin_xs'),
          right: $r('app.string.margin_xs')
        });

      Text(this.activity.supportStoreName)
        .fontColor('rgba(0,0,0,60)')
        .fontSize($r('app.string.font_size_12'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Start)
        .width('100%')
        .padding({ bottom: $r('app.string.margin_xxs'), left: $r('app.string.margin_xs') });
    }
    .shadow({
      radius: 8, // 模糊半径
      color: 'rgba(0,0,0,0.08)', // 阴影颜色
    })
    .height(168)
    .width(158)
    .borderRadius($r('app.string.border_radius_8'))
    .backgroundColor('#FFFFFF')
    .margin({ bottom: $r('app.string.margin_s') })
    .onClick(() => {
      this.onClickAction()
    })
  }
}