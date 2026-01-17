import { UIUtils } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { LoginSheetUtils } from 'lib_account';
import { BaseViewModel, RouterParams, RouterToNews } from 'lib_common';
import { CommentServiceApi, MineServiceApi, NewsResponse, PostServiceApi } from 'lib_news_api';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { TabEnum } from '../common/Constants';

@ObservedV2
export class InteractionViewModel extends BaseViewModel {
  private authorId: string = ''
  @Trace isRefreshing: boolean = false
  @Trace interactionList: NewsResponse[] = []
  @Trace resourceId: TabEnum = TabEnum.Watch
  @Trace isLoading: boolean = false
  @Trace currentIndex: number = 10
  @Trace currentPage: number = 0
  private uiContext: UIContext

  constructor(uiContext: UIContext) {
    super()
    this.uiContext = uiContext
  }

  @Monitor('resourceId')
  tabChange() {
    this.tabSwitch()
  }

  setAuthorId(authorId: string) {
    this.authorId = authorId
  }

  public isWatch() {
    return this.userInfoModel.isLogin && this.userInfoModel.watchers.includes(this.authorId)
  }

  public init(resourceId: TabEnum) {
    this.isRefreshing = true
    this.resourceId = resourceId
    this.setActionData(PostServiceApi.queryPostFollowList)
    if (this.resourceId === TabEnum.Recommend) {
      emitter.on('recommendRefresh', () => {
        this.refresh()
      })
    }
  }


  public emitterOff() {
    emitter.off('recommendRefresh')
  }

  public async setActionData(actionAPi: () => Promise<NewsResponse[]>) {
    this.interactionList = await actionAPi()
    this.interactionList = this.interactionList.map(item => UIUtils.makeObserved(item))
    this.isRefreshing = false
  }

  public tabSwitch() {
    switch (this.resourceId) {
      case TabEnum.Watch:
        this.setActionData(PostServiceApi.queryPostFollowList)
        break
      case TabEnum.Recommend:
        this.setActionData(PostServiceApi.queryPostRecommendList)
        break
      case TabEnum.Nearby:
        this.setActionData(PostServiceApi.queryPostRecommendList)
        break
    }
  }

  public refresh() {
    this.tabSwitch()
  }

  public watchOperation() {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    if (!this.isWatch()) {
      this.addWatch()
      return
    }
    this.cancelWatch()
  }

  public addWatch() {
    this.userInfoModel.watchers.push(this.authorId)
    MineServiceApi.addWatch(this.authorId)
  }

  public cancelWatch() {
    let watchIndex = this.userInfoModel.watchers.findIndex(v => v === this.authorId)
    this.userInfoModel.watchers.splice(watchIndex, 1)
    MineServiceApi.cancelWatch(this.authorId)
  }

  public actionToNewsDetails(cardData: NewsResponse, index: number, resourceId: number, formType?: string,
    isQueryCardData: boolean = false) {
    let params: RouterParams<NewsResponse> = {
      newsId: cardData.id,
      authorId: cardData.author.authorId,
      type: cardData.type,
      surfaceUrl: cardData.postImgList?.[0]?.surfaceUrl,
      cardData: cardData,
      isQueryCardData: isQueryCardData,
      formType: formType ?? '',
    }
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.uiContext, 'action_flow' + resourceId + index, 9);
    if (longTakeTransitionParam) {
      params.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterToNews.pushToNewsDetails<NewsResponse>(params)
  }

  public addLike(cardInfo: NewsResponse) {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    cardInfo.isLiked = !cardInfo.isLiked
    if (cardInfo.isLiked) {
      CommentServiceApi.addPosterLike(cardInfo.id)
      cardInfo.likeCount += 1
      return
    }
    CommentServiceApi.cancelPosterLike(cardInfo.id)
    cardInfo.likeCount -= 1
  }

  public emptyToast() {
    this.contextModel.showToast({
      message: '暂无更新数据',
      alignment: Alignment.Bottom,
    })
  }

  public async loadMore() {
    this.isLoading = true
    this.currentIndex += this.currentPage
    this.currentPage += 5
    let followList = await PostServiceApi.queryPostFollowList(this.currentIndex, this.currentPage)
    if (!followList.length) {
      this.emptyToast()
    } else {
      followList.forEach(item => this.interactionList.push(UIUtils.makeObserved(item)))
    }
    this.isLoading = false
  }
}