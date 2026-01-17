import { uiObserver, UIUtils, window, AppStorageV2 } from '@kit.ArkUI';
import { Context } from '@kit.AbilityKit';
import {
  BreakpointNameEnum,
  CircleButtonModifier,
  CommonConstants,
  CommonDataSource,
  RouterMap,
  RouterUtils,
  GridRowColSetting,
} from 'lib_common'
import { VideoPipViewModel } from 'lib_av_details';
import {
  AVPlayerSession,
  PiPWindowModel,
  VideoCard,
  VideoCardPlayerController,
  VideoNetworkModel,
  VideoNetworkSetting,
} from 'module_swipeplayer';
import { LongTakeAnimationProperties } from 'module_transition';
import { CommentInfo } from 'module_feedcomment';
import { TabNav, VideoNewsData } from '../models/VideoModel';
import { LivestreamDetailPageVM } from '../viewmodels/LivestreamDetailPageVM';
import { IntroductionView } from '../views/IntroductionView';
import { LiveCommentView, LivestreamCommentListScroller } from '../views/LiveCommentView';
import { LivestreamFooterView } from '../components/LivestreamFooterView';
import { setOrientation } from '../commons/Util';

@Builder
export function LivestreamDetailPageBuilder() {
  LivestreamDetailPage()
}

const TAG = '[LivestreamDetailPage]';

@ComponentV2
export struct LivestreamDetailPage {
  @Local detailData: VideoNewsData | undefined = undefined;
  @Local isLivestream: boolean = false;
  // 路由栈
  pathStack = new NavPathStack()
  videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController();
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  // 评论的懒加载数据源
  @Provider() commentListDataSource: CommonDataSource<CommentInfo> = new CommonDataSource<CommentInfo>();
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local commentListScroller: LivestreamCommentListScroller = new LivestreamCommentListScroller()
  vm: LivestreamDetailPageVM = new LivestreamDetailPageVM();
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();
  @Local videoPipModel:VideoPipViewModel = new VideoPipViewModel()
  private landscapeListener = (info: uiObserver.NavDestinationInfo) => {
    this.pipWindowModel.navDestinationUpdateListeners.forEach((callback, key) => {
      if (key === 'landscapeListener') {
        callback(info)
      }
    })
  }
  // WindowStage生命周期变化的监听回调函数
  private windowStageEventCallback = (type: window.WindowStageEventType) => {
    const allPathStack = RouterUtils.getStack().getAllPathName()
    const lastPathName = allPathStack[allPathStack.length - 1];
    if (lastPathName === RouterMap.LIVESTREAM_DETAIL_PAGE) {
      // 不展示画中画时，保持原有逻辑
      if (!this.vm.settingInfo.network.enableLivePiP) {
        if (type === window.WindowStageEventType.RESUMED || type === window.WindowStageEventType.SHOWN) {
          this.videoCardPlayerController.play()
          this.pipWindowModel.isBackgroundPip = false;
        } else if (type === window.WindowStageEventType.PAUSED || type === window.WindowStageEventType.HIDDEN) {
          this.videoCardPlayerController.pause()
          this.pipWindowModel.isBackgroundPip = true;
        }
      }
    }
  }


  @Computed
  get isTablet() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.vm.breakPointModel.currentBreakpoint);
  }

  @Computed
  get videoBoxHeight() {
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.vm.breakPointModel.currentBreakpoint)) {
      return '100%'
    }
    return this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 200 : 400
  }

  aboutToAppear(): void {
    // 无感监听路由变化
    uiObserver.on('navDestinationUpdate', this.landscapeListener);
    this.videoPipModel.setContext(this.getUIContext().getHostContext() as Context)
    this.vm.windowStageModel.windowStageEventListeners.delete('livestreamDetailPage');
    this.vm.windowStageModel.windowStageEventListeners.set('livestreamDetailPage', (type) => {
      this.windowStageEventCallback(type)
    })
  }

  aboutToDisappear(): void {
    uiObserver.off('navDestinationUpdate', this.landscapeListener)
  }

  getTextColor(item: TabNav, index: number): ResourceColor {
    if (this.vm.indicatorIndex === index) {
      return item.activeColor
    }
    return $r('sys.color.font_primary')
  }

  onBack() {
    this.videoPipModel.enableVideoPip(this.detailData!.id)
    RouterUtils.pop();
  }

  build() {
    NavDestination() {
      // 头部
      this.headerBuilderView();
      GridRow({
        columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 8,
            lg: 8,
          }
        }) {
          Column() {
            Stack({ alignContent: Alignment.TopStart }) {
              Column() {
                VideoCard({
                  currentIndex: 0,
                  index: 0,
                  videoData: this.detailData,
                  isShown: true,
                  videoNetwork: this.vm.networkModel as VideoNetworkModel,
                  videoNetworkSetting: this.vm.settingInfo.network as VideoNetworkSetting,
                  currentBreakpoint: this.vm.breakPointModel.currentBreakpoint,
                  videoCardPlayerController: this.videoPipModel.getVideoCardPlayerController(),
                  isFromDetailCard: true,
                  completedBtnBuilder: this.isLivestream ? wrapBuilder(liveCompletedBtnView) :
                    wrapBuilder(completedBtnView),
                  canChangeSlide: !this.isLivestream,
                  isHideSlide: this.isLivestream,
                  pathStack: this.pathStack,
                  xComponentReadyCallback: (controller: XComponentController) => {
                    this.videoPipModel.setMXComponentController(controller)
                    this.videoPipModel.handlePip()
                  },
                })
                  .clip(true)
              }
              .width('100%')
              .height(this.videoBoxHeight)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(Color.Black)

              Column() {
                // 头部
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
                    this.onBack();
                  })
                }
                .height(56)
                .padding({left: CommonConstants.PADDING_L})
                .alignItems(VerticalAlign.Center)
                .visibility(this.isTablet ? Visibility.Visible : Visibility.None)

                Row({ space: CommonConstants.SPACE_S }) {
                  Row({ space: 2 }) {
                    Image(this.isLivestream ? $r('app.media.ic_live') : $r('app.media.ic_playback'))
                      .width(this.isLivestream ? 12 : 11)
                      .height(this.isLivestream ? 12 : 7)
                    Text(this.isLivestream ? '直播中' : '精彩回顾')
                      .fontSize(10)
                      .fontColor(Color.White)
                      .lineHeight(13)
                  }
                  .padding({
                    left: 8,
                    top: 3,
                    right: 8,
                    bottom: 3,
                  })
                  .borderRadius(4)
                  .backgroundColor(this.isLivestream ? $r('sys.color.warning') : '#33000000')

                  if (this.isLivestream) {
                    Text('2078人观看')
                      .fontSize(10)
                      .fontColor(Color.White)
                      .lineHeight(13)
                      .padding({
                        left: 8,
                        top: 3,
                        right: 8,
                        bottom: 3,
                      })
                      .borderRadius(4)
                      .backgroundColor('#33000000')
                  }
                }
                .padding({ left: CommonConstants.PADDING_L, top: CommonConstants.PADDING_L })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .priorityGesture(
              GestureGroup(GestureMode.Exclusive,
                // 双击暂停或播放
                TapGesture({ count: 2 })
                  .onAction((event: GestureEvent) => {
                    if (!event) {
                      return
                    }
                    this.videoPipModel.getVideoCardPlayerController().switchPlayPause()
                  }),
              ),
            )

            if (!this.isTablet) {
              // tab页签
              this.tabHeaderView()
              // tab内容
              this.tanContentView()
              // 底部区域
              LivestreamFooterView({
                livestreamInfo: this.vm.livestreamInfo,
                commentListScroller: this.commentListScroller,
              })
            }
          }
          .padding({
            top: this.isTablet ? this.vm.windowModel.windowTopPadding : 0,
            bottom: this.isTablet ? this.vm.windowModel.windowBottomPadding : 0,
          })
        }
        if (this.isTablet) {
          GridCol({
            span: {
              lg: 4,
            }
          }) {
            Column() {
              // tab页签
              this.tabHeaderView()
              // tab内容
              this.tanContentView()
              // 底部区域
              LivestreamFooterView({
                livestreamInfo: this.vm.livestreamInfo,
                commentListScroller: this.commentListScroller,
              })
            }
            .padding({
              top: this.vm.windowModel.windowTopPadding,
              bottom: this.vm.windowModel.windowBottomPadding,
            })
            .backgroundColor($r('sys.color.comp_background_primary'))
          }
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor(this.isTablet ? '#000000' : $r('sys.color.comp_background_primary'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      let param = context.pathInfo?.param as Record<string, boolean | VideoNewsData>
      this.detailData = param.detailData as VideoNewsData;
      this.vm.livestreamInfo = UIUtils.makeObserved(this.detailData)
      this.isLivestream = param.isLivestream as boolean;
      this.vm.init()
      this.commentListDataSource.setData(this.vm.commentList)

      this.vm.registerCustomTransition(this.longTakeSession, context)
    })
    .onBackPressed(() => {
      this.onBack();
      return true;
    })
    .onWillShow(() => {
      this.pipWindowModel.isBackPiP = false;
      setOrientation(window.Orientation.FOLLOW_DESKTOP);
    })
    .onShown(() => {
      this.videoPipModel.initVideoPip()
    })
    .onWillDisappear(() => {
      if (!this.vm.settingInfo.network.enableLivePiP) {
        this.videoPipModel.getVideoCardPlayerController().pause();
        this.pipWindowModel.pipController?.setAutoStartEnabled(false);
      }
    })
  }

  @Builder
  headerBuilderView() {
    Row() {
      Row({ space: CommonConstants.SPACE_S }) {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontColor([$r('sys.color.font_primary')])
            .fontWeight(FontWeight.Normal)
            .fontSize($r('app.float.normal_img_size'))
        }
        .attributeModifier(this.buttonModifier)
        .accessibilityText('返回')
        .onClick(() => {
          this.onBack();
        })

        Text(this.detailData?.title)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .height($r('app.float.nav_header_height'))
    }
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
      top: this.vm.windowModel.windowTopPadding,
    })
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.Transparent)
    .visibility(this.isTablet ? Visibility.None : Visibility.Visible)
  }

  @Builder
  tabHeaderView() {
    List({ space: CommonConstants.SPACE_L }) {
      ForEach(this.vm.tabNavs, (item: TabNav, index: number) => {
        ListItem() {
          this.tabBuilder(item, index)
        }
      }, (item: TabNav, index: number) => item.id + index)
    }
    .height(56)
    .width(CommonConstants.FULL_PERCENT)
    .listDirection(Axis.Horizontal)
    .padding({ left: CommonConstants.PADDING_L, right: CommonConstants.PADDING_L })
    .alignListItem(ListItemAlign.Start)
    .border({
      width: { bottom: 0.5 },
      color: '#33000000',
      style: BorderStyle.Solid,
    })
  }

  @Builder
  tabBuilder(item: TabNav, index: number) {
    Column() {
      Text(item.name)
        .fontColor(this.getTextColor(item, index))
        .fontSize(16)
        .fontWeight(this.vm.indicatorIndex === index ? 600 : 400)

      Row() {
      }
      .width(16)
      .height(2)
      .borderRadius(1)
      .backgroundColor(this.vm.indicatorIndex === index ? item.activeColor : '')
      .position({ left: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
    }
    .justifyContent(FlexAlign.Center)
    .height(CommonConstants.FULL_PERCENT)
    .onClick(() => {
      this.vm.indicatorIndex = index;
      this.vm.currentTabIndex = index;
    })
  }

  @Builder
  tanContentView() {
    Tabs({ controller: this.vm.tabController, index: this.vm.currentTabIndex }) {
      TabContent() {
        IntroductionView()
      }

      TabContent() {
        LiveCommentView({
          commentListScroller: this.commentListScroller,
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .layoutWeight(1)
    .barHeight(0)
    .scrollable(!this.vm.videoExtraInfoModel.isDisplayChange)
    .animationDuration(100)
    .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
      this.vm.handleAnimationStart(_index, targetIndex)
    })
    .onChange((index: number) => {
      this.vm.currentTabIndex = index;
    })
  }
}

@Builder
export function completedBtnView(playerSession: AVPlayerSession) {
  Row({ space: 8 }) {
    Image($r('app.media.ic_replay')).width(12).height(12)
    Text('重新播放')
      .fontSize(14)
      .fontColor(Color.White)
      .lineHeight(20)
  }
  .padding({
    left: 10,
    right: 10,
    top: 4,
    bottom: 4,
  })
  .borderRadius(20)
  .backgroundColor('#1b1a1b')
  .zIndex(9)
  .onClick(() => {
    playerSession.play()
  })
}

@Builder
export function liveCompletedBtnView(playerSession: AVPlayerSession) {
  Row({ space: 8 }) {
    Image($r('app.media.ic_replay')).width(12).height(12)
    Text('查看回放')
      .fontSize(14)
      .fontColor(Color.White)
      .lineHeight(20)
  }
  .padding({
    left: 10,
    right: 10,
    top: 4,
    bottom: 4,
  })
  .borderRadius(20)
  .backgroundColor('#1b1a1b')
  .zIndex(9)
  .onClick(() => {
    playerSession.play()
  })
}

