import { TextReader } from '@kit.SpeechKit';
import { GlobalContextUtils, Logger } from 'lib_common';
import { AudioConstants, MediaController, AudioService } from 'module_audioplayer';
import { VideoPlayService } from 'module_swipeplayer';

const TAG = '[AVSessionUtils]';

/**
 * 播控中心工具类
 */
export class AVSessionUtils {
  /**
   * 释放【视频】Session
   */
  public static async destroyVideoSession() {
    await VideoPlayService.destroySession(GlobalContextUtils.globalContext);
  }

  /**
   * 释放【音频】Session
   */
  public static async destroyAudioSession() {
    await AudioService.destroySession(GlobalContextUtils.globalUIAbilityContext);
    AudioService.destroySubWindow(AudioConstants.AUDIO_SUB_NAME);
    MediaController.pause();
  }

  /**
   * 释放【小艺朗读】Session
   */
  public static async destroyReaderSession() {
    try {
      await TextReader.release();
    } catch (e) {
      Logger.error(TAG, `Failed to release TextReader. code: ${e.code}, message: ${e.message}`);
    }
  }
}
