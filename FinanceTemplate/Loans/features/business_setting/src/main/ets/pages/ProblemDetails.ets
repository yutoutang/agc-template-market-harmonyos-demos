import { CommonConstants, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { QuestionInfo } from '../types/Types';
import { AppStorageV2 } from '@kit.ArkUI';


@Builder
export function ProblemDetailsBuilder() {
  ProblemDetails()
}

@ComponentV2
struct ProblemDetails {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  private questionList: QuestionInfo | null = null;

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '问题详情',
      })
      Column({ space: CommonConstants.SPACE_L }) {
        Text(this.questionList?.text)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .lineHeight(21)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: CommonConstants.SPACE_S })
        Text(this.questionList?.desc)
          .fontSize(16)
          .lineHeight(22)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: CommonConstants.PADDING_PAGE,
        right: CommonConstants.PADDING_PAGE,
        top: CommonConstants.SPACE_M,
        bottom: this.windowModel.windowBottomPadding
      })
    }
    .onReady((context: NavDestinationContext) => {

      if (context.pathInfo.param) {
        const params = context.pathInfo.param as Record<string, Object>;
        this.questionList = params.question as QuestionInfo;
      }
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
