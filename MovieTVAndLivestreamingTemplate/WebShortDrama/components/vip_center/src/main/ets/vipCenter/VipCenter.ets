import { DividerTmp } from 'base_apis'
import { VipPackage } from '../components/VipPackage';
import { VipBenefits } from '../components/VipBenefits';
import { VipOpen } from '../components/VipOpen';
import { VipPackageItem } from '../model/Model';
import { calculateNewVipExpiryDate, getVipDuration } from '../utils/Utils';
import { MockApi } from '../utils/MockApi'
import { WxExtraInfo, AggregatedPaymentPicker, ChannelType } from 'aggregated_payment';
import { promptAction } from '@kit.ArkUI';
import dayjs from 'dayjs';

@ComponentV2
export struct VipCenter {
  private wxOrderReq: WxExtraInfo = new WxExtraInfo();
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
  @Local isPaymentChannelSheetShow: boolean = false
  @Local isMemberServiceAgreementSheetShow: boolean = false

  @Builder
  paymentChannelSheet() {
    AggregatedPaymentPicker({
      title: this.vipPackage.title || '会员周卡',
      amount: this.vipPackage.amount || 5,
      channelInfo: [{
        channelType: ChannelType.HUAWEI_PAY,
        name: '华为支付',
        icon: $r('app.media.hwpay'),
        preOrderInfo: this.hwOrderStr,
        event: () => {
        }
      }, {
        channelType: ChannelType.WECHAT_PAY,
        preOrderInfo: this.wxOrderReq,
        appId: MockApi.WX_APP_ID,
        icon: $r('app.media.wechat'),
        name: '微信支付',
        event: () => {
          // this.isShow = false;
        },
      }, {
        channelType: ChannelType.ALI_PAY,
        name: '支付宝支付',
        icon: $r('app.media.alipay'),
        preOrderInfo: this.aliOrderStr,
      }],
      paySuccessEvent: (type: ChannelType) => {
        this.isVip = true
        this.vipType = this.vipPackage.duration || 'week'
        this.vipExpiryDate = calculateNewVipExpiryDate(this.vipExpiryDate, this.vipPackage.duration || 'week')
        this.packageBack(this.isVip, this.vipExpiryDate)
        promptAction.showToast({ message: '开通成功' })
      },
    });
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
    MockApi.getAliPreOrderInfo().then((res) => {
      this.aliOrderStr = res;
    });
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
                this.isPaymentChannelSheetShow = !this.isPaymentChannelSheetShow
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
          .bindSheet(
            this.isPaymentChannelSheetShow,
            this.paymentChannelSheet(),
            { height: 438, preferType: SheetType.BOTTOM }
          )
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