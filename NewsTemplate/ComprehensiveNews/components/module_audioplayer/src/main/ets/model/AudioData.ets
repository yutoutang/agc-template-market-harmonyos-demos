/**
 * 音频数据模型
 */
export class AudioItem {
  /**
   * 专辑 id
   */
  id: string = '';

  /**
   * 音频audioId
   */
  audioId: string = '';

  /**
   * 音频副标题
   */
  mainTitle: string = '';
  /**
   * 音频名称
   */
  title: string = '';

  /**
   * 音频作者
   */
  description: string = '';

  /**
   * 音频封面
   */
  mark: string = '';

  /**
   * 音频标签
   */
  label: ResourceStr = '';

  /**
   * 音频源
   */
  src: string = '';

  /**
   * 音频索引
   */
  index: number = 0;

  /**
   * 音频歌词
   */
  lyric?: string = '';
}


export enum AudioPlayMode {
  SINGLE_CYCLE = 0,
  ORDER = 1,
  RANDOM = 2
}

export enum AudioPlayerState {
  IDLE,
  INITIALIZED,
  LOAD,
  PREPARED,
  PLAY,
  PAUSE,
  STOP,
  ERROR,
  COMPLETED,
  RELEASED,
  PROGRESS_SPEED,
  TIME_UPDATE,
  VOLUME_CHANGE,
  UNKNOWN
}