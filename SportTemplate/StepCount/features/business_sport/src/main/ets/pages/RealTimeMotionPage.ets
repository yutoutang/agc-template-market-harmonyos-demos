import { mapCommon } from '@kit.MapKit';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { CommonConstants, EventEnum, EventHubUtils, RouterMap, RouterUtils, RunningVoiceSetting } from 'lib_common';
import { runState, TrackMap } from 'module_trajectory';
import {
  ChildSportType,
  ControlType,
  MoveState,
  RealTimeMotionMain,
  RealTimeMotionVM,
  SportItem,
  SportItemTarget,
  SportType,
  TargetType
} from 'module_running';

@Builder
export function RealTimeMotionPageBuilder() {
  RealTimeMotionPage()
}

/**
 * 实时运动页面
 */
@ComponentV2
export struct RealTimeMotionPage {
  @Local countDownBg: ResourceStr = $r('app.media.ic_walking_bg')
  @Local stack: NavPathStack = new NavPathStack();
  timer: number = -1
  @Local showCountDown: boolean = true;
  @Local countDown: number = 3;
  @Provider('isRun') isRun: runState = runState.Stop;
  @Provider('runningControlLock') runningControlLock: boolean = false;
  @Provider('realTimeMotionVM') realTimeMotionVM?: RealTimeMotionVM
  @Provider('bindSheetShow') bindSheetShow: boolean = false;
  @Provider('moveType') moveType: SportType = SportType.WALKING
  @Provider('motionType') motionType: string = ''
  @Provider('currentClickControlType') currentClickControlType: ControlType = ControlType.Start;
  @Local locusPoints: mapCommon.LatLng[] = []
  @Local target: TargetType = TargetType.DISTANCE
  @Local params: string = ''
  @Local hour: number = 0
  @Local minute: number = 0
  @Provider() runningVoiceSetting: RunningVoiceSetting =
    AppStorageV2.connect(RunningVoiceSetting, 'runningVoiceSetting', () => new RunningVoiceSetting())!;

  aboutToAppear(): void {
    this.initData()
    this.countDownHandler()
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
    this.realTimeMotionVM!.distanceMap = new Map()
    EventHubUtils.getInstance().off(EventEnum.PAGE_DIALOG_EVENT)
  }

  build() {
    NavDestination() {
      Column() {
        RealTimeMotionMain() {
          TrackMap({
            isRun: this.isRun,
            isTrack: true,
            locusPoints: this.locusPoints,
            allDistance: this.realTimeMotionVM?.distance,
            reportedDistance: (distance: number) => {
              this.realTimeMotionVM?.addDistance(distance)
            },
            trackInfo: (isStandards: boolean, points?: mapCommon.LatLng[]) => {
              if (!isStandards) {
                this.stack.pop()
                return
              }
              let motionSubtype: ChildSportType = this.realTimeMotionVM?.getChildSport() ?? ChildSportType.FREE_WALKING
              let sportItemTarget: SportItemTarget | undefined
              if (this.target) {
                let value: number = this.realTimeMotionVM?.parameterTransition() ?? 0
                sportItemTarget = {
                  targetType: this.target,
                  value: value
                }
              }
              let returnParameters: SportItem = {
                //运动类型
                type: this.moveType,
                //运动子类型
                childType: motionSubtype,
                //开始时间
                hour: this.hour,
                //开始时间
                minute: this.minute,
                //运动距离 单位米
                distance: this.realTimeMotionVM?.distance ?? 0,
                //运动时长 单位秒
                timeLength: this.realTimeMotionVM?.duration ?? 0,
                //单次运动目标
                target: sportItemTarget,
                //运动消耗 单位 卡
                deplete: this.realTimeMotionVM?.heat ?? 0,
                //步数（跑步，步行）
                stepCount: this.realTimeMotionVM?.steps ?? 0,
                //轨迹点
                locusPoints: points
              }
              this.stack.pop(returnParameters)
            }
          })
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .overlay(this.showCountDown ? this.CountDownBuilder() : undefined)
    }
    .hideTitleBar(true)
    .onWillDisappear(() => {
      this.bindSheetShow = false
    })
    .onBackPressed(() => {
      this.backPressedHandler()
      return false
    })
    .onReady((context) => {
      this.stack = context.pathStack;
    })
  }

  // 返回处理
  backPressedHandler() {
    if (this.runningControlLock) {
      promptAction.showToast({ message: $r('app.string.running_back_pressed_lock') })
      return
    }
    if (this.currentClickControlType === ControlType.Start) {
      promptAction.showToast({ message: $r('app.string.running_back_pressed_start') })
    }
    if (this.currentClickControlType === ControlType.Pause) {
      promptAction.showToast({ message: $r('app.string.running_back_pressed_end') })
    }
  }

  initData() {
    let param: ESObject = RouterUtils.getParamByName(RouterMap.REAL_TIME_MOTION_PAGE) as ESObject
    this.moveType = param.sportType as SportType
    this.target = param.target
    this.params = param.params
    this.motionType = param.motionType
    this.locusPoints = param.locusPoints ?? []
    this.realTimeMotionVM = new RealTimeMotionVM(this.moveType, this.target, this.params, this.motionType)
    this.realTimeMotionVM!.distanceMap = new Map();
  }

  countDownHandler(): void {
    this.timer = setInterval(() => {
      this.countDown--;
      if (this.countDown <= 0) {
        clearInterval(this.timer);
        this.showCountDown = false;
        this.bindSheetShow = true;
        this.isRun = runState.Start;
        this.realTimeMotionVM!.move = MoveState.startMove
        this.hour = new Date().getHours()
        this.minute = new Date().getMinutes()
      }
    }, 1000)
  }

  @Builder
  CountDownBuilder() {
    Column() {
      Text(this.countDown + '')
        .fontSize(200)
        .fontStyle(FontStyle.Italic)
        .fontColor('#ffffffff')
    }
    .backgroundImage(this.countDownBg)
    .backgroundImageSize(ImageSize.Cover)
    .justifyContent(FlexAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}