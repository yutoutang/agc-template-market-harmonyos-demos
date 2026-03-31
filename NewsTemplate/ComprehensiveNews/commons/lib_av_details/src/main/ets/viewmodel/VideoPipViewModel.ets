import { AppStorageV2, PiPWindow } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppConstants, BaseViewModel, Logger } from 'lib_common';
import { AVPlayerState, PiPWindowModel, VideoCardPlayerController } from 'module_swipeplayer';
import { PipUINodeController } from '../utils/PipUINodeController';

const TAG = '[VideoPipViewModel]'

@ObservedV2
export class VideoPipViewModel extends BaseViewModel {
  @Trace pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  context: Context | undefined = undefined
  videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController();
  @Trace mXComponentController: XComponentController | undefined = undefined;
  @Trace curState: string = '';
  @Trace videoId: string = '';
  @Trace pipUINodeController: PipUINodeController = new PipUINodeController();

  @Monitor('pipWindowModel.isEnablePiP')
  onEnablePiPChange() {
    // 处理画中画控制面板控件功能状态  视频播放控制面板中播放/暂停控件。
    const controlType: PiPWindow.PiPControlType = PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE;
    const status: PiPWindow.PiPControlStatus =
      this.pipWindowModel.videoPlayerStatus === AVPlayerState.PLAYING ? PiPWindow.PiPControlStatus.PLAY :
        PiPWindow.PiPControlStatus.PAUSE;
    this.pipWindowModel.pipController?.updatePiPControlStatus(controlType, status);

    if (this.pipWindowModel.isBackPiP || this.pipWindowModel.isBackgroundPip) {
      return;
    }
    // 播放状态时才能使用画中画，其他状态不展示画中画;
    this.pipWindowModel.pipController?.setAutoStartEnabled(this.pipWindowModel.isEnablePiP);
  }

  @Monitor('userInfoModel.isLogin')
  onLogin() {
    if (this.pipWindowModel.pipController) {
      this.pipUINodeController.setMessage(this.userInfoModel.isLogin ? '请开通会员后继续观看' :
        '请登录/开通会员后继续观看');
      this.pipUINodeController.update();
    }
  }

  updatePip(canPlay: boolean) {
    if (this.pipWindowModel.pipController) {
      this.pipWindowModel.pipController.setPiPControlEnabled(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, canPlay);
      this.pipUINodeController.setVisible(!canPlay);
      this.pipUINodeController.update();
    }
  }

  initVideoPip() {
    if (this.mXComponentController && this.pipWindowModel.videoPlayerStatus === 'playing') {
      this.handlePip();
    }
  }

  public enableVideoPip(videoId: string, isBackPiP = true) {
    if (this.settingInfo.network.enableLivePiP) {
      if (this.pipWindowModel.isEnablePiP) {
        this.pipWindowModel.isBackPiP = isBackPiP;
        if (this.pipWindowModel.isBackPiP) {
          this.pipWindowModel.isReleaseVideoPlayer = false;
        }
        this.videoId = videoId
        this.startPip();
      } else {
        this.destroy()
      }
    } else {
      this.destroy()
    }
  }

  // 启动画中画
  private async startPip() {
    if (!this.pipWindowModel.pipController) {
      await this.createPipController();
    }
    if (!this.pipWindowModel.pipController) {
      return;
    }
    try {
      await this.pipWindowModel.pipController.startPiP();
    } catch (error) {
      Logger.error(TAG, 'Failed to startPiP Cause: %{public}s', JSON.stringify(error) ?? '');
    }
    this.audioInterrupt()
  }

  private async createPipController() {
    this.pipWindowModel.pipController = undefined;
    try {
      this.pipUINodeController.setMessage(this.userInfoModel.isLogin ? '请开通会员后继续观看' :
        '请登录/开通会员后继续观看');
      this.pipWindowModel.pipController = await PiPWindow.create({
        context: this.context,
        componentController: this.mXComponentController,
        navigationId: AppConstants.NAVIGATION_ID,
        templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY,
        customUIController: this.pipUINodeController,
      });
      this.pipWindowModel.pipController.on('stateChange', (state: PiPWindow.PiPState) => {
        this.onStateChange(state);
      });
      this.pipWindowModel.pipController.on('controlEvent', (control) => {
        this.onActionEvent(control);
      });
    } catch (e) {
      Logger.error(TAG, 'create pipController error' + e)
    }
    this.pipWindowModel.pipController?.setAutoStartEnabled(true);
  }

  private onActionEvent(control: PiPWindow.ControlEventParam) {
    switch (control.controlType) {
      case PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE:
        // 画中画面板上播放和暂停操作
        if (control.status === PiPWindow.PiPControlStatus.PAUSE) {
          this.videoCardPlayerController.pause();
        } else if (control.status === PiPWindow.PiPControlStatus.PLAY) {
          this.videoCardPlayerController.play();
        }
        break;
      default:
        break;
    }
  }

  private destroy() {
    this.pipWindowModel.isReleaseVideoPlayer = true;
    this.pipWindowModel.pipController?.setAutoStartEnabled(false);
    this.pipWindowModel.pipController = undefined;
    Logger.debug('isReleaseVideoPlayer destroy')
  }

  private onStateChange(state: PiPWindow.PiPState) {
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        // 返回时出现的画中画，不需要销毁播放器对象
        if (this.pipWindowModel.isBackPiP) {
          this.pipWindowModel.isReleaseVideoPlayer = false;
        }
        this.pipWindowModel.isPipStop = false;
        this.curState = 'ABOUT_TO_START';
        break;
      case PiPWindow.PiPState.STARTED:
        this.pipWindowModel.currentPiPVideoId = this.videoId;
        this.curState = 'STARTED';
        this.videoCardPlayerController.play();
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        this.curState = 'ABOUT_TO_STOP';
        this.pipUINodeController.dispose();
        break;
      case PiPWindow.PiPState.STOPPED:
        this.pipWindowModel.currentPiPVideoId = '';
        // 返回时出现的画中画，当关闭画中画时，需要销毁播放器对象
        if (this.pipWindowModel.isBackPiP) {
          this.pipWindowModel.isReleaseVideoPlayer = true;
        }
        this.pipWindowModel.isPipStop = true;
        this.curState = 'STOPPED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        // 画中画恢复到原页面时，重置状态
        this.pipWindowModel.isBackPiP = false;
        this.curState = 'ABOUT_TO_RESTORE';
        break;
      case PiPWindow.PiPState.ERROR:
        this.curState = 'ERROR';
        break;
      default:
        break;
    }
  }

  async handlePip() {
    // 设置页 启用小窗播放的开关是否打开
    const enableLivePiP = this.settingInfo.network.enableLivePiP;
    if (!enableLivePiP) {
      return;
    }
    if (this.pipWindowModel.pipController) {
      this.pipWindowModel.pipController.setAutoStartEnabled(true);
    } else {
      await this.createPipController();
    }
  }

  // 停止画中画
  public async stopPip() {
    if (!this.pipWindowModel.pipController) {
      return;
    }
    try {
      await this.pipWindowModel.pipController.stopPiP();
      this.cancelAudioInterrupt()
    } catch (error) {
      Logger.error(TAG, `Failed to stopPiP Cause: ${JSON.stringify(error)}`);
    }
  }

  public async isRestPipController(id: string) {
    // 切换视频时，如果画中画和切换的视频时同一个，则进入详情继续播放，否则重置
    if (this.pipWindowModel.pipController) {
      this.pipWindowModel.isBackPiP = false;
      try {
        await this.pipWindowModel.pipController.stopPiP()
      } catch (e) {
        Logger.error(TAG, 'stopPiP fail, error: ' + JSON.stringify(e));
      }
      if (this.pipWindowModel.currentPiPVideoId !== id) {
        this.pipWindowModel.isReleaseVideoPlayer = true;
        this.pipWindowModel.pipController.setAutoStartEnabled(false);
        this.pipWindowModel.pipController.off('stateChange');
        this.pipWindowModel.pipController.off('controlEvent');
        this.pipWindowModel.pipController = undefined;
        Logger.debug('isReleaseVideoPlayer isRestPipController')
      }
    }
  }

  public setContext(context: Context) {
    this.context = context
  }

  public setMXComponentController(mXComponentController: XComponentController) {
    this.mXComponentController = mXComponentController
  }

  public getVideoCardPlayerController() {
    return this.videoCardPlayerController
  }

  /**
   * 监听拦截系统媒体打断事件
   */
  public audioInterrupt() {
    let avPlayer = this.videoCardPlayerController.getAvplayer()
    if (avPlayer) {
      avPlayer.on('audioInterrupt', (info: audio.InterruptEvent) => {
        if (info.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
          this.pipWindowModel.isBackPiP = false;
          this.pipWindowModel.pipController?.stopPiP().catch((e: BusinessError) => {
            Logger.error(TAG, `Failed to stopPiP. Code: ${e.code}, message: ${e.message}`);
          })
        }
      });
    }
  }

  /**
   * 取消监听拦截系统媒体打断事件
   */
  public cancelAudioInterrupt() {
    let avPlayer = this.videoCardPlayerController.getAvplayer()
    if (avPlayer) {
      avPlayer.off('audioInterrupt');
    }
  }
}