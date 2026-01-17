import { AlertDialog } from '@kit.ArkUI';
import { calendarManager } from '@kit.CalendarKit';
import { serviceNotification } from '@kit.PushKit';
import { i18n } from '@kit.LocalizationKit';
import { OperateBtn } from './OperateBtn';
import { SystemSceneUtils } from '../common/SystemSceneUtils';
import { AppointState, AppointmentInfo } from '../common/Type';
import { SET_SCHEDULE, SET_SUBSCRIBE } from '../common/Constants';
import { FormItem } from './FormItem';

@ComponentV2
export struct ReservationCard {
  // 预约信息
  @Param appointInfo: AppointmentInfo = new AppointmentInfo();
  // 主题色
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  // 推送模板订阅ID，格式"xxx,xxx"
  @Param entityIds: string = '';
  // 系统语言
  @Param systemLanguage: string = i18n.System.getFirstPreferredLanguage();
  // 更新预约信息
  @Event updateReservation: (setSchedule: number, setSubscription: number) => void = () => {
  };
  // 取消预约
  @Event cancelReservation: () => void = () => {
  };
  // 刷新预约信息
  @Event refreshReservation: () => void = () => {
  };
  @Local reserveTime: string = '';
  private dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.dialog_cancel_appoint_title'),
      secondaryTitle: '',
      content: $r('app.string.dialog_cancel_appoint_content'),
      primaryButton: {
        value: $r('app.string.dialog_cancel_appoint_no'),
        fontColor: $r('sys.color.font_primary'),
        action: () => {
        },
      },
      secondaryButton: {
        value: $r('app.string.dialog_cancel_appoint_yes'),
        role: ButtonRole.NORMAL,
        fontColor: this.themeColor,
        action: () => {
          this.cancelReservation();
        },
      },
    }),
  })

  @Monitor('systemLanguage')
  onSysLangChange() {
    this.reserveTime = this.getReserveTime();
  }

  aboutToAppear(): void {
    // 初始化
    SystemSceneUtils.init(this.getUIContext());
    this.reserveTime = this.getReserveTime();
  }

  @Computed
  get maskPhoneNumber() {
    // 手机号脱敏
    return this.appointInfo.contactPhone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
  }

  build() {
    Row() {
      Column({ space: 12 }) {
        Row() {
          Text($r('app.string.text_appoint_time_desc', this.reserveTime))
            .fontSize(16)
            .fontColor(this.showOperateBar() ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Medium)
        }.width('100%')

        Column({ space: 4 }) {
          FormItem({
            info: { label: $r('app.string.form_item_project'), content: this.appointInfo.itemName },
            enableOperate: this.showOperateBar(),
          })
          FormItem({
            info: {
              label: $r('app.string.form_item_contact'),
              content: this.appointInfo.contactName,
            },
            enableOperate: this.showOperateBar(),
          })
          FormItem({
            info: {
              label: $r('app.string.form_item_phone'),
              content: this.maskPhoneNumber,
            },
            enableOperate: this.showOperateBar(),
          })
          FormItem({
            info: {
              label: $r('app.string.form_item_remark'),
              content: this.appointInfo.remarks || $r('app.string.form_item_remark_empty'),
            },
            enableOperate: this.showOperateBar(),
          })
        }

        if (this.showOperateBar()) {
          this.OperateBar()
        }
      }
      .layoutWeight(1)

      if (this.showCanceledIcon) {
        Image($r('app.media.icon_canceled')).waterMark()
      }

      if (this.showFinishedIcon) {
        Image($r('app.media.icon_finished')).waterMark()
      }

      if (this.showOverTimeIcon()) {
        Image($r('app.media.ic_overtime')).waterMark()
      }
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({ left: 12, right: 12, top: 16, bottom: 16})
  }

  @Builder
  OperateBar() {
    Column({ space: 12 }) {
      Divider()
      Row() {
        OperateBtn({
          imgSrc: $r('sys.symbol.xmark_circle'),
          btnText: $r('app.string.btn_cancel_appoint'),
          fgColor: $r('sys.color.font_primary'),
          onClickEvent: this.openCancelConfirmDialog,
        })

        Divider().vertical(true).height(20)

        OperateBtn({
          imgSrc: $r('sys.symbol.checkmark_calendar'),
          btnText: $r('app.string.schedule_to_add'),
          fgColor: this.themeColor,
          isDisabled: this.isAddSchedule,
          onClickEvent: this.onScheduleClick,
        })

        Divider().vertical(true).height(20)

        OperateBtn({
          imgSrc: $r('sys.symbol.bell'),
          btnText: $r('app.string.subscribe_to_add'),
          fgColor: this.themeColor,
          isDisabled: this.isSubscribe,
          onClickEvent: this.onSubscribeClick,
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  showOperateBar() {
    // 已取消/已完成/已过期不显示，其他均显示
    return !this.showCanceledIcon && !this.showFinishedIcon && !this.showOverTimeIcon();
  }

  showOverTimeIcon() {
    return this.appointInfo.state === AppointState.OVER_TIME ||
      this.appointInfo.state === AppointState.NEW && this.isOverTime();
  }

  // 是否过期
  isOverTime() {
    return this.appointInfo.reserveTime <= new Date().getTime();
  }

  getReserveTime() {
    const date = new Date(this.appointInfo.reserveTime);
    const monthDayFormat = new Intl.DateTimeFormat(this.systemLanguage, { month: 'long', day: 'numeric' });
    const timeFormat = new Intl.DateTimeFormat(this.systemLanguage, { timeStyle: 'short', hourCycle: 'h24' });
    return `${monthDayFormat.format(date)} ${timeFormat.format(date)}`;
  }

  // 添加日程
  async addEvent() {
    const calendarMgr: calendarManager.CalendarManager | null = await SystemSceneUtils.getCalendarMgr();
    if (!calendarMgr) {
      return false;
    }
    const date = new Date(this.appointInfo.reserveTime);
    const event: calendarManager.Event = {
      title: `预约的${this.appointInfo.itemName}`, // 日程标题
      type: calendarManager.EventType.NORMAL,
      startTime: date.getTime(),
      endTime: date.getTime() + 60 * 60 * 1000,
      reminderTime: [30], // 距开始时间提前10分钟提醒
    };

    const calendar = await calendarMgr.getCalendar();
    return calendar.addEvent(event).then(() => {
      return true;
    }).catch(() => {
      return false;
    });
  };

  openCancelConfirmDialog: () => void = () => {
    if (this.showOverTimeIcon()) {
      this.refreshReservation();
      return;
    }
    this.dialogControllerConfirm.open();
  };
  // 日程
  onScheduleClick: () => void = async () => {
    if (this.showOverTimeIcon()) {
      this.refreshReservation();
      return;
    }
    if (this.isAddSchedule) {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.toast_schedule_cannot_cancel') });
      return;
    }

    const isSuccess = await this.addEvent();
    if (!isSuccess) {
      return;
    }
    this.getUIContext().getPromptAction().showToast({ message: $r('app.string.toast_schedule_added') });
    const newV = this.isAddSchedule ? 0 : 1;
    this.appointInfo.setSchedule = newV;
    this.updateReservation(newV, this.appointInfo.setSubscription);
  };
  // 推送
  onSubscribeClick: () => void = async () => {
    if (this.showOverTimeIcon()) {
      this.refreshReservation();
      return;
    }
    if (this.isSubscribe) {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.toast_subscribe_cannot_cancel') });
      return;
    }
    const resp = await SystemSceneUtils.requestSubscribeNotification(this.entityIds);
    if (resp && resp?.entityResult?.length &&
      resp.entityResult[0]?.resultCode === serviceNotification.ResultCode.ACCEPTED) {
      const newV = this.isSubscribe ? 0 : 1;
      this.appointInfo.setSubscription = newV;
      this.updateReservation(this.appointInfo.setSchedule, newV);
    }
  };

  @Computed
  get isAddSchedule() {
    return this.appointInfo.setSchedule === SET_SCHEDULE;
  }

  @Computed
  get isSubscribe() {
    return this.appointInfo.setSubscription === SET_SUBSCRIBE;
  }

  @Computed
  get showFinishedIcon() {
    return this.appointInfo.state === AppointState.FINISH;
  }

  @Computed
  get showCanceledIcon() {
    return this.appointInfo.state === AppointState.CANCEL;
  }
}

@Extend(Image)
function waterMark() {
  .width(48)
  .height(48)
}