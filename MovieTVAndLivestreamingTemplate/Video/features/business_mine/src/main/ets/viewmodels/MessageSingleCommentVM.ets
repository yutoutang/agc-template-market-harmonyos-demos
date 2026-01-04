import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { CommentModel, MessageServiceApi, MineServiceApi, PublishCommentRequest } from 'lib_video_api';
import { commentSheetOpen } from 'video_interaction';
import { CommentDetailModel } from '../common/ObservedModel';

@ObservedV2
export class MsgSingleCommentListViewModel extends BaseViewModel {
  @Trace replyContent: string = '';
  @Trace currentCommentId: string = '';
  @Trace data: CommentDetailModel | undefined = undefined;
  @Trace publishList: CommentModel[] = [];

  init() {
    this.getParams();
    this.queryList();
  }

  getParams() {
    this.currentCommentId = RouterUtils.getParamByName(RouterMap.MINE_MSG_COMMENT_DETAIL) as string
  }

  queryList() {
    MessageServiceApi.querySingleCommentList(this.currentCommentId).then((resp) => {
      this.data = new CommentDetailModel(resp)
    })
  }

  getRootComment() {
    return this.data?.root;
  }

  getCurrentComment() {
    return this.data?.current;
  }

  getLeftList() {
    return this.data?.list || [];
  }

  publishReply(data: CommentModel, content: string) {
    const params: PublishCommentRequest = {
      videoId: data.videoId,
      content: content,
      parentCommentId: data.commentId,
    };
    MineServiceApi.publishComment(params).then((resp) => {
      this.publishList.push(new CommentModel(resp));
      promptAction.showToast({ message: '评论成功' });
    })
  }

  showCommentSheet(data?: CommentModel) {
    if (data) {
      commentSheetOpen(data.author.authorNickName, (content: string) => {
        this.publishReply(data, content);
      }, false)
    }
  }

  @Computed
  get showAllReply() {
    return this.getLeftList().length > 0;
  }

  @Computed
  get showMyInstantReply() {
    return this.publishList.length > 0;
  }
}