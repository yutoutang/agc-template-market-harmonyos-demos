import { CommonConstants, CommonBreakpoint } from 'lib_common'
import { LoadMoreFooter } from 'lib_flex_layout';
import { NewsResponse } from 'lib_news_api';
import { TabEnum, TabItem } from '../common/Constants';
import { InteractionViewModel } from '../viewmodels/InteractionViewModel';
import { InteractionFeedCard } from './InteractionFeedCard'
import { NoWatcher } from './NoWatcher';

@ComponentV2
export struct InterActionTabContent {
  @Param @Require resource: TabItem
  @Param @Require selectedId: number
  @Local vm: InteractionViewModel = new InteractionViewModel(this.getUIContext());
  @Local lanesCount: CommonBreakpoint<number> = new CommonBreakpoint<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  @Monitor('selectedId')
  setSelectId() {
    this.vm.setSelectId(this.selectedId)
    this.vm.refresh()
  }

  aboutToAppear(): void {
    this.vm.init(this.resource.id)
  }

  aboutToDisappear(): void {
    this.vm.emitterOff()
  }

  @Builder
  loadMoreFooter() {
    LoadMoreFooter({ 'isLoading': this.vm.isLoading })
  }

  build() {
    Column() {
      if (!this.vm.interactionList.length && this.resource.id === TabEnum.Watch) {
        Column() {
          NoWatcher()
        }
        .justifyContent(FlexAlign.Center)
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
      }
      Refresh({ refreshing: $$this.vm.isRefreshing }) {
        WaterFlow({ footer: this.loadMoreFooter }) {
          Repeat(this.vm.interactionList)
            .each((repeatItem: RepeatItem<NewsResponse>) => {
              FlowItem() {
                InteractionFeedCard({
                  resource: this.resource,
                  cardInfo: repeatItem.item,
                  index: repeatItem.index,
                })
              }
              .id('action_flow' + this.resource.id + repeatItem.index)
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius(16)
              .clip(true)
              .padding(CommonConstants.PADDING_M)
            })
            .key((item: NewsResponse, index: number) => index + this.vm.getEachId(item))
            .virtualScroll()
        }
        .onReachEnd(() => {
          // 滚动到列表底部时触发加载
          this.vm.loadMore()
        })
        .edgeEffect(EdgeEffect.Spring)
        .columnsTemplate(`repeat(${this.lanesCount.getLanes()}, 1fr)`)
        .columnsGap(16)
        .rowsGap(12)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .padding({
          left: this.lanesCount.breakpointModel.pagePadding,
          right: this.lanesCount.breakpointModel.pagePadding,
        })
        .margin({ top: 16 })
      }
      .layoutWeight(1)
      .pullToRefresh(true)
      .accessibilityLevel('no')
      .onRefreshing(() => {
        this.vm.refresh()
      })
    }
    .height(CommonConstants.FULL_PERCENT)
  }
}