import { webview } from '@kit.ArkWeb';
import { bindWith } from '../utils/Index'
import { Callback } from '@kit.BasicServicesKit';
import { RawEditorOptions } from '../options/tinymce'
import { EasyEditorBridge } from '../utils/Bridge';
import { EasyEditorController } from '../utils/Controller';

@Preview
@ComponentV2
export struct EasyEditor {
  @Local _privateController: webview.WebviewController = new webview.WebviewController();
  @Local _privateDisposer?: Callback<void>
  @Param darkMode:boolean = false
  @Param @Once config: string | RawEditorOptions = ''
  @Param @Once controller?: EasyEditorController = undefined
  @Param @Once content: string = ''
  @Param @Once javascriptProxies?: Array<JavaScriptProxy> = []
  @Param hideRichOperation:boolean = false
  @Event onContentChange?: Callback<string> = undefined

  @Monitor('content')
  contentChanged(_: IMonitor) {
    this.onContentChange && this.onContentChange(this.content)
  }

  @Monitor('hideRichOperation')
  hideRichOperationChange(_: IMonitor) {
    this.onHideOperation()
  }

  aboutToAppear(): void {
    /*
     * get set方法绑定到controller中
     * */
    this._privateDisposer = bindWith(this, this.controller, {
      'setContent': 'setContent',
      'getContent': 'getContent',
      'onHideOperation': 'onHideOperation',
      'setDarkMode':'setDarkMode'
    })
  }

  aboutToDisappear(): void {
    this._privateDisposer && this._privateDisposer()
  }

  build() {
    Web({ src: '', controller: this._privateController })
      .geolocationAccess(false)
      .domStorageAccess(true)
      .mixedMode(MixedMode.None)
      .fileAccess(false)
      .imageAccess(true)
      .javaScriptAccess(true)
      .backgroundColor($r('sys.color.background_primary'))
      .onlineImageAccess(true)
      .databaseAccess(true)
      .mixedMode(MixedMode.All)
      .onControllerAttached(() => {
        this._privateController.registerJavaScriptProxy(new EasyEditorBridge(this),
          'EasyEditorBridge',
          ['fetchConfig', 'onContentChanged', 'fetchContent','darkMode'], [],
          `{"javascriptProxyPermission":{"urlPermissionList":[{"scheme":"resource","host":"rawfile","port":"","path":""}]}}`)
        if (this.javascriptProxies?.length) {
          this.javascriptProxies.forEach(proxy => {
            this._privateController.registerJavaScriptProxy(proxy.object,
              proxy.name,
              proxy.methodList ?? [],
              proxy.asyncMethodList ?? [],
              proxy.permission ??
                `{"javascriptProxyPermission":{"urlPermissionList":[{"scheme":"resource","host":"rawfile","port":"","path":""}]}}`)
          })
        }
        this._privateController.loadUrl($rawfile('easy_tinymce/index.html'));
      })
      .width('100%')
      .layoutWeight(1)
  }

  /**
   * 设置内容
   * @param content 要设置的内容
   */
  setContent(content: string) {
    this.content = content
    this._privateController.runJavaScript(`window.injectContent()`)
  }

  /**
   * 获取内容
   * @returns 获取到的内容
   */
  getContent() {
    return this.content
  }

  /**
   * 设置操作栏显示
   * @returns 操作栏显示状态
   */
  onHideOperation() {
    this._privateController.runJavaScript(`window.toggleToolbar(${this.hideRichOperation})`)
  }
}





