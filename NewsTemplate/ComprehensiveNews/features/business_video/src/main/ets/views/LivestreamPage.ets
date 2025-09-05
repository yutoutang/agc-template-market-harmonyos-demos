import { CommonConstants, NetworkUtil } from 'lib_common';
import { NetworkExceptionView } from 'lib_widget';
import { LiveHighlightsView } from '../components/LiveHighlightsView';
import { LiveNoticePreview } from '../components/LiveNoticePreview';
import { LivestreamCard } from '../components/LivestreamCard';
import { VideoNewsData } from '../models/VideoModel';
import { LivestreamPageVM } from '../viewmodels/LivestreamPageVM';

@ComponentV2
export struct LivestreamPage {
  // tab页面的index
  @Param index: number = 3
  // 视频页里面的头部tabIndex
  @Param currentTabIndex: number = 3;
  vm: LivestreamPageVM = new LivestreamPageVM()

  aboutToAppear(): void {
    // 模拟首次进入页面时，判断是否展示网络异常页面
    this.vm.showExceptionPage = !this.vm.networkModel.isNetworkAvailable;
    this.vm.init()
  }

  build() {
    Column() {
      if (this.vm.showExceptionPage) {
        if (!this.vm.loading) {
          NetworkExceptionView({
            textFontColor: $r('sys.color.font_primary'),
            btnFontColor: $r('sys.color.font_primary'),
            btnBorderColor: $r('sys.color.font_primary'),
            refreshNetwork: () => {
              this.vm.loading = true;
              // 模拟请求判断网络能否使用
              let networkUtil = NetworkUtil.getInstance()
              networkUtil.handleNetworkAvailable();
              setTimeout(() => {
                // 模拟
                if (this.vm.networkModel.isNetworkAvailable) {
                  this.vm.init()
                  this.vm.showExceptionPage = false;
                } else {
                  this.vm.loading = false
                }
              }, 100)
            }
          })
        }
      } else {
        Refresh({ refreshing: $$this.vm.isRefreshing, builder: this.customRefreshComponent }) {
          Scroll() {
            Column({ space: CommonConstants.SPACE_M }) {
              // 直播预告
              LiveNoticePreview({
                swiperData: this.vm.livestreamPreviewList
              })
              // 直播Banner
              Row() {
                this.liveBannerView()
              }
              // 精彩回放
              Column() {
                this.liveHighlightsTitle()
                LiveHighlightsView({
                  liveHighlightsList: this.vm.liveHighlightsList,
                  currentBreakpoint: this.vm.breakPointModel.currentBreakpoint
                })
              }
              .width(CommonConstants.FULL_PERCENT)
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
        }
        .layoutWeight(1)
        .pullToRefresh(true)
        .pullDownRatio(this.vm.ratio)
        .refreshOffset(64)
        .accessibilityLevel('no')
        .onRefreshing(() => {
          this.vm.refreshList()
        })
        .onStateChange((state: RefreshStatus) => {
          this.vm.refreshStatus = state;
        })
        .onOffsetChange((offset: number) => {
          this.vm.offsetChanged(offset)
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_L,
      top: this.vm.windowModel.windowTopPadding + 56,
      bottom: this.vm.pagePaddingBottom,
      right: CommonConstants.PADDING_L,
    })
  }

  @Builder
  liveBannerView() {
    Swiper() {
      LazyForEach(this.vm.liveBannerListDataSource, (item: VideoNewsData, index: number) => {
        LivestreamCard({
          cardData: item,
          showLiveTag: true,
          imgBorderRadius: 16,
          titleFontSize: 16,
        })
      }, (item: VideoNewsData, index: number) => JSON.stringify(item) + index)
    }
    .displayCount(this.vm.getDisplayCount())
    .itemSpace(12)
    .loop(false)
    .indicator(false)
  }

  @Builder
  liveHighlightsTitle() {
    Row() {
      Text('精彩回放')
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .fontSize(18)
        .lineHeight(24)
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
    .padding({ top: CommonConstants.PADDING_L, bottom: CommonConstants.PADDING_L})
  }

  @Builder
  customRefreshComponent() {
    Stack() {
      LoadingProgress()
        .height(32)
    }
    .align(Alignment.Bottom)
    .padding({top: 16, bottom: 16})
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width('100%')
  }
}