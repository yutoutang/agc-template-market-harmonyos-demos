import { AbilityConstant, common } from '@kit.AbilityKit'
import { AppStorageV2, UIUtils } from '@kit.ArkUI'
import { BaseViewModel, BundleInfo, CommonConfirmDialog, ContinueModel, GridRowColSetting, Logger,
  RouterParams,
  RouterToNews} from 'lib_common'
import {
  BaseNewsServiceApi,
  CommentResponse,
  CommentServiceApi,
  MineServiceApi,
  NewsResponse,
  PublishCommentRequest,
} from 'lib_news_api'
import { LoginSheetUtils } from 'lib_account'
import { LoneTakeAnimationsTransition, LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition'
import { CommentInfo, NewsFeedInfo } from '../model/Model'
import { MakeObCommentServed } from '../utils/Utils'
import { FeedBreakPointVM } from './FeedBreakPointVM'

const TAG = 'NewsFeedVM'

@ObservedV2
export class NewsFeedVM extends BaseViewModel {
  private static _instance: NewsFeedVM
  @Trace articleDetails: NewsFeedInfo = new NewsFeedInfo()
  @Trace commentInfoList: CommentInfo[] = []
  @Trace scroller: Scroller = new Scroller();
  @Trace bundleInfo: BundleInfo | undefined = undefined
  @Trace continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  @Trace feedBreakPointVM: FeedBreakPointVM = new FeedBreakPointVM()
  feedCommentScroller: Scroller = new Scroller()
  uiContext:UIContext | undefined = undefined
  @Computed
  get isFeedSelf() {
    return this.userInfoModel.authorId === this.articleDetails?.author?.authorId;
  }

  public static get instance() {
    if (!NewsFeedVM._instance) {
      NewsFeedVM._instance = new NewsFeedVM()
    }
    return NewsFeedVM._instance
  }

  public setUiContext(uiContext:UIContext) {
    this.uiContext = uiContext
  }

  public initArticle(articleId: string) {
    let articleRes = BaseNewsServiceApi.queryNews(articleId) as NewsFeedInfo
    this.articleDetails = UIUtils.makeObserved(articleRes);
  }

  public initComment(articleId: string) {
    let commentInfo = CommentServiceApi.queryCommentList(articleId) as CommentInfo[]
    this.commentInfoList = commentInfo?.map((value: CommentInfo) => {
      return new MakeObCommentServed(value)
    }) ?? [];
  }

  public newsLike() {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    this.articleDetails.isLiked = !this.articleDetails.isLiked
    if (this.articleDetails.isLiked) {
      CommentServiceApi.addPosterLike(this.articleDetails.id)
      MineServiceApi.addLike(this.articleDetails.id)
      this.articleDetails.likeCount++
      return
    }
    CommentServiceApi.cancelPosterLike(this.articleDetails.id)
    MineServiceApi.cancelLike(this.articleDetails.id)
    this.articleDetails.likeCount--
  }


  public isWatch() {
    let authorId = this.articleDetails?.author?.authorId ?? ''
    return this.userInfoModel.isLogin && this.userInfoModel.watchers.includes(authorId)
  }

  public watchOperation(isLoginCb?: (isLogin: boolean) => void) {
    isLoginCb?.(this.userInfoModel.isLogin)
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
    let authorId = this.articleDetails?.author?.authorId ?? ''
    this.userInfoModel.watchers.push(authorId)
    MineServiceApi.addWatch(authorId)
  }

  public cancelWatch() {
    CommonConfirmDialog.show({
      content: '确定不再关注TA？',
      confirm: () => {
        let watchIndex = this.userInfoModel.watchers.findIndex(v => v === this.articleDetails?.author?.authorId)
        this.userInfoModel.watchers.splice(watchIndex, 1)
        MineServiceApi.cancelWatch(this.articleDetails?.author?.authorId)
      },
    })
  }

  public addHistory() {
    MineServiceApi.addToHistory(this.articleDetails.id)
  }

  public addSingleComment(comment: CommentResponse, parentCommentId: string) {
    const params: PublishCommentRequest = {
      newsId: comment.newsId,
      content: comment.commentBody,
      parentCommentId: parentCommentId,
    };
    MineServiceApi.publishComment(params)
  }

  public deleteComment(commentId: string) {
    const index = this.commentInfoList.findIndex(v => v.commentId === commentId);
    if (index !== -1) {
      this.commentInfoList.splice(index, 1);
    }
    this.articleDetails.commentCount--
    CommentServiceApi.deleteComment(commentId)
  }

  public setCommentInfo(commentInfoList: CommentInfo[], comment: CommentResponse, isLike: boolean) {
    if (commentInfoList.length) {
      commentInfoList.forEach(item => {
        if (item.commentId === comment.commentId) {
          item.isLiked = isLike
          item.commentLikeNum = isLike ? item.commentLikeNum + 1 : item.commentLikeNum - 1
        }
        this.setCommentInfo(item.replyComments, comment, isLike)
      })
    }
  }

  public addLike(comment: CommentResponse, isLike: boolean) {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    this.setCommentInfo(this.commentInfoList, comment, isLike)
    if (comment.isLiked) {
      CommentServiceApi.addCommentLike(comment.commentId)
      return
    }
    CommentServiceApi.cancelCommentLike(comment.commentId)
  }

  public addMark(isMark: boolean) {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    this.articleDetails.isMarked = isMark
    if (isMark) {
      BaseNewsServiceApi.addMark(this.articleDetails.id)
      MineServiceApi.addMark(this.articleDetails.id)
      this.articleDetails.markCount += 1
      return
    }
    BaseNewsServiceApi.cancelMark(this.articleDetails.id)
    MineServiceApi.cancelMark(this.articleDetails.id)
    this.articleDetails.markCount -= 1
  }

  public async addNewsComment(commentContent: string) {
    this.articleDetails.commentCount++
    const params: PublishCommentRequest = {
      newsId: this.articleDetails.id,
      content: commentContent,
      parentCommentId: '',
    };
    let addComment = await MineServiceApi.publishComment(params) as CommentInfo
    /*
     * 通知卡片刷新
     * */
    this.commentInfoList.unshift(new MakeObCommentServed(addComment))
  }

  public setCardData(cardData: NewsFeedInfo) {
    this.articleDetails = UIUtils.makeObserved(cardData);
  }

  getUserInfo() {
    return this.userInfoModel
  }

  setWebFontColor(isDark: boolean): string {
    if (isDark) {
      return 'white'
    }
    return 'black'
  }

  setRichToHtml() {
    return `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
        </head>
        <style>
            @media (0px<=width<320px) {
               .image-preview {
                   width: 100%;
               }
           }
           @media (320px<=width<600px) {
               .image-preview {
                   width: 100%;
               }
           }

           @media (600px<=width<840px) {
               .image-preview {
                   width: 80%;
               }
           }

           @media (840px<=width) {
               .image-preview {
                   width: 50%;
               }
           }
           .post-image {
              display: block;
              margin-left: auto;
              margin-right: auto;
              height: auto;
           }
        </style>
        <body id="body">
          ${this.articleDetails.richContent}
          <script>
           function callNativePreview(srcList, index) {
                native.preview(srcList, index);
            }
           function setWebFontColor(isDark) {
              if(isDark) {
                document.getElementById('body').style.color = 'white';
                return
              }
              document.getElementById('body').style.color = 'black';
            }
            let imageList = document.querySelectorAll(".image-preview")
            imageList.forEach((element,index) => {
                element.addEventListener('click', function () {
                    let scrList = [...imageList].map(value => {
                        return value.src
                    })
                    callNativePreview(scrList, index)
                })
            });
        </script>
      </body>
    </html>
   `
  }

  public scrollToComment(isSplit?: boolean) {
    /*
     *  1、未分屏情况下快速定位到评论区域
     *  2、分屏情况下评论区可以快速置顶
     * */
    if (isSplit) {
      this.feedCommentScroller.scrollToIndex(0, true)
      return
    }
    this.scroller.scrollToIndex(3, true)
  }

  public registerCustomTransition(navDestContext: NavDestinationContext, longTakeSession: LongTakeAnimationProperties) {
    let param = navDestContext.pathInfo?.param as Record<string, Object>;
    let longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
    if (longTakeTransitionParam) {
      longTakeSession.init(navDestContext, longTakeTransitionParam, {
        pop: () => {
          navDestContext.pathStack.pop()
        },
      });
    }
  }

  public scrollToRestorePosition() {
    if (!this.continueModel.isTargetDevice) {
      return;
    }
    if (!this.continueModel.scrollOffset) {
      this.continueModel.isTargetDevice = false;
      return;
    }
    // 对端还原参数
    let yOffset = this.continueModel.scrollOffset;
    if (this.continueModel.breakpoint !== this.breakPointModel.currentBreakpoint) {
      const continueCount = GridRowColSetting.getWindowColumn(this.continueModel.breakpoint);
      const curCount = GridRowColSetting.getWindowColumn(this.breakPointModel.currentBreakpoint);
      yOffset = yOffset * continueCount / curCount;
    }
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: yOffset,
    })
    this.continueModel.isTargetDevice = false;
  }

  public enableContinue(context: common.UIAbilityContext) {
    context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE).then(() => {
      Logger.info(TAG, 'setMissionContinueState ACTIVE result: ACTIVE')
    });
  }

  public setContinueData() {
    if (this.continueModel.isTargetDevice) {
      return;
    }
    // 源端保存参数
    this.continueModel.newsId = this.articleDetails.id;
    this.continueModel.newsType = this.articleDetails.type;
    this.continueModel.breakpoint = this.breakPointModel.currentBreakpoint;
  }

  public setContinueOffset() {
    if (this.continueModel.isTargetDevice) {
      return;
    }
    try {
      // 源端保存参数
      const scrollOffset = this.scroller?.currentOffset()?.yOffset;
      this.continueModel.scrollOffset = scrollOffset ?? 0;
    } catch (e) {
      Logger.error(TAG, 'setContinueOffset fail, error: ' + JSON.stringify(e));
    }
  }

  /*
  * cardData 数据源
  * formType 跳转来源，判断是否是从首页点击评论进入
  * componentId  一镜到底id
  * isQueryCardData 是否携带新闻详情跳转到详情页
  * */
  public pushToNewsDetails(cardData: NewsFeedInfo,componentId: string, formType?: string,
    isQueryCardData: boolean = false) {
    let params: RouterParams<NewsResponse> = {
      newsId: cardData.id,
      type: cardData.type,
      surfaceUrl: cardData.postImgList?.[0]?.surfaceUrl,
      cardData: cardData,
      isQueryCardData: isQueryCardData,
      formType: formType ?? '',
    }
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.uiContext as UIContext,
        componentId, 9);
    if (longTakeTransitionParam) {
      params.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterToNews.pushToNewsDetails<NewsResponse>(params)
  }
}

export default NewsFeedVM