/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { PiPWindow } from '@kit.ArkUI';
import { AVPlayer } from './AVPlayer';

export class CustomXComponentController extends XComponentController {
  onSurfaceCreated(surfaceId: string): void {
    if (PipManager.getInstance().player.surfaceID !== surfaceId) {
      PipManager.getInstance().player.setSurfaceId(surfaceId);
    }
  }
}

// 画中画控制器
export class PipManager {
  private static instance: PipManager = new PipManager();
  private mXComponentController: XComponentController;
  private pipController?: PiPWindow.PiPController;
  player: AVPlayer;

  public static getInstance(): PipManager {
    return PipManager.instance;
  }

  getXComponentController(): CustomXComponentController {
    return this.mXComponentController;
  }

  constructor() {
    this.player = new AVPlayer();
    this.mXComponentController = new CustomXComponentController();
  }

  init(ctx: Context, navigationId: string) {
    // 当前设备如若不支持画中画则退出
    if (!PiPWindow.isPiPEnabled()) {
      return;
    }
    let config: PiPWindow.PiPConfiguration = {
      context: ctx,
      componentController: this.mXComponentController,
      templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY,
      contentHeight: 900,
      contentWidth: 1600,
      navigationId: navigationId,
    };
    PiPWindow.create(config).then((controller: PiPWindow.PiPController) => {
      this.pipController = controller;
      this.pipController?.setAutoStartEnabled(false);
      this.pipController.on('controlEvent', (control: PiPWindow.ControlEventParam) => {
        this.onActionEvent(control);
      });
      this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
        this.onStateChange(state, reason);
      });
    });
  }

  unregisterPipStateChangeListener() {
    this.pipController?.off('controlEvent');
    this.pipController?.off('stateChange');
  }

  stopPip() {
    this.pipController?.stopPiP().then(() => {
    });
  }

  startPip() {
    this.pipController?.startPiP().then(() => {
    });
  }

  setAutoStart(autoStart: boolean): void {
    this.pipController?.setAutoStartEnabled(autoStart);
  }

  updatePiPControlStatus() {
    let status: PiPWindow.PiPControlStatus = PiPWindow.PiPControlStatus.PLAY;
    let controlType: PiPWindow.PiPControlType = PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE;
    this.pipController?.updatePiPControlStatus(controlType, status);
  }

  updateContentSize(width: number, height: number) {
    if (this.pipController) {
      this.pipController.updateContentSize(width, height);
    }
  }

  onStateChange(state: PiPWindow.PiPState, reason: string) {
    switch (state) {
      // 表示画中画将要启动
      case PiPWindow.PiPState.ABOUT_TO_START:
        break;
      // 表示画中画已经启动
      case PiPWindow.PiPState.STARTED:
        // 启动画中画
        PipManager.getInstance().player.isPiPWindowLoad = true;
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        PipManager.getInstance().player.isPiPWindowLoad = false;
        break;
      case PiPWindow.PiPState.STOPPED:
        // 画中画关闭
        PipManager.getInstance().player.isPiPWindowLoad = false;
        // 小窗口点击关闭画中画
        if (!PipManager.getInstance().player.isPiPWindowRestore) {
          PipManager.getInstance().player.isPlaying = false;
        }
        PipManager.getInstance().player.isPiPWindowRestore = false;
        break;
      // 恢复到原始播放界面
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        PipManager.getInstance().player.isPiPWindowLoad = false;
        PipManager.getInstance().player.isPiPWindowRestore = true;
        if (!PipManager.getInstance().player.isPlaying) {
          PipManager.getInstance().player.isPlaying = true;
        }
        break;
      // 画中画异常
      case PiPWindow.PiPState.ERROR:
        break;
      default:
        break;
    }
  }

  // 监听画中画控制面板控件动作事件
  onActionEvent(control: PiPWindow.ControlEventParam) {
    switch (control.controlType) {
      // 视频播放、停止
      case PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE:
        if (control.status === PiPWindow.PiPControlStatus.PAUSE) {
          // 停止视频
          PipManager.getInstance().player.isPlaying = false;
        } else if (control.status === PiPWindow.PiPControlStatus.PLAY) {
          // 播放视频
          PipManager.getInstance().player.isPlaying = true;
        }
        break;
      // 切换到下一个视频
      case PiPWindow.PiPControlType.VIDEO_NEXT:
        break;
      // 切换到上一个视频
      case PiPWindow.PiPControlType.VIDEO_PREVIOUS:
        break;
      // 视频进度快进
      case PiPWindow.PiPControlType.FAST_FORWARD:
        break;
      // 视频进度后退
      case PiPWindow.PiPControlType.FAST_BACKWARD:
        break;
      default:
        break;
    }
  }
}