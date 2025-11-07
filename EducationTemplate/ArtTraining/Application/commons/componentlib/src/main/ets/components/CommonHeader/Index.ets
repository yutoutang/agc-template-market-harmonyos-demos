import { RouterModule } from 'commonlib';


@ComponentV2
export struct CommonHeader {
  @Param title: string = '';
  @Param bgColor: ResourceStr = $r('app.color.system_color_background_white');
  private _topBannerHeight: number = 56;

  @Computed
  get showBackButton() {
    return Boolean(RouterModule.size() > 0);
  }

  build() {
    Column() {
      Row() {
        if (this.showBackButton) {
          Row() {
            Image($r('app.media.ic_back'))
              .width(40)
              .height(40)
              .aspectRatio(1)
              .draggable(false)
              .margin({ right: $r('app.string.margin_s') })
              .borderRadius($r('app.string.border_radius_capsule'))
              .stateStyles({
                normal: { .backgroundColor(Color.Transparent)
                },
                pressed: { .backgroundColor($r('sys.color.interactive_pressed'))
                },
              })
          }
          .onClick(() => {
            RouterModule.pop();
          });
        }
        Text(this.title)
          .fontSize(this.showBackButton ? $r('app.string.font_size_20') : $r('app.string.font_size_24'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Bold);
      }
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .height(this._topBannerHeight)
      .padding({ left: $r('app.string.padding_l') })
    }
    .alignItems(HorizontalAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(this.bgColor)
  }
}