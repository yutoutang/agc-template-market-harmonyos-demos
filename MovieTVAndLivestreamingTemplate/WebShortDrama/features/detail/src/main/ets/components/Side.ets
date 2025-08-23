import { AppStorageV2, ComponentContent, promptAction } from '@kit.ArkUI';
import { ShortDramaDetailItemVM } from '../viewmodels/ShortDramaDetailItemVM';
import { PlayController } from 'video_swiper';
import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources';
import { UserInfoModel } from '@agctemplate/widgets';
import { commentBuilder, CommentParam } from './CommentComp';
import { FirstShare, SheetShowVM } from '@agctemplate/module_share';
import { appRouter, Logger, WindowManager } from '@agctemplate/utils';
import { MyMessageStorage } from '../models/MyMessageStorage';
import { emitter } from '@kit.BasicServicesKit';

const TAG: string = '[Side]'

/**
 * 功能描述：
 * 1. 展示视频播放界面右侧用户头像、视频评论数量、收藏数量、分享数量、作者是否被用户关注等信息
 *
 */
@ComponentV2
export struct Side {
  @Param @Require videoDes: ShortDramaDetailItemVM = new ShortDramaDetailItemVM;
  @Param @Require playControl: PlayController;
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!;
  @Local myMessageStorage: MyMessageStorage = MyMessageStorage.instance()
  @Local isShowShareSheet: boolean = false
  @Local commentShow: boolean = false
  @Local shareShowVM: SheetShowVM = SheetShowVM.instance
  private commentNode: ComponentContent<CommentParam> = new ComponentContent(
    this.getUIContext(),
    wrapBuilder<[CommentParam]>(commentBuilder),
    {
      dramaInfo: this.videoDes.dramaInfo,
      commentNum: (comments: number) => {
        this.videoDes.commentCount = comments.toString()
      },
      closeSheet: () => {
        this.commentShow = false
        this.closeCommentDialog()
      }
    } as CommentParam
  )

  openCommentDialog() {
    this.getUIContext().getPromptAction().openCustomDialog(this.commentNode, {
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        Logger.info(TAG, 'reason' + JSON.stringify(dismissDialogAction.reason))
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss()
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss()
        }
      },
      alignment: DialogAlignment.Bottom,
      onWillDisappear: () => {
        this.commentShow = false
        this.myMessageStorage.showFlag = false
        this.myMessageStorage.isShowCommentSheet = false
        this.playControl.setPlayerHeight(`100%`)
      }
    })
  }

  closeCommentDialog() {
    this.getUIContext().getPromptAction().closeCustomDialog(this.commentNode)
  }


  // 点击点赞按钮的回调函数
  private changeLikeCount(isAdd: boolean) {
    if (isAdd) {
      this.videoDes.dramaSocialInfo.setLike();
      promptAction.showToast({
        message: '点赞成功',
        backgroundColor: 'rgba(46, 48, 51, 0.9)',
        backgroundBlurStyle: BlurStyle.NONE,
        textColor: 'rgba(255, 255, 255, 0.9)',
        bottom: '12%'
      })
    } else {
      this.videoDes.dramaSocialInfo.unsetLike();
      promptAction.showToast({
        message: '取消点赞',
        backgroundColor: 'rgba(46, 48, 51, 0.9)',
        backgroundBlurStyle: BlurStyle.NONE,
        textColor: 'rgba(255, 255, 255, 0.9)',
        bottom: '12%'
      })
    }
  }

  // 点击收藏按钮的回调函数
  private changeFavoriteCount(isIncrease: boolean) {
    if (isIncrease) {
      this.videoDes.dramaSocialInfo.setFavor();
      promptAction.showToast({
        message: '收藏成功',
        backgroundColor: 'rgba(46, 48, 51, 0.9)',
        backgroundBlurStyle: BlurStyle.NONE,
        textColor: 'rgba(255, 255, 255, 0.9)',
        bottom: '12%'
      })
    } else {
      this.videoDes.dramaSocialInfo.unsetFavor();
      promptAction.showToast({
        message: '取消收藏',
        backgroundColor: 'rgba(46, 48, 51, 0.9)',
        backgroundBlurStyle: BlurStyle.NONE,
        textColor: 'rgba(255, 255, 255, 0.9)',
        bottom: '12%'
      })
    }
  }

  aboutToAppear(): void {
    if (this.myMessageStorage.showFlag) {
      return
    } else {
      this.commentShow = this.myMessageStorage.isShowCommentSheet
      if (this.commentShow) {
        this.openCommentDialog()
        this.myMessageStorage.showFlag = true
      }
    }
  }

  sideSendFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 7
    };
    let eventData: emitter.EventData = {
      data: {
        id: 7
      }
    };
    emitter.emit(event, eventData);
  }

  build() {
    Column({ space: 16 }) {
      Column() {
        Image(this.videoDes.dramaSocialInfo.isLike ? getMedia('app.media.thumb_select') :
        getMedia('app.media.thumb_white'))
          .width(22)
          .height(20)
          .margin({ top: 2 })
          .onClick(() => {
            if (this.userInfo.isPhoneAssociated) {
              this.changeLikeCount(!this.videoDes.dramaSocialInfo.isLike ? true : false)
              this.sideSendFavoriteEmitter()
            } else {
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
              appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
            }
          })
        Text(`${this.videoDes.dramaSocialInfo.likeCount}`)
          .fontSize(10)
          .fontColor('#fff')
          .margin({ top: 4 })
      }
      .width(40)
      .height(40)
      .id('fabulousButton')

      Column() {
        Image(getMedia('app.media.comment_white'))
          .width(22)
          .height(20)
          .margin({ top: 2 })
        Text(this.videoDes.commentCount)
          .fontSize(10)
          .fontColor('#fff')
          .margin({ top: 4 })
      }
      .width(40)
      .height(40)
      .id('comment_button')
      .onClick(() => {
        this.playControl.setPlayerHeight(`48%`)
        this.commentShow = true
        this.openCommentDialog()
      })

      Column() {
        Image(this.videoDes.dramaSocialInfo.isFavorite ? getMedia('app.media.favorite_select') :
        getMedia('app.media.favorite_white'))
          .width(22)
          .height(20)
          .margin({ top: 2 })
          .onClick(() => {
            if (this.userInfo.isPhoneAssociated) {
              this.changeFavoriteCount(!this.videoDes.dramaSocialInfo.isFavorite ? true : false);
              this.sideSendFavoriteEmitter()
            } else {
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
              appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
            }
          })
        Text(`${this.videoDes.dramaSocialInfo.favoriteCount}`)
          .fontSize(10)
          .fontColor('#fff')
          .margin({ top: 4 })
      }
      .width(40)
      .height(40)
      .id('favoriteButton')

      Column() {
        Image(getMedia('app.media.share_white'))
          .width(22)
          .height(20)
          .margin({ top: 2 })
        Text('分享')
          .fontSize(10)
          .fontColor('#fff')
          .margin({ top: 4 })
      }
      .width(40)
      .height(40)
      .id('shareButton')
      .onClick(() => {
        this.shareShowVM.setPosterInfo('', this.videoDes.dramaInfo.coverUrl, '', '', this.videoDes.dramaInfo.name)
        this.isShowShareSheet = !this.isShowShareSheet
      })
      .bindSheet($$this.isShowShareSheet, this.FirstShareBuilder(), {
        title: { title: '分享到' },
        height: 352,
        preferType: SheetType.BOTTOM
      })
    }
    .width(40)
    .height(208)
  }

  @Builder
  FirstShareBuilder() {
    FirstShare({
      close: () => {
        this.isShowShareSheet = !this.isShowShareSheet
      }
    })
  }
}