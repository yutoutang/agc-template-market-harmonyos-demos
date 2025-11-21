import { Style } from '../../commons/Style';

@ComponentV2
export struct BaseTitle {
  // 是否展示返回按钮
  @Param public showBackBtn: boolean = false;
  // 背景色
  @Param public barColor: ResourceColor = $r('app.color.background_color_grey')
  // 是否使用沉浸式扩展
  @Param public barExpandSafeArea: boolean = true;
  // 返回按钮点击事件
  @Event onBack: () => void = () => {
  };
  // 自定义内容
  @BuilderParam titleContentBuilder: CustomBuilder;

  build() {
    Row() {
      Row() {
        if (this.showBackBtn) {
          Column() {
            Image($r('app.media.ic_left_arrow'))
              .height(Style.TITLE_BAR_BACK_ICON_HEIGHT)
              .objectFit(ImageFit.Contain)
              .fillColor($r('sys.color.mask_secondary'))
          }
          .width(Style.TITLE_BAR_BACK_BTN_WIDTH)
          .height(Style.TITLE_BAR_HEIGHT)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (this.onBack) {
              this.onBack();
            }
          })
        }
        Column() {
          if (this.titleContentBuilder) {
            this.titleContentBuilder();
          }
        }
        .layoutWeight(1)
        .height(Style.TITLE_BAR_HEIGHT)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(this.barColor)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], this.barExpandSafeArea ? [SafeAreaEdge.TOP] : [])
    }
    .width('100%')
    .height(Style.TITLE_BAR_HEIGHT)
  }
}