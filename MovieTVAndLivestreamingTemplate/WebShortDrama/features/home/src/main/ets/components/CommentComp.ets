import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources'
import { UserInfoModel } from '@agctemplate/widgets';
import { AppStorageV2, ComponentContent, display } from '@kit.ArkUI'
import { commentInputDialogBuilder } from './CommentInputDialog'
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { appRouter, container, Logger, WindowManager } from '@agctemplate/utils';
import { CommentInfo, CommentListRes, DramaInfo, ReplyInfo, RequestAPI } from '@agctemplate/server';
import { CommentData, Reply } from '../models/CommentData';

const TAG = '[CommentComp]'

@ComponentV2
export struct CommentComp {

  @Param @Require dramaInfo: DramaInfo
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!;
  private contentNode: ComponentContent<Object> =
    new ComponentContent(this.getUIContext(), wrapBuilder(commentInputDialogBuilder), (textComment: string) => {
      this.publishComment(textComment)
    })
  private replyNode: ComponentContent<Object> =
    new ComponentContent(this.getUIContext(), wrapBuilder(commentInputDialogBuilder), (textComment: string) => {
      this.replyComment(textComment)
    })
  @Local commentDataList: Array<CommentData> = []
  @Local moreList: Array<number> = []
  @Local commentId: number = 1
  @Local replyPerson: string = ''
  @Local replyContent: string = ''
  @Local isTabletLandScape: boolean = deviceInfo.deviceType === 'tablet' &&
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE
  @Event commentNum: Function = () => {
  }
  @Event closeSheet: Function = () => {
  }
  callback:Callback<number> = (data:number) =>{
    if(deviceInfo.deviceType === 'tablet' &&
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE){
      this.isTabletLandScape = true
    }else{
      this.isTabletLandScape = false
    }
  }
  // 发布评论
  publishComment(textComment: string): void {
    if (this.contentNode !== null) {
      this.getUIContext().getPromptAction().closeCustomDialog(this.contentNode)
        .then(() => {
          Logger.info(TAG, 'CloseCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
    this.commentDataList.unshift(new CommentData(this.commentDataList.length + 1, this.dramaInfo,
      this.dramaInfo.coverUrl, this.userInfo.avatar, this.userInfo.nickname, textComment, 0, false, 0, [], []))
    this.commentNum(this.commentDataList.length)
    this.moreList.unshift(0)
    container.resolve(RequestAPI).addComment({
      id: this.commentDataList.length,
      drama: this.dramaInfo,
      coverUrl: this.dramaInfo.coverUrl,
      avatar: this.userInfo.avatar,
      name: this.userInfo.nickname,
      commentContent: textComment,
      timeAgo: 0,
      isLike: false,
      likeCount: 0,
      likeList: [],
      replyList: []
    })
  }

  // 回复评论
  replyComment(textComment: string): void {
    if (this.replyNode !== null) {
      this.getUIContext().getPromptAction().closeCustomDialog(this.replyNode)
        .then(() => {
          Logger.info(TAG, 'CloseCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
    let index: number = -1
    this.commentDataList.forEach((item) => {
      if(item.id === this.commentId) {
        index = this.commentDataList.indexOf(item)
      }
    })
    this.commentDataList[index].replyList.unshift(new Reply(
      this.userInfo.avatar, this.userInfo.nickname, textComment, 0, false, 0, [], this.replyPerson, this.replyContent
    ))
    this.moreList[index] += 5
    container.resolve(RequestAPI).addReply({
      id: this.commentId,
      reply: {
        replyAvatar: this.userInfo.avatar,
        replyName: this.userInfo.nickname,
        replyContent: textComment,
        replyTimeAgo: 0,
        replyIsLike: false,
        replyLikeCount: 0,
        replyLikeList: [],
        replyPeople: this.replyPerson,
        replyComment: this.replyContent
      }
    })
  }


  aboutToAppear(): void {
    display.on('change',this.callback)
    container.resolve(RequestAPI).getCommentList({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.commentDataList = []
      this.moreList = []
      let commentListRes: CommentListRes = new CommentListRes(res.getBody())
      commentListRes.commentList?.map((commentInfo: CommentInfo) => {
        let replyListRes: Reply[] = []
        commentInfo.replyList?.map((replyInfo: ReplyInfo) => {
          replyListRes.push(new Reply(replyInfo.replyAvatar, replyInfo.replyName, replyInfo.replyContent,
            replyInfo.replyTimeAgo, replyInfo.replyIsLike, replyInfo.replyLikeCount, replyInfo.replyLikeList,
            replyInfo.replyPeople, replyInfo.replyComment))
        })
        this.commentDataList.push(new CommentData(commentInfo.id, commentInfo.drama, commentInfo.coverUrl,
          commentInfo.avatar, commentInfo.name, commentInfo.commentContent, commentInfo.timeAgo, commentInfo.isLike,
          commentInfo.likeCount, commentInfo.likeList, replyListRes))
        this.moreList.push(0)
      })
      this.commentNum(this.commentDataList.length)
    }).catch((error: Error) => {
      Logger.info(TAG, `get comment list failed:${error.message}`)
    })
  }

  aboutToDisappear(): void {
    display.off('change',this.callback)
  }

  openReplyDialog() {
    this.getUIContext().getPromptAction().openCustomDialog(this.replyNode, {
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        Logger.info(TAG, 'reason' + JSON.stringify(dismissDialogAction.reason))
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss()
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss()
        }
      },
      alignment: DialogAlignment.Bottom
    })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `openCustomDialog error code is ${error.code}, message is ${error.message}`)
      })
  }


  openDialog() {
    this.getUIContext().getPromptAction().openCustomDialog(this.contentNode, {
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        Logger.info(TAG, 'reason' + JSON.stringify(dismissDialogAction.reason))
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss()
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss()
        }
      },
      alignment: DialogAlignment.Bottom
    })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `openCustomDialog error code is ${error.code}, message is ${error.message}`)
      })
  }


  build() {
    Column() {
      Row() {
        Text(`${this.commentDataList.length}条评论`)
          .lineHeight(27)
          .fontSize(20)
          .fontWeight(700)
          .fontColor('#000')
        Image(getMedia('app.media.close_btn'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.closeSheet()
          })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)

      List({ space: 12 }) {
        ForEach(
          this.commentDataList,
          (item: CommentData, index: number) => {
            ListItem() {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Image(item.avatar)
                    .width(16)
                    .height(16)
                    .borderRadius(8)
                  Text(item.name)
                    .lineHeight(16)
                    .fontSize(12)
                    .fontColor('rgba(0, 0, 0, 0.6)')
                }
                .width('100%')
                .height(16)

                Row() {
                  Text(item.commentContent)
                    .lineHeight(19)
                    .fontSize(14)
                    .fontColor('#000')
                }
                .width('100%')
                .padding({ left: 24 })

                Row() {
                  Row() {
                    Row({ space: 8 }) {
                      Text(item.timeAgo < 1 ? '刚刚' : (item.timeAgo >= 60 ? `${Math.floor(item.timeAgo / 60)}小时前` :
                        `${item.timeAgo}分钟前`))
                        .lineHeight(13)
                        .fontSize(10)
                        .fontColor('rgba(0, 0, 0, 0.4)')
                      Text('回复')
                        .lineHeight(13)
                        .fontSize(10)
                        .fontColor('rgba(0, 0, 0, 0.4)')
                        .onClick(() => {
                          this.commentId = item.id
                          this.replyPerson = item.name
                          this.replyContent = item.commentContent
                          if (this.userInfo.isPhoneAssociated) {
                            this.openReplyDialog()
                          } else {
                            this.closeSheet()
                            WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                            appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
                          }
                        })
                    }

                    Row({ space: 4 }) {
                      Image(item.isLike ? getMedia('app.media.thumb_select') : getMedia('app.media.hand_thumbsup'))
                        .width(16)
                        .height(16)
                      Text(`${item.likeCount}`)
                        .lineHeight(13)
                        .fontSize(10)
                        .fontColor('rgba(0, 0, 0, 0.4)')
                    }
                    .onClick(() => {
                      if(item.isLike) {
                        this.commentDataList[index].likeCount--
                        this.commentDataList[index].isLike = false
                      }else {
                        this.commentDataList[index].likeCount++
                        this.commentDataList[index].isLike = true
                      }
                      container.resolve(RequestAPI).onCommentLike(item.id)
                    })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                .width('100%')
                .height(16)
                .padding({ left: 24 })

                // 更多评论
                if(item.replyList) {
                  Column({ space: 8 }) {
                    if(this.moreList[index] > 0) {
                      List({ space: 8 }) {
                        ForEach(
                          this.moreList[index] <= item.replyList.length ?
                          item.replyList.slice(0, this.moreList[index]) : item.replyList,
                          (each: Reply, replyIndex: number) => {
                            ListItem() {
                              Column({ space: 8 }) {
                                Row({ space: 8 }) {
                                  Image(each.replyAvatar)
                                    .width(16)
                                    .height(16)
                                    .borderRadius(8)
                                  Text(each.replyName)
                                    .lineHeight(16)
                                    .fontSize(12)
                                    .fontColor('rgba(0, 0, 0, 0.6)')
                                }
                                .width('100%')
                                .height(16)

                                Row() {
                                  Text() {
                                    if(each.replyPeople !== item.name) {
                                      Span('回复')
                                      Span(`@${each.replyPeople}`)
                                        .fontColor('rgba(0, 0, 0, 0.6)')
                                      Span('：')
                                    }
                                    Span(each.replyContent)
                                  }
                                  .lineHeight(19)
                                  .fontSize(14)
                                  .fontColor('#000')
                                }
                                .width('100%')
                                .padding({ left: 24 })

                                Row() {
                                  Row() {
                                    Row({ space: 8 }) {
                                      Text(each.replyTimeAgo < 1 ? '刚刚' : (each.replyTimeAgo >= 60 ?
                                        `${Math.floor(each.replyTimeAgo / 60)}小时前` : `${each.replyTimeAgo}分钟前`))
                                        .lineHeight(13)
                                        .fontSize(10)
                                        .fontColor('rgba(0, 0, 0, 0.4)')
                                      Text('回复')
                                        .lineHeight(13)
                                        .fontSize(10)
                                        .fontColor('rgba(0, 0, 0, 0.4)')
                                        .onClick(() => {
                                          this.commentId = item.id
                                          this.replyPerson = each.replyName
                                          this.replyContent = each.replyContent
                                          if (this.userInfo.isPhoneAssociated) {
                                            this.openReplyDialog()
                                          } else {
                                            this.closeSheet()
                                            WindowManager.setWindowSystemBarProperties({
                                              statusBarContentColor: '#e6000000'
                                            })
                                            appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name,
                                              params: { isChange: true } })
                                          }
                                        })
                                    }

                                    Row({ space: 4 }) {
                                      Image(each.replyIsLike ? getMedia('app.media.thumb_select') :
                                      getMedia('app.media.hand_thumbsup'))
                                        .width(16)
                                        .height(16)
                                      Text(`${each.replyLikeCount}`)
                                        .lineHeight(13)
                                        .fontSize(10)
                                        .fontColor('rgba(0, 0, 0, 0.4)')
                                    }
                                    .onClick(() => {
                                      if(each.replyIsLike) {
                                        this.commentDataList[index].replyList[replyIndex].replyLikeCount--
                                      }else {
                                        this.commentDataList[index].replyList[replyIndex].replyLikeCount++
                                      }
                                      this.commentDataList[index].replyList[replyIndex].replyIsLike =
                                        !this.commentDataList[index].replyList[replyIndex].replyIsLike
                                      container.resolve(RequestAPI).onReplyLike({
                                        id: item.id,
                                        index: replyIndex
                                      })
                                    })
                                  }
                                  .width('100%')
                                  .justifyContent(FlexAlign.SpaceBetween)
                                }
                                .width('100%')
                                .height(16)
                                .padding({ left: 24 })
                              }
                              .width('100%')
                            }
                            .width('100%')
                          },
                          (each: Reply, replyIndex: number) => each.replyContent + '_' + replyIndex.toString()
                        )
                      }
                      .width('100%')
                    }

                    if(item.replyList.length - this.moreList[index] > 0) {
                      Row() {
                        Text(`展开更多${item.replyList.length - this.moreList[index]}条`)
                          .lineHeight(16)
                          .fontSize(12)
                          .fontColor('rgba(0, 0, 0, 0.6)')
                        Image(getMedia('app.media.arrow_down_black'))
                          .width(16)
                          .height(16)
                      }
                      .onClick(() => {
                        this.moreList[index] += 5
                      })
                    }
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                  .padding({ left: 24 })
                }
              }
              .width('100%')
            }
            .width('100%')
          },
          (item: CommentData, index: number) => item.id.toString()
        )
      }
      .width('100%')
      .height(310)
      .scrollBar(BarState.Off)

      Row() {
        Text('发表评论')
          .lineHeight(21)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 0.6)')
      }
      .width('100%')
      .height(40)
      .borderRadius(24)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
      .margin({ top: 17 })
      .padding({ left: 12 })
      .onClick(() => {
        if (this.userInfo.isPhoneAssociated) {
          this.openDialog()
        } else {
          this.closeSheet()
          WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
          appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
        }
      })
    }
    .width(this.isTabletLandScape ? '40%' : '100%')
    .height(this.isTabletLandScape ? '90%' : '40%')
    .padding({ left: 16, top: 8, right: 16 })
    .backgroundColor('#F1F3F5')
  }
}

@Builder
export function commentBuilder(commentParam: CommentParam) {
  CommentComp({
    dramaInfo: commentParam.dramaInfo,
    commentNum: commentParam.commentNum,
    closeSheet: commentParam.closeSheet
  })
}

export interface CommentParam {
  dramaInfo: DramaInfo
  commentNum: Function
  closeSheet: Function
}