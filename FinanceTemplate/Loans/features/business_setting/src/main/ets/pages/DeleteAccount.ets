import { CommonConstants, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingViewModel } from '../viewmodels/SettingVM';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function DeleteAccountBuilder() {
  DeleteAccount()
}

@ComponentV2
struct DeleteAccount {
  @Local vm: SettingViewModel = new SettingViewModel();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  aboutToAppear(): void {
    this.vm.getLoginPhoneNumber();
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '注销账号',

      })
      Column({ space: 8 }) {
        Text('在您申请注销账号前，请仔细阅读以下内容:')
          .fontSize(16)
          .textAlign(TextAlign.Start)
          .fontSize(14)
          .lineHeight(19)
          .fontColor('#E6000000')
          .fontWeight(FontWeight.Medium)
          .width(CommonConstants.FULL_PERCENT)
        this.Content('注销账号后，将无法再登录或使用本平台服务，所有个人信息、历史记录将被清除且无法恢复。')
        this.Content('如您名下仍有 未结清的贷款、正在进行的借款中请或未完成的合同，将无法注销账号。请先完成相关业务后再申请。')
        this.Content('注销账号不会影响您已产生的借款合同、还款义务及征信记录，您仍需按时履行还款责任。')
        this.Content('与账号绑定的权益将一并清除，无法转移或退还，若您已确认理解并同意上述内容，可继续提交注销中。')

      }
      .width(CommonConstants.FULL_PERCENT)
      .flexGrow(1) // 【关键】让内容区域填充剩余空间
      .backgroundColor('#f2f4f5')
      .padding({
        left: 16,
        right: 16,
        bottom: 16,
        top: 14
      })

      Row() {
        Button('确定注销')
          .width('100%')
          .height(40)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.warning'))
          .margin({ top: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.CONFIRM_CANCELLATION)
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: 16, right: 16, bottom: this.windowModel.windowBottomPadding })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  Content(title: string) {
    Row({ space: 8 }) {
      Text('')
        .width(6)
        .height(6)
        .backgroundColor('#66000000')
        .borderRadius(6)
      Text(title)
        .fontSize(14)
        .lineHeight(20)
        .fontColor('#99000000')
        .layoutWeight(1)
        .align(Alignment.Top)
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }
}
