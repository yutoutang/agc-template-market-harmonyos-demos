import web_webview from '@ohos.web.webview';
import { AsWebRichText, Constants, NavHeaderBar, RouterMap, RouterModule, WindowModel } from 'common/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function AnswerPageBuilder() {
  AnswerPage()
}

@ComponentV2
struct AnswerPage {
  @Local answerDetail: string = ''
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  controller: web_webview.WebviewController = new web_webview.WebviewController();
  private scroller: Scroller = new Scroller()

  getAnswerDetail() {
    let params = RouterModule.getNavParam<string>(RouterMap.ANSWER_PAGE)
    if (params) {
      this.answerDetail =
        `<meta name="viewport" content="width=device-width, initial-scale=1.0">${params}`
    }
  }

  aboutToAppear(): void {
    this.getAnswerDetail()
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: '' })
      Scroll(this.scroller) {
        AsWebRichText({ url: Constants.RICH_TEXT_URI, richTextStr: this.answerDetail }).layoutWeight(1)
      }
      .edgeEffect(EdgeEffect.Spring)
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
      .align(Alignment.Top)
    }
    .hideTitleBar(true)
    .padding({ bottom: this.windowModel.getWindowBottomHeight() })
  }
}