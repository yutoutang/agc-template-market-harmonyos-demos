import { media } from '@kit.MediaKit';
import { AVVolumePanel } from '@kit.AudioKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { LongTakeAnimationProperties } from 'module_transition';
import { Battery } from '../components/Battery';
import { VideoProgressBar } from '../components/VideoProgressBar';
import { AVPlayerSession } from '../controller/AVPlayerManager';
import { Constants } from '../constants/Constants';
import { AVPlayerState, BreakpointNameEnum } from '../type/Index';
import { LandscapeVideoVM } from '../viewmodel/LandscapeVideoVM';
import { PlayerSpeedRateView } from '../components/PlayerSpeedRateView';
import { PlayerSlider } from '../components/PlayerSlider';
import { PlayerSliderModel, SliderType } from '../models/PlayerSliderModel';
import { BreakpointModel } from '../models/BreakpointModel';
import { Logger } from '../utils/Logger';

@Builder
export function LandscapeVideoBuilder() {
  LandscapeVideo()
}

const TAG = '[LandscapeVideo]';

@ComponentV2
export struct LandscapeVideo {
  xComponentController: XComponentController = new XComponentController();
  vm: LandscapeVideoVM = new LandscapeVideoVM(this.getUIContext())
  @Provider() playerSliderModel: PlayerSliderModel = this.vm.volumeUtil.playerSliderModel;
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();

  aboutToAppear(): void {
    this.vm.init();
  }

  aboutToDisappear(): void {
    this.vm.disappear()
  }

  private onBackPressed(): boolean {
    this.vm.onBack()
    return true;
  }

  build() {
    NavDestination() {
      FolderStack({ upperItems: ['upperVideoPlayer'] }) {
        Column() {
          XComponent({
            id: 'xmComponent',
            type: XComponentType.SURFACE,
            controller: this.xComponentController,
          })
            .aspectRatio(this.vm.videoWidth / this.vm.videoHeight)
            .onLoad(() => {
              const surfaceId = this.xComponentController.getXComponentSurfaceId();
              if (this.vm.player) {
                this.vm.player.surfaceId = surfaceId;
              }
              this.vm.player?.play().catch((e: BusinessError) => {
                Logger.error(TAG, 'play fail, error: ' + JSON.stringify(e));
              });
            })
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .id('upperVideoPlayer')

        Stack({ alignContent: Alignment.TopStart }) {
          // 音量、亮度、倍速
          this.videoExtraView()
          // 视频外层
          RelativeContainer() {
            // 头部
            Column() {
              this.topRegionView()
            }
            .width('100%')
            .alignRules({
              middle: { anchor: '__container__', align: HorizontalAlign.Center },
            })
            .visibility(this.vm.showBar ? Visibility.Visible : Visibility.Hidden)
            .animation({ duration: 200 })

            // 中心区域
            Column() {
              this.centerRegionView()
            }
            .width('100%')
            .height('calc(100% - 64vp - 82vp)')
            .alignRules({
              middle: { anchor: '__container__', align: HorizontalAlign.Center },
              center: { anchor: '__container__', align: VerticalAlign.Center },
            })

            // 底部进度条
            Row() {
              VideoProgressBar({
                playerSession: this.vm.playerSession,
                showProgressBarLeft: true,
                showProgressBarRight: true,
                selectedColor: Color.White,
                trackColor: $r('app.color.landscape_slide_track_color'),
                isFullScreen: true,
                isHideSlide: this.vm.isHideSlide,
                progressController: this.vm.progressController,
                onSwitchPlayCallback: () => {
                  this.vm.switchPlayOrPause()
                  this.vm.handleVideoLayerVisible()
                },
                onSwitchFullScreenCallback: () => {
                  this.vm.onBack()
                },
                onSlideChange: (flag) => {
                  if (flag) {
                    this.vm.showBar = true
                    this.vm.showLock = true
                  } else {
                    this.vm.showOrHiddenBar()
                  }
                },
              })
            }
            .width(Constants.FULL_PERCENT)
            .padding({ bottom: Constants.BOTTOM_PADDING_HEIGHT })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              left: { anchor: '__container__', align: HorizontalAlign.Start },
            })
            .visibility(this.vm.showBar && !this.vm.isLockScreen ? Visibility.Visible : Visibility.Hidden)
            .animation({ duration: 200 })

            // 页面锁住时，底部展示控制器
            Column() {
              // 视频的进度控制器
              VideoProgressBar({
                playerSession: this.vm.playerSession,
                canChangeSlide: false,
                isProgressFullWidth: true,
                showSlideBlock: false,
                selectedColor: Color.White,
                slideHeight: 14,
              })
            }
            .visibility(this.vm.isLockScreen && !this.vm.isHideSlide ? Visibility.Visible : Visibility.Hidden)
            .width(Constants.FULL_PERCENT)
            .padding({ left: Constants.PADDING_L, right: Constants.PADDING_L })
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              left: { anchor: '__container__', align: HorizontalAlign.Start },
            })
          }
          .width(Constants.FULL_PERCENT)
          .height(Constants.FULL_PERCENT)
        }
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
        .gesture(
          // 组合手势，互斥识别
          GestureGroup(GestureMode.Exclusive,
            // 长按加速
            LongPressGesture({ repeat: true, duration: 300 })
              .onAction((event: GestureEvent) => {
                // 页面锁住时，不能进行操作
                if (!this.vm.isLockScreen) {
                  this.vm.onLongPress(event)
                }
              })
              .onActionCancel(() => {
                // 页面锁住时，不能进行操作
                if (!this.vm.isLockScreen) {
                  this.vm.offLongPress()
                }
              })
              .onActionEnd(() => {
                // 页面锁住时，不能进行操作
                if (!this.vm.isLockScreen) {
                  this.vm.offLongPress()
                }
              }),
            // 双击暂停或播放
            TapGesture({ count: 2 })
              .onAction((event: GestureEvent) => {
                if (!event) {
                  return
                }
                // 页面锁住时，不能进行操作
                if (this.vm.isLockScreen) {
                  return
                }
                if (!this.vm.isBuffering) {
                  this.vm.switchPlayOrPause()
                }
              }),
            // 单击显隐外层视图
            TapGesture({ count: 1 })
              .onAction((event: GestureEvent) => {
                if (event) {
                  this.vm.handleClickScreen()
                }
              }),
            // 竖直滑动修改音量或亮度
            PanGesture({ direction: PanDirection.Vertical })
              .onActionStart((event?: GestureEvent) => {
                this.vm.handleBrightAndVolumePanStart(event)
              })
              .onActionUpdate((event?: GestureEvent) => {
                this.vm.handleBrightAndVolumePanUpdate(event)
              })
              .onActionCancel(() => {
                this.vm.onActionEnd();
              })
              .onActionEnd(() => {
                this.vm.onActionEnd();
              }),
            // 横向滑动更新进度条
            PanGesture({ direction: PanDirection.Horizontal })
              .onActionStart((event?: GestureEvent) => {
                if (this.vm.isHideSlide) {
                  return
                }
                this.vm.handleProgressStart(event)
              })
              .onActionUpdate((event?: GestureEvent) => {
                if (this.vm.isHideSlide) {
                  return
                }
                this.vm.handleProgressUpdate(event)
              })
              .onActionCancel(() => {
                if (this.vm.isHideSlide) {
                  return
                }
                this.vm.handleProgressEnd();
              })
              .onActionEnd(() => {
                if (this.vm.isHideSlide) {
                  return
                }
                this.vm.handleProgressEnd()
              }),
          ),
        )
      }
      .enableAnimation(false)
      .alignContent(Alignment.Center)
    }
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.vm.pathStack = context.pathStack
      let param = context.pathInfo?.param as Record<string, Object | AVPlayerSession | BreakpointNameEnum>;
      this.vm.playerSession = (param.playerSession as AVPlayerSession)
      this.vm.player = (param.playerSession as AVPlayerSession).getAVPlayer() as media.AVPlayer;
      this.vm.videoWidth = param.videoWidth as number
      this.vm.videoHeight = param.videoHeight as number
      this.vm.videoTitle = param.videoTitle as string
      this.vm.breakpointModel = param.breakpointModel as BreakpointModel
      this.vm.isMute = param.isMute as boolean
      this.vm.isHideSlide = param.isHideSlide as boolean
      // 音量初始化
      this.vm.volumeUtil.init()
      this.vm.setMute()
      // 设置亮度
      this.vm.volumeUtil.updateBrightness(this.getUIContext().getHostContext() as Context)
      // 状态监听
      this.vm.playerSession?.onEvent('stateChange', (state: string) => {
        // 横屏时，播放完之后会重头播放，需要保持播放状态
        this.vm.isPlaying = state === AVPlayerState.PLAYING || state === AVPlayerState.COMPLETED
      });
      this.vm.playerSession?.onEvent('bufferingUpdate', (infoType: media.BufferingInfoType) => {
        if (infoType === media.BufferingInfoType.BUFFERING_START) {
          this.vm.isBuffering = true;
        }
        if (infoType === media.BufferingInfoType.BUFFERING_END) {
          this.vm.isBuffering = false
        }
      });
      this.vm.registerCustomTransition(context, this.longTakeSession)
    })
    // 返回后继续播放
    .onBackPressed(() => {
      return this.onBackPressed();
    })
    .onAppear(async () => {
      try {
        await this.vm.windowClass!.setSpecificSystemBarEnabled('navigationIndicator', false);
        await this.vm.windowClass!.setSpecificSystemBarEnabled('status', false);
      } catch (e) {
        Logger.error(TAG, 'onAppear setSpecificSystemBarEnabled fail, error: ' + JSON.stringify(e));
      }
    })
    .onDisAppear(async () => {
      try {
        await this.vm.windowClass!.setSpecificSystemBarEnabled('navigationIndicator', true);
        await this.vm.windowClass!.setSpecificSystemBarEnabled('status', true);
      } catch (e) {
        Logger.error(TAG, 'onDisAppear setSpecificSystemBarEnabled fail, error: ' + JSON.stringify(e));
      }
    })
  }

  @Builder
  videoExtraView() {
    // 系统音量控制面板
    VolumePanelView()
    // 倍速
    PlayerSpeedRateView({
      leftRateOpacity: this.vm.leftRateOpacity,
      rightRateOpacity: this.vm.rightRateOpacity,
      offsetTop: 56,
    })
      .visibility(this.vm.isAccelerate ? Visibility.Visible : Visibility.None)

    // 亮度或音量进度
    this.volumeAndBrightView()
  }

  @Builder
  topRegionView() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(Constants.FULL_PERCENT)
        .height(this.vm.isFullMode ? 104 : 64)
        .linearGradient({
          angle: 180,
          colors: [[Color.Black, 0], [Color.Transparent, 1]],
        })

      Row() {
        Row() {
          Row() {
            Image($r('app.media.ic_left_arrow')).width(9).height(16)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .accessibilityText('退出全屏')
          .onClick(() => {
            this.vm.onBack()
          })

          // 标题
          Text(this.vm.videoTitle ?? '').fontSize(14)
            .fontColor(Color.White)
            .accessibilityLevel('yes')
        }

        // 电池
        Battery()
      }
      .width(Constants.FULL_PERCENT)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(Constants.FULL_PERCENT)
    .height(this.vm.isFullMode ? 104 : 64)
  }

  @Builder
  centerRegionView() {
    RelativeContainer() {
      // 锁屏按钮
      this.lockScreenView()

      Stack() {
        Image(this.vm.isPlaying && !this.vm.isBuffering ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
          .width(50)
          .height(50)
          .visibility(this.vm.showBar && !this.vm.isBuffering ? Visibility.Visible : Visibility.Hidden)
          .animation({ duration: 200 })
          .accessibilityText(this.vm.isPlaying && !this.vm.isBuffering ? '点击暂停' : '点击播放')
          .onClick(() => {
            if (!this.vm.isBuffering) {
              this.vm.switchPlayOrPause()
              this.vm.handleVideoLayerVisible()
            }
          })

        if (this.vm.isBuffering) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color($r('sys.color.icon_on_primary'))
            Text('缓冲中...')
              .fontSize(12)
              .fontColor($r('sys.color.icon_on_primary'))
          }
        }
      }
      .width(60)
      .height(60)
      .alignRules({
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
        center: { anchor: '__container__', align: VerticalAlign.Center },
      })
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
  }

  @Builder
  lockScreenView() {
    Stack() {
      Row()
        .width(50)
        .height(50)
        .borderRadius('50%')
        .backgroundColor(Color.Black)
        .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
      Image(this.vm.isLockScreen ? $r('app.media.ic_lock') : $r('app.media.ic_unlock'))
        .width(30)
        .height(30)
        .objectFit(ImageFit.Contain)
        .accessibilityText(this.vm.isLockScreen ? '点击解锁' : '点击锁屏')
        .onClick(() => {
          this.vm.lockScreen()
        })
    }
    .offset({ left: 56 })
    .alignRules({
      left: { anchor: '__container__', align: HorizontalAlign.Start },
      center: { anchor: '__container__', align: VerticalAlign.Center },
    })
    .visibility(this.vm.showLock ? Visibility.Visible : Visibility.Hidden)
    .animation({ duration: 200 })
  }

  @Builder
  volumeAndBrightView() {
    Row() {
      if (this.vm.volumeUtil.playerSliderModel.showVolumeProgress) {
        PlayerSlider({ type: SliderType.VOLUME })
      } else if (this.vm.volumeUtil.playerSliderModel.showBrightProgress) {
        PlayerSlider({ type: SliderType.BRIGHT })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .offset({ top: 80 })
    .zIndex(2)
  }
}

// 用来设置音量同步系统音量
@Component
struct VolumePanelView {
  @State volume: number = 0

  aboutToAppear(): void {
    emitter.on('systemVolumeChange', (eventData: emitter.EventData) => {
      this.volume = eventData.data!.volume * 15
    })
  }

  build() {
    AVVolumePanel({
      volumeLevel: this.volume,
      volumeParameter: {
        position: {
          x: -50,
          y: 150,
        },
      },
    })
      .width(100)
  }
}