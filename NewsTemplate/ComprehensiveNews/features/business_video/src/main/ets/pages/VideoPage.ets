import { emitter } from '@kit.BasicServicesKit';
import { CommonConstants, VideoType } from 'lib_common';
import { VideoViewModel } from '../viewmodels/VideoViewModel';
import { FollowPage } from '../views/FollowPage';
import { FeaturedPage } from '../views/FeaturedPage';
import { RecommendPage } from '../views/RecommendPage';
import { TabHeaderView } from '../components/TabHeaderView';
import { LivestreamPage } from '../views/LivestreamPage';
import { BroadcastPage } from '../views/BroadcastPage';
import { TelevisionPage } from '../views/TelevisionPage';


@Builder
export function VideoPageBuilder() {
  VideoPage()
}

@ComponentV2
struct VideoPage {
  // 是否刷新页面，下滑滚动多个视频时，点击对应的tab，刷新页面
  @Provider() isRefreshPage: boolean = false;
  // 实例
  vm: VideoViewModel = new VideoViewModel()

  aboutToAppear(): void {
    this.vm.setWindowSystemBarContentColor('#ffffff')

    // 视频评论出现时，tab头部隐藏
    emitter.on('showTabHeader', (eventData: emitter.EventData) => {
      this.vm.showTabHeader = eventData.data!.showTabHeader
    })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 导航栏
      Column() {
        TabHeaderView({
          tabNavs: this.vm.tabNavs,
          currentTabIndex: this.vm.currentTabIndex,
          indicatorIndex: this.vm.indicatorIndex,
          onChangeTabIndex: (index: number) => {
            this.isRefreshPage = this.vm.currentTabIndex === index
            this.vm.onChangeTabIndex(index)
          },
        })
      }
      .animation({ duration: 200 })
      .visibility(this.vm.showTabHeader ? Visibility.Visible : Visibility.Hidden)
      .zIndex(2)

      // 内容
      Column() {
        this.tabContentView()
      }
      .zIndex(1)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  @Builder
  tabContentView() {
    Tabs({ controller: this.vm.tabController, index: this.vm.currentTabIndex }) {
      TabContent() {
        // 关注
        FollowPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.FOLLOW,
        })
      }

      TabContent() {
        // 精选
        FeaturedPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.CHOICE,
        })
      }

      TabContent() {
        // 推荐
        RecommendPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.RECOMMEND,
        })
      }

      TabContent() {
        // 直播
        LivestreamPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.LIVE,
        })
      }

      TabContent() {
        // 电视
        TelevisionPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.TELEVISION,
        })
      }

      TabContent() {
        // 广播
        BroadcastPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.BROADCAST,
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .layoutWeight(1)
    .barHeight(0)
    .scrollable(!this.vm.videoExtraInfoModel.isDisplayChange)
    .animationDuration(100)
    .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
      this.vm.handleTabAnimationStart(_index, targetIndex)
    })
    .onChange((index: number) => {
      this.vm.currentTabIndex = index;
    })
  }
}