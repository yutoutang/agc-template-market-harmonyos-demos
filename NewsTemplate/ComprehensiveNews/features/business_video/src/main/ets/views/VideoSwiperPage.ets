import { uiObserver, window } from '@kit.ArkUI';
import { VideoSwipePlayer, VideoNetworkModel, VideoNetworkSetting } from 'module_swipeplayer';
import {
  CommonConstants,
  SystemBarOperation,
  RouterUtils,
  GridRowColSetting,
  NetworkUtil
} from 'lib_common';
import { NewsResponse } from 'lib_news_api';
import { NetworkExceptionView } from 'lib_widget';
import { VideoLayerViewBuilder } from '../components/VideoLayerView';
import { VideoSwipePageVM } from '../viewmodels/VideoSwipePageVM';
import { TabPageType } from '../types/Index';
import { CommentView } from '../components/CommentView';

@ComponentV2({ freezeWhenInactive: true })
export struct VideoSwiperPage {
  // tab页面的index
  @Param index: number = 1
  // 视频页里面的头部tabIndex
  @Param currentTabIndex: number = 1;
  // tab的页面类别
  @Param pageType: TabPageType = TabPageType.FEATURED
  // 是否刷新页面
  @Consumer() isRefreshPage: boolean = false;
  // 路由栈
  @Local pathStack: NavPathStack = RouterUtils.getStack('main')
  @Local vm: VideoSwipePageVM = new VideoSwipePageVM()
  // WindowStage生命周期变化的监听回调函数
  private windowStageEventCallback = (type: window.WindowStageEventType) => {
    if (this.currentTabIndex === this.index && this.vm.tabModel.selectedIndex === 1) {
      let eventType = window.WindowStageEventType
      if (type === eventType.RESUMED || type === eventType.SHOWN) {
        this.vm.swipePlayerController.getAVPlayer()?.play();
      } else if (type === eventType.PAUSED || type === eventType.HIDDEN) {
        this.vm.swipePlayerController.getAVPlayer()?.pause()
      }
    }
  }

  // 切换视频头部tab
  @Monitor('currentTabIndex')
  onChangeTabIndex() {
    if (this.currentTabIndex === this.index) {
      this.vm.swipePlayerController.play();
    } else {
      this.vm.swipePlayerController.pause();
    }
    this.vm.tabModel.showTabBar = true;
  }

  // 切换底部tab
  @Monitor('vm.tabModel.selectedIndex')
  onChangeSelectedIndex() {
    if (this.currentTabIndex === this.index) {
      let swiperPlayerIdx = [0, 1];
      if (this.vm.tabModel.selectedIndex === 1 && swiperPlayerIdx.includes(this.currentTabIndex)) {
        this.vm.swipePlayerController.play();
      } else {
        this.vm.swipePlayerController.pause();
      }
    }
  }

  // 监听是否刷新
  @Monitor('isRefreshPage')
  onRefreshPage() {
    if (this.currentTabIndex === this.index && this.isRefreshPage) {
      setTimeout(() => {
        // 刷新数据
        this.vm.initVideoDataSource();
        this.isRefreshPage = false;
        // 回到第一个
        this.vm.swipePlayerController?.changeIndex(0, false)
      }, 500)
    }
  }

  aboutToAppear(): void {
    this.vm.pageType = this.pageType;
    this.vm.swipePlayerController.setAVPlayerMgr(this.vm.avPlayerManager)
    // 初始化视频数据
    this.vm.initVideoDataSource()
    // 模拟首次进入页面时，判断是否展示网络异常页面
    this.vm.showExceptionPage = !this.vm.networkModel.isNetworkAvailable
    // 监听 windowStageEvent
    this.vm.windowStageModel.windowStageEventListeners.delete('videoSwiperPage');
    this.vm.windowStageModel.windowStageEventListeners.set('videoSwiperPage', (type) => {
      this.windowStageEventCallback(type)
    })

    // 记录路由跳转之前视频的播放状态
    let avPlayerState = ''
    // 监听页面跳转
    this.vm.navRouteModel.navDestinationUpdateListeners.delete('leaveVideoPageListener_' + this.index)
    this.vm.navRouteModel.navDestinationUpdateListeners.set('leaveVideoPageListener_' + this.index, (info) => {
      if (this.vm.navRouteModel.videoPauseByRoutePage.includes(info.name) &&
        info.state === uiObserver.NavDestinationState.ON_WILL_SHOW
      ) {
        avPlayerState = this.vm.swipePlayerController.getAVPlayer()?.state as string
        this.vm.swipePlayerController.pause();
        SystemBarOperation.setWindowSystemBarProp({
          statusBarContentColor: this.vm.settingInfo.darkSwitch ? '#ffffff' : '#ff090909',
        })
        return;
      }

      if (info.name === 'IndexPage' && this.vm.tabModel.selectedIndex === 1 &&
        info.state === uiObserver.NavDestinationState.ON_WILL_SHOW &&
        this.index === this.currentTabIndex
      ) {
        // 如果跳转之前是播放状态，则返回时继续播放，否则暂停
        if (avPlayerState === 'playing') {
          this.vm.swipePlayerController.play();
        }
        setTimeout(() => {
          SystemBarOperation.setWindowSystemBarProp({
            statusBarContentColor: '#ffffff',
          })
        }, 300)
      }
    });
  }

  build() {
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
          Stack({alignContent: Alignment.Top}) {
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
              this.loadingView()
              Refresh({ refreshing: $$this.vm.isRefreshing, builder: this.customRefreshComponent }) {
                VideoSwipePlayer({
                  datasource: this.vm.videoDataSources,
                  swipePlayerController: this.vm.swipePlayerController,
                  videoLayerBuilder: wrapBuilder(VideoLayerViewBuilder),
                  videoNetwork: this.vm.networkModel as VideoNetworkModel,
                  videoNetworkSetting: this.vm.settingInfo.network as VideoNetworkSetting,
                  pathStack: this.pathStack,
                  isLandscape: this.vm.displayModel.isLandscape,
                  currentBreakpoint: this.vm.breakPointModel.currentBreakpoint,
                  isShown: this.vm.tabModel.selectedIndex === 1 && this.currentTabIndex === this.index,
                  playerStateCallback: (state: string, id: string) => {
                    this.vm.onPlayerStateListen(state, id)
                  },
                  options: {
                    autoPlay: this.currentTabIndex === this.index,
                    bottomTabHeight: this.vm.tabModel.tabHeight,
                    totalCount: Number.POSITIVE_INFINITY,
                    swiperCallback: {
                      onAnimationStart: (_index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
                        this.vm.handleSwiperAnimationStart(_index, targetIndex)
                      },
                      onChange: (index: number) => {
                        this.vm.handleSwiperChange(index)
                      }
                    }
                  }
                })
              }
              .layoutWeight(1)
              .accessibilityLevel('no')
              .onRefreshing(() => {
                this.vm.refreshList()
              })
              .pullToRefresh(true)
              .pullDownRatio(this.vm.ratio)
              .refreshOffset(56)
              .onStateChange((state: RefreshStatus) => {
                this.vm.refreshStatus = state;
              })
              .onOffsetChange((offset: number) => {
                this.vm.offsetChanged(offset)
              })
            }
          }
          .backgroundColor(Color.Black)
          .padding({ bottom: this.vm.pagePaddingBottom })
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
                isShowKeyboard: this.vm.videoExtraInfoModel.isShowKeyboard as boolean,
              })
            }
          }
        }
        .width('100%')
        .height('100%')
      }
    }
  }

  @Builder
  loadingView() {
    Row() {
      LoadingProgress()
        .height(32)
        .color(Color.White)
    }
    .height(32)
    .width(CommonConstants.FULL_PERCENT)
    .padding({ top: this.vm.windowModel.windowTopPadding + 62, bottom: 16 })
    .clip(true)
    .justifyContent(FlexAlign.Center)
    .zIndex(2)
    .visibility(
      (this.vm.status.includes(this.vm.refreshStatus) && this.vm.refreshOffset > 36) ||
      this.isRefreshPage ? Visibility.Visible : Visibility.Hidden,
    )
  }

  @Builder
  customRefreshComponent() {
    Row() {
    }
    .height(32)
    .width(CommonConstants.FULL_PERCENT)
  }
}