import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import hilog from '@ohos.hilog';
import { DrinkVM } from '../viewmodels/DrinkVM';
import { DrinkWarnParam } from '../models/DrinkModel';
import { PreferenceUtils } from 'lib_common';
import { DrinkWarnViewModel } from '../viewmodels/DrinkWarnViewModel';

@ObservedV2
export class TargetReminderAgentHelper {
  /**
   * 通过通知提示
   */
  public static readonly TYPE_NOTICE: string = 'notice';
  /**
   * 通过闹钟提示
   */
  public static readonly TYPE_ALARM_CLOCK: string = 'alarm_clock';
  private static instance: TargetReminderAgentHelper;
  @Trace
  type: string = '';
  private store: PreferenceUtils =
    PreferenceUtils.getInstance(getContext() as common.UIAbilityContext, 'drink_warn_storage')
  /**
   * 定时器Id
   */
  private intervalId: number = 0;

  public static getInstance(): TargetReminderAgentHelper {
    if (!TargetReminderAgentHelper.instance) {
      TargetReminderAgentHelper.instance = new TargetReminderAgentHelper();
    }
    return TargetReminderAgentHelper.instance;
  }

  public start(context: common.UIAbilityContext) {

    this.type = this.store.get('drink_warn_type', TargetReminderAgentHelper.TYPE_NOTICE) as string

    notificationManager.requestEnableNotification(context).then(() => {

      if (this.type === TargetReminderAgentHelper.TYPE_ALARM_CLOCK) {
        reminderAgentManager.cancelAllReminders().then(() => {
          hilog.info(0x0000, 'testTag', '闹钟批量取消成功');
          this.startPushReminder()
        }).catch((err: BusinessError) => {
          hilog.error(0x0000, 'testTag', '闹钟批量取消失败' + err.message);
        });
      } else {
        this.startPushReminder()
      }

    }).catch((err: BusinessError) => {
      if (1600004 === err.code) {
        //用户主动拒绝
        hilog.info(0x0000, 'testTag', '用户主动拒绝');
      } else {
        //请求权限失败
        hilog.info(0x0000, 'testTag', '请求权限失败');
      }
    });
  }

  public addPushTask(item: DrinkWarnParam): Promise<boolean> {

    if (this.type === TargetReminderAgentHelper.TYPE_ALARM_CLOCK) {
      return this.startPushByAlarmClock(item)
    } else {
      //本地默认成功
      return Promise.resolve(true);
    }
  }

  public async startPushReminder() {
    if (this.type === TargetReminderAgentHelper.TYPE_ALARM_CLOCK) {
      const drinkTimeList = DrinkWarnViewModel.getInstance().getWarnTimes()
      drinkTimeList.forEach(async (item) => {
        if (item.isOpen) {
          await this.addPushTask(item)
        }
      })

      DrinkWarnViewModel.getInstance().setWarnTimes()

    } else {
      this.startPushByNotice()
    }
  }

  public async startPushByAlarmClock(item: DrinkWarnParam) {

    const hour: number = parseInt(item.time.split(':')[0])
    const minute: number = parseInt(item.time.split(':')[1])

    let targetReminderAgent: reminderAgentManager.ReminderRequestAlarm = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM, // 提醒类型为闹钟类型
      hour: hour, // 指明提醒的目标时刻
      minute: minute, // 指明提醒的目标分钟
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
      actionButton: [// 设置弹出的提醒通知信息上显示的按钮类型和标题
        {
          title: '关闭',
          type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
        }
      ],
      wantAgent: {
        // 点击提醒通知后跳转的目标UIAbility信息
        pkgName: (getContext() as common.UIAbilityContext).abilityInfo.bundleName,
        abilityName: 'EntryAbility'
      },
      ringDuration: 5, // 指明响铃时长（单位：秒）
      snoozeTimes: 2, // 指明延迟提醒次数
      timeInterval: 5 * 60, // 执行延迟提醒间隔（单位：秒）
      title: '喝水提醒', // 指明提醒标题
      content: item.prompt || '提醒您喝水啦', // 指明提醒内容
      notificationId: item.id, // 指明提醒使用的通知的ID号，相同ID号的提醒会覆盖
      // 指明提醒的Slot类型
      slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
    }

    return reminderAgentManager.publishReminder(targetReminderAgent)
      .then((res: number) => {
        hilog.info(0x0000, 'testTag', '闹钟发布成功');
        item.reminderId = res;
        return Promise.resolve(true);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', '闹钟发布失败' + err.message);
        return Promise.resolve(false);
      });
  }

  /**
   * 停止定时器
   */
  public stopPushNotice() {
    clearInterval(this.intervalId)
  }

  /**
   * 切换提醒类型
   * @param type 提醒类型
   */
  public async switchType(type: string) {
    hilog.info(0x0000, 'testTag', '提醒方式切换：' + type);
    // 公共操作提取
    const updateStoreAndStart = () => {
      this.type = type;
      this.store.put('drink_warn_type', type);
      this.startPushReminder();
    };

    if (type === TargetReminderAgentHelper.TYPE_NOTICE) {
      reminderAgentManager.cancelAllReminders().then(() => {
        hilog.info(0x0000, 'testTag', '闹钟批量取消成功');
        updateStoreAndStart();
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', '闹钟批量取消失败' + err.message);
      });
      return
    } else {
      this.stopPushNotice();
      updateStoreAndStart();
    }
  }

  public async cancelPushTask(item: DrinkWarnParam): Promise<boolean> {

    if (this.type === TargetReminderAgentHelper.TYPE_ALARM_CLOCK) {
      return reminderAgentManager.cancelReminder(item.reminderId)
        .then(() => {
          hilog.info(0x0000, 'testTag', '闹钟取消成功');
          return Promise.resolve(true);
        })
        .catch(() => {
          hilog.info(0x0000, 'testTag', '闹钟取消失败');
          return Promise.resolve(false);
        });
    } else {
      //本地不更新
      return Promise.resolve(true);
    }
  }

  public getWarnTimes(): DrinkWarnParam[] {
    return this.store.get('drink_warn_data', []) as DrinkWarnParam[]
  }

  private startPushByNotice() {
    // 喝水通知提醒
    const drinkNotice = (text: string) => {

      // publish回调
      let publishCallback = (err: BusinessError): void => {
        if (err) {
          // 通知发布失败
          hilog.info(0x0000, 'testTag', '通知发布失败');
        } else {
          // 通知发布成功
          hilog.info(0x0000, 'testTag', '通知发布成功');
        }
      }

      // 拉取权限
      let requestEnableNotification = (): void => {
        // 通知Request对象
        let notificationRequest: notificationManager.NotificationRequest = {
          id: 1,
          content: {
            notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT, // 基础文字内容
            normal: {
              title: '喝水提醒',
              text: text,
            }
          },
          notificationSlotType: notificationManager.SlotType.SERVICE_INFORMATION // 通知类提醒
        };

        // 推送消息
        try {
          notificationManager.publish(notificationRequest, publishCallback);
        } catch (error) {
          hilog.info(0x0000, 'testTag', 'publish error');
        }
      };

      requestEnableNotification()
    }

    // 查询是否需要提醒喝水
    const checkDrink = () => {
      const drinkTimeList = this.getWarnTimes()
      drinkTimeList.forEach((item) => {
        if (item.isOpen) {
          const timeStart: string = DrinkVM.dateToStr(new Date()) + ' ' + item.time + ':00'
          const timeEnd: string = DrinkVM.dateToStr(new Date()) + ' ' + item.time + ':59'
          const startTime: number = new Date(timeStart).getTime()
          const endTime: number = new Date(timeEnd).getTime()
          const currentTime: number = new Date().getTime()
          if ((startTime <= currentTime) && (currentTime <= endTime)) {
            drinkNotice(item.prompt || '提醒您喝水啦')
          }
        }
      })
    }

    checkDrink()
    this.intervalId = setInterval(() => {
      checkDrink()
    }, 60000)
  }
}