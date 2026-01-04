import { NavHeaderBar } from '../components/NavHeaderBar';
import { FeedbackConstants } from '../common/FeedbackConstants';
import { RecordListVM } from '../viewmodels/RecordListVM';
import { FeedbackResponseParams } from '../services/ResponseModel';
import { RecordCard } from '../components/RecordCard';
import { Empty } from '../components/Empty';

@Builder
export function RecordListPageBuilder() {
  RecordListPage()
}

@ComponentV2
export struct RecordListPage {
  @Provider() stack: NavPathStack = new NavPathStack();
  @Local vm: RecordListVM = new RecordListVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: '反馈记录' })
        Scroll() {
          if (this.vm.loading) {
            Column() {
              LoadingProgress()
                .width(72)
                .aspectRatio(1)
            }
            .height(FeedbackConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Center)
          } else if (this.vm.list.length) {
            Column({ space: FeedbackConstants.SPACE_12 }) {
              ForEach(this.vm.list, (v: FeedbackResponseParams) => {
                RecordCard({
                  record: v,
                  fontSizeRatio: this.vm.feedbackModel.fontSizeRatio,
                })
              }, (v: FeedbackResponseParams) => v.id)
            }
          } else {
            Column() {
              Empty({
                fontSizeRatio: this.vm.feedbackModel.fontSizeRatio,
              })
            }
            .height(FeedbackConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width(FeedbackConstants.FULL_PERCENT)
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .backgroundColor($r('sys.color.background_secondary'))
        .padding({
          left: FeedbackConstants.PADDING_PAGE,
          right: FeedbackConstants.PADDING_PAGE,
          top: FeedbackConstants.PADDING_M,
          bottom: this.vm.feedbackModel.windowBottomPadding,
        })
      }
    }
    .hideTitleBar(true)
    .onReady((context) => {
      this.stack = context.pathStack;
    })
  }
}