import { CommonConstants } from 'lib_common';

@ComponentV2
export struct GoodsTypeItem {
  @Param @Require typeName: string;
  @Param hasIcon: boolean = false
  @Param isSelected: boolean = false;
  @Event onClickAction: () => void = () => {
  }

  build() {
    Row() {
      if (this.hasIcon) {
        Image($r('app.media.hot'))
          .width(16)
      }
      Text(this.typeName)
        .fontSize($r('sys.float.Body_S'))
        .fontColor(this.isSelected ? $r('sys.color.multi_color_09') : $r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isSelected ? '#0FED6F21' : '#0D979797')
    .width(CommonConstants.FULL_PERCENT)
    .height(48)
    .padding({ left: 10, right: 10 })
    .onClick(this.onClickAction)
  }
}