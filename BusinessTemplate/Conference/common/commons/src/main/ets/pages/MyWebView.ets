import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

// 跳转页面入口函数
@Builder
export function MyWebViewBuilder() {
  MyWebView()
}

interface MyParams {
  url: string;
}

@Component
export struct MyWebView {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageProp('deviceId') deviceId: string = '';
  controller: webview.WebviewController = new webview.WebviewController();
  @State url: string = '';
  @State loading: boolean = true;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageLink('mainTabIndex') currentTabIndex: number = 0;
  @State pageTitle: string = ''; // 初始标题
  ports: webview.WebMessagePort[] = [];
  @State isInteraction: boolean = false;
  @State isVisible: boolean = true;

  async aboutToAppear() {
    let params: MyParams = this.pageStack.getParamByName('MyWebView')[0] as MyParams;
    this.url = params.url;
    this.isInteraction = this.url.includes('interaction2025');
  }

  // 获取网页标题
  private getWebTitle() {
    // 通过 JavaScript 获取url
    this.controller.runJavaScript('window.location.href').then(async (url) => {
      if (url.indexOf('hdc2025.html') > -1) {
        this.pageTitle = '会务模板2025'
      } else if (url.indexOf('beian.miit') > -1) {
        this.pageTitle = 'ICP备案查询';
      } else if (url.indexOf('4qdsju.epub360') > -1) {
        this.pageTitle = '探索东莞';
      } else {
        // 通过 JavaScript 获取标题
        let title = await this.controller.runJavaScript('document.title');
        try {
          // 如果是 JSON 字符串，则解析成原始字符串
          this.pageTitle = JSON.parse(title);
        } catch (e) {
          // 如果不是合法 JSON，直接使用原始值
          this.pageTitle = title;
        }
      }
    });
  }

  handelMessage(message: string): void {
    // 可选：验证消息内容
    switch (message) {
      case 'goto_home':
        this.currentTabIndex = 0;
        this.pageStack.popToName('PrepareIndex');
        break;
      case 'showLoading':
        this.loading = true;
        break;
      case 'hideLoading':
        this.loading = false;
        break;
      case 'back':
        try {
          if (this.controller?.accessBackward()) {
            this.controller.backward();
          } else {
            this.pageStack.pop();
          }
        } catch (e) {
          this.pageStack.pop();
        }
        break;
      default:
        break;
    }
  }

  private changeOrientation(isLandscape: boolean) {
    let context = getContext(this) as common.UIAbilityContext;
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT);
    });
  }

  build() {
    NavDestination() {
      Stack() {
        if (this.url) {
          Web({ src: this.url, controller: this.controller })
            .geolocationAccess(false)
            .domStorageAccess(true)
            .fileAccess(false)
            .onPageBegin(() => {
              const script = `window.topRectHeight = ${px2vp(this.topRectHeight)};`;
              this.controller.runJavaScript(script);
            })
            .onPageEnd((event) => {
              try {
                // 1、创建两个消息端口。
                this.ports = this.controller.createWebMessagePorts();
                // 2、在应用侧的消息端口(如端口1)上注册回调事件。
                this.ports[1].onMessageEvent((result: webview.WebMessage) => {
                  if (typeof (result) === 'string') {
                    this.handelMessage(result);
                  } else {
                    console.info('not support');
                  }
                });
                // 3、将另一个消息端口(如端口0)发送到HTML侧，由HTML侧保存并使用。
                setTimeout(() => {
                  this.controller.postMessage('__init_port__', [this.ports[0]], '*');
                }, 100);
              } catch (error) {
                console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
              }
              this.getWebTitle();
              if (event && !this.isInteraction) {
                this.loading = false;
              }
            })
            .onFullScreenEnter((event) => {
              // 当全屏的时候，isVisible标志位为false，组件状态为不可见，不参与布局、不进行占位
              this.isVisible = false;
              this.changeOrientation(true);
            })
            .onFullScreenExit(() => {
              // 当退出全屏的时候，isVisible标志位为true，组件状态为可见
              this.isVisible = true;
              this.changeOrientation(false);
            });
        }
        if (this.loading) {
          Column() {
            LoadingProgress().width(80);
          }.width('100%').height('100%').backgroundColor('#ffffff').justifyContent(FlexAlign.Center);
        }
      };
    }
    .onBackPressed(() => {
      try {
        if (!this.isVisible) {
          this.changeOrientation(false);
        }
        if (this.controller?.accessBackward()) {
          this.controller.backward();
          return true;
        } else {
          this.pageStack.pop();
          return true;
        }
      } catch (e) {
        this.pageStack.pop();
        return true;
      }
    })
    .hideTitleBar(this.isInteraction || !this.isVisible)
    .title(this.pageTitle)
    .padding({
      top: this.isInteraction ? 0 : px2vp(this.topRectHeight),
    });
  }
}
