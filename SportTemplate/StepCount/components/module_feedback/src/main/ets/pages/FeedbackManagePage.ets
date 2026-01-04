import { AppStorageV2 } from '@kit.ArkUI';
import { FeedbackModel } from '../common/FeedbackModel';
import { NavHeaderBar } from '../components/NavHeaderBar';
import { FeedbackConstants, LIST_INFO } from '../common/FeedbackConstants';
import { SettingList } from '../components/SettingList';

@Builder
export function FeedbackManagePageBuilder() {
  FeedbackManagePage()
}

@ComponentV2
export struct FeedbackManagePage {
  @Provider() stack: NavPathStack = new NavPathStack();
  @Local feedbackModel: FeedbackModel = AppStorageV2.connect(FeedbackModel, () => new FeedbackModel())!;

  build() {
    NavDestination() {
      Column({ space: FeedbackConstants.SPACE_12 }) {
        NavHeaderBar({ title: '意见反馈' })
        Scroll() {
          Column() {
            SettingList({
              list: LIST_INFO,
              fontSizeRatio: this.feedbackModel.fontSizeRatio,
            })
          }
          .padding({
            left: FeedbackConstants.PADDING_PAGE,
            right: FeedbackConstants.PADDING_PAGE,
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context) => {
      this.stack = context.pathStack;
      if (context?.pathInfo?.param) {
        const params = context.pathInfo.param as FeedbackModel;
        this.feedbackModel.windowTopPadding = params.windowTopPadding;
        this.feedbackModel.windowBottomPadding = params.windowBottomPadding;
        this.feedbackModel.fontSizeRatio = params.fontSizeRatio;
      }
    })
  }
}