import { common } from '@kit.AbilityKit';
import { uiObserver, window } from '@kit.ArkUI'
import { util } from '@kit.ArkTS';
import {
  CircleButtonModifier,
  CommonConstants,
  GridRowColSetting,
  NetworkUtil,
  RouterMap,
  RouterUtils,
  SystemBarOperation } from 'lib_common';
import { NewsResponse } from 'lib_news_api';
import { NetworkExceptionView, NewsSearchTransition } from 'lib_widget';
import {
  AVPlayerSession,
  VideoNetworkModel,
  VideoNetworkSetting,
  VideoSwipePlayer,
} from 'module_swipeplayer';
import { LongTakeAnimationProperties, LongTakeTransitionDelegate } from 'module_transition';
import { VideoNewsData } from '../models/VideoModel';
import { VideoLayerViewBuilder } from '../components/VideoLayerView';
import { VideoDetailPageModel } from '../models/VideoDetailPageModel';
import { BaseParamType } from '../types/Index';
import { CommentView } from '../components/CommentView';

@Builder
export function VideoDetailBuilder() {
  VideoDetailPage()
}

@ComponentV2
export struct VideoDetailPage {
  pathStack = new NavPathStack()
  // 数据源
  @Local videoList: VideoNewsData[] = [];
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  buttonModifier: CircleButtonModifier = new CircleButtonModifier();
  vm: VideoDetailPageModel = new VideoDetailPageModel()
  // WindowStage生命周期变化的监听回调函数
  private windowStageEventCallback = (type: window.WindowStageEventType) => {
    const allPathStack = this.pathStack.getAllPathName()
    const lastPathName = allPathStack[allPathStack.length - 1];
    if (lastPathName === RouterMap.VIDEO_DETAIL_PAGE) {
      let eventType = window.WindowStageEventType
      if (type === eventType.RESUMED || type === eventType.SHOWN) {
        this.vm.swipePlayerController.play();
      } else if (type === eventType.PAUSED || type === eventType.HIDDEN) {
        this.vm.swipePlayerController.pause();
      }
    }
  }

  aboutToAppear(): void {
    // 模拟首次进入页面时，判断是否展示网络异常页面
    this.vm.showExceptionPage = !this.vm.networkModel.isNetworkAvailable
    // 监听 windowStageEvent
    this.vm.windowStageModel.windowStageEventListeners.delete('videoDetailPage');
    this.vm.windowStageModel.windowStageEventListeners.set('videoDetailPage', (type) => {
      this.windowStageEventCallback(type)
    })
    // 记录路由跳转之前视频的播放状态
    let avPlayerState = ''
    // 监听页面跳转
    this.vm.navRouteModel.navDestinationUpdateListeners.delete('leaveVideoDetailPageListener')
    this.vm.navRouteModel.navDestinationUpdateListeners.set('leaveVideoDetailPageListener', (info) => {
      if (this.vm.navRouteModel.videoPauseByRoutePage.includes(info.name) &&
      this.pathStack.getIndexByName(RouterMap.VIDEO_DETAIL_PAGE).length &&
        info.state === uiObserver.NavDestinationState.ON_WILL_SHOW
      ) {
        avPlayerState = this.vm.swipePlayerController.getAVPlayer()?.state as string
        this.vm.swipePlayerController.pause();
        return;
      }

      if (info.name === RouterMap.VIDEO_DETAIL_PAGE &&
        info.state === uiObserver.NavDestinationState.ON_WILL_SHOW
      ) {
        // 如果跳转之前是播放状态，则返回时继续播放，否则暂停
        if (avPlayerState === 'playing') {
          this.vm.swipePlayerController.play();
        }
      }
    });
  }


  @Builder
  ContentBuilder() {
    Stack() {
      GridRow({
        columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS
      }) {
        GridCol({
          span: {
            sm: 4,
            md: this.vm.isShowSideComment ? 4 : 8,
            lg: this.vm.isShowSideComment ? 8 : 12,
          }
        }) {
          Stack({ alignContent: Alignment.TopStart }) {
            if (this.vm.showExceptionPage) {
              if (!this.vm.loading) {
                NetworkExceptionView({
                  refreshNetwork: () => {
                    this.vm.loading = true;
                    // 模拟请求判断网络能否使用
                    let networkUtil = NetworkUtil.getInstance()
                    networkUtil.handleNetworkAvailable();
                    setTimeout(() => {
                      // 模拟
                      if (this.vm.networkModel.isNetworkAvailable) {
                        this.vm.initVideoDataSource()
                        this.vm.showExceptionPage = false;
                      } else {
                        this.vm.loading = false
                      }
                    }, 100)
                  }
                })
              }
            } else {
              VideoSwipePlayer({
                datasource: this.vm.videoDataSources,
                swipePlayerController: this.vm.swipePlayerController,
                videoItemPlayerSession: this.vm.videoItemPlayerSession,
                videoLayerBuilder: wrapBuilder(VideoLayerViewBuilder),
                videoNetwork: this.vm.networkModel as VideoNetworkModel,
                videoNetworkSetting: this.vm.settingInfo.network as VideoNetworkSetting,
                pathStack: this.pathStack,
                isShown: this.vm.isShown,
                isLandscape: this.vm.displayModel.isLandscape,
                currentBreakpoint: this.vm.breakPointModel.currentBreakpoint,
                playerStateCallback: (state: string, id: string) => {
                  this.vm.onPlayerStateListen(state, id)
                },
                playerTimeUpdateCallback: (id: string, timeMs: number) => {
                  this.vm.setContinueData(id, timeMs)
                },
                options: {
                  autoPlay: true,
                  totalCount: this.vm.totalCount,
                  bottomTabHeight: this.vm.tabModel.tabHeight,
                  swiperCallback: {
                    onAnimationStart: (_index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
                      this.vm.handleSwiperAnimationStart(_index, targetIndex)
                      // 判断是否到底
                      if (_index === targetIndex && this.vm.totalCount === targetIndex + 1) {
                        this.getUIContext().getPromptAction().showToast({
                          message: '暂无更多视频',
                          alignment: Alignment.Center,
                        });
                      }
                    },
                  },
                }
              })
            }

            Row() {
              Button() {
                SymbolGlyph($r('sys.symbol.chevron_backward'))
                  .fontColor([$r('sys.color.white')])
                  .fontWeight(FontWeight.Normal)
                  .fontSize($r('app.float.normal_img_size'))
              }
              .attributeModifier(this.buttonModifier)
              .accessibilityText('返回')
              .onClick(() => {
                RouterUtils.pop()
              })
              NewsSearchTransition({
                isVideo:true,
                componentId: 'videoPage' + util.generateRandomUUID(),
                indicatorIndex: 0
              })
                .visibility(this.vm.showExceptionPage ? Visibility.Hidden : Visibility.Visible)
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({
              left: CommonConstants.PADDING_S,
              right: CommonConstants.PADDING_L,
              top: this.vm.windowModel.windowTopPadding,
            })
            // 从右向左滑，进入用户信息界面
            Column() {
            }
            .width(CommonConstants.FULL_PERCENT)
            .height('75%')
            .backgroundColor(Color.Transparent)
            .hitTestBehavior(HitTestMode.Transparent)
            .gesture(
              PanGesture({ direction: PanDirection.Left })
                .onActionUpdate((event: GestureEvent) => {
                  if (event) {
                    this.vm.offsetX = event.offsetX;
                  }
                })
                .onActionCancel(() => {
                  this.vm.handleSwiperRightAction()
                })
                .onActionEnd(() => {
                  this.vm.handleSwiperRightAction()
                })
            )
            .priorityGesture(
              PanGesture({ direction: PanDirection.Left })
                .onActionUpdate((event: GestureEvent) => {
                  if (event) {
                    this.vm.offsetX = event.offsetX;
                  }
                })
                .onActionEnd(() => {
                  this.vm.handleSwiperRightAction()
                })
            )
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .backgroundColor(Color.Black)
          .padding({
            bottom: this.vm.windowModel.windowBottomPadding
          })
        }
      }

      // 评论区适配双折叠和平板
      if (this.vm.isShowSideComment) {
        GridRow({
          columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS
        }) {
          GridCol({
            span: {
              md: this.vm.isShowSideComment ? 4 : 8,
              lg: this.vm.isShowSideComment ? 8 : 12,
            }
          }) {
            Column() {
            }
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.vm.videoExtraInfoModel.isDisplayChange = false;
            })
          }
          .backgroundColor(Color.Transparent)

          GridCol({ span: { md: 4, lg: 4 } }) {
            Column() {
              CommentView({
                videoInfo: this.vm.videoExtraInfoModel.videoInfo as NewsResponse,
              })
            }
          }
        }
        .width('100%')
        .height('100%')
      }
    }
  }

  build() {
    NavDestination() {
      if (this.vm.needLongTake && this.longTakeSession) {
        LongTakeTransitionDelegate({
          longTakeSession: this.longTakeSession,
          contentBuilder: (): void => {
            this.ContentBuilder()
          },
        })
      } else {
        this.ContentBuilder()
      }
    }
    .hideTitleBar(true)
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
    .backgroundColor(this.longTakeSession.navDestinationBgColor)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      let param = context.pathInfo?.param as Record<string, AVPlayerSession | BaseParamType | Object>
      // 初始化播放管理
      this.vm.initAVPlayerMgr(param)
      // 获取数据
      this.vm.initVideoListDataSource(param)
      if (this.vm.needLongTake) {
        this.vm.registerCustomTransition(param,this.longTakeSession,context)
      }
      this.vm.enableContinue(this.getUIContext().getHostContext() as common.UIAbilityContext);
      this.vm.isShown = true;
    })
    .onWillDisappear(() => {
      if (this.vm.needReleasePlayer ||
        (!this.vm.needReleasePlayer && this.vm.swipePlayerController.curentIndex !== 0)
      ) {
        this.vm.swipePlayerController.getAVPlayer()?.release()
        this.vm.swipePlayerController.getAVPlayerMgr()?.clear()
        this.vm.continueModel.playerProgress = 0
      }
    })
    .onDisAppear(() => {
      this.vm.isShown = false;
    })
    .onShown(() => {
      setTimeout(() => {
        SystemBarOperation.setWindowSystemBarProp({
          statusBarContentColor: '#ffffff',
        })
      }, 300)
    })
    .onHidden(() => {
      SystemBarOperation.setWindowSystemBarProp({
        statusBarContentColor: '#ff090909',
      })
    })
  }
}

