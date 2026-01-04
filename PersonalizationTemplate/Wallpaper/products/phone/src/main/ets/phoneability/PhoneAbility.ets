import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, PersistenceV2, ThemeControl, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  BundleUtils, Logger, SettingModel, SystemBarOperation, WindowModel,
} from 'lib_common';
import { WXApi, WXEventHandler } from 'lib_account';
import { gAppTheme } from '../common/AppTheme';
import { FormCardRouterModel } from '../common/Types';
import { rpc } from '@kit.IPCKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { media } from '@kit.MediaKit';

const TAG = '[PhoneAbility]';
const DOMAIN_NUMBER: number = 0xFF00;
const MSG_SEND_METHOD: string = 'funA';
const CONST_NUMBER_1: number = 1;

class MyParcelable implements rpc.Parcelable {
  num: number;
  str: string;

  constructor(num: number, str: string) {
    this.num = num;
    this.str = str;
  };

  marshalling(messageSequence: rpc.MessageSequence): boolean {
    messageSequence.writeInt(this.num);
    messageSequence.writeString(this.str);
    return true;
  };

  unmarshalling(messageSequence: rpc.MessageSequence): boolean {
    this.num = messageSequence.readInt();
    this.str = messageSequence.readString();
    return true;
  };
}

// 在收到call事件后会触发callee监听的方法
let funACall = (data: rpc.MessageSequence): MyParcelable => {
  // 获取call事件中传递的所有参数
  let params: Record<string, string> = JSON.parse(data.readString());
  if (params.formId !== undefined) {
    let curFormId: string = params.formId;
    let message: string = params.calleeDetail;
    hilog.info(DOMAIN_NUMBER, TAG, `UpdateForm formId: ${curFormId}, message: ${message}`);
    playMp3()
    let formData: Record<string, string> = {
      'calleeDetail': message
    };
    let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    try {
      formProvider.updateForm(curFormId, formMsg).then((data) => {
        hilog.info(DOMAIN_NUMBER, TAG, `updateForm success. ${JSON.stringify(data)}`);
      }).catch((error: BusinessError) => {
        hilog.error(DOMAIN_NUMBER, TAG, `updateForm failed: ${JSON.stringify(error)}`);
      });
    } catch (error) {
      Logger.error(TAG, 'open dialog failed. error:' + JSON.stringify(error));
    }
  }
  return new MyParcelable(CONST_NUMBER_1, 'aaa');
};

async function playMp3() {
  try {
    //播放在线的语音文件
    const avplayer = await media.createAVPlayer()

    avplayer.url =
      'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-5xjsz/mp3%2Fwooden_fish_sound.mp3?token=dabcb88e-983f-4d93-8fc7-4705d9534d8c'
    avplayer.on('stateChange', (state: media.AVPlayerState) => {
      //监控状态
      if (state === 'initialized') {
        //说明已经是初始化状态-可以准备播放
        avplayer.prepare()
      }
      if (state === 'prepared') {
        avplayer.loop = false //循环播放
        //已是准备播放状态--可以播放
        avplayer.play() //播放
      }
    })
    avplayer.on('error', (error: BusinessError) => {
      // 开发者根据需要写入业务逻辑。
      avplayer.release((err: BusinessError) => {
        if (err) {
        } else {
        }
      })
    });
  } catch (error) {
    Logger.error(TAG, 'open dialog failed. error:' + JSON.stringify(error));
  }
}

export default class PhoneAbility extends UIAbility {
  private targetPage: string = ''

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info(TAG, 'Ability onCreate');
    try {
      // 监听call事件所需的方法
      this.callee.on(MSG_SEND_METHOD, funACall);
    } catch (error) {
      hilog.error(DOMAIN_NUMBER, TAG, `${MSG_SEND_METHOD} register failed with error ${JSON.stringify(error)}`);
    }
    this.handleWeChatCallIfNeed(want);
    this.handleFormCardCall(want);
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    this.offAvoidAreaChange();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');
    ThemeControl.setDefaultTheme(gAppTheme)
    this.setWinConfig(windowStage);
    this.setAppTheme();
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      this.setColorMode(this.context);
      BundleUtils.getBundleInfo()
    });
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onNewWant(want: Want): void {
    this.handleWeChatCallIfNeed(want);
    this.handleFormCardCall(want);
  }

  onForeground(): void {
    Logger.info(TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    Logger.info(TAG, '%{public}s', 'Ability onBackground');
  }

  private setAppTheme() {
    ThemeControl.setDefaultTheme(gAppTheme);
  }

  private async setWinConfig(windowStage: window.WindowStage) {
    AppStorage.setOrCreate('windowStage', windowStage);
    let windowClass: window.Window = windowStage.getMainWindowSync();
    await windowClass.setWindowLayoutFullScreen(true);
    this.setAvoidArea(windowClass);
    this.onAvoidAreaChange(windowStage);
    this.setWindowSize(windowStage)
  }

  private setAvoidArea(windowClass: window.Window) {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    let type = window.AvoidAreaType.TYPE_SYSTEM;
    let avoidArea = windowClass.getWindowAvoidArea(type);
    windowModel.windowTopPadding = px2vp(avoidArea.topRect.height);
    type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
    avoidArea = windowClass.getWindowAvoidArea(type);
    windowModel.windowBottomPadding = px2vp(avoidArea.bottomRect.height);
  }

  private onAvoidAreaChange(windowStage: window.WindowStage) {
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowClass.on('avoidAreaChange', () => {
        this.setAvoidArea(windowClass);
      });
    } catch (e) {
      Logger.error(TAG, 'Failed to onAvoidAreaChange. Cause: ' + JSON.stringify(e));
    }
  }

  private offAvoidAreaChange() {
    try {
      let windowStage = AppStorage.get('windowStage') as window.WindowStage;
      if (windowStage) {
        windowStage.getMainWindowSync().off('avoidAreaChange');
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to offAvoidAreaChange. Cause: ' + JSON.stringify(e));
    }
  }

  private setWindowSize(windowStage: window.WindowStage) {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    let windowClass: window.Window = windowStage.getMainWindowSync();
    windowModel.windowWidth = windowClass.getWindowProperties().windowRect.width;
    windowModel.windowHeight = windowClass.getWindowProperties().windowRect.height;
  }

  private handleWeChatCallIfNeed(want: Want) {
    WXApi.handleWant(want, WXEventHandler);
  }

  private handleFormCardCall(want: Want) {
    if (want?.parameters?.targetPage && want?.parameters?.formId) {
      const formCardRouter: FormCardRouterModel =
        AppStorageV2.connect(FormCardRouterModel, () => new FormCardRouterModel())!;
      formCardRouter.targetPage = want?.parameters?.targetPage as string ?? '';
      formCardRouter.formId = want?.parameters?.formId as string ?? '';
      formCardRouter.cardSize = want?.parameters?.cardSize as string ?? '';
      formCardRouter.cardId = want?.parameters?.cardId as string | number ?? '';
      formCardRouter.cardInfo = want?.parameters?.cardInfo as string ?? '';
      formCardRouter.cardType = want?.parameters?.cardType as string ?? '';
    }
  }

  private setColorMode(context: common.UIAbilityContext) {
    Logger.info('setColorMode PersistenceV2 keys: ' + JSON.stringify(PersistenceV2.keys()));
    const settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
    const mode = settingInfo.darkSwitch ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK :
    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    context.getApplicationContext().setColorMode(mode);
    SystemBarOperation.setWindowSystemBarProp({
      statusBarContentColor: settingInfo.darkSwitch ? '#ffffff' : '#ff090909',
    })
  }
}