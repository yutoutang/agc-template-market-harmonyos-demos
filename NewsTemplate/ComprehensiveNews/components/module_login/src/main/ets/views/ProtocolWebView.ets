import { webview } from '@kit.ArkWeb';
import { UtilLog } from '@hw-agconnect/util-log';
import { ProtocolRouterParams } from '../model/Index';
import { Constants } from '../common/Constant';

@Builder
export function ProtocolWebViewBuilder() {
  ProtocolWebView()
}

const TAG = '[LoginProtocolWebView]';

@ComponentV2
struct ProtocolWebView {
  @Local content: string = '';
  @Local isSheet: boolean = false;
  @Local sheetType: SheetType = SheetType.BOTTOM;
  @Local pagePadding: Padding = {};
  webViewController: webview.WebviewController = new webview.WebviewController();
  stack: NavPathStack = new NavPathStack();

  @Computed
  get headerPaddingTop() {
    if (!this.isSheet) {
      return undefined;
    }
    if (this.sheetType === SheetType.CENTER) {
      return Constants.PADDING_L;
    }
    if (this.sheetType === SheetType.BOTTOM) {
      return Constants.ZERO;
    }
    return 0;
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontColor([$r('sys.color.icon_primary')])
              .fontSize(Constants.BACK_WIDTH)
          }
          .width(Constants.BACK_BACKGROUND_WIDTH)
          .height(Constants.BACK_BACKGROUND_HEIGHT)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.stack.pop();
          })
        }
        .width(Constants.FULL_PERCENT)
        .margin({
          top: this.headerPaddingTop,
          bottom: Constants.SPACE_S,
        })

        Scroll() {
          this.coreInfo()
        }
        .constraintSize({ maxWidth: Constants.MAX_WIDTH })
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .padding({
        left: Constants.PADDING_L,
        right: Constants.PADDING_L,
      })
      .height(Constants.FULL_PERCENT)
      .width(Constants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.login_page_bg'))
    .padding({
      top: this.isSheet ? 0 : this.pagePadding.top,
      bottom: this.pagePadding.bottom,
    })
    .onReady((context) => {
      this.stack = context.pathStack;
      const params = context.pathInfo.param as ProtocolRouterParams;
      if (params) {
        this.content = params.content;
        this.isSheet = params.isSheet ?? false;
        this.sheetType = params.sheetType ?? SheetType.BOTTOM;
        this.pagePadding = params.pagePadding ?? {};
      }
    })
  }

  @Builder
  coreInfo() {
    Web({
      src: '',
      controller: this.webViewController,
    })
      .fileAccess(false)
      .geolocationAccess(false)
      .darkMode(WebDarkMode.Auto)
      .forceDarkAccess(true)
      .verticalScrollBarAccess(false)
      .backgroundColor($r('app.color.login_page_bg'))
      .layoutWeight(1)
      .onControllerAttached(() => {
        try {
          if (this.content.startsWith('http://') || this.content.startsWith('https://')) {
            this.webViewController.loadUrl(this.content)
          } else {
            this.webViewController.loadData(
              this.content,
              'text/html',
              'UTF-8',
              '',
              '',
            );
          }
        } catch (e) {
          UtilLog.error(TAG, 'webViewController load data fail, error: ' + JSON.stringify(e));
        }
      })
  }
}
