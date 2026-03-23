import { MinePageCommonService } from '../constants/MineUiConstants';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct MineItem {
  @Param @Require commonService: MinePageCommonService;
  @Param @Require appPathStack: NavPathStack

  build() {
    Row() {
      Image($r(this.commonService.icon))
        .width(24)
        .height(24)
        .margin({ left: 12 })
      Text(this.commonService.label)
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 16 })
      Blank()
      Image($r('app.media.ic_right_arrow_lined'))
        .width(7)
        .height(14)
        .fillColor($r('sys.color.icon_secondary'))
        .margin({ right: 12 })
    }
    .width('100%')
    .height(46)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .justifyContent(FlexAlign.Start)
    .margin({ top: 12 })
    .onClick(() => {
      this.appPathStack.pushPathByName(this.commonService.nextPage, undefined);
    })
  }
}


@ComponentV2
export struct ContactItem {
  @Param @Require commonService: MinePageCommonService;
  @Param @Require appPathStack: NavPathStack

  @Local openSheet: boolean = false;
  build() {
    Row() {
      Image($r(this.commonService.icon))
        .width(24)
        .height(24)
        .margin({ left: 12 })
      Text(this.commonService.label)
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 16 })
      Blank()
      Image($r('app.media.ic_right_arrow_lined'))
        .width(7)
        .height(14)
        .fillColor($r('sys.color.icon_secondary'))
        .margin({ right: 12 })
    }
    .width('100%')
    .height(46)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .justifyContent(FlexAlign.Start)
    .margin({ top: 12 })
    .onClick(() => {
      this.openSheet = !this.openSheet
    })
    .bindSheet($$this.openSheet, this.contactBuilder(), {
      title: {title: '联系客服' },
      height: 280,
      width: '100%'
    })
  }

  @Builder
  contactBuilder(){
    Column({ space: 12 }){
      Text('000000')
        .fontWeight(FontWeight.Medium)
        .fontSize(18)
        .fontColor($r('sys.color.font_primary'))
        .padding({
          top: 16
        })

      Button(){
        Row({ space: 4 }){
          SymbolGlyph($r('sys.symbol.phone_badge_waveform_2_fill'))
            .fontSize(14)
          Text('一键拨号')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
        }
      }
      .backgroundColor('#387BF1')
      .height(40)
      .width('94%')
      .onClick(() => {
        // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
        try {
          call.makeCall('000000', (err: BusinessError) => {
            if (!err) {
              console.log('make call success.');
            } else {
              let errMsg: string;
              try {
                errMsg = JSON.stringify(err);
              } catch (e) {
                errMsg = 'unknown error';
              }
              console.log('make call fail, err is:' + errMsg);
            }
          });
        } catch (error) {
          const e = error as BusinessError;
          console.log('make call throw error, code:' + e.code + ', message:' + e.message);
        }
      })

      Button('取消')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_tertiary'))
        .height(40)
        .width('94%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.openSheet = false;
        })
    }
    .margin({
      top: 10
    })
    .height(156)
    .width('92%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
  }
}