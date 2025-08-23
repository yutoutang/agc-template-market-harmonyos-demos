import { call } from '@kit.TelephonyKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'module_ui_base';

const TAG: string = '[CallDialog]'

@ComponentV2
export struct CallDialog {
  @BuilderParam
  customUI: () => void = this.defaultUIBuilder
  @Param
  phoneNumber: string = ''
  @Param
  themeColor: ResourceColor = $r('app.color.theme_color')
  @Local
  showSheet: boolean = false

  build() {
    Column() {
      this.customUI()
    }
    .bindSheet($$this.showSheet, this.callDialogBuilder(), {
      title: { title: '联系客服' },
      height: 280,
      dragBar: true,
      backgroundColor: $r('app.color.background_color_grey'),
    })
    .hitTestBehavior(HitTestMode.Block)
    .onClick(() => {
      this.showSheet = true;
    })
  }

  @Builder
  defaultUIBuilder() {
    Button('拨号')
  }

  @Builder
  callDialogBuilder() {
    Column() {
      Text(this.phoneNumber)
        .fontColor($r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_20'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.string.space_m') });

      Button() {
        Row() {
          Image($r('app.media.ic_tel'))
            .width(16)
            .margin({ right: $r('app.string.space_m') });
          Text('一键拨号')
            .fontColor($r('app.color.font_color_level1_invert'))
            .fontWeight(FontWeight.Medium);
        };
      }
      .width($r('app.string.size_percent_100'))
      .height(40)
      .backgroundColor(this.themeColor)
      .margin({ bottom: $r('app.string.space_m') })
      .onClick(() => {
        if (!this.phoneNumber) {
          this.toast('号码传入错误')
        }
        if (canIUse('SystemCapability.Applications.Contacts')) {
          call.makeCall(this.phoneNumber, (error: BusinessError) => {
            if (error) {
              Logger.error(TAG, 'make call fail, error is: ' + JSON.stringify(error));
            } else {
              Logger.info(TAG, 'make call success.');
            }
          });
        } else {
          this.toast('当前设备暂不支持一键拨号')
        }
      });

      Button('取消')
        .backgroundColor($r('app.color.background_color_grey'))
        .fontColor($r('app.color.font_color_level2'))
        .fontWeight(FontWeight.Medium)
        .height(40)
        .width($r('app.string.size_percent_100'))
        .onClick(() => {
          this.showSheet = false
        });

    }
    .backgroundColor($r('app.color.background_color_white'))
    .padding($r('app.string.space_l'))
    .margin($r('app.string.space_l'))
    .borderRadius($r('app.string.border_radius_16'))
    .backgroundColor($r('app.color.background_color_white'))
  }

  toast(message: string) {
    try {
      this.getUIContext().getPromptAction().showToast({ message })
    } catch (err) {
      Logger.error(TAG, 'show toast failed.error: ' + JSON.stringify(err))
    }

  }
}