import { AlertDialog } from '@kit.ArkUI';
import { calendarManager } from '@kit.CalendarKit';
import { serviceNotification } from '@kit.PushKit';
import { i18n, intl } from '@kit.LocalizationKit';
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
      primaryTitle: '',
      secondaryTitle: '',
      content: $r('app.string.dialog_cancel_appoint_title'),
      primaryButton: {
        value: $r('app.string.dialog_cancel_appoint_no'),
        role: ButtonRole.NORMAL,
        action: () => {
        },
      },
      secondaryButton: {
        value: $r('app.string.dialog_cancel_appoint_yes'),
        role: ButtonRole.ERROR,
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
    this.reserveTime = this.getReserveTime();
  }

  build() {
    Stack() {
      Column({ space: 4 }) {
        Row({ space: 10 }) {
          Image(this.showOperateBar() ? $r('app.media.icon_circle_red') : $r('app.media.icon_circle_grey'))
            .width(10)
            .height(10)
          Text($r('app.string.text_appoint_time_desc', this.reserveTime))
            .fontSize(18)
            .fontColor(this.showOperateBar() ? '#212121' : '#878787')
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
              content: `${this.appointInfo.contactName} ${this.appointInfo.contactPhone}`,
            },
            enableOperate: this.showOperateBar(),
          })
          FormItem({
            info: {
              label: $r('app.string.form_item_nums'),
              content: $r('app.string.form_content_nums', this.appointInfo.numbers.toString()),
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
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(8)
      .padding(10)

      if (this.showCanceledIcon) {
        Image($r('app.media.icon_canceled')).waterMark()
      }

      if (this.showFinishedIcon) {
        Image($r('app.media.icon_finished')).waterMark()
      }

      if (this.showOverTimeIcon()) {
        Image($r('app.media.ic_overtime')).waterMark()
      }

    }.alignContent(Alignment.End)

  }

  @Builder
  OperateBar() {
    Column() {
      Divider()
      Row() {
        OperateBtn({
          imgSrc: $r('app.media.icon_cancel'),
          btnText: $r('app.string.btn_cancel_appoint'),
          fgColor: '#878787',
          onClickEvent: this.openCancelConfirmDialog,
        })

        Divider().vertical(true).height(20)

        OperateBtn({
          imgSrc: this.scheduleIcon,
          btnText: this.scheduleText,
          fgColor: this.isAddSchedule ? '#434343' : this.themeColor,
          onClickEvent: this.onScheduleClick,
        })

        Divider().vertical(true).height(20)

        OperateBtn({
          imgSrc: this.subscribeIcon,
          btnText: this.subscribeText,
          fgColor: this.isSubscribe ? '#434343' : this.themeColor,
          onClickEvent: this.onSubscribeClick,
        })
      }
      .width('100%')
      .padding(6)
      .justifyContent(FlexAlign.SpaceBetween)
    }.margin({ top: 10 })
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
    const monthDayFormat = new intl.DateTimeFormat(this.systemLanguage, { month: 'long', day: 'numeric' });
    const timeFormat = new intl.DateTimeFormat(this.systemLanguage, { timeStyle: 'short', hourCycle: 'h24' });
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
  get scheduleText() {
    return this.isAddSchedule ? $r('app.string.schedule_added') : $r('app.string.schedule_to_add');
  }

  @Computed
  get scheduleIcon() {
    return this.isAddSchedule ? $r('app.media.icon_schedule_done') :
    $r('app.media.icon_schedule');
  }

  @Computed
  get subscribeText() {
    return this.isSubscribe ? $r('app.string.subscribe_added') : $r('app.string.subscribe_to_add');
  }

  @Computed
  get subscribeIcon() {
    return this.isSubscribe ? $r('app.media.icon_subscribe_done') :
    $r('app.media.icon_subscribe');
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
  .width(64)
  .height(56)
  .margin({ right: 20 })
}