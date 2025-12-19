import { emitter } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, CommonBreakpoint, CommonDataSource, NetworkUtil } from 'lib_common';
import { HomeServiceApi, NewsEnum, RequestListData } from 'lib_news_api';
import { RendNewsInfo } from '../model/Model';


@ObservedV2
export class NewsContentVM extends BaseViewModel {
  @Trace isRefreshing: boolean = false
  @Trace resource: string = 'recommend'
  @Trace rendNewsInfoList: RendNewsInfo[] = []
  @Trace bgColor: ResourceStr = $r('sys.color.background_primary')
  @Trace isLoading: boolean = false;
  @Trace currentPage: number = 0;
  @Trace currentIndex: number = 10;
  @Trace lanesCount: CommonBreakpoint<number> = new CommonBreakpoint<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });
  @Trace showExceptionPage: boolean = false;

  @Computed
  get getLanesPoint() {
    return this.resource === 'hotService' ? 1 : this.lanesCount.getLanes()
  }

  public init(resource: string, rendNewsInfoList: RendNewsInfo[]) {
    this.showExceptionPage = !this.networkModel.isNetworkAvailable;
    this.rendNewsInfoList = rendNewsInfoList
    this.resource = resource
    this.isRefreshing = true
    emitter.on('follow_recommend_fresh', () => {
      this.refresh()
    })
  }

  public emitterOff() {
    emitter.off('follow_recommend_fresh')
  }

  public async getNewsDynamicData(resource: string) {
    let newsInfoList: RequestListData[] = []
    if (resource === 'recommend' && AppStorage.get('recommendList')) {
      newsInfoList = AppStorage.get('recommendList') as RequestListData[]
      /*
       * 再次刷新不需要从AppStorage取
       * */
      AppStorage.setOrCreate('recommendList', '')
    } else {
      newsInfoList = await HomeServiceApi.queryHomeRecommendList(resource, this.currentIndex);
    }
    if (resource === 'follow') {
      newsInfoList = await HomeServiceApi.queryHomeFollowList([NewsEnum.Article], this.currentIndex)
      /*
       * 处理extraInfo
       * */
      newsInfoList.forEach(item => {
        item.extraInfo.isFollow = true
        item.extraInfo.isNeedAuthor = false
      })
    }
    let list = this.rendNewsInfoList.find(item => item.id === resource)
    if (list) {
      list.newsList.setData(newsInfoList)
    }
    this.isRefreshing = false
  }

  public async loadMore(newsList: CommonDataSource<RequestListData>) {
    this.isLoading = true
    let isNetworkAvailable = await this.checkNetworkAvailable()
    if (isNetworkAvailable) {
      this.currentPage = this.currentIndex
      this.currentIndex += 5
      let newsInfoList: RequestListData[] =
        await HomeServiceApi.queryNextPageData(this.resource, this.currentIndex, this.currentPage);
      if (!newsInfoList.length) {
        this.emptyToast()
      } else {
        newsInfoList.forEach(item => newsList.pushData(item))
      }
      this.isLoading = false
    } else {
      this.isLoading = false;
      this.toast()
    }
  }

  public async refresh() {
    // 模拟请求判断网络能否使用
    let isNetworkAvailable = await this.checkNetworkAvailable()
    if (isNetworkAvailable) {
      this.showExceptionPage = false;
      await this.getNewsDynamicData(this.resource)
    } else {
      this.isRefreshing = false;
      this.toast()
    }
  }

  public reloadData() {
    this.isRefreshing = true;
  }

  public checkNetworkAvailable(): Promise<boolean> {
    // 模拟请求判断网络能否使用
    let networkUtil = NetworkUtil.getInstance()
    networkUtil.handleNetworkAvailable();

    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(this.networkModel.isNetworkAvailable)
      }, 500)
    })
  }

  public toast() {
    if (!this.showExceptionPage) {
      promptAction.showToast({
        message: '网络连接不可用',
        alignment: Alignment.Center,
        textColor: Color.Red
      })
    }
  }

  public emptyToast() {
    promptAction.showToast({
      message: '暂无更新数据',
      alignment: Alignment.Bottom,
    })
  }

  public throttle(func: Function, interval: number) {
    let lastTime = 0;
    return () => {
      const nowTime = Date.now();
      const remainTime = interval - (nowTime - lastTime);
      if (remainTime <= 0) {
        lastTime = nowTime;
        func();
      }
    };
  }
}