import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { PopViewUtils } from '../common/PopViewUtils';

const TAG = '[DialogCall]';

export class Params {
  phones: string[] = [];
  constructor(phones: string[]) {
    this.phones = phones;
  }
}

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

@Builder
export function DialogCallBuilder(params: Params) {
  CallDialog({
    params: params,
  })
}

@ComponentV2
struct CallDialog {
  @Param @Require params: Params

  callPhone(value: string) {
    try {
      const canUse = canIUse('SystemCapability.Applications.Contacts');
      if (!canUse) {
        ToastDialog.showToast({ message: '此设备不支持打电话' });
        return;
      }
      call.makeCall(value, (err: BusinessError) => {
        if (!err) {
          Logger.info(TAG, 'make call success.');
        } else {
          Logger.error(TAG, 'make call fail, err is:' + JSON.stringify(err));
        }
      });
    } catch (e) {
      ToastDialog.showToast({ message: '此设备不支持打电话' });
    }
  }

  build() {
    Column({ space: 10 }) {
      ForEach(this.params.phones, (phone: string) => {
        Text(phone).textStyle().onClick(() => {
          this.callPhone(phone);
        })
      }, (item: string) => item)
      Text('取消').textStyle().onClick(() => {
        PopViewUtils.closePopView();
      })
    }
    .width('100%')
    .padding({ left: 10, right: 10, bottom: 30 })
  }
}