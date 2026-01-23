import { HomePage } from '@ohos_agcit/children_education_homepage';
import { MinePage } from '@ohos_agcit/children_education_minepage';
import {
  AudioPlayPage,
  AuthUtil,
  BreakpointType,
  CommonConstants,
  DateConstants,
  DateUtil,
  GlobalContext,
  GlobalInfoModel,
  ObjectUtil,
  PushActionParams,
  PushUtils,
  StringUtil,
  VideoPlayPage
} from '@ohos_agcit/children_education_utils';
import { emitter } from '@kit.BasicServicesKit';
import { History, UsedLimit, User, VipRecord } from '@ohos_agcit/children_education_datasource';
import { AppStorageV2, CustomContentDialog, PersistenceV2 } from '@kit.ArkUI';
import { ArrayList } from '@kit.ArkTS';
import { userAuth } from '@kit.UserAuthenticationKit';
import { AuthOptions } from '@ohos_agcit/children_education_utils/src/main/ets/model/AuthOptions';
import { notificationManager } from '@kit.NotificationKit';


@Entry
@ComponentV2
struct Index {
  private tabsController: TabsController = new TabsController();
  private timerID: number = -1;
  @Provider(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Provider(CommonConstants.USER_INFO) user: User = PersistenceV2.connect(User, () => new User())!;
  @Provider(CommonConstants.VIP_RECORD) vipRecord: VipRecord = PersistenceV2.connect(VipRecord, () => new VipRecord())!;
  @Local currentIndex: number = 0;
  @Local usedLimit: UsedLimit = PersistenceV2.connect(UsedLimit, () => new UsedLimit())!;
  @Local dialogOpen: boolean = false;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
  @Local isVertical: boolean = new BreakpointType<boolean>({
    sm: false,
    md: false,
    lg: true,
  }).getValue(this.globalInfo.currentBreakpoint)

  /**
   * 监听断点变化
   */
  @Monitor('globalInfo.currentBreakpoint')
  onBreakPointChange() {
    this.isVertical = new BreakpointType<boolean>({
      sm: false,
      md: false,
      lg: true,
    }).getValue(this.globalInfo.currentBreakpoint)
  }

  sendPushMessage() {
    let pushArticle:PushActionParams = {
      picVideoUrl: '',
      title: '儿童教育模板',
      id: '461323198429547557'
    }
    PushUtils.randomPushMessage(pushArticle, this.getUIContext().getHostContext() as Context)
  }

  sendPushNotice() {
    try {
      const isOn = notificationManager.isNotificationEnabledSync();
      if (isOn) {
        this.sendPushMessage();
      }
    } catch (error) {
    }
  }

  aboutToAppear(): void {
    this.sendPushMessage()
    emitter.on(CommonConstants.VIP_RECORD, (eventData: emitter.EventData) => {
      console.log('receive change vip message data: ' + eventData?.data?.isVip);
      this.vipRecord.isVip = eventData?.data?.isVip;
      this.vipRecord.validTime = eventData?.data?.validTime;
      PersistenceV2.save(VipRecord);
    });

    emitter.on(CommonConstants.TIME_CONTROL, (eventData: emitter.EventData) => {
      this.vipRecord.timeLimit = eventData?.data?.timeLimit;
      this.vipRecord.lunchTimeState = eventData?.data?.lunchTimeState;
      this.vipRecord.nightTimeState = eventData?.data?.nightTimeState;
      this.vipRecord.lunchStartTime = eventData?.data?.lunchStartTime;
      this.vipRecord.lunchEndTime = eventData?.data?.lunchEndTime;
      this.vipRecord.nightStartTime = eventData?.data?.nightStartTime;
      this.vipRecord.nightEndTime = eventData?.data?.nightEndTime;
      PersistenceV2.save(VipRecord);
    });
    emitter.on(CommonConstants.USER_INFO, (eventData: emitter.EventData) => {
      if (ObjectUtil.isNotNull(eventData?.data?.isLogin)) {
        this.user.isLogin = eventData?.data?.isLogin;
      }
      if (StringUtil.isNotEmpty(eventData?.data?.userName)) {
        this.user.userName = eventData?.data?.userName;
      }
      if (StringUtil.isNotEmpty(eventData?.data?.fullName)) {
        this.user.fullName = eventData?.data?.fullName;
      }
      if (ObjectUtil.isNotNull(eventData?.data?.userAvatar)) {
        this.user.userAvatar = eventData?.data?.userAvatar;
      }
      if (ObjectUtil.isNotNull(eventData?.data?.gender)) {
        this.user.gender = eventData?.data?.gender;
      }
      if (StringUtil.isNotEmpty(eventData?.data?.phone)) {
        this.user.phone = eventData?.data?.phone;
      }
      if (StringUtil.isNotEmpty(eventData?.data?.birthDate)) {
        this.user.birthDate = eventData?.data?.birthDate;
      }
      if (StringUtil.isNotEmpty(eventData?.data?.introDesc)) {
        this.user.introDesc = eventData?.data?.introDesc;
      }
      PersistenceV2.save(User);
    })

    this.appPathStack.pushPathByName('AdPage', undefined);
  }

  onPageShow(): void {
    console.log('enter onPageShow');
    this.timeChecked();
    this.initAppData();

    this.timerID = setInterval(() => {
      console.log('start to execute the scheduled task');
      this.recordUsedTime();
    }, 60 * 1000); // 60秒触发一次
  }

  /**
   * 时长检查，判断是否超时
   * 如果是新的一天，使用时长重置
   * 如果是当天，判断使用时长是否超出限制
   */
  timeChecked() {
    let today = Number(DateUtil.getTodayStr(DateConstants.DATE_FORMAT18));
    if (this.usedLimit.date !== today) {
      this.usedLimit.date = today;
      this.usedLimit.usedDuration = 0;
      PersistenceV2.save(UsedLimit);
    } else {
      // 已经超出使用时长
      if (this.usedLimit.isTimeOut === true) {
        if (!this.dialogOpen) {
          this.dialogOpen = true;
          this.dialogController.open();
        }
      }
    }
  }

  /**
   * 初始化数据
   */
  initAppData() {
    GlobalContext.getContext().setObject(CommonConstants.LUNCH_TIME_STATE, this.vipRecord.lunchTimeState);
    GlobalContext.getContext().setObject(CommonConstants.NIGHT_TIME_STATE, this.vipRecord.nightTimeState);
    GlobalContext.getContext().setObject(CommonConstants.LUNCH_START_TIME, this.vipRecord.lunchStartTime);
    GlobalContext.getContext().setObject(CommonConstants.LUNCH_END_TIME, this.vipRecord.lunchEndTime);
    GlobalContext.getContext().setObject(CommonConstants.NIGHT_START_TIME, this.vipRecord.nightStartTime);
    GlobalContext.getContext().setObject(CommonConstants.NIGHT_END_TIME, this.vipRecord.nightEndTime);
    if (this.vipRecord.timeLimit === 1440) {
      GlobalContext.getContext().setObject(CommonConstants.TIME_LIMIT, CommonConstants.NO_LIMIT);
    } else if (this.vipRecord.timeLimit >= 60) {
      GlobalContext.getContext()
        .setObject(CommonConstants.TIME_LIMIT, this.vipRecord.timeLimit / 60 + CommonConstants.HOUR);
    } else {
      GlobalContext.getContext()
        .setObject(CommonConstants.TIME_LIMIT, this.vipRecord.timeLimit + CommonConstants.MINUTE);
    }
    GlobalContext.getContext().setObject(CommonConstants.HISTORY_LIST, new ArrayList<History>());
  }

  /**
   * 时长记录
   */
  recordUsedTime() {
    this.usedLimit.usedDuration++;
    if (this.usedLimit.usedDuration >= this.vipRecord.timeLimit) {
      this.usedLimit.isTimeOut = true;
      PersistenceV2.save(UsedLimit);
      if (!this.dialogOpen) {
        this.dialogOpen = true;
        this.dialogController.open();
      }
    }
    PersistenceV2.save(UsedLimit);
  }

  onPageHide() {
    if (this.timerID !== -1) {
      clearInterval(this.timerID);
      this.timerID = -1;
    }
  }

  @Builder
  pageMap(name: string) {
    if (name === CommonConstants.VIDEO_PLAY_PAGE) {
      VideoPlayPage();
    }
    if (name === CommonConstants.AUDIO_PLAY_PAGE) {
      AudioPlayPage();
    }
  }

  @Builder
  tabBuilder(title: Resource, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedImg : normalImg)
        .width(24)
        .height(24);

      Text(title)
        .margin({ top: 4 })
        .fontSize(10)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentIndex === index ? $r('sys.color.black') : Color.Gray);
    }
    .justifyContent(FlexAlign.Center)
    .height(52)
    .width(CommonConstants.FULL_PERCENT)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    });
  }

  build() {
    Navigation(this.appPathStack) {
      Column() {
        Tabs({
          barPosition: this.isVertical ? BarPosition.Start : BarPosition.End,
          controller: this.tabsController,
        }) {
          TabContent() {
            HomePage();
          }
          .tabBar(this.tabBuilder($r('app.string.home_page'), 0, $r('app.media.ic_tab_homepage_on'),
            $r('app.media.ic_tab_homepage_off')));

          TabContent() {
            MinePage();
          }
          .tabBar(this.tabBuilder($r('app.string.mine_page'), 1, $r('app.media.ic_tab_mine_on'),
            $r('app.media.ic_tab_mine_off')));
        }
        .clip(false)
        .layoutWeight(1)
        .scrollable(false)
        .width(CommonConstants.FULL_PERCENT)
        .barHeight(this.isVertical ? '60%' : 52)
        .barWidth(this.isVertical ? 52 : '100%')
        .barMode(BarMode.Fixed)
        .onAnimationStart((index: number, targetIndex: number) => {
          this.currentIndex = targetIndex;
        })
        .vertical(this.isVertical)
      };
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.pageMap);
  }

  @Builder
  buildContent(): void {
    Column() {
      Text($r('app.string.Used_Duration'));
    }
    .width(CommonConstants.FULL_PERCENT);
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '温馨提示',
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: '时长控制',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            const options: AuthOptions = new AuthOptions();
            options.showTip = true
            options.uiContext = this.getUIContext()

            AuthUtil.onStartEasy(options, (result: userAuth.UserAuthResult) => {
              if (result.result === 12500000) {
                this.dialogOpen = false;
                this.usedLimit.isTimeOut = false;
                PersistenceV2.save(UsedLimit);
                this.appPathStack.pushPathByName('TimeCtrl', undefined);
              } else if (result.result === 12500010) {
                this.dialogOpen = false;
                this.usedLimit.isTimeOut = false;
                PersistenceV2.save(UsedLimit);
                this.dialogRemindController.open();
                this.appPathStack.pushPathByName('TimeCtrl', undefined);
              } else {
                this.dialogOpen = true;
                this.dialogController.open();
              }
            });
          },
        },
        {
          value: '退出应用',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR,
          action: () => {
            // 终止应用的所有进程，进程退出时不会正常走完应用生命周期。使用Promise异步回调。仅支持主线程调用。
            let applicationContext = this.getUIContext().getHostContext()!.getApplicationContext();
            applicationContext.killAllProcesses();
          },
        },
      ],
    }),
    autoCancel: false,
    cancel: () => (this.dialogController.open()),
  });
  dialogRemindController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '温馨提示',
      contentBuilder: () => {
        this.buildRemindContent();
      },
      buttons: [
        {
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR,
          value: '确定',
          action: () => {
          },
        },
      ],
    }),
    autoCancel: false,
  });

  @Builder
  buildRemindContent(): void {
    Column() {
      Text('您的手机还未录入指纹、人脸识别、锁屏密码中的一种，建议前往 设置-生物识别和密码 进行添加');
    }
    .width(CommonConstants.FULL_PERCENT);
  }
}