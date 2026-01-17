import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { CommonConstants } from '../constants/CommonConstants';
import { PopViewUtils } from '../utils/PopViewUtils';

const TAG = '[DialogCall]';

export class Params {
  phones: string[] = [];

  constructor(phones: string[]) {
    this.phones = phones;
  }
}

function callPhone(value: string) {
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

@Extend(Text)
function textStyle() {
  .fontSize(18)
  .fontColor('#007dff')
  .width(CommonConstants.FULL_PERCENT)
  .height(48)
  .textAlign(TextAlign.Center)
  .backgroundColor($r('app.color.common_card_bg'))
  .borderRadius(8)
}

@Builder
export function DialogCallBuilder(params: Params) {
  Column({ space: 10 }) {
    ForEach(params.phones, (phone: string) => {
      Text(phone).textStyle().onClick(() => {
        callPhone(phone);
      })
    }, (item: string) => item)
    Text($r('app.string.btn_common_cancel')).textStyle().onClick(() => {
      PopViewUtils.closePopView();
    })
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({ left: 10, right: 10, bottom: 30 })
}