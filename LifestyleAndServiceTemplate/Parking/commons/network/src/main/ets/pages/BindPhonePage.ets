import { CommonConstants, CommonHeader, WindowUtil } from 'common';
import { AssociateUtil } from '../utils/AssociateUtil';
import { FunctionalButton, functionalButtonComponentManager } from '@hms.core.atomicserviceComponent.atomicserviceUi';

@ComponentV2
export struct BindPhonePage {
  buttonFontColor: ResourceStr = $r('sys.color.font_primary');
  buttonBgColor: ResourceStr = $r('sys.color.comp_background_tertiary');
  buttonMargin: ResourceStr = '16vp';

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '账号关联' });

        Scroll() {
          Column() {
            Image($r('app.media.ic_bind_account'))
              .width('40%')
              .aspectRatio(1)
            Text('绑定手机号后体验更多功能')
              .fontColor('#191919')
              .fontWeight(FontWeight.Medium)
              .fontSize(18);
            FunctionalButton({
              params: {
                openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
                label: '快速验证手机号',
                styleOption: {
                  plain: true,
                  styleConfig: new functionalButtonComponentManager
                    .ButtonConfig()
                    .fontColor(this.buttonFontColor)
                    .backgroundColor(this.buttonBgColor)
                    .width(CommonConstants.FULL_WIDTH)
                    .margin({ top: this.buttonMargin }),
                },
              },
              controller: new functionalButtonComponentManager.FunctionalButtonController()
                .onGetPhoneNumber((err, data) => {
                  AssociateUtil.associateAccount(err, data?.code);
                }),
            }).margin(this.buttonMargin)
            Blank().layoutWeight(1)
          }
          .margin({ top: '30%' })
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.Center)
        }.layoutWeight(1)
      }
    }
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
    .hideTitleBar(true);
  }
}

@Builder
export function bindPhonePageBuilder() {
  BindPhonePage();
}