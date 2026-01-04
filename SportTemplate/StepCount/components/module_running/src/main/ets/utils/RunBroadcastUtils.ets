import { textToSpeech } from '@kit.CoreSpeechKit';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { RunLogger } from './RunLogger';

export enum RunVoiceType {
  CN_FEMALE_DEFAULT = 0,
  CN_MALE = 21,
  US_FEMALE = 8,
  CN_FEMALE = 13,
}

@ObservedV2
export class VoiceModel {
  @Trace curVoice: RunVoiceType = RunVoiceType.CN_FEMALE_DEFAULT;
}

const TAG = '[RunBroadCastUtils]';

@ObservedV2
export class RunBroadCastUtils {
  private static _voiceModel: VoiceModel =
    PersistenceV2.connect(VoiceModel, 'voiceModel', () => new VoiceModel())!;
  private static _ttsEngine: textToSpeech.TextToSpeechEngine | undefined;

  public static getCurVoiceType() {
    return RunBroadCastUtils._voiceModel.curVoice;
  }

  public static stop() {
    if (RunBroadCastUtils._ttsEngine) {
      RunBroadCastUtils._ttsEngine.stop();
    }
  }

  public static async speak(text: string) {
    if (!RunBroadCastUtils._ttsEngine) {
      await RunBroadCastUtils._createEngine();
    }
    RunBroadCastUtils.stop();
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
    RunBroadCastUtils._ttsEngine!.speak(text, speakParams);
  }

  private static async _createEngine() {
    let extraParam: Record<string, string> =
      { 'style': 'interaction-broadcast', 'locate': 'CN', 'name': 'ttsEngine' };
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: RunBroadCastUtils._voiceModel.curVoice === RunVoiceType.US_FEMALE ? 'en-US' : 'zh-CN',
      person: RunBroadCastUtils._voiceModel.curVoice,
      online: 1,
      extraParams: extraParam,
    };

    let speakListener: textToSpeech.SpeakListener = {
      // 开始播报回调
      onStart(requestId: string, response: textToSpeech.StartResponse) {
        RunLogger.info(TAG, `onStart, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 完成播报回调
      onComplete(requestId: string, response: textToSpeech.CompleteResponse) {
        RunLogger.info(TAG, `onComplete, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 停止播报完成回调，调用stop方法并完成时会触发此回调
      onStop(requestId: string, response: textToSpeech.StopResponse) {
        RunLogger.info(TAG, `onStop, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 错误回调，播报过程发生错误时触发此回调
      // 未创建引擎时调用speak方法时返回错误码1003400007，合成及播报失败
      // 连续调用两次speak，第二次speak会返回错误码1003400006，服务正忙碌
      onError(requestId: string, errorCode: number, errorMessage: string) {
        RunLogger.error(TAG, `onError, requestId: ${requestId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      },
    };

    try {
      RunBroadCastUtils._ttsEngine = await textToSpeech.createEngine(initParamsInfo);
      RunBroadCastUtils._ttsEngine.setListener(speakListener);
      RunLogger.info(TAG, 'Succeeded in creating engine.');
    } catch (err) {
      // 创建引擎失败时返回错误码1003400005，可能原因：引擎不存在、资源不存在、创建引擎超时
      RunLogger.error(TAG, `Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
    }
  }
}

