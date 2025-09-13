import { PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants, UserInfoModel } from 'lib_common'
import { RequestListData } from 'lib_news_api';
import { NetworkExceptionView } from 'lib_widget';
import { NewsContentVM } from '../viewmodel/NewsContentVM';
import { NoLoginPage } from './NoLoginPage';
import { LoadMoreFooter } from './LoadMoreFooter';
import { FlexLayoutPage } from './FlexLayoutPage';
import { RendNewsInfo } from '../model/Model';

@ComponentV2
export struct NewsTabContent {
  @Param @Require channelItem: RendNewsInfo
  @Param rendNewsInfoList: RendNewsInfo[] = []
  @Param bgColor: ResourceStr = $r('sys.color.background_primary')
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local newsContentVM: NewsContentVM = new NewsContentVM()
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.newsContentVM.init(this.channelItem.id, this.rendNewsInfoList)
  }

  aboutToDisappear(): void {
    this.newsContentVM.emitterOff()
  }

  @Builder
  loadMoreFooter() {
    LoadMoreFooter({ 'isLoading': this.newsContentVM.isLoading })
  }

  build() {
    Column() {
      Column() {
        if (this.channelItem.id === 'follow' && !this.userInfoModel.isLogin) {
          Column() {
            NoLoginPage()
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.background_primary'))
          .height(CommonConstants.FULL_PERCENT)
          .width(CommonConstants.FULL_PERCENT)
        }
      }

      Refresh({ refreshing: $$this.newsContentVM.isRefreshing }) {
        if (this.newsContentVM.showExceptionPage) {
          if (!this.newsContentVM.isRefreshing) {
            NetworkExceptionView({
              textFontColor: $r('sys.color.font_primary'),
              btnFontColor: $r('sys.color.font_primary'),
              btnBorderColor: $r('sys.color.font_primary'),
              refreshNetwork: () => {
                this.newsContentVM.reloadData()
              }
            })
          }
        } else {
          WaterFlow({ scroller: this.scroller, footer: this.loadMoreFooter }) {
            LazyForEach(this.channelItem.newsList, (value: RequestListData, index: number) => {
              FlowItem() {
                FlexLayoutPage({
                  channelItem: this.channelItem,
                  setting: JSON.parse(value.navInfo.setting),
                  articles: value.articles,
                  extraInfo: value.extraInfo,
                  flowIndex: index,
                })
              }
              .backgroundColor($r('sys.color.background_primary'))
              .id('news_flow_' + this.channelItem.id +'_'+ index + '_'+ value.extraInfo.flexId)
            }, (value: RequestListData, index: number) => index + JSON.stringify(value.articles[0]))
          }
          .onReachEnd(
            // 防止回弹时额外触发
            this.newsContentVM.throttle(() => {
              // 滚动到列表底部时触发加载
              this.newsContentVM.loadMore(this.channelItem.newsList)
            }, 800)
          )
          .edgeEffect(EdgeEffect.Spring)
          .columnsTemplate(`repeat(${this.newsContentVM.getLanesPoint}, 1fr)`)
          .columnsGap(16)
          .rowsGap(12)
          .scrollBar(BarState.Off)
          .cachedCount(1)
        }
      }
      .pullToRefresh(true)
      .height(CommonConstants.FULL_PERCENT)
      .accessibilityLevel('no')
      .onRefreshing(() => {
        this.newsContentVM.refresh()
      })
    }
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
  }
}