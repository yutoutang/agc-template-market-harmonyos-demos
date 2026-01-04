import { FeedbackConstants, ISettingItem } from '../common/FeedbackConstants';

@ComponentV2
export struct SettingList {
  @Param list: ISettingItem[] = [];
  @Param fontSizeRatio: number = 1;
  @Consumer() stack: NavPathStack = new NavPathStack();

  build() {
    List({ space: FeedbackConstants.SPACE_12 }) {
      ForEach(this.list, (v: ISettingItem) => {
        ListItem() {
          Row() {
            Row({ space: FeedbackConstants.SPACE_8 }) {
              Text(v.label)
                .fontSize(16 * this.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
              Image($r('app.media.ic_right'))
                .width($r('app.float.arrow_right_w'))
                .draggable(false)
            }
            .padding({
              left: FeedbackConstants.PADDING_S,
              right: FeedbackConstants.PADDING_S,
              top: FeedbackConstants.PADDING_M,
              bottom: FeedbackConstants.PADDING_M,
            })
            .borderRadius(FeedbackConstants.RADIUS_16)
            .stateStyles({
              normal: this.normalStyles,
              pressed: this.pressedStyles,
            })
          }
          .width(FeedbackConstants.FULL_PERCENT)
          .padding(FeedbackConstants.PADDING_XS)
          .borderRadius(FeedbackConstants.RADIUS_16)
          .backgroundColor($r('sys.color.comp_background_primary'))
        }
        .onClick(() => {
          if (v.routerName) {
            this.stack.pushPathByName(v.routerName, null);
          }
        })
      }, (v: ISettingItem) => v.label)
    }
    .width(FeedbackConstants.FULL_PERCENT)
    .height(FeedbackConstants.FULL_PERCENT)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }
}
