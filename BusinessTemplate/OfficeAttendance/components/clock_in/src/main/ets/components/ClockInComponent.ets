import { Animator as animator, AnimatorResult } from '@kit.ArkUI';
import { CheckInChannelUtil } from '../util/CheckInChannelUtil';
import { ServiceCardNotificationUtil } from '../util/ServiceCardNotificationUtil';
import { ClockInSettings } from './ClockInSettings'
import { VibratorUtil } from '../util/VibratorUtil'
import { LocationUtil, AddressParam } from '../util/LocationUtil'
import { FormatUtil } from '../util/FormatUtil'
import { ClockInStatus } from '../types/ClockInEnums'
import { DataManager } from '../controller/DataManagerController';

@ComponentV2
export struct ClockInComponent {
  private circleAnimator: AnimatorResult | undefined = this.create()

  create(): AnimatorResult {
    const circleAnimator = animator.create({
      // 建议使用 this.getUIContext.createAnimator()接口
      duration: 1000,
      easing: 'ease-in-out',
      delay: 0,
      fill: 'backwards',
      direction: 'alternate',
      iterations: -1,
      begin: 1,
      end: 1.05
    })
    circleAnimator.onFrame = (value: number) => {
      this.scaleX = value;
      this.scaleY = value;
    }
    return circleAnimator;
  }

  @Param onSuccess: (address:AddressParam) => void = () => {
  };
  @Param onFailed: () => void = () => {
  };
  @Local clockInStatus: ClockInStatus = ClockInStatus.NOT_STARTED;
  @Local max: number = 170;
  @Local min: number = 160;
  @Local scaleX: number = 1;
  @Local scaleY: number = 1;
  @Local displayAddition: boolean = false;
  @Local timerId: number = 0;
  @Local location: string | undefined = undefined;
  @Local time: string = FormatUtil.formatTime(new Date());
  @Local showSetting: boolean = false;
  @Require @Param latitude: number;
  @Require @Param longitude: number;
  @Require @Param distance: number; // 单位米
  @Consumer() isPageShow: boolean = false;
  @Monitor('isPageShow')
  tryCheckInAutomatically() {
    if (this.isPageShow) { // 是否需要增加当前所处tab index的判断待定
      if (CheckInChannelUtil.fromServiceCard()) {
        this.checkin();
        CheckInChannelUtil.reset();
      } else {
        const isQuickCheck = DataManager.isQuickCheckIn()
        if (isQuickCheck) {
          this.checkin();
        }
      }
    }
  }

  // 快捷打卡
  tryWhenTabChanged() {
    const isQuickCheck = DataManager.isQuickCheckIn();
    if (isQuickCheck) {
      this.checkin();
    }
  }

  aboutToAppear() {
    this.timerId = setInterval(() => {
      this.time = FormatUtil.formatTime(new Date());
    }, 1000);
  }

  aboutToDisappear(): void {
    clearInterval(this.timerId); // 页面退出时，取消定时器
  }

  @Builder
  clockSetting() {
    ClockInSettings()
  }

  build() {
    Scroll() {
      Stack() {
        Column() {
          Stack() {
            Shape() {
              this.circleBuilder(this.max, 0.1)
              this.circleBuilder(this.min, 1.0)
            }.align(Alignment.Center).width(180).height(180)

            this.checkInBuilder($r('app.media.click'), $r('app.string.checkin_tip'), ClockInStatus.NOT_STARTED)
            this.checkInBuilder($r('app.media.ticking'), $r('app.string.checkin_is_finished'), ClockInStatus.FINISHED)
            this.checkInStatusTipBuilder($r('app.string.checkin_is_on_going'), ClockInStatus.ON_GOING)
            this.checkInStatusTipBuilder($r('app.string.checkin_is_failed'), ClockInStatus.FAILED)
          }.align(Alignment.Top)
          .onClick(async () => {
            this.checkin();
          }).margin({ top: 76 })

          this.additionBuilder()
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.SpaceBetween)


        Stack() {
          Circle()
            .shadow({
              radius: vp2px(8),
              offsetX: 0,
              offsetY: vp2px(2),
              color: 'rgba(0,0,0,0.08)'
            })
            .borderRadius('50%')
            .height(40)
            .width(40)
            .fill(Color.White)
          Image($r('app.media.settings')).height(24).width(24)
        }
        .height(40)
        .width(40)
        .margin({ right: 16, bottom: 24 })
        .alignContent(Alignment.Center)
        .backgroundColor(Color.Transparent)
        .bindSheet(this.showSetting, this.clockSetting, {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 0],
          backgroundColor: $r('app.string.white_90'),
          blurStyle: BlurStyle.Thick,
          title:{title:'设置'},
          onDisappear: () => {
            this.showSetting = !this.showSetting;
          }
        })
        .onClick(() => {
          this.showSetting = true;
        })
      }.height('100%')
      .width('100%').alignContent(Alignment.BottomEnd)
    }.scrollBar(BarState.Off)
  }

  @Builder
  circleBuilder(size: number, opacity: number) {
    Circle()
      .width(size)
      .height(size)
      .scale({ x: this.scaleX, y: this.scaleY })
      .fillOpacity(opacity)
      .fill($r('app.color.checkin_background'))
      .renderFit(RenderFit.CENTER)
  }

  @Builder
  checkInBuilder(image: Resource, text: Resource, checkInStatus: ClockInStatus) {
    Column() {
      Image(image)
        .width(64)
        .height(64)
        .margin({ top: 32 })
        .opacity(this.clockInStatus === checkInStatus ? 1 : 0)
      Text(text)
        .width(72)
        .height(24)
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 8 })
        .opacity(this.clockInStatus === checkInStatus ? 1 : 0)
    }.height(160)
  }

  @Builder
  checkInStatusTipBuilder(text: Resource, checkInStatus: ClockInStatus) {
    Text(text)
      .fontSize(24)
      .fontColor(Color.White)
      .fontWeight(FontWeight.Bolder)
      .opacity(this.clockInStatus === checkInStatus ? 1 : 0)
      .scale({ x: this.scaleX, y: this.scaleY })
      .height(180)
      .renderFit(RenderFit.CENTER)
  }

  @Builder
  additionBuilder() {
    if (this.displayAddition) {
      Column() {
        Text(this.location).fontSize(14).fontColor(Color.Black).margin({ bottom: 16 })

        Divider()
          .vertical(true)
          .strokeWidth(1)
          .color($r('app.color.checkin_background'))
          .height(20);
        Circle()
          .width(5)
          .height(5)
          .stroke($r('app.color.checkin_background'))
          .fill(Color.White);

        Text(this.time).fontSize(26).margin({ top: 16, bottom: 16 })

        Circle()
          .width(5)
          .height(5)
          .stroke($r('app.color.checkin_background'))
          .fill(Color.White);
        Divider()
          .vertical(true)
          .strokeWidth(1)
          .color($r('app.color.checkin_background'))
          .height(20);
      }.margin({ bottom: 28 })
    }
  }

  addCheckInDetail(address: AddressParam) {
    const today: Date = new Date();
    DataManager.addCheckInDetail({
      'day': FormatUtil.formatDate(today),
      'dayOfWeek': today.getDay(),
      'location': address.addressName as string,
      'time': FormatUtil.formatTime(today),
      'latitude': address.latitude,
      'longitude': address.longitude
    });
  }

  checkin() {
    if (this.clockInStatus !== ClockInStatus.NOT_STARTED) {
      return;
    }
    this.circleAnimator?.play();
    this.clockInStatus = ClockInStatus.ON_GOING;
    this.displayAddition = false;
    VibratorUtil.notification(500, 0);

    const id = setTimeout(() => {
      this.clockInStatus = ClockInStatus.FAILED;
      this.finishAnimator();
      this.resetCheckInStatusLater();
    }, 8000) // 5秒未获取到位置，打卡失败

    LocationUtil.getLocationName().then((address: AddressParam) => {
      this.finishAnimator();
      clearInterval(id);
      if (this.clockInStatus === ClockInStatus.FAILED || this.clockInStatus === ClockInStatus.NOT_STARTED) {
        return; //如果已经打卡超时，不再处理
      }



      if (address.addressName) {
        const distance = LocationUtil.calculateDistance(
          this.latitude, this.longitude, address.latitude,address.longitude)
        if (distance > this.distance) {
          this.clockInStatus = ClockInStatus.FAILED;
          this.resetCheckInStatusLater();
          ServiceCardNotificationUtil.notify(this.clockInStatus);
          this.getUIContext().getPromptAction().showToast({
            duration:1500,
            message: '不在打卡范围内'
          })
          this.onFailed();
          return ;
        }
        this.location = address.addressName;
        this.clockInStatus = ClockInStatus.FINISHED;
        this.displayAddition = true;
        this.addCheckInDetail(address)
        this.onSuccess(address);
      } else {
        this.onFailed();
        this.clockInStatus = ClockInStatus.FAILED;
      }
      this.resetCheckInStatusLater();
      ServiceCardNotificationUtil.notify(this.clockInStatus);
    });
  }

  private finishAnimator() {
    this.circleAnimator?.finish();
    this.scaleX = 1;
    this.scaleY = 1;
  }

  private resetCheckInStatusLater() {
    setTimeout(() => {
      this.clockInStatus = ClockInStatus.NOT_STARTED;
      ServiceCardNotificationUtil.notify(this.clockInStatus);
    }, 1500);
  }
}