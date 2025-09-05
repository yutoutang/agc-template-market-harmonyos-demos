import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { display, promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { Logger } from './Logger';
import { AVPlayerState } from '../type/Index';

const TAG = '[CommonUtils]';

export function secondToTime(seconds: number): string {
  let hourUnit = 60 * 60;
  let hour: number = Math.floor(seconds / hourUnit);
  let minute: number = Math.floor((seconds % hourUnit) / 60);
  let second: number = Math.floor(seconds % 60);
  let hourStr: string = hour < 10 ? `0${hour.toString()}` : `${hour.toString()}`;
  let minuteStr: string = minute < 10 ? `0${minute.toString()}` : `${minute.toString()}`;
  let secondStr: string = second < 10 ? `0${second.toString()}` : `${second.toString()}`;
  if (hour > 0) {
    return `${hourStr}:${minuteStr}:${secondStr}`;
  }
  if (minute > 0) {
    return `${minuteStr}:${secondStr}`;
  }
  return `00:${secondStr}`;
}

export function setSeek(avPlayer: media.AVPlayer | undefined, seek: number) {
  if (!avPlayer) {
    Logger.debug(TAG, 'setSeek error! avPlayer undefined!');
    return;
  }
  let states = [AVPlayerState.PREPARED, AVPlayerState.PLAYING, AVPlayerState.PAUSED, AVPlayerState.COMPLETED]
  if (states.includes(avPlayer.state as AVPlayerState)) {
    avPlayer.seek(seek, media.SeekMode.SEEK_PREV_SYNC);
  }
}

export function setSpeed(avPlayer: media.AVPlayer | undefined, speed: media.PlaybackSpeed) {
  if (avPlayer === undefined) {
    Logger.debug(TAG, 'setSpeed error! avPlayer undefined!');
    return;
  }
  if (speed < 0) {
    speed = media.PlaybackSpeed.SPEED_FORWARD_0_125_X;
    Logger.debug(TAG, 'The player speed cannot be lower than 0.125');
  }
  if (speed > 9) {
    speed = media.PlaybackSpeed.SPEED_FORWARD_3_00_X
    Logger.debug(TAG, 'The player speed cannot be higher than 3');
  }
  if (avPlayer.state === AVPlayerState.PLAYING) {
    avPlayer.setSpeed(speed);
  }
}

export async function playVideo(avPlayer: media.AVPlayer | undefined, curIndex?: number, index?: number) {
  if (!avPlayer) {
    Logger.debug(TAG, `playVideo error! avPlayer undefined! curIndex: ${curIndex}, index: ${index}.`);
    return;
  }
  let states = [AVPlayerState.PREPARED, AVPlayerState.PAUSED, AVPlayerState.COMPLETED]
  if (states.includes(avPlayer.state as AVPlayerState)) {
    Logger.debug(TAG, `playVideo. state:${avPlayer.state}, curIndex: ${curIndex}, index: ${index}.`);
    await avPlayer.play();
  }
}

export async function pauseVideo(avPlayer: media.AVPlayer | undefined, curIndex?: number, index?: number) {
  if (!avPlayer) {
    Logger.debug(TAG, `pauseVideo error! avPlayer undefined! curIndex: ${curIndex}, index: ${index}.`);
    return;
  }
  Logger.debug(TAG, `pauseVideo. state:${avPlayer.state}, curIndex: ${curIndex}, index: ${index}.`);
  await avPlayer.pause();
}

export function setOrientation(orientation: number): Promise<void> {
  let context: common.UIAbilityContext = getContext() as common.UIAbilityContext
  return context.windowStage.getMainWindowSync().setPreferredOrientation(orientation)
}

export function toast(uiContext: UIContext, options: promptAction.ShowToastOptions) {
  let target = {
    duration: 2000,
  } as promptAction.ShowToastOptions;
  target = assign(target, options)
  uiContext.getPromptAction().showToast(target);
}

// 合并对象
export function assign(
  target: promptAction.ShowToastOptions,
  ...source: promptAction.ShowToastOptions[]
): promptAction.ShowToastOptions {
  for (let s of source) {
    for (let k of Object.keys(s)) {
      target[k] = Reflect.get(s, k)
    }
  }
  return target
}

// 本地沙箱视频链接处理
export function handleSandboxVideoUrl(videoUrlPath: string): string {
  // 打开相应的资源文件地址获取fd，并为url赋值触发initialized状态机上报
  let file = fs.openSync(videoUrlPath);
  let fdPath = 'fd://' + file.fd;
  return fdPath
}

// 判断是否是大折叠、阔折叠外屏、小折叠内屏
export const isDisplayModeFull = (): boolean => {
  // 是否可折叠
  let isFoldable = display.isFoldable();
  // 当前设备的显示模式
  let foldDisplayMode: display.FoldDisplayMode | undefined = undefined
  if (isFoldable) {
    foldDisplayMode = display.getFoldDisplayMode();
  }
  return foldDisplayMode === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL;
}