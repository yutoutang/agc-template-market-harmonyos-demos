import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { CommonConstants, RouterMap, RouterUtils, SettingModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingViewModel } from '../viewmodels/SettingVM';

@Builder
export function SettingPageBuilder() {
  SettingPage()
}

@ComponentV2
struct SettingPage {
  @Local vm: SettingViewModel = new SettingViewModel();
  @Local accessShow: boolean = false; // 交通方式
  @Local speedShow: boolean = false; // 刷新速率
  @Local warnShow: boolean = false; // 提醒
  // 临时选择状态（弹窗中使用）
  @Local tempAccessType: number = 0;
  @Local tempSpeedType: number = 1;
  @Local tempWarnType: number = 0;
  @Local tempWarnValue: number = 1;
  settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  getWarnDisplayText(): string {
    if (this.settingInfo.warnType === 0) {
      return `提前${this.settingInfo.warnValue}分钟`
    } else {
      return `提前${this.settingInfo.warnValue}站`
    }
  }

  getAccessDisplayText(): string {
    const types = ['公交', '地铁']
    return types[this.settingInfo.accessType]
  }

  getSpeedDisplayText(): string {
    const types = ['10秒', '30秒', '1分钟']
    return types[this.settingInfo.speedType]
  }

  @Builder
  AccessShowBuilder() {
    Column() {
      Row() {
        Image($r('app.media.close'))
          .width(35)
          .aspectRatio(1)
          .onClick(() => {
            this.tempAccessType = this.settingInfo.accessType // 恢复原状态
            this.accessShow = false
          })

        Text('优先交通方式')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Image($r('app.media.open'))
          .width(35)
          .aspectRatio(1)
          .onClick(() => {
            this.settingInfo.accessType = this.tempAccessType // 应用选择
            this.accessShow = false
          })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
      })


      Column() {
        TextPicker({
          range: ['公交', '地铁'],
          selected: this.tempAccessType,
        })
          .canLoop(false)
          .width('90%')
          .onChange((value: string | string[], index: number | number[]) => {
            if (typeof index === 'number') {
              this.tempAccessType = index
            }
          })
      }.height(240)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  @Builder
  SpeedShowBuilder() {
    Column() {
      Row() {
        Image($r('app.media.close'))
          .width(35)
          .aspectRatio(1)
          .onClick(() => {
            this.tempSpeedType = this.settingInfo.speedType // 恢复原状态
            this.speedShow = false
          })

        Text('车辆刷新频率')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Image($r('app.media.open'))
          .width(35)
          .aspectRatio(1)
          .onClick(() => {
            this.settingInfo.speedType = this.tempSpeedType // 应用选择
            PersistenceV2.save(SettingModel)
            this.speedShow = false
          })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
      })


      Column() {
        TextPicker({
          range: ['10秒', '30秒', '1分钟'],
          selected: this.tempSpeedType
        })
          .canLoop(false)
          .width('90%')
          .onChange((value: string | string[], index: number | number[]) => {
            if (typeof index === 'number') {
              this.tempSpeedType = index
            }
          })
      }.height(240)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  @Builder
  warnShowBuilder() {
    Column() {
      Row() {
        Image($r('app.media.close'))
          .width(35)
          .aspectRatio(1)
          .onClick(() => {
            this.tempWarnType = this.settingInfo.warnType // 恢复原状态
            this.tempWarnValue = this.settingInfo.warnValue
            this.warnShow = false
          })

        Text('提醒时机')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Image($r('app.media.open'))
          .width(35)
          .aspectRatio(1)
          .onClick(() => {
            this.settingInfo.warnType = this.tempWarnType // 应用选择
            this.settingInfo.warnValue = this.tempWarnValue
            this.warnShow = false
          })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 16
      })


      // 两列选择器
      Row() {
        // 左侧类型选择
        Column() {
          Text('提前分钟数')
            .fontSize(16)
            .fontColor(this.tempWarnType === 0 ? '#007AFF' : '#666666')
            .margin({ bottom: 15 })
            .onClick(() => {
              this.tempWarnType = 0
            })

          Text('提前站点')
            .fontSize(16)
            .fontColor(this.tempWarnType === 1 ? '#007AFF' : '#666666')
            .onClick(() => {
              this.tempWarnType = 1
            })
        }
        .width('50%')
        .alignItems(HorizontalAlign.End)
        .padding({ left: 20 })

        // 右侧数字选择器
        Column() {
          TextPicker({
            range: ['1', '2', '3', '4', '5'],
            selected: this.tempWarnValue - 1,
          })
            .defaultPickerItemHeight(35)
            .divider(null)
            .onChange((value: string | string[], index: number | number[]) => {
              if (typeof index === 'number') {
                this.tempWarnValue = index + 1
              }
            })
        }
        .width('50%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(240)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  @Builder
  SelectBuilder() {
    Column() {
      Row() {
        Row() {
          Text('优先交通方式')
          Image($r('app.media.need_vip'))
            .width(25)
            .height(15)
            .margin({ left: 10 })
        }

        Row() {
          Text(this.getAccessDisplayText()).fontColor('#a0a0a0').margin({ right: 10 })
          Image($r('app.media.ic_right')).width(20).height(20)
        }
        .onClick(() => {
          if (this.vm.userInfoModel.isVip) {
            // 已开通VIP：正常显示选择弹窗
            this.tempAccessType = this.settingInfo.accessType
            this.accessShow = true
          } else {
            // 未开通VIP：显示VIP弹窗
            this.showVipRequiredDialog()
          }
        })
        .bindSheet($$this.accessShow, this.AccessShowBuilder(), {
          height: 300,
          showClose: false,
          preferType: SheetType.CENTER
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .border({ width: { bottom: 1 }, color: '#f2f2f2' })
      .padding({ bottom: 15, top: 10 })

      Row() {
        Row() {
          Text('车辆刷新频率')
          Image($r('app.media.need_vip'))
            .width(25)
            .height(15)
            .margin({ left: 10 })
        }

        Row() {
          Text(this.getSpeedDisplayText()).fontColor('#a0a0a0').margin({ right: 10 })
          Image($r('app.media.ic_right')).width(20).height(20)
        }
        .onClick(() => {
          if (this.vm.userInfoModel.isVip) {
            // 已开通VIP：正常显示选择弹窗
            this.tempSpeedType = this.settingInfo.speedType
            this.speedShow = true
          } else {
            // 未开通VIP：显示VIP弹窗
            this.showVipRequiredDialog()
          }
        })
        .bindSheet($$this.speedShow, this.SpeedShowBuilder(), {
          height: 300,
          showClose: false,
          preferType: SheetType.CENTER
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ bottom: 10, top: 15 })

    }.backgroundColor(Color.White).padding(10).borderRadius(20)

    Column() {
      Row() {
        Text('到站提醒')
        Toggle({ type: ToggleType.Switch, isOn: this.settingInfo.isArrivalReminder })
          .onChange((isOn: boolean) => {
            this.settingInfo.isArrivalReminder = isOn
            if (isOn) {
              promptAction.showToast({
                message: '已开启到站提醒',
                duration: 2000
              })
            } else {
              promptAction.showToast({
                message: '已关闭到站提醒',
                duration: 2000
              })
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      .padding({ bottom: 10, top: 10 })

      if (this.settingInfo.isArrivalReminder) {
        Row() {
          Text('提醒时机')
          Row() {
            Text(this.getWarnDisplayText()).fontColor('#a0a0a0').margin({ right: 10 })
            Image($r('app.media.ic_right')).width(20).height(20)
          }
          .onClick(() => {
            this.tempWarnType = this.settingInfo.warnType // 初始化临时状态
            this.tempWarnValue = this.settingInfo.warnValue
            this.warnShow = true
          })
          .bindSheet($$this.warnShow, this.warnShowBuilder(), {
            height: 300,
            showClose: false,
            preferType: SheetType.CENTER
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ bottom: 10, top: 15 })
        .border({ width: { top: 1 }, color: '#f2f2f2' })
      }
    }.backgroundColor(Color.White).padding(10).borderRadius(20).margin({ top: 10 })

    Column() {
      Row() {
        Text('异常提醒')
        Toggle({ type: ToggleType.Switch, isOn: this.settingInfo.abnormalReminderOn })
          .onChange((isOn: boolean) => {
            this.settingInfo.abnormalReminderOn = isOn
            if (isOn) {
              promptAction.showToast({
                message: '已开启异常提醒',
                duration: 2000
              })
            } else {
              promptAction.showToast({
                message: '已关闭异常提醒',
                duration: 2000
              })
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .border({ width: { bottom: 1 }, color: '#f2f2f2' })
      .padding({ bottom: 10, top: 10 })

      Row() {
        Text('末班提醒')
        Toggle({ type: ToggleType.Switch, isOn: this.settingInfo.lastTrainReminderOn })
          .onChange((isOn: boolean) => {
            this.settingInfo.lastTrainReminderOn = isOn
            if (isOn) {
              promptAction.showToast({
                message: '已开启末班提醒',
                duration: 2000
              })
            } else {
              promptAction.showToast({
                message: '已关闭末班提醒',
                duration: 2000
              })
            }
          })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 15, bottom: 10 })
    }.backgroundColor(Color.White).padding(10).margin({ top: 10 }).borderRadius(20)
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '设置',
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            this.SelectBuilder()
          }
          .padding({
            left: CommonConstants.PADDING_PAGE,
            right: CommonConstants.PADDING_PAGE,
            top: CommonConstants.PADDING_M,
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)

        Column() {
          Button() {
            Row({ space: CommonConstants.SPACE_XS }) {
              LoadingProgress()
                .width(24)
                .aspectRatio(1)
                .color($r('sys.color.icon_on_primary'))
                .visibility(this.vm.isLoading ? Visibility.Visible : Visibility.None)
              Text(this.vm.signOutBtnLabel)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
            }
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(40)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .margin({ top: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
          .enabled(!this.vm.isLoading)
          .onClick(() => {
            this.getUIContext().showAlertDialog(
              {
                title: '',
                message: '确定要退出登录吗？',
                autoCancel: true,
                alignment: DialogAlignment.Center,
                width: 300,
                height: 120,
                offset: { dx: 0, dy: -20 },
                primaryButton: {
                  value: '取消',
                  fontColor: '#99000000',
                  action: () => {
                  }
                },
                secondaryButton: {
                  enabled: true,
                  value: '确定',
                  action: () => {
                    this.vm.onSignOutBtnClick();
                  }
                }
              })
          })
        }
        .visibility(this.vm.userInfoModel.isLogin ? Visibility.Visible : Visibility.None)
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          bottom: this.vm.windowModel.windowBottomPadding,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  // vip弹窗
  private showVipRequiredDialog() {
    this.getUIContext().showAlertDialog({
      message: '请先开通会员后操作',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      width: 300,
      height: 120,
      primaryButton: {
        value: '取消',
        fontColor: '#99000000',
        action: () => {
          // 取消操作，关闭弹窗
        }
      },
      secondaryButton: {
        enabled: true,
        value: '去开通',
        fontColor: '#007AFF',
        action: () => {
          // 跳转到会员中心页面
          RouterUtils.pushPathByName(RouterMap.VIPCENTER_PAGE);
        }
      }
    });
  }
}