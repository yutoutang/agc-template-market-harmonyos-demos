import { DividerTmp } from 'base_apis'
import { VipPackage } from '../components/VipPackage';
import { VipBenefits } from '../components/VipBenefits';
import { VipOpen } from '../components/VipOpen';
import { VipPackageItem } from '../model/Model';
import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import { UIContext } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import dayjs from 'dayjs';

@ComponentV2
export struct VipCenter {
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Param userName: string = ''
  @Param avatar: string = ''
  @Param @Once isVip: boolean = false
  @Param @Once vipType: string = ''
  @Param @Once vipExpiryDate: Date = new Date
  @Param routerModule: NavPathStack = new NavPathStack()
  hwOrderStr: string = '';
  @Local aliOrderStr: string = '';
  @Event onVerifyNow: () => void = () => {
  }
  @Event onVipOpen: () => void = () => {
  }
  @Event packageBack: (isVip: boolean, vipExpiryDate: Date) => void = () => {
  }
  @Local vipPackage: VipPackageItem = new VipPackageItem()
  @Local customDialogId: number = 0
  @Local isMemberServiceAgreementSheetShow: boolean = false
  private uiContext: UIContext = this.getUIContext();
  private navPathStack: NavPathStack = new NavPathStack();
  private cashierPicker: CashierPicker = new CashierPicker(this.uiContext)
    .onRealPayment(async (type: PaymentType) => {
      // todo: 根据支付类型向服务器请求支付所需参数
      if (type === PaymentType.ALIPAY) {
        /**
         * 请求拉起支付宝
         *
         * 临时测试时，orderInfo 不推荐传入空字符串，这会导致跳转至支付宝行为仅仅是跳转，不会有支付相关的交互
         * 未安装支付宝且参数真实时，SDK 会尝试使用 this.navPathStack 跳转至 H5 页面继续支付，该参数可不传
         */
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: 'ORDER_INFO' }, this.navPathStack);
      } else if (type === PaymentType.HUAWEI) {
        /**
         * 请求拉起华为支付
         */
        if (deviceInfo.marketName === 'emulator') {
          this.showToast('华为支付在模拟器场景下无任何响应');
          return;
        }
        aggregatedPaymentService.requestPaymentByHuawei(this.uiContext, { orderStr: '' });
      } else if (type === PaymentType.WECHAT) {
        /**
         * 请求拉起微信支付
         *
         * 微信支持获取拉起结果，如果拉起成功，则可以进一步尝试等待支付回调。如果拉起失败，则不会有支付回调。
         */
        const isWeChatOpenSuccess: boolean =
          await aggregatedPaymentService.requestPaymentByWeChat(this.uiContext, {
            partnerId: '',
            prepayId: '',
            nonceStr: '',
            timeStamp: '',
            sign: ''
          });
        if (!isWeChatOpenSuccess) {
          this.showToast('微信拉起失败');
        }
      }
    })
    .onWillDismiss((reason: DismissReason) => {
      if (reason === DismissReason.TOUCH_OUTSIDE) {
        this.showToast('已拦截点击其它区域进行关闭的交互方式');
      } else {
        this.cashierPicker.close();
      }
    });

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: `Test: ${msg}` });
  }

  @Builder
  memberServiceAgreementSheet() {
    Column() {
      Image($r('app.media.pic'))
        .height(30)
        .margin({ bottom: 18 })

      Text('会员服务协议')
        .fontSize(20)
        .fontWeight(700)
        .lineHeight(27)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 4 })

      Text('更新日期：2025年5月25日')
        .fontSize(14)
        .fontWeight(400)
        .lineHeight(19)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ bottom: 24 })

      Column() {
        Text('欢迎您使用“华为短剧”。“华为短剧”采用收费。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，' +
          '您就可以使用短剧会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
          '本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“华为直播”提供的各种付费服务签订的服务协议，' +
          '描述了华为与直播付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，' +
          '您可享受会员权益。\n您同意本“华为短剧”付费服务协议条款即表示同意遵守《华为短剧用户协议》《关于华为短剧与隐私的声明》' +
          '（以下称“基础协议”），本协议未涉及事项以《华为短剧用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。\n' +
          '华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。' +
          '请您仔细审阅并决定接受或不接受本服务协议。若您拒绝接受本协议，不影响已同意的基础协议。')
          .fontSize(16)
          .fontWeight(400)
          .lineHeight(21)
          .fontColor($r('sys.color.font_primary'))
      }
    }
    .margin({ top: 72 })
    .height(636)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  automaticRenewalAgreement() {
    Column() {
      Text('自动续费规则')
        .fontSize(20)
        .fontWeight(700)
        .lineHeight(27)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 15 })
      Column() {
        Text('1.自动续费前5日将通过push方式、短信\n' +
          '方式提醒您；\n' +
          '2.开通服务后，系统通过订阅用户账户\n' +
          '扣除下一计费周期（月/季/年），同时\n' +
          '在会员到期当天/前一天自动续费，不同\n' +
          '支付平台，不同会员的到期自动续费时\n' +
          '间不同；\n' +
          '3.您可以通过以下任一方式取消自动续\n' +
          '费：\n' +
          '1）本应用内：在本应用中前往“我的”>\n' +
          '“会员中心”>“会员管理”，该页面展示了\n' +
          '所有自动续订项目，点击相应连包会员\n' +
          '卡片，进入“订阅详情”页面，您可根据\n' +
          '需要取消自动续订服务；\n' +
          '2）支付宝支付:前往“支付宝”>“我的’\n' +
          '，点击“设置”图标，前往“支付设置”>“\n' +
          '免密支付/自动扣款”，找到签约的本应\n' +
          '用自动续订服务，并关闭该服务，即可\n' +
          '取消自动续订；\n' +
          '3）微信支付：前往“微信”>“我”>“服务\n' +
          '”>“钱包”>“支付设置”>“自动续费”，找\n' +
          '到签约的本应用自动续订服务，并关闭\n' +
          '该服务，即可取消自动续订')
          .fontSize(16)
          .margin({ bottom: 16 })
          .fontWeight(400)
          .lineHeight(21)
          .fontColor($r('sys.color.font_primary'))
      }

      Text('知道了')
        .fontColor('#EC6E45')
        .fontSize(16)
        .fontWeight(500)
        .lineHeight(21)
        .padding(9)
        .onClick(() => {
          this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogId)
        })
    }
    .padding({
      top: 15,
      bottom: 9,
      left: 24,
      right: 24
    })
  }

  aboutToAppear(): void {
    // todo: 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖。如：实际支付成功，但支付回调没有触发。
    aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean) => {
        this.showToast(`收到 ${type} 支付回调，支付结果：${(isSuccess ? '成功' : '失败')}`);
      }
    );
  }

  aboutToDisappear(): void {
    aggregatedPaymentService.unregisterAllPaymentCallbacks();
  }

  build() {
    Column() {
      Column() {
        Column() {
          Row({ space: 12 }) {
            Image(this.avatar || $r('app.media.avatar')).width(48).height(48).borderRadius('50%').clip(true)
            Column({ space: 5 }) {
              Row({ space: 8 }) {
                Text(this.userName)
                  .fontWeight(FontWeight.Medium)
                Row({ space: 5 }) {
                  Image($r('app.media.vip'))
                    .width(12).height(12)
                  Text(this.isVip ? '已开通' : '未开通')
                    .fontSize(10)
                }
                .padding({ left: 4, right: 4 })
                .borderRadius(4)
                .backgroundColor('#F1D1A5')
                .opacity(this.isVip ? 1 : 0.5)
              }

              Column() {
                Text(`${dayjs(this.vipExpiryDate).format('YYYY-MM-DD')}`)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
              }.visibility(this.isVip ? Visibility.Visible : Visibility.None)
            }
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')
        .margin({ bottom: 24, top: 16 })
        .alignItems(HorizontalAlign.Start)

        Column() {
          Column() {
            VipPackage({
              userName: this.userName,
              avatar: this.avatar,
              isVip: this.isVip,
              packageChange: (vipPackage: VipPackageItem) => {
                this.vipPackage = vipPackage
              },
            })
            Column() {
              VipBenefits()
            }
            .padding({ top: 20 })
          }
          .clip(true)
          .margin({ bottom: 42 })

          Column() {
            VipOpen({
              onVipOpen: () => {
                this.cashierPicker
                  .reset() // 内部状态重置
                  .setAmount(this.vipPackage.amount*100 || 500) // 支付金额，单位：分
                  .setTradeSummary(this.vipPackage.title || '会员周卡') // 订单摘要 (可选，不填则不显示)
                  .open();
              },
              isVip:this.isVip,
              onMemberServiceAgreementSheetOpen: () => {
                this.isMemberServiceAgreementSheetShow = !this.isMemberServiceAgreementSheetShow
              },
              onAutomaticRenewalAgreementDialogOpen: () => {
                this.getUIContext().getPromptAction().openCustomDialog({
                  builder: () => {
                    this.automaticRenewalAgreement()
                  }
                }).then((dialogId: number) => this.customDialogId = dialogId)
              }
            })
              .bindSheet(
                this.isMemberServiceAgreementSheetShow,
                this.memberServiceAgreementSheet(), {
                height: 736,
                preferType: SheetType.BOTTOM
              })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .layoutWeight(1)
      }
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ bottom: Number(AppStorage.get('bottomRectHeight')) })
  }
}