import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, CommonConfirmDialog, RouterMap, RouterUtils } from 'lib_common';
import { MessageServiceApi, MineServiceApi, PublishCommentRequest } from 'lib_video_api';
import { commentSheetOpen } from 'video_interaction';
import { AggregateNewsCommentModel } from '../common/ObservedModel';

@ObservedV2
export class MyCommentVM extends BaseViewModel {
  @Trace list: AggregateNewsCommentModel[] = [];
  @Trace loading: boolean = false;
  @Trace allSelected: boolean = false;
  @Trace selectedIds: string[] = []; // 存储选中的视频id
  constructor() {
    super();
    this.queryList();
    this.setAllRead();
  }

  queryList() {
    MessageServiceApi.queryMyAllCommentsAndReplies().then((resp) => {

      this.list = resp.map(v => new AggregateNewsCommentModel(v));
      this.loading = false;
    })
  }

  replyComment(v: AggregateNewsCommentModel) {
    commentSheetOpen(v.author.authorNickName, (content: string) => {
      this.publishReply(v, content);
    }, false)
  }

  jumpProfile(v: AggregateNewsCommentModel) {
    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, v.author.authorId);
  }

  jumpMoreComment(v: AggregateNewsCommentModel) {
    RouterUtils.pushPathByName(RouterMap.MINE_MSG_COMMENT_DETAIL, v.commentId);
  }

  publishReply(data: AggregateNewsCommentModel, content: string) {
    const params: PublishCommentRequest = {
      videoId: data.videoId,
      content: content,
      parentCommentId: data.commentId,
    };
    MineServiceApi.publishComment(params).then(() => {
      promptAction.showToast({ message: '评论成功' });
    })
  }

  // 区分评论/回复
  isReply(v: AggregateNewsCommentModel) {
    return v.parentCommentId;
  }

  onRefresh() {
    this.queryList();
  }

  setAllRead() {
    MessageServiceApi.setReplyRead();
  }

  onBackPressed() {
    RouterUtils.pop('1');
    return true;
  }

  deleteAllConfirm() {
    if (this.list.length === 0) {
      promptAction.showToast({ message: '列表为空，无法操作' });
      return;
    }

    if (!this.allSelected) {
      // 如果不是全选状态，则执行全选
      this.selectedIds = this.list.map(item => item.commentId);
      this.allSelected = true;
    } else {
      // 如果已是全选状态，则执行取消全选
      this.selectedIds = [];
      this.allSelected = false;
    }
  }

  deleteConfirm() {
    const dialogText: string =
      this.selectedIds.length === 1 ? '删除动作不可恢复，是否删除此条浏览记录？' :
        `删除动作不可恢复，是否删除 ${this.selectedIds.length} 条浏览记录？`;
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: dialogText,
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        if (this.selectedIds.length === 0) {
          promptAction.showToast({ message: '至少选择一条数据' });
          return
        }
        for (const commentId of this.selectedIds) {
          MessageServiceApi.deleteComment(commentId);
        }

        // 删除成功后，更新本地状态
        this.list = this.list.filter(
          (item: AggregateNewsCommentModel) => !this.selectedIds.includes(item.commentId)
        );
        this.selectedIds = [];
        promptAction.showToast({ message: '已删除' });
      },
    })
  }

  onChange(selected: boolean, item: AggregateNewsCommentModel) {
    if (selected) {
      // 如果选中，且不在selectedIds中，则添加
      if (!this.selectedIds.includes(item.commentId)) {
        this.selectedIds.push(item.commentId);
      }
    } else {
      this.selectedIds = this.selectedIds.filter(id => id !== item.commentId);
    }
    this.allSelected = this.selectedIds.length === this.list.length;
  }
}