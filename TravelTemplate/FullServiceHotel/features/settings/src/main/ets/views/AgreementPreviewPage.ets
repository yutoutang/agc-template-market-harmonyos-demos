import webview from '@ohos.web.webview';
import { AgreementType, RouterMap, RouterModule } from 'commonlib';
import { ProtocolMap } from '../commons/Constants';

@Builder
export function AgreementPreviewPageBuilder() {
  AgreementPreviewPage()
}

@ComponentV2
export struct AgreementPreviewPage {
  @Local
  title: string = ''
  @Local
  content: string = ''
  controller: webview.WebviewController = new webview.WebviewController();

  @Monitor('content')
  loadContent() {
    if (!this.content) {
      return;
    }
    const timer = setTimeout(() => {
      this.controller.loadData(
        this.content,
        'text/html',
        'UTF-8',
        '',
        '',
      );
      clearTimeout(timer)
    }, 100)
  }

  build() {
    NavDestination() {
      Web({ src: '', controller: this.controller })
        .fileAccess(false)
        .geolocationAccess(false)
        .forceDarkAccess(true)
        .verticalScrollBarAccess(false)
        .backgroundColor($r('app.color.background_color_grey'))
        .layoutWeight(1)
        .onControllerAttached(() => {
          setTimeout(() => {
            this.loadContent()
          }, 100)
        })
    }
    .title(this.title)
    .backgroundColor($r('app.color.background_color_grey'))
    .onReady(() => {
      const param: AgreementType | undefined = RouterModule.getNavParam({ url: RouterMap.MINE_AGREEMENT_PREVIEW })
      if (param) {
        this.title = param;
        this.content = ProtocolMap.get(param) ?? '';
      }
    })
    .height($r('app.string.height_percent_full'))
  }
}