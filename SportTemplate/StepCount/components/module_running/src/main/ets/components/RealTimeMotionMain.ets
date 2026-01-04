import { map, mapCommon } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { RealTimeMotionComponent } from '../components/RealTimeMotionComponent';
import { promptAction } from '@kit.ArkUI';
import { RunningConstants } from '../common/RunningConstants';
import { ControlType, RunningVoiceModel, RunState } from '../models/RealTimeMotionModel';
import { MotionType, MoveState, RealTimeMotionVM, SportType } from '../viewmodels/RealTimeMotionVM';
import { DailyRunningVoiceSetting } from '../models/DailyStorageModel';
import { CommonPageDialog } from '../common/CommonPageDialog';
import { RunEventEnum } from '../common/RunEventEnum';
import { RunEventHubUtils } from '../utils/RunEventHubUtils';
import { RunStrUtil } from '../utils/RunStrUtil';
import { RunBroadCastUtils } from '../utils/RunBroadcastUtils';
import { NavHeaderBar } from './NavHeaderBar';
import { RunCommonConstants } from '../common/RunCommonConstants';

/**
 * 实时运动页面
 */
@ComponentV2
export struct RealTimeMotionMain {
  @BuilderParam mainBuilder: () => void
  @Consumer('titleShow') titleShow: boolean = true
  @Consumer('isRun') isRun: RunState = RunState.Stop;
  @Local mapController?: map.MapComponentController
  timer: number = -1
  mapOption?: mapCommon.MapOptions;
  callback?: AsyncCallback<map.MapComponentController>;
  @Consumer('bindSheetShow') bindSheetShow: boolean = false;
  @Local bindSheetHeight: [
    (SheetSize | Length),
    (SheetSize | Length)?,
    (SheetSize | Length)?
  ] = [RunningConstants.BIND_SHEET_MAX, RunningConstants.BIND_SHEET_MIN]
  @Consumer('runningControlLock') runningControlLock: boolean = false;
  @Consumer('realTimeMotionVM') realTimeMotionVM?: RealTimeMotionVM
  @Consumer('currentClickControlType') currentClickControlType: ControlType = ControlType.Start;
  @Consumer() runningVoiceSetting: DailyRunningVoiceSetting = new DailyRunningVoiceSetting();
  voiceRange: number[] = [30, 50, 80, 100]; // 语音播报范围
  runningVoiceModel: RunningVoiceModel[] = [
    { step: 30, finish: false },
    { step: 50, finish: false },
    { step: 80, finish: false },
    { step: 100, finish: false }
  ]
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CommonPageDialog({
      buildContent: () => {
        this.SettingVoiceBuilder()
      },
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        RunEventHubUtils.getInstance().emit(RunEventEnum.PAGE_DIALOG_EVENT)
      }
    },
    customStyle: true,
  })
  @Local voiceSwitch: boolean = false
  @Consumer('moveType') moveType: SportType = SportType.WALKING
  @Consumer('motionType') motionType: string = ''

  // 监控进度
  @Monitor('realTimeMotionVM.progressValue')
  progressValueMonitor() {
    if (RunStrUtil.isBlank(this.realTimeMotionVM?.progressValue)) {
      return
    }
    let progressValue: number = Number(this.realTimeMotionVM?.progressValue)
    // 播报进度
    if (this.getRunningVoiceSetting() && progressValue > 10) {
      for (let i = 0; i < this.runningVoiceModel.length; i++) {
        if (progressValue >= this.runningVoiceModel[i].step && !this.runningVoiceModel[i].finish) {
          this.runningVoiceModel[i].finish = true
          // 特殊处理100%的播报
          if (this.runningVoiceModel[i].step === 100) {
            RunBroadCastUtils.speak('已完成目标')
          } else {
            RunBroadCastUtils.speak(`已完成目标的${this.runningVoiceModel[i].step}`)
          }
          break
        }
      }
    }
  }

  // 监控状态
  @Monitor('realTimeMotionVM.move')
  moveMonitor() {
    if (this.realTimeMotionVM?.move === MoveState.stopMove) {
      this.isRun = RunState.Stop
    }
  }

  aboutToAppear(): void {
    // 调整bindSheet高度
    if (this.motionType === MotionType.walkDog) {
      this.bindSheetHeight = [RunningConstants.BIND_SHEET_MID, RunningConstants.BIND_SHEET_MIN]
    } else if (this.motionType !== MotionType.target) {
      this.bindSheetHeight = [RunningConstants.BIND_SHEET_MID_L, RunningConstants.BIND_SHEET_MIN]
    }
    this.mapInit()
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
    this.realTimeMotionVM!.distanceMap = new Map()
    RunEventHubUtils.getInstance().off(RunEventEnum.PAGE_DIALOG_EVENT)
  }

  // 修改语音播报
  setRunningVoiceSetting(val: boolean) {
    switch (this.moveType) {
      case SportType.WALKING:
        this.runningVoiceSetting.walkVoiceOn = val
        if (this.motionType === MotionType.isFreedom) {
          this.runningVoiceSetting.walkFreeVoiceOn = val
        }
        if (this.motionType === MotionType.target) {
          this.runningVoiceSetting.walkTargetVoiceOn = val
        }
        if (this.motionType === MotionType.walkDog) {
          this.runningVoiceSetting.walkDogVoiceOn = val
        }
        break;
      case SportType.JOGGING:
        this.runningVoiceSetting.joggingVoiceOn = val
        if (this.motionType === MotionType.isFreedom) {
          this.runningVoiceSetting.joggingFreeVoiceOn = val
        }
        if (this.motionType === MotionType.target) {
          this.runningVoiceSetting.joggingTargetVoiceOn = val
        }
        break;
      case SportType.CYCLING:
        this.runningVoiceSetting.cyclingVoiceOn = val
        if (this.motionType === MotionType.isFreedom) {
          this.runningVoiceSetting.cyclingFreeVoiceOn = val
        }
        if (this.motionType === MotionType.target) {
          this.runningVoiceSetting.cyclingTargetVoiceOn = val
        }
        break;
      case SportType.CLOCK_BASE_EXCERCISE:
        this.runningVoiceSetting.clockBaseVoiceOn = val
        break;

      default:
        break;
    }
  }

  // 语音播报
  getRunningVoiceSetting() {
    let val = false
    switch (this.moveType) {
      case SportType.WALKING:
        val = this.runningVoiceSetting.walkVoiceOn
        if (this.motionType === MotionType.isFreedom) {
          val = this.runningVoiceSetting.walkFreeVoiceOn
        }
        if (this.motionType === MotionType.target) {
          val = this.runningVoiceSetting.walkTargetVoiceOn
        }
        if (this.motionType === MotionType.walkDog) {
          val = this.runningVoiceSetting.walkDogVoiceOn
        }
        break;
      case SportType.JOGGING:
        val = this.runningVoiceSetting.joggingVoiceOn
        if (this.motionType === MotionType.isFreedom) {
          val = this.runningVoiceSetting.joggingFreeVoiceOn
        }
        if (this.motionType === MotionType.target) {
          val = this.runningVoiceSetting.joggingTargetVoiceOn
        }
        break;
      case SportType.CYCLING:
        val = this.runningVoiceSetting.cyclingVoiceOn
        if (this.motionType === MotionType.isFreedom) {
          val = this.runningVoiceSetting.cyclingFreeVoiceOn
        }
        if (this.motionType === MotionType.target) {
          val = this.runningVoiceSetting.cyclingTargetVoiceOn
        }
        break;
      case SportType.CLOCK_BASE_EXCERCISE:
        val = this.runningVoiceSetting.clockBaseVoiceOn
        break;

      default:
        break;
    }
    return val
  }

  // 语音设置播报
  @Builder
  SettingVoiceBuilder() {
    Column() {
      NavHeaderBar({
        title: $r('app.string.running_settings'),
        onBack: () => {
          RunEventHubUtils.getInstance().emit(RunEventEnum.PAGE_DIALOG_EVENT)
        }
      })
      Column() {
        Row() {
          Text($r('app.string.running_voice_broadcast'))
            .fontSize(16)
            .fontColor('#333333')
          Toggle({ type: ToggleType.Switch, isOn: this.voiceSwitch })
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .hitTestBehavior(HitTestMode.Block)
            .onChange((isOn: boolean) => {
              this.setRunningVoiceSetting(isOn)
              this.voiceSwitch = isOn
            })
            .height(20)
            .width(36)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(RunCommonConstants.PADDING_M)
        .borderRadius(RunCommonConstants.PADDING_M)
        .width(RunCommonConstants.FULL_PERCENT)
        .height(RunCommonConstants.BOXH_XL)
        .backgroundColor(Color.White)

        Text($r('app.string.running_settings_description'))
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 16 })
      }
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: RunCommonConstants.PADDING_PAGE,
        right: RunCommonConstants.PADDING_PAGE,
        top: RunCommonConstants.PADDING_M,
      })
    }
    .width(RunCommonConstants.FULL_PERCENT)
    .height(RunCommonConstants.FULL_PERCENT)
    .backgroundColor('#F1F3F5')
  }

  @Builder
  BindSheetDataBuilder() {
    RealTimeMotionComponent({
      moveType: this.moveType as SportType,
      motionType: this.motionType as MotionType,
      buttonClick: (controlType: ControlType) => {
        if (controlType === ControlType.Setting) {
          this.voiceSwitch = this.getRunningVoiceSetting()
          this.dialogController?.open()
        }
        if (controlType === ControlType.Start) {
          this.currentClickControlType = controlType
          this.isRun = RunState.Start
          this.realTimeMotionVM!.move = MoveState.startMove
        }
        if (controlType === ControlType.Pause) {
          this.currentClickControlType = controlType
          this.isRun = RunState.Pause
          this.realTimeMotionVM!.move = MoveState.pauseMove
        }
        if (controlType === ControlType.End) {
          this.isRun = RunState.Stop
          this.realTimeMotionVM!.move = MoveState.pauseMove
        }
      }
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
      }
      .height(RunCommonConstants.FULL_PERCENT)
      .width(RunCommonConstants.FULL_PERCENT)
      .zIndex(this.runningControlLock ? 2 : 0)

      NavHeaderBar({
        onBack: () => {
          this.backPressedHandler()
        }
      })
        .zIndex(3)
        .visibility(this.titleShow ? Visibility.Visible : Visibility.None)

      Column() {
        if (this.mainBuilder) {
          this.mainBuilder()
        }
      }
      .width(RunCommonConstants.FULL_PERCENT)
      .height(RunCommonConstants.FULL_PERCENT)
      .bindSheet(this.bindSheetShow, this.BindSheetDataBuilder(), {
        detents: this.bindSheetHeight,
        dragBar: this.runningControlLock ? false : true,
        backgroundColor: '#FFFFFF',
        showClose: false,
        enableOutsideInteractive: true,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        onDetentsDidChange: (height: number) => {
          this.realTimeMotionVM!.showAll = px2vp(height) > RunningConstants.BIND_SHEET_MIN + 100
        },
        onWillDismiss: ((dismissSheetAction: DismissSheetAction) => {
          if (dismissSheetAction.reason === DismissReason.PRESS_BACK) {
            this.bindSheetShow = true
            this.backPressedHandler()
          }
        })
      })

    }
    .width(RunCommonConstants.FULL_PERCENT)
    .height(RunCommonConstants.FULL_PERCENT)
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

  mapInit(): void {
    this.mapOption = {
      position: {
        target: {
          latitude: 39.9056,
          longitude: 116.4247
        },
        zoom: 19
      },
      tiltGesturesEnabled: false
    };
    this.callback = (err, mapController) => {
      if (!err) {
        this.mapController = mapController
        this.mapController?.setMyLocationEnabled(false);
        this.mapController?.setMyLocationControlsEnabled(true);
        this.mapController?.setTrafficEnabled(true);
        this.mapController?.setBuildingEnabled(true);
      }
    };
  }
}