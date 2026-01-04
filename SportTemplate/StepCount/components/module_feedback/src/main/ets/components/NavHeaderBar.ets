import { AppStorageV2 } from '@kit.ArkUI';
import { FeedbackConstants } from '../common/FeedbackConstants';
import { FeedbackModel } from '../common/FeedbackModel';

@ComponentV2
export struct NavHeaderBar {
  @Param showBackBtn: boolean = true;
  @Param title: ResourceStr = '';
  @Param isSubTitle: boolean = true;
  @Param hasBgColor: boolean = false;
  @Consumer() stack: NavPathStack = new NavPathStack();
  @Local feedbackModel: FeedbackModel = AppStorageV2.connect(FeedbackModel, () => new FeedbackModel())!;

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(40)
          .aspectRatio(1)
          .draggable(false)
          .borderRadius(FeedbackConstants.HALF_PERCENT)
          .stateStyles({
            normal: { .backgroundColor(Color.Transparent)
            },
            pressed: { .backgroundColor($r('sys.color.interactive_pressed'))
            },
          })
          .margin({ right: FeedbackConstants.SPACE_8 })
          .onClick(() => {
            this.stack.pop();
          })
        if (this.title) {
          Text(this.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
        }
      }
      .height(56)
      .width(FeedbackConstants.FULL_PERCENT)
    }
    .padding({
      right: FeedbackConstants.PADDING_PAGE,
      left: FeedbackConstants.PADDING_PAGE,
      top: this.feedbackModel.windowTopPadding,
    })
    .width(FeedbackConstants.FULL_PERCENT)
    .backgroundColor(this.hasBgColor ? $r('sys.color.background_primary') : '#00000000')
  }
}