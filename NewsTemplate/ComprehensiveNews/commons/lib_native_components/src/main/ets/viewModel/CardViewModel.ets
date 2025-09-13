import { LoginSheetUtils } from 'lib_account';
import { BaseViewModel, CommonConfirmDialog, RouterParams, RouterToNews } from 'lib_common';
import { CommentServiceApi, MineServiceApi, NewsResponse } from 'lib_news_api';
import { LayoutParams } from 'module_flexlayout';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';

export class CardViewModel extends BaseViewModel {
  private authorId: string = ''
  private uiContext: UIContext

  constructor(uiContext: UIContext) {
    super()
    this.uiContext = uiContext
  }

  setAuthorId(authorId: string) {
    this.authorId = authorId
  }

  public isWatch() {
    return this.userInfoModel.isLogin && this.userInfoModel.watchers.includes(this.authorId)
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

  public likeOperation(cardInfo: NewsResponse) {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    cardInfo.isLiked = !cardInfo.isLiked
    if (cardInfo.isLiked) {
      cardInfo.likeCount += 1
      CommentServiceApi.addPosterLike(cardInfo.id)
      MineServiceApi.addLike(cardInfo.id)
      return
    }
    cardInfo.likeCount -= 1
    CommentServiceApi.cancelPosterLike(cardInfo.id)
    MineServiceApi.cancelLike(cardInfo.id)
  }

  public cancelWatch() {
    CommonConfirmDialog.show({
      content: '确定不再关注TA？',
      confirm: () => {
        MineServiceApi.cancelWatch(this.authorId);
        let watchIndex = this.userInfoModel.watchers.findIndex(v => v === this.authorId)
        this.userInfoModel.watchers.splice(watchIndex, 1)
        MineServiceApi.cancelWatch(this.authorId)
      },
    })
  }

  /*
   * cardData 数据源
   * formType 跳转来源，判断是否是从首页点击评论进入
   * componentId  一镜到底id
   * isQueryCardData 是否携带新闻详情跳转到详情页
   * */

  public pushToNewsDetails(cardData: LayoutParams, formType?: string, componentId?: string,
    isQueryCardData: boolean = false) {
    let params: RouterParams<NewsResponse> = {
      newsId: cardData.nativeCardData.id,
      type: cardData.nativeCardData.type,
      surfaceUrl: cardData.nativeCardData.postImgList?.[0]?.surfaceUrl,
      cardData: cardData.nativeCardData,
      isQueryCardData: isQueryCardData,
      formType: formType ?? '',
    }
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.uiContext,
        componentId ? componentId :
          'news_flow_' + cardData.extraInfo.channelId + '_' + cardData.extraInfo.flowIndex + '_' +
          cardData.extraInfo.flexId, 9);
    if (longTakeTransitionParam) {
      params.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterToNews.pushToNewsDetails<NewsResponse>(params)
  }
}