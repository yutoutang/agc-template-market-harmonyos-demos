/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { emitter } from '@kit.BasicServicesKit';
import { display, uiObserver, window } from '@kit.ArkUI';
import { PipManager } from '../tools/PipManager';
import { PlayerControl } from '../components/PlayerControl';
import { PlayerVM } from '../viewModels/PlayerVM';
import { AVPlayer } from '../tools/AVPlayer';
import { MovieItem } from '../models/Type';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const controllerDelay = 2000; // 控制器时延

@ComponentV2
export struct PlayerComponent {
  logTag: string = 'PlayerComponent';
  domainId: number = 0x0000;
  @Param @Require movieItems: MovieItem[] = []
  @Param @Require playerIndex: number = 0
  // 选集
  @Param selectionEvent: (idx: number) => void = () => {
  }
  @Param fullScreen: (isLayoutFullScreen: boolean) => void = () => {
  }
  @Param callbackTimeUpdate: (nol: number, total: number) => void = () => {
  };
  // 退出事件
  @Param exitEvent: () => void = () => {
  }
  // 分享事件
  @Param shareEvent: () => void = () => {
  }
  // 控制器是否显示
  @Local controlShow: boolean = false;
  // 是否全屏
  @Local isLayoutFullScreen: boolean = false;
  // 清晰度
  @Local isShowDefinitionSheet: boolean = false;
  // 设置
  @Local isShowSettingSheet: boolean = false;
  @Local playerVM: PlayerVM = PlayerVM.instance;
  @Local player: AVPlayer = PipManager.getInstance().player;
  @Local windowStatusType: number = 0;
  @Local isFoldable: boolean = false;
  @Local componentHeight: string = '100%';
  curFoldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;
  mWindow?: window.Window;
  private surfaceId: string = '';
  private timer: number = -1;
  private uiContext: UIContext = this.getUIContext() as UIContext;
  private context: common.UIAbilityContext = this.uiContext.getHostContext() as common.UIAbilityContext;

  @Monitor('player.isPlaying')
  onNameChange() {
    if (PipManager.getInstance().player.isResetPause) {
      PipManager.getInstance().player.getPause();
    } else {
      PipManager.getInstance().player.isPlaying ? PipManager.getInstance().player.getPlay() :
        PipManager.getInstance().player.getPause();
    }
  }

  // 设置窗口方向
  setR(orientation: number) {
    window.getLastWindow(this.context).then((win) => {
      win.setPreferredOrientation(orientation).then(() => {
      }).catch(() => {
      })
    }).catch(() => {
    })
  }

  // 设置沉浸式窗口
  setFullScreen(isLayoutFullScreen: boolean) {
    window.getLastWindow(this.context).then((win: window.Window) => {
      win.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      }).catch(() => {
      })
    }).catch(() => {
    })
    this.fullScreen(isLayoutFullScreen)
    this.setComponentHeight()
  }

  regDisplayListener(): void {
    try {
      display.on('foldStatusChange', async (curFoldStatus: display.FoldStatus) => {
        // 同一个状态重复触发不做处理
        if (this.curFoldStatus === curFoldStatus) {
          return;
        }
        this.curFoldStatus = curFoldStatus;
        this.setComponentHeight()
      })
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `Error occurred. errCode is ${error.code}, errMessage is ${error.message}`);
    }
  }

  setComponentHeight() {
    let screenWidth = 0
    try {
      screenWidth = display.getDefaultDisplaySync().width
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `Error occurred. errCode is ${error.code}, errMessage is ${error.message}`);
    }
    if (this.curFoldStatus === display.FoldStatus.FOLD_STATUS_FOLDED ||
      this.curFoldStatus === display.FoldStatus.FOLD_STATUS_UNKNOWN) {
      this.componentHeight = '100%'
    } else {
      if (this.isLayoutFullScreen) {
        let height = (this.getUIContext().px2vp(screenWidth) - 32) * 9 / 16
        this.componentHeight = height.toString() + 'vp'
      } else {
        this.componentHeight = '100%'
      }
    }
  }

  async aboutToAppear() {
    if (this.movieItems && this.movieItems.length > 0) {
      this.playerVM.movieItemList = this.movieItems
      this.playerVM.movieItem = this.playerVM.movieItemList[this.playerIndex]
    }
    PipManager.getInstance().init(this.context, this.playerVM.navId)
    window.getLastWindow(this.context).then((currentWindow: window.Window) => {
      this.mWindow = currentWindow;
      // 获取窗口属性
      try {
        let properties = currentWindow.getWindowProperties();
        let rect = properties.windowRect;
        if (this.getUIContext().px2vp(rect.height) <= 680) {
          this.windowStatusType = 5
          this.playerVM.windowStatusType = this.windowStatusType
          this.isLayoutFullScreen = false
          this.setR(1)
          this.setFullScreen(false)
        }
        currentWindow.on('windowStatusChange', (windowStatusType) => {
          this.windowStatusType = windowStatusType
          this.playerVM.windowStatusType = this.windowStatusType
          if (windowStatusType === 5) {
            this.isLayoutFullScreen = false
            this.setR(1)
            this.setFullScreen(false)
          }
        });
      } catch (error) {
        hilog.error(this.domainId, this.logTag,
          `Error occurred. errCode is ${error.code}, errMessage is ${error.message}`);
      }
    }).catch((error: BusinessError) => {
      hilog.error(this.domainId, this.logTag,
        `Error occurred. errCode is ${error.code}, errMessage is ${error.message}`);
    })
    emitter.on('playerPause', (event: emitter.EventData) => {
      let isPlaying = event.data!.isPlaying as boolean
      if (isPlaying) {
        PipManager.getInstance().player.isResetPause = false
        PipManager.getInstance().player.isPlaying = true
      } else {
        PipManager.getInstance().player.isResetPause = true
        PipManager.getInstance().player.isPlaying = false
      }
    })
    emitter.on('autoStartPip', () => {
      if (this.playerVM.autoStartEnabled) {
        if (PipManager.getInstance().player.isPipOpen) {
        } else {
          PipManager.getInstance().startPip()
          PipManager.getInstance().updatePiPControlStatus();
        }
      } else {
        if (PipManager.getInstance().player.isPipOpen) {
        } else {
          PipManager.getInstance().player.isPlaying = false
        }
      }
    })
    emitter.on('chapterDetailBack', () => {
      if (!PipManager.getInstance().player.isPipOpen) {
        // 释放AVPlayer资源
        PipManager.getInstance().stopPip()
        PipManager.getInstance().player.isCreate = true
        PipManager.getInstance().player.release();
      }
    })
    try {
      if (display.isFoldable()) {
        this.regDisplayListener();
      }
      this.curFoldStatus = display.getFoldStatus()
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `Error occurred. errCode is ${error.code}, errMessage is ${error.message}`);
    }

    this.setComponentHeight()

    this.getUIContext().getUIObserver().on('navDestinationSwitch', this.releaseResource);
  }

  aboutToDisappear() {
    this.getUIContext().getUIObserver().off('navDestinationSwitch', this.releaseResource);
  }

  /**
   * 页面导航切换时释放播放器相关资源以及回调
   */
  releaseResource = (info: uiObserver.NavDestinationSwitchInfo) => {
    emitter.off('playerPause')
    emitter.off('autoStartPip')
    emitter.off('chapterDetailBack')

    this.playerVM.movieItem.movieUrl = 'null'
    this.isLayoutFullScreen = false
    this.setR(this.isLayoutFullScreen ? 2 : 1)
    this.setFullScreen(this.isLayoutFullScreen)

    PipManager.getInstance().player.isCreate = true
    PipManager.getInstance().player.release()
  }

  @Builder
  xComponentView() {
    Column() {
      XComponent({
        type: XComponentType.SURFACE,
        controller: PipManager.getInstance().getXComponentController()
      })
        .id('XComponent01')
        .layoutWeight(1)
        .onLoad(() => {
          this.surfaceId = PipManager.getInstance().getXComponentController().getXComponentSurfaceId();
          // 将surfaceId设置给媒体源
          PipManager.getInstance().getXComponentController().onSurfaceCreated(this.surfaceId)
          PipManager.getInstance().player.init(this.playerVM.movieItem.movieUrl, this.playerVM.movieItem.learnProgress)
          PipManager.getInstance().player.callbackTimeUpdate = (vol: number, total: number) => {
            this.callbackTimeUpdate(vol, total)
            this.playerVM.movieItem.learnProgress = Math.floor(vol / total * 100)
          }
        })
    }
    .width('100%')
    .height('100%')
  }

  getSpeed(selectItem: string): number {
    if (selectItem === '0.75') {
      return 0
    } else if (selectItem === '1.0') {
      return 1
    } else if (selectItem === '1.25') {
      return 2
    } else if (selectItem === '1.5') {
      return 6
    } else if (selectItem === '2.0') {
      return 4
    }
    return 1
  }

  resetTimer() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.controlShow = false;
    }, controllerDelay)
  }

  build() {
    Column() {
      Stack((PipManager.getInstance().player.isLoading || PipManager.getInstance().player.isLoadError) ?
        { alignContent: Alignment.Center } :
        { alignContent: Alignment.Center }) {
        
        this.xComponentView()
        
        if (PipManager.getInstance().player.isLoading || PipManager.getInstance().player.isLoadError) {
          // 加载页面
          Column() {
            LoadingProgress()
              .color($r('sys.color.icon_on_primary'))
              .width(72)
              .height(72)
            Text('加载中')
              .fontSize(16)
              .fontColor(Color.White)
          }
          .justifyContent(FlexAlign.Center)
          .zIndex(2)
          .visibility(PipManager.getInstance().player.isLoading ? Visibility.Visible : Visibility.Hidden)

          Column() {
            Text('加载失败')
              .fontSize(16)
              .fontColor(Color.White)
          }
          .justifyContent(FlexAlign.Center)
          .zIndex(2)
          .visibility(PipManager.getInstance().player.isLoadError ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            PipManager.getInstance()
              .player
              .changePlay(this.playerVM.movieItem.movieUrl, this.playerVM.movieItem.learnProgress)
          })
        } else {
          // 控制层
          PlayerControl({
            playerIndex: this.playerIndex,
            isLayoutFullScreen: this.isLayoutFullScreen,
            fullScreen: (isLayoutFullScreen: boolean) => {
              this.isLayoutFullScreen = isLayoutFullScreen
              this.setR(this.isLayoutFullScreen ? 2 : 1)
              this.setFullScreen(this.isLayoutFullScreen)
            },
            selectionEvent: (item: MovieItem) => {
              let idx = this.playerVM.movieItemList.indexOf(item)
              this.selectionEvent(idx)
            },
            exitEvent: () => {
              this.isLayoutFullScreen = false
              this.setR(this.isLayoutFullScreen ? 2 : 1)
              this.setFullScreen(this.isLayoutFullScreen)
              this.exitEvent()
            },
            shareEvent: () => {
              this.isLayoutFullScreen = false
              this.setR(this.isLayoutFullScreen ? 2 : 1)
              this.setFullScreen(this.isLayoutFullScreen)
              this.shareEvent()
            }
          })
            .width('100%')
            .height('100%')
        }
      }
      .width('100%')
      .backgroundColor('#000000')
    }
  }
}