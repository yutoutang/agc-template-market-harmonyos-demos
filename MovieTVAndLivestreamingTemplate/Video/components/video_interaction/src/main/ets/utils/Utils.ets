import { publishCommentBuilder } from '../components/PublishComment';
import { CommentEventDispatcher } from './EventDispatcher';
import { PopViewUtils } from './PopViewUtils';


export class CommentParams {
  reNickName: string = ''
  callback: (replyContent: string) => void

  constructor(replyAuthor: string | null, callback: (replyContent: string) => void) {
    this.reNickName = replyAuthor ?? ''
    this.callback = callback
  }
}

export function openPublishComment(replyAuthor: string | null, callback: (replyContent: string) => void) {
  PopViewUtils.showSheet<CommentParams>(wrapBuilder(publishCommentBuilder), {
    showClose: false,
    scrollSizeMode: ScrollSizeMode.CONTINUOUS,
    detents: [SheetSize.FIT_CONTENT],
    dragBar: true,
  }, new CommentParams(replyAuthor, callback));
}

/**
 * 打开评论弹窗
 * @param replyAuthor 回复对象
 * @param callback 回复回调事件
 * @param isVerifyLogin 是否校验登录
 */

export function commentSheetOpen(replyAuthor: string | null, callback: (replyContent: string) => void,
  isVerifyLogin?: boolean) {
  /*
   * 判断用户是否登录
   * */
  if (isVerifyLogin !== undefined && !isVerifyLogin) {
    openPublishComment(replyAuthor, callback)
    return
  }
  CommentEventDispatcher.dispatchToInterceptLogin((isLogin: boolean) => {
    /*
      * isLogin字段为undefined，不校验
      * */
    if (isLogin || isLogin === undefined) {
      openPublishComment(replyAuthor, callback)
    }
  })
}

export function formatToK(number: number) {
  if (Math.abs(number) < 1000) {
    return String(number);
  }
  const valueInK = (number / 1000).toFixed(1);
  return valueInK.replace(/\.0$/, '') + 'k';
}
