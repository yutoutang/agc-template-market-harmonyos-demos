import { uiObserver, UIUtils, window } from '@kit.ArkUI';
import { CircleButtonModifier, CommonConstants, CommonDataSource, RouterMap, RouterUtils } from 'lib_common'
import { VideoCard, VideoCardPlayerController, VideoNetworkModel, VideoNetworkSetting } from 'module_swipeplayer';
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

@ComponentV2
export struct LivestreamDetailPage {
  @Local detailData: VideoNewsData | undefined = undefined;
  @Local isLivestream: boolean = false;
  // 路由栈
  pathStack = new NavPathStack()
  videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController();
  @Provider() navDestinationUpdateListeners: Map<string, (info: uiObserver.NavDestinationInfo) => void> = new Map();
  // 评论的懒加载数据源
  @Provider() commentListDataSource: CommonDataSource<CommentInfo> = new CommonDataSource<CommentInfo>();
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local commentListScroller: LivestreamCommentListScroller = new LivestreamCommentListScroller()
  vm: LivestreamDetailPageVM = new LivestreamDetailPageVM();
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();
  private landscapeListener = (info: uiObserver.NavDestinationInfo) => {
    this.navDestinationUpdateListeners.forEach((callback, key) => {
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
      let eventType = window.WindowStageEventType;
      if (type === eventType.RESUMED || type === eventType.SHOWN) {
        this.videoCardPlayerController.play()
      } else if (type === eventType.PAUSED || type === eventType.HIDDEN) {
        this.videoCardPlayerController.pause()
      }
    }
  }

  aboutToAppear(): void {
    // 无感监听路由变化
    uiObserver.on('navDestinationUpdate', this.landscapeListener);

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

  build() {
    NavDestination() {
      // 头部
      this.headerBuilderView();

      Stack({ alignContent: Alignment.TopStart }) {
        VideoCard({
          currentIndex: 0,
          index: 0,
          videoData: this.detailData,
          isShown: true,
          videoNetwork: this.vm.networkModel as VideoNetworkModel,
          videoNetworkSetting: this.vm.settingInfo.network as VideoNetworkSetting,
          currentBreakpoint: this.vm.breakPointModel.currentBreakpoint,
          videoCardPlayerController: this.videoCardPlayerController,
          isFromDetailCard: true,
          canChangeSlide: !this.isLivestream,
          pathStack: this.pathStack,
        })
          .clip(true)
          .constraintSize({ maxHeight: 400 })

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
      .priorityGesture(
        GestureGroup(GestureMode.Exclusive,
          // 双击暂停或播放
          TapGesture({ count: 2 })
            .onAction((event: GestureEvent) => {
              if (!event) {
                return
              }
              this.videoCardPlayerController.switchPlayPause()
            }),
        ),
      )

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
    .hideTitleBar(true)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
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
    .onWillShow(() => {
      setOrientation(window.Orientation.FOLLOW_DESKTOP)
    })
    .onWillDisappear(() => {
      this.videoCardPlayerController.pause();
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
          RouterUtils.pop()
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
    .backgroundColor('#00000000')
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