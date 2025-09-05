import { BaseViewModel } from 'lib_common';
import { CommentServiceApi, MineServiceApi, NewsResponse } from 'lib_news_api';
import { LivestreamCommentListScroller } from '../views/LiveCommentView';

@ObservedV2
export class LivestreamFooterViewVM extends BaseViewModel {
  @Trace livestreamInfo: NewsResponse = {} as NewsResponse;
  @Trace commentListScroller: LivestreamCommentListScroller = new LivestreamCommentListScroller();

  handlerCoverImage(newsDetails: NewsResponse): string {
    return newsDetails.coverUrl || ''
  }

  // 点赞操作
  likeAction() {
    this.livestreamInfo.isLiked = !this.livestreamInfo.isLiked;
    if (this.livestreamInfo.isLiked) {
      CommentServiceApi.addPosterLike(this.livestreamInfo.id)
      MineServiceApi.addLike(this.livestreamInfo.id)
      this.livestreamInfo.likeCount++
      return
    }
    CommentServiceApi.cancelPosterLike(this.livestreamInfo.id)
    MineServiceApi.cancelLike(this.livestreamInfo.id)
    this.livestreamInfo.likeCount--
  }
}