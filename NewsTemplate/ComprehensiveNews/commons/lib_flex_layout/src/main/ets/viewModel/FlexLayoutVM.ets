import { PersistenceV2, UIUtils } from '@kit.ArkUI';
import { TabInfo } from 'module_channeledit';
import { BaseViewModel, CommonDataSource, SettingModel } from 'lib_common';
import { HomeServiceApi, RequestListData } from 'lib_news_api';
import { RendNewsInfo } from '../sdk/model/Model';
import { channelList } from '../constants/ChannelList';


@ObservedV2
export class FlexLayoutVM extends BaseViewModel {
  @Trace isRefreshing: boolean = false
  @Trace rendNewsInfoList: RendNewsInfo[] = []
  @Trace currentIndex: number = 1
  @Trace channelsList: TabInfo[] = []
  @Trace bgColor: ResourceStr = $r('sys.color.background_primary')
  @Trace tabIndex: number = 1
  @Trace setting: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Trace pageIndex: number = 10;

  @Monitor('setting.personalizedPush')
  async switchRecommend() {
    if (this.setting.personalizedPush) {
      let lazyNewsInfoList: CommonDataSource<RequestListData> = new CommonDataSource()
      let newsInfoList = await HomeServiceApi.queryHomeRecommendList('recommend',this.pageIndex);
      lazyNewsInfoList.setData(newsInfoList)
      this.channelsList.splice(1, 0, UIUtils.makeObserved({
        text: '推荐',
        id: 'recommend',
        selected: true,
        order: 2,
        disabled: true,
      }));
      this.rendNewsInfoList.splice(1, 0, new RendNewsInfo('recommend', '推荐', lazyNewsInfoList))
      return
    }
    let recommendIndex = this.channelsList.findIndex(item => item.id === 'recommend')
    if (recommendIndex !== -1) {
      this.channelsList.splice(recommendIndex, 1)
      this.rendNewsInfoList.splice(recommendIndex, 1)
    }
  }

  @Monitor('currentIndex')
  indexChange() {
    this.bgColor =
      this.channelsList[this.currentIndex].id === 'follow' ? $r('sys.color.background_secondary') :
      $r('sys.color.background_primary')
  }

  tabsController: TabsController = new TabsController();

  @Monitor('networkModel.netAddress')
  onChangeNetAddress() {
    // 处理本地tab的名称
    this.handleLocalTabTitle()
  }

  public init() {
    this.tabIndex = this.currentIndex
    this.channelsList = channelList.map((tab: TabInfo) => UIUtils.makeObserved(tab)).filter(v => Boolean(v))
    if(!this.setting.personalizedPush) {
      let recommendIndex = this.channelsList.findIndex(item => item.id === 'recommend')
      if (recommendIndex !== -1) {
        this.channelsList.splice(recommendIndex, 1)
      }
    }
    this.initNewsDynamicData()
    // 处理本地tab的名称
    this.handleLocalTabTitle()
  }


  public initNewsDynamicData() {
    this.channelsList.filter(item => item.selected).forEach((item: TabInfo, index: number) => {
      let lazyNewsInfoList: CommonDataSource<RequestListData> = new CommonDataSource()
      this.rendNewsInfoList.push(new RendNewsInfo(item.id, item.text, lazyNewsInfoList))
    })
  }

  public syncNewsChannels(
    channelsList: TabInfo[],
    rendNewsInfoList: RendNewsInfo[],
  ): void {
    const selectedChannels = channelsList.filter(channel => channel.selected);
    const newsMap = new Map<string, RendNewsInfo>(
      rendNewsInfoList.map(item => [item.id, item]),
    );
    const newNewsList: RendNewsInfo[] = [];
    for (const channel of selectedChannels) {
      const existingItem = newsMap.get(channel.id);
      if (existingItem) {
        newNewsList.push(existingItem);
        newsMap.delete(channel.id);
      } else {
        let lazyNewsInfoList: CommonDataSource<RequestListData> = new CommonDataSource()
        newNewsList.push(new RendNewsInfo(channel.id, channel.text, lazyNewsInfoList))
      }
    }
    rendNewsInfoList.splice(0, rendNewsInfoList.length, ...newNewsList);
  }

  handleChannel() {
    if (!this.channelsList[this.currentIndex]) {
      this.currentIndex = 1
    }
    this.channelsList.forEach((item, index) => {
      let isFixed = this.rendNewsInfoList[index]?.id === item.id
      if (!isFixed) {
        this.rendNewsInfoList[index] = new RendNewsInfo(item.id, item.text, new CommonDataSource())
      }
    })
  }

  public channelConfirm() {
    this.handleChannel()
    this.syncNewsChannels(this.channelsList, this.rendNewsInfoList)
  }

  public handleLocalTabTitle() {
    let ip = this.networkModel.netAddress[0];
    HomeServiceApi.queryCityByIP(ip).then((res) => {
      const localTabIdx = this.channelsList.findIndex((tab: TabInfo) => tab.id === 'location')
      if (localTabIdx !== -1 && res) {
        this.channelsList[localTabIdx].text = res
      }
    });
  }

  public tabIndexChange(index: number) {
    this.tabIndex = index
  }

  public currentIndexChange(index: number) {
    this.currentIndex = index
  }

}