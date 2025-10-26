import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources'
import { calculateNewVipExpiryDate, VipOpen, VipPackage, VipPackageItem } from 'vip_center'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { AppStorageKeys, BreakPoint, UserInfoModel } from '@agctemplate/widgets'
import { appRouter, WindowManager } from '@agctemplate/utils';
import { AggregatedPaymentPicker, ChannelType } from 'aggregated_payment'

@ComponentV2
export struct LockedLayer {
  @Local isShowUnlockSheet: boolean = false
  @Local isShowVIPSheet: boolean = false
  @Local _isShowVIPSheet: boolean = false
  @Local isShowBuySheet: boolean = false
  @Local vipPackage: VipPackageItem = new VipPackageItem();
  @Local customDialogId: number = 0
  @Local unIndex: number = 0
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local bonus: number = this.userInfo.bonus
  @Local vipExpiryDate: Date = new Date
  @Local isPaymentChannelSheetShow: boolean = false
  @Local isMemberServiceAgreementSheetShow: boolean = false
  @Local bonusAgree: boolean = true
  @Event onUnLocked: Function
  breakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  @Local purAgree: boolean = false

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            Image(getMedia('app.media.ic_lock'))
              .width(16)
              .margin({ left: 16, right: 8 })
            Text('看点解锁/单集购买')
              .width(135)
              .height(21)
              .font({ weight: 500, size: 16 })
              .fontColor($r('sys.color.font_on_primary'))
          }
          .width('100%')
        }
        .width(191)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#BD9164')
        .margin({ bottom: 24 })
        .bindSheet($$this.isShowUnlockSheet, this.unlockSheet(), {
          height: 468,
          showClose: true,
          title: { title: '解锁剧集' },
          preferType: SheetType.BOTTOM,
        })
        .onClick(() => {
          if (this.userInfo.isPhoneAssociated) {
            this.isShowUnlockSheet = !this.isShowUnlockSheet
          } else {
            WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
            appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
          }
        })

        Text('开通会员看全集 >')
          .font({ weight: 500, size: 16 })
          .fontColor('#fff')
          .bindSheet($$this.isShowVIPSheet, this.vipSheet(), {
            height: 468,
            showClose: true,
            title: { title: '开通会员' },
            preferType: SheetType.BOTTOM,
          })
          .onClick(() => {
            if (this.userInfo.isPhoneAssociated) {
              this.isShowVIPSheet = !this.isShowVIPSheet
            } else {
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
              appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
            }
          })
      }
    }
    .zIndex(200)
    .width('100%')
    .height(this.breakPoint.value === 'sm' ? '93%' : '100%')
    .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
    .id('LockLayer')
  }

  @Builder
  unlockSheet() {
    Column() {
      Text(this.unIndex === 0 ? `看点余额：${this.userInfo.bonus}` : '单集购买')
        .font({ weight: 400, size: 14 })
        .width('100%')
        .margin({ bottom: 12, top: 12 })

      Row() {
        Column() {
          Text('看点解锁')
            .fontSize(14)
            .fontColor(this.userInfo.bonus >= 100 ? '#e6000000' : '#66000000')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })

          Column() {
            Text() {
              Span('100')
                .fontWeight(600)
                .fontSize(28)
              Span('点')
                .fontWeight(400)
                .fontSize(14)
            }
            .fontColor(this.userInfo.bonus >= 100 ? '#e6000000' : '#66000000')
          }
        }
        .border({
          width: this.unIndex === 0 ? 2 : 1,
          color: this.unIndex === 0 && this.userInfo.bonus >= 100 ? '#BD9164' : '#0d000000',
        })
        .backgroundColor('#fff')
        .borderRadius(16)
        .width(160)
        .height(90)
        .margin({ right: 8 })
        .clip(true)
        .onClick(() => {
          this.unIndex = 0
        })
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('单集购买')
            .fontSize(14)
            .fontColor('#e6000000')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })

          Column() {
            Text() {
              Span('¥')
                .fontWeight(400)
                .fontSize(14)
              Span('1')
                .fontWeight(600)
                .fontSize(28)
              Span('¥3')
                .fontSize(12)
                .fontColor($r('sys.color.font_tertiary'))
                .decoration({ type: TextDecorationType.LineThrough })
            }
          }
        }
        .backgroundColor('#fff')
        .border({
          width: this.unIndex === 1 ? 2 : 1,
          color: this.unIndex === 1 ? '#BD9164' : '#0d000000',
        })
        .borderRadius(16)
        .width(160)
        .height(90)
        .clip(true)
        .onClick(() => {
          this.unIndex = 1
        })
        .justifyContent(FlexAlign.Center)
      }
      .margin({ bottom: 12 })

      Row() {
        if (this.unIndex === 0) {
          Checkbox({ name: this.unIndex === 0 ? 'checkbox1' : '2' })
            .select(this.unIndex === 0 ? this.bonusAgree : this.purAgree)
            .selectedColor(true ? '#EC6E45' : $r('sys.color.comp_background_emphasize'))
            .onChange((value) => {
              if (this.unIndex === 0) {
                this.bonusAgree = value
              } else {
                this.purAgree = value
              }
            })
            .width(20)
            .aspectRatio(1)

          Text(this.unIndex === 0 ? '自动解锁下一集' : '自动购买下一集')
            .font({ weight: 400, size: 12 })
        } else {
          Blank()
            .height(28)
        }
      }
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 111 })
      .width('100%')

      Button(this.unIndex === 0 ? '立即开通' : '立即购买')
        .backgroundColor('#BD9164')
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .width('100%')
        .height(40)
        .margin({ bottom: 8 })
        .enabled(this.unIndex === 0 ? this.userInfo.bonus >= 100 ? true : false : true)
        .bindSheet($$this.isShowBuySheet, this.paymentChannelSheet('单集购买', 1), {
          height: 468,
          showClose: true,
          preferType: SheetType.BOTTOM,
        })
        .onClick(() => {
          if (this.unIndex === 0 && this.userInfo.bonus >= 100) {
            // 单集解锁
            this.bonus -= 100
            this.isShowUnlockSheet = false
            this.onUnLocked?.()
          } else if (this.unIndex === 1) {
            this.isShowBuySheet = true
          } else if (this.userInfo.bonus < 100) {
            promptAction.showToast({ message: '看点余额不足' })
          }
        })

      Column() {
        Text('开通会员')
          .fontColor('#BD9164')
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
          .bindSheet($$this._isShowVIPSheet, this.vipSheet(), {
            height: 468,
            showClose: true,
            title: this.titleBuilder,
            preferType: SheetType.BOTTOM,
            onWillDismiss: (callback: DismissSheetAction) => {
              if (callback.reason === 2) {
                this.isShowUnlockSheet = false
              }
            }
          })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this._isShowVIPSheet = true
      })
    }
    .padding({ left: 16, right: 16 })
  }

  @Builder
  vipSheet() {
    Column() {
      Column() {
        VipPackage({
          packageChange: (vipPackage: VipPackageItem) => {
            this.vipPackage = vipPackage
          }
        })
      }
      .clip(true)
      .margin({ bottom: 111, left: 16, right: 16 })

      Column() {
        VipOpen({
          onVipOpen: () => {
            this.isPaymentChannelSheetShow = !this.isPaymentChannelSheetShow
          },
          isVip: this.userInfo.isVip,
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
        this.paymentChannelSheet(this.vipPackage.title, this.vipPackage.amount),
        { height: 468, preferType: SheetType.BOTTOM }
      )
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .layoutWeight(1)
  }

  @Builder
  paymentChannelSheet(title: string, value: number) {
    AggregatedPaymentPicker({
      title: title || '会员周卡',
      amount: value || 5,
      channelInfo: [{
        channelType: ChannelType.HUAWEI_PAY,
        name: '华为支付',
        icon: $r('app.media.hwpay'),
        preOrderInfo: '',
        event: () => {
        }
      }, {
        channelType: ChannelType.WECHAT_PAY,
        preOrderInfo: '',
        appId: 'wx05b3e2e9fc730840',
        icon: $r('app.media.wechat'),
        name: '微信支付',
        event: () => {
          // this.isShow = false;
        },
      }, {
        channelType: ChannelType.ALI_PAY,
        name: '支付宝支付',
        icon: $r('app.media.alipay'),
        preOrderInfo: '',
      }],
      paySuccessEvent: (type: ChannelType) => {
        if (title !== '单集购买') {
          this.vipExpiryDate = calculateNewVipExpiryDate(this.vipExpiryDate, this.vipPackage.duration)
          this.userInfo.isVip = true
          this.userInfo.vipExpiryDate = this.vipExpiryDate
          this.onUnLocked?.()
        } else {
          this.onUnLocked?.()

        }
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
        .fontColor(true ? '#EC6E45' : $r('sys.color.comp_background_emphasize'))
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

  @Builder
  titleBuilder() {
    Row() {
      Image(getMedia('app.media.arrow_back'))
        .width(40)
        .margin({ right: 8 })
        .onClick(() => {
          this._isShowVIPSheet = false
        })
      Text('开通会员')
        .font({ weight: 700, size: 20 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }
}

@Builder
export function
lockedBuilder(onUnlocked: Function) {
  LockedLayer({
    onUnLocked: onUnlocked
  })
}