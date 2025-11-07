import { image } from '@kit.ImageKit';
import { Type } from '@kit.ArkUI';

export class VideoAsset {
  videoUri: string | undefined;
  fd?: number = 0;
  screenWidth: Length | undefined;
  screenHeight: Length | undefined;
}

@ObservedV2
export class EditVideo {
  @Trace videoId: string = '';
  @Trace videoUri: string = '';
  @Trace previewUri: image.PixelMap | null = null;
  @Trace duration: string = '';
  @Trace size: string = '';
  @Trace mediaUri: string = '';
  @Trace isSelect: boolean = false;
}

// 定义贴图信息结构
export interface TImageInfo {
  imageId: string;
  width: number;
  height: number;
}

// 定义音频信息结构
@ObservedV2
export class AudioInfo {
  @Trace id: number = 0;
  @Trace uri: string = '';
  @Trace fd?: number = 0;
  @Trace name: string = '';
  @Trace tag?: string = '';
  @Trace isCached?: boolean = false;
  @Trace fileUri?: string = '';
  @Trace progress: number = 0;
}

// 视频边界信息（用于创建视频外蒙层）
export interface VideoRect {
  x: number;
  y: number;
  width: number;
  height: number;
}

export class SoundByTag {
  tag: string = '';
  sounds: AudioInfo[] = [];
}

@ObservedV2
export class TextInfo {
  @Trace currentColor: string = '#000000';
  @Trace fontSize: number = 16;
  @Trace opacity: number = 100;
  @Trace isBold: boolean = false;
  @Trace isItalics: boolean = false;
  @Trace isUnderline: boolean = false;
  @Trace text: string = '';
  @Trace dx: number = 150;
  @Trace dy: number = 200;
}

export interface TextEditDialogParams {
  cloneText: string;
  textInfo: TextInfo;
  close: Function;
}

@ObservedV2
export class DownloadSound {
  @Trace name: string = '';
  @Trace fileUri: string = ''
}

@ObservedV2
export class DownloadSoundList {
  @Type(DownloadSound)
  @Trace list: DownloadSound[] = [];
}

// 定义按钮位置接口
export interface BtnPosition {
  x: number;
  y: number;
}

export interface Point {
  x: number;
  y: number;
}