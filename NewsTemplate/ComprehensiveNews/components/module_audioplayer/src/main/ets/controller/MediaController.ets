import { window } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { AudioItem } from '../model/AudioData';
import { MediaViewModel } from '../viewmodel/MediaViewModel';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class MediaController {
  static instance: MediaController | null;

  @Computed
  public static get playingId() {
    return MediaViewModel.getInstance().playingId
  }

  /**
   * 设置avplayer实例
   * @param windowStage 窗口管理实例
   */
  public static getAvplayer(): media.AVPlayer | undefined {
    return MediaViewModel.getInstance().getAvplayer()
  }

  /**
   * 设置窗口管理实例
   * @param windowStage 窗口管理实例
   */
  public static setWindowStage(windowStage: window.WindowStage) {
    MediaViewModel.setWindowStage(windowStage)
  }

  /**
   * 设置音频列表
   * @param list 音频列表
   */
  public static setAudioList(list: AudioItem[]) {
    MediaViewModel.getInstance().setAudioList(list)
  }

  /**
   * 根据索引播放音频
   * @param audioIndex
   * @param isNeedPlay
   */
  public static loadAssent(audioIndex: number, loadOnly?: boolean) {
    MediaViewModel.getInstance().loadAssent(audioIndex, loadOnly)
  }

  /**
   * 设置专辑id
   * @param albumId 专辑id
   */
  public static setAlbumId(albumId: string) {
    MediaViewModel.getInstance().setAlbumIdId(albumId)
  }

  /**
   * 判断当前播放专辑是否参入的专辑id
   * @param albumId 专辑id
   */
  public static isSameCurrentPlay(albumId: string): boolean {
    return MediaViewModel.getInstance().isSameCurrentPlay(albumId)
  }

  /**
   * 音频初始化
   * @param context 上下文
   */
  public static initAudioList(context: common.UIAbilityContext) {
    MediaViewModel.getInstance().initAudioList(context)
  }

  /**
   * 根据id判断当前播放的是否是专辑的某个音频
   * @param playerId 音频id
   * @param playingId 当前播放的视频id
   */
  public static isSameCurrentPlayWithIndex(albumId: string, playingId: string): boolean {
    return MediaViewModel.getInstance().isSameCurrentPlayWithIndex(albumId, playingId)
  }

  // 暂停
  public static pause() {
    MediaViewModel.getInstance().pause()
  }
}
