import { AsWebRichText, Constants, HttpRequest, NavHeaderBar, WindowModel } from 'common/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function PrivacyPageBuilder() {
  PrivacyPage()
}

@ComponentV2
struct PrivacyPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local privacyInfo: string = ''

  aboutToAppear() {
    this.getPrivacyInfo()
  }

  getPrivacyInfo() {
    HttpRequest.getPrivacyInfo().then((res) => {
      this.privacyInfo = `<meta name="viewport" content="width=device-width, initial-scale=1.0">${res ?? ''}`;
    })
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.privacy') })
      Column() {
        AsWebRichText({ url: Constants.RICH_TEXT_URI, richTextStr: this.privacyInfo }).layoutWeight(1)
      }
      .width(Constants.FULL_SIZE)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .backgroundColor($r('sys.color.background_primary'))
      .margin({
        top: 12,
        left: Constants.BORDER_WIDTH,
        right: Constants.BORDER_WIDTH,
        bottom: this.windowModel.getWindowBottomHeight(),
      })
    }.hideTitleBar(true)
  }
}