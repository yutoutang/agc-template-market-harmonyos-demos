import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit'
import { common, Want } from '@kit.AbilityKit'
import { UtilLog } from '@hw-agconnect/util-log';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { StoreInfo } from '../models/Index'


@Extend(Text)
function textStyle() {
  .fontSize(18)
  .fontColor('#007dff')
  .width('100%')
  .height(48)
  .textAlign(TextAlign.Center)
  .backgroundColor(Color.White)
  .borderRadius(8)
}

const TAG = '[StoreCard]';

@ComponentV2
export struct StoreCard {
  @Param @Require storeInfo: StoreInfo
  @Param @Require packageName: string
  @Param isSelect: boolean = false
  @Local callTelSheet: boolean = false

  openPhoneDialog() {
    UIDialog.open({
      bgColor: Color.Transparent,
      alignment: DialogAlignment.Bottom,
      contentBuilder: () => {
        this.callTelBuilder()
      },
    })
  }

  callPhone() {
    try {
      const canUse = canIUse('SystemCapability.Applications.Contacts');
      if (!canUse) {
        ToastDialog.showToast({ message: '此设备不支持打电话' });
        return;
      }
      call.makeCall(this.storeInfo.tel, (err: BusinessError) => {
        if (!err) {
          UtilLog.info(TAG, 'make call success.');
        } else {
          UtilLog.error(TAG, 'make call fail, err is:' + JSON.stringify(err));
        }
      });
    } catch (e) {
      ToastDialog.showToast({ message: '此设备不支持打电话' });
    }
  }

  build() {
    Column() {
      Row() {
        Text(this.storeInfo.name)
          .fontSize(12)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: 180 })
          .layoutWeight(1)

        Row() {
          Image($r('app.media.ic_public_position')).width(12)
          Text(this.storeInfo.distanceStr).fontSize(10).fontColor($r('sys.color.font_secondary')).margin({ left: 8 })
        }.margin({ left: 8 })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(this.storeInfo.address).fontSize(10).fontColor($r('sys.color.font_secondary')).maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.margin({ top: 12 }).constraintSize({ maxWidth: 200 })

      Row() {
        Row() {
          Image($r('app.media.ic_clock_grey')).width(12)
          Text($r('app.string.store_open_time'))
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: 8 })
          Text(`${this.storeInfo.time1} - ${this.storeInfo.time2}`)
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
        }

        Row() {
          Image($r('app.media.ic_public_location')).width(24).onClick(() => {
            let coordinates = this.storeInfo.coordinates?.split(',')
            if (coordinates?.length === 2) {
              let longitude: number = Number(coordinates[0])
              let latitude: number = Number(coordinates[1])
              let petalMapWant: Want = {
                bundleName: 'com.huawei.hmos.maps.app',
                uri: 'maps://routes',
                parameters: {
                  linkSource: this.packageName,
                  destinationLatitude: latitude,
                  destinationLongitude: longitude,
                  destinationPoiId: '',
                  destinationName: this.storeInfo.address ?? '',
                },
              }
              let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              context.startAbility(petalMapWant);
            } else {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.store_address_error') })
            }
          })
          Image($r('app.media.ic_public_telephone'))
            .width(24).margin({ left: 24 })
            .onClick(() => {
              this.openPhoneDialog();
            })
        }

      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 4 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .border(this.isSelect ? { width: 1, color: $r('sys.color.multi_color_07'), radius: 16 } :
      { width: 1, color: '#26000000', radius: 16 })
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8,
    })
  }

  @Builder
  callTelBuilder() {
    Column({ space: 10 }) {
      Text(this.storeInfo.tel).textStyle().onClick(() => {
        this.callPhone();
      })
      Text('取消').textStyle().onClick(() => {
        UIDialog.closeLast()
      })
    }
    .width('100%')
    .padding({ left: 10, right: 10, bottom: 30 })
  }
}