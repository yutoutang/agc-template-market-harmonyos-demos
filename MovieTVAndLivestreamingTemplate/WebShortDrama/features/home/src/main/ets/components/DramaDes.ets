import { DramaItemVM } from '../viewmodel/DramaItemVM';
import { ProcessBar, VideoPlayData, PlayController, PlaySession } from 'video_swiper';
import { DramaInfo, RequestAPI } from '@agctemplate/server';
import { jumpDetailPage } from '@agctemplate/detail';
import { DramaDesLayer } from './DramaDesLayer';
import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources';
import { commentBuilder, CommentParam } from './CommentComp';
import { appRouter, container, Logger, WindowManager } from '@agctemplate/utils';
import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { UserInfoModel } from '@agctemplate/widgets';
import { FirstShare, SheetShowVM } from '@agctemplate/module_share';
import { emitter } from '@kit.BasicServicesKit';

const TAG = '[DramaDes]'

/**
 * 功能描述：
 * 1. Home剧集信息流上层独立绘制页面，视频描述信息，海报，看全集。
 *
 */
@Preview
@ComponentV2
export struct HomeDramaDes {
  @Param @Once @Require dramaInfo: DramaInfo = new DramaInfo([]) //剧集信息
  @Param @Require playControl: PlayController;
  @Param @Require playerSession: PlaySession
  @Local isThumb: boolean = false
  @Local likeCount: number = 0
  @Local favoriteCount: number = 0
  @Local isFavorite: boolean = false
  @Local isShowCommentSheet: boolean = false
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!;
  @Local commentCount: number = 3
  @Local isShowShareSheet: boolean = false
  @Local shareShowVM: SheetShowVM = SheetShowVM.instance
  private commentNode: ComponentContent<CommentParam> = new ComponentContent(
    this.getUIContext(),
    wrapBuilder<[CommentParam]>(commentBuilder),
    {
      dramaInfo: this.dramaInfo,
      commentNum: (comments: number) => {
        this.commentCount = comments
      },
      closeSheet: () => {
        this.isShowCommentSheet = false
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
        this.isShowCommentSheet = false
        this.playControl.setPlayerHeight(`100%`)
      }
    })
  }

  closeCommentDialog() {
    this.getUIContext().getPromptAction().closeCustomDialog(this.commentNode)
  }

  aboutToAppear(): void {
    this.getDeleteEmitter()
    this.getDetailInfoFavoriteEmitter()
    this.getSideFavoriteEmitter()
    this.playerSession.onStateChange('stateChange', (state: string) => {
      // 进入详情播放页播放下一集
      if (state === 'completed') {
        jumpDetailPage(this.dramaInfo, this.dramaInfo.curIndex + 1, 0, (data: PopInfo) => {
          this.onReEnter()
        })
      }
    })
    this.isFavorite = this.dramaInfo.isFavorite
    this.isThumb = this.dramaInfo.isLike
    this.likeCount = this.dramaInfo.likeCount
    this.favoriteCount = this.dramaInfo.favoriteCount
    container.resolve(RequestAPI).getCommentList({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.commentCount = res.getBody().commentList.length
    })
  }

  getDeleteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 6
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.isFavorite = this.dramaInfo.isFavorite
      this.isThumb = this.dramaInfo.isLike
      this.likeCount = this.dramaInfo.likeCount
      this.favoriteCount = this.dramaInfo.favoriteCount
    }
    emitter.on(event, callback);
  }

  getDetailInfoFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 5
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.isFavorite = this.dramaInfo.isFavorite
      this.isThumb = this.dramaInfo.isLike
      this.likeCount = this.dramaInfo.likeCount
      this.favoriteCount = this.dramaInfo.favoriteCount
    }
    emitter.on(event, callback);
  }

  getSideFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 7
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.isFavorite = this.dramaInfo.isFavorite
      this.isThumb = this.dramaInfo.isLike
      this.likeCount = this.dramaInfo.likeCount
      this.favoriteCount = this.dramaInfo.favoriteCount
    }
    emitter.on(event, callback);
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      DramaDesLayer({ dramaInfo:this.dramaInfo, playControl: this.playControl, playerSession: this.playerSession})

      Column({ space: 16 }) {
        Column() {
          Image(this.isThumb ? getMedia('app.media.thumb_select') : getMedia('app.media.thumb_white'))
            .width(22)
            .height(20)
            .margin({ top: 2 })
            .onClick(() => {
              if (this.userInfo.isPhoneAssociated) {
                if(this.isThumb) {
                  this.likeCount--
                  container.resolve(RequestAPI).unsetLike(this.dramaInfo.id)
                }else {
                  this.likeCount++
                  container.resolve(RequestAPI).setLike(this.dramaInfo.id)
                }
                this.isThumb = !this.isThumb
              } else {
                WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
              }
            })
          Text(`${this.likeCount}`)
            .fontSize(10)
            .fontColor('#fff')
            .margin({ top: 4 })
        }
        .width(40)
        .height(40)

        Column() {
          Image(getMedia('app.media.comment_white'))
            .width(22)
            .height(20)
            .margin({ top: 2 })
          Text(`${this.commentCount}`)
            .fontSize(10)
            .fontColor('#fff')
            .margin({ top: 4 })
        }
        .width(40)
        .height(40)
        .onClick(() => {
          this.isShowCommentSheet = !this.isShowCommentSheet
          this.playControl.setPlayerHeight('40%')
          this.openCommentDialog()
        })

        Column() {
          Image(this.isFavorite ? getMedia('app.media.favorite_select') :
          getMedia('app.media.favorite_white'))
            .width(22)
            .height(20)
            .margin({ top: 2 })
            .onClick(() => {
              if (this.userInfo.isPhoneAssociated) {
                if(this.isFavorite) {
                  this.favoriteCount--
                  container.resolve(RequestAPI).unsetFavorite(this.dramaInfo.id)
                }else {
                  this.favoriteCount++
                  container.resolve(RequestAPI).setFavorite(this.dramaInfo.id)
                }
                this.isFavorite = !this.isFavorite
              } else {
                WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
              }
            })
          Text(`${this.favoriteCount}`)
            .fontSize(10)
            .fontColor('#fff')
            .margin({ top: 4 })
        }
        .width(40)
        .height(40)

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
        .onClick(() => {
          this.shareShowVM.setPosterInfo('', this.dramaInfo.coverUrl, '', '', this.dramaInfo.name)
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
      .margin({ bottom: 72, right: 8 })

      ProcessBar({ playerSession: this.playerSession })
        .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FirstShareBuilder() {
    FirstShare({
      close: () => {
        this.isShowShareSheet = !this.isShowShareSheet
      }
    })
  }

  onReEnter() {
    this.playControl.play()
  }
}

@Builder
export function DramaDesComponent(videoData: VideoPlayData, playControl: PlayController, playerSession: PlaySession) {
  HomeDramaDes({
    dramaInfo: (videoData as DramaItemVM).dramaInfo,
    playControl: playControl,
    playerSession: playerSession
  })
}
