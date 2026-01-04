import { textToSpeech } from '@kit.CoreSpeechKit';
import { Logger } from './Logger';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';

export enum VoiceType {
  CN_FEMALE_DEFAULT = 0,
  CN_FEMALE = 13,
  CN_MALE = 21,
  US_FEMALE = 8,
}

@ObservedV2
export class VoicePackage {
  pic: ResourceStr;
  type: VoiceType;
  desc: string;
  used: number;
  rate: number;
  installed: boolean;

  constructor(pic: ResourceStr, type: VoiceType, desc: string, used: number, rate: number, installed: boolean) {
    this.pic = pic;
    this.type = type;
    this.desc = desc;
    this.used = used;
    this.rate = rate;
    this.installed = installed;
  }
}

@ObservedV2
export class VoiceModel {
  @Trace curVoice: VoiceType = VoiceType.CN_FEMALE_DEFAULT;
}

const TAG = '[BroadCastUtils]';

@ObservedV2
export class BroadCastUtils {
  private static _voiceModel: VoiceModel =
    PersistenceV2.connect(VoiceModel, 'voiceModel', () => new VoiceModel())!;
  private static _ttsEngine: textToSpeech.TextToSpeechEngine | undefined;

  public static getCurVoiceType() {
    return BroadCastUtils._voiceModel.curVoice;
  }

  private static async _createEngine() {
    let extraParam: Record<string, string> =
      { 'style': 'interaction-broadcast', 'locate': 'CN', 'name': 'ttsEngine' };
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: BroadCastUtils._voiceModel.curVoice === VoiceType.US_FEMALE ? 'en-US' : 'zh-CN',
      person: BroadCastUtils._voiceModel.curVoice,
      online: 1,
      extraParams: extraParam,
    };

    let speakListener: textToSpeech.SpeakListener = {
      // 开始播报回调
      onStart(requestId: string, response: textToSpeech.StartResponse) {
        Logger.info(TAG, `onStart, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 完成播报回调
      onComplete(requestId: string, response: textToSpeech.CompleteResponse) {
        Logger.info(TAG, `onComplete, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 停止播报完成回调，调用stop方法并完成时会触发此回调
      onStop(requestId: string, response: textToSpeech.StopResponse) {
        Logger.info(TAG, `onStop, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 错误回调，播报过程发生错误时触发此回调
      // 未创建引擎时调用speak方法时返回错误码1003400007，合成及播报失败
      // 连续调用两次speak，第二次speak会返回错误码1003400006，服务正忙碌
      onError(requestId: string, errorCode: number, errorMessage: string) {
        Logger.error(TAG, `onError, requestId: ${requestId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      },
    };

    try {
      BroadCastUtils._ttsEngine = await textToSpeech.createEngine(initParamsInfo);
      BroadCastUtils._ttsEngine.setListener(speakListener);
      Logger.info(TAG, 'Succeeded in creating engine.');
    } catch (err) {
      // 创建引擎失败时返回错误码1003400005，可能原因：引擎不存在、资源不存在、创建引擎超时
      Logger.error(TAG, `Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
    }
  }

  public static async speak(text: string) {
    if (!BroadCastUtils._ttsEngine) {
      await BroadCastUtils._createEngine();
    }
    BroadCastUtils.stop();
    // 设置播报相关参数
    let extraParam: Record<string, string | number> = {
      'queueMode': 0,
      'speed': 1,
      'volume': 1,
      'pitch': 1,
      'languageContext': 'zh-CN',
      'audioType': 'pcm',
      'soundChannel': 1,
      'playType': 1,
    };
    let speakParams: textToSpeech.SpeakParams = {
      requestId: Date.now().toString(),
      extraParams: extraParam,
    };
    BroadCastUtils._ttsEngine!.speak(text, speakParams);
  }

  public static stop() {
    if (BroadCastUtils._ttsEngine) {
      BroadCastUtils._ttsEngine.stop();
    }
  }

  public static change(type: VoiceType) {
    if (BroadCastUtils._ttsEngine) {
      BroadCastUtils._ttsEngine.stop();
      BroadCastUtils._ttsEngine.shutdown();
      BroadCastUtils._ttsEngine = undefined;
    }
    BroadCastUtils._voiceModel.curVoice = type;
  }

  public static async _queryList() {
    let voicesQuery: textToSpeech.VoiceQuery = {
      requestId: Date.now().toString(),
      online: 1,
    };
    if (!BroadCastUtils._ttsEngine) {
      await BroadCastUtils._createEngine();
    }
    return BroadCastUtils._ttsEngine!.listVoices(voicesQuery);
  }
}

