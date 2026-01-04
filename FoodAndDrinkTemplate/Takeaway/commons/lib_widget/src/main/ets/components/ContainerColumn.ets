import { CommonConstants } from 'lib_common';

@ComponentV2
export struct ContainerColumn {
  @Param title: string = '';
  @Param subTitle: string = '';
  @Param isShowRightIc: boolean = false;
  @BuilderParam customBuilderParam: () => void = this.buildEmpty;

  build() {
    Column() {
      if (this.title) {
        Row() {
          Text(this.title).titleStyle();
          Image($r('app.media.ic_right'))
            .width($r('app.float.arrow_right_w'))
            .draggable(false)
            .visibility(this.isShowRightIc ? Visibility.Visible : Visibility.Hidden)

          //占位
          Blank()
          Text(this.subTitle).subTitleStyle();
        }
        .justifyContent(FlexAlign.Start)
        .width(CommonConstants.FULL_PERCENT)

        Divider()
          .margin({ top: $r('app.float.space_m'), bottom: $r('app.float.space_m') })
          .color($r('sys.color.comp_divider'))
      }

      this.customBuilderParam();
    }
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: $r('app.float.space_l') })
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius($r('app.float.border_radius_l'))
    .width($r('app.string.size_percent_full'))
    .padding($r('app.float.space_m'))
    .height('auto')
  }

  @Builder
  buildEmpty() {
    // do nothing.
  }
}

@Extend(Text)
function titleStyle() {
  .fontSize($r('app.float.font_size_16'))
  .fontWeight(FontWeight.Medium)
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(Text)
function subTitleStyle() {
  .fontSize($r('app.float.font_size_12'))
  .fontColor($r('app.color.font_color_level2'));
}