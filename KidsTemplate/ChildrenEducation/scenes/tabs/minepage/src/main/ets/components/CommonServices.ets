import { CommonServiceModel, mineCommonService } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, rightArrow } from '@ohos_agcit/children_education_utils';
import { DialPanel } from 'dial_panel';

@ComponentV2
export struct CommonServices {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  private uiContext: UIContext = this.getUIContext();
  private mineCommonService: Array<CommonServiceModel> = mineCommonService;
  private dialPanel: DialPanel = new DialPanel(this.uiContext)
    .onMakeCall((e: BusinessError<void>): void => {
      if (e.code) {
        this.showToast(`拨号页面跳转失败 -> code: ${e.code}, msg: ${e.message}`);
      }
    })
    .onWillDismiss((reason: DismissReason): void => {
      this.dialPanel.close();
    });

  private showToast(msg: string): void {
    try {
      this.uiContext.getPromptAction().showToast({ message: msg });
    } catch (error) {
    }
  }

  build() {
    Row() {
      Column({ space: 20 }) {
        Text($r('app.string.common_service'))
          .padding({ top: 25 })
          .fontColor($r('sys.color.black'))
          .fontWeight(FontWeight.Bold)
          .fontSize(18);
        ForEach(this.mineCommonService, (item: CommonServiceModel, index: number) => {
          Row() {
            SymbolGlyph($r(item.symbol)).padding({ right: 16 });
            Text($r(item.serviceName)).fontSize(16).fontWeight(FontWeight.Medium).fontFamily('鸿蒙黑体');
            Blank();
            rightArrow()
          }
          .width(CommonConstants.FULL_PERCENT)
          .padding({ bottom: index !== mineCommonService.length - 1 ? 0 :25 })
          .onClick(() => {
            if (item.pageName === 'ContactUs') {
              this.dialPanel
                .setTitle('联系客服')
                .setPhoneNumber('12345678901')
                .setAutoClosePanel(true)
                .open();
              return
            }
            
            this.appPathStack.pushPathByName(item.pageName, undefined);
          });

          if (index !== mineCommonService.length - 1) {
            Divider().width('85%').alignSelf(ItemAlign.End);
          }
        }, (item:CommonServiceModel) => JSON.stringify(item));
      }
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.FULL_PERCENT)
      .padding({ right: '4%', left: '4%' });
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16);
  }
}


