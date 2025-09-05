import { FeedComment } from 'module_feedcomment'
import { RouterMap, RouterUtils } from 'lib_common';
import { CommentResponse } from 'lib_news_api';
import NewsFeedVM from '../viewmodel/NewsFeedVM';
import { LoginSheetUtils } from 'lib_account';

@Builder
export function CommentBuilder(newsFeedVM: NewsFeedVM) {
  FeedComment({
    userInfo: newsFeedVM.getUserInfo(),
    commentList: newsFeedVM.commentInfoList,
    navPathStack: RouterUtils.getStack(),
    addComment: (comment: CommentResponse, parentCommentId: string) => {
      newsFeedVM.addSingleComment(comment, parentCommentId)
    },
    giveLike: (comment: CommentResponse,isLike:boolean) => {
      newsFeedVM.addLike(comment,isLike)
    },
    onGoAuthorInfo: (authorId: string) => {
      RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
    },
    onDeleteComment: (commentId: string) => {
      newsFeedVM.deleteComment(commentId)
    },
  })
}