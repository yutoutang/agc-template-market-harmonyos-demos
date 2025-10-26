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
import { Share } from '@agctemplate/module_share';
import { emitter } from '@kit.BasicServicesKit';
import { ProcessController } from 'video_swiper/src/main/ets/view/ProcessController';
import { AVPlayerListener } from 'video_swiper/src/main/ets/controller/AvPlayerListener';

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
  @Consumer('curTabIndex') curTabIndex: number = 0;
  @Local processController: ProcessController | undefined = undefined
  avPlayerListener: AVPlayerListener = {
    onEnded: () => {
      Logger.info(TAG, 'onEnded')
      this.playerSession.avPlayer?.pause()
      this.unEmitter()
      this.playerSession.unregisterListener(this.avPlayerListener)
      jumpDetailPage(this.dramaInfo, this.dramaInfo.curIndex + 1, 0, (data: PopInfo) => {
        Logger.info(TAG, 'onReEnter')
        this.onReEnter()
      })
    }
  }
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
    this.playerSession.registerListener(this.avPlayerListener)
    this.getDeleteEmitter()
    this.getDetailInfoFavoriteEmitter()
    this.getSideFavoriteEmitter()
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
    this.registerEmitter()
  }

  registerEmitter() {
    this.backEmitter()
    this.foreEmitter()
  }

  onForeground: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    Logger.info(TAG, `onForeground: ${JSON.stringify(eventData)}`);
    // 不响应非本tab事件
    if (this.curTabIndex === 0) {
      return
    }
    this.playControl.pause()
  }
  onBackground: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    Logger.info(TAG, `onBackground: ${JSON.stringify(eventData)}`);
    if (this.curTabIndex !== 0) {
      return
    }
    this.playControl.pause()
  }

  backEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 1
    };
    emitter.on(event, this.onBackground);
  }

  foreEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 2
    };
    emitter.on(event, this.onForeground);
  }

  unEmitter() {
    Logger.info(TAG, 'on jump')
    emitter.off(1, this.onBackground)
    emitter.off(2, this.onForeground)
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
      DramaDesLayer({
        dramaInfo: this.dramaInfo,
        playControl: this.playControl,
        playerSession: this.playerSession,
        onJump: () => {
          Logger.info(TAG, 'onJump')
          this.playControl.pause()
          this.unEmitter()
          jumpDetailPage(this.dramaInfo, this.dramaInfo.curIndex, this.playerSession.avPlayer?.currentTime,
            (data: PopInfo) => {
              Logger.info(TAG, 'onReEnter')
              this.onReEnter()
            })
        }
      })

      Column({ space: 16 }) {
        Column() {
          Image(this.isThumb ? getMedia('app.media.thumb_select') : getMedia('app.media.thumb_white'))
            .width(22)
            .height(20)
            .margin({ top: 2 })
            .onClick(() => {
              if (this.userInfo.isPhoneAssociated) {
                if (this.isThumb) {
                  this.likeCount--
                  container.resolve(RequestAPI).unsetLike(this.dramaInfo.id)
                } else {
                  this.likeCount++
                  container.resolve(RequestAPI).setLike(this.dramaInfo.id)
                }
                this.isThumb = !this.isThumb
              } else {
                WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                this.playControl.pause()
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
                if (this.isFavorite) {
                  this.favoriteCount--
                  container.resolve(RequestAPI).unsetFavorite(this.dramaInfo.id)
                } else {
                  this.favoriteCount++
                  container.resolve(RequestAPI).setFavorite(this.dramaInfo.id)
                }
                this.isFavorite = !this.isFavorite
              } else {
                WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                this.playControl.pause()
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

        this.shareBuilder()

      }
      .width(40)
      .height(208)
      .margin({ bottom: 72, right: 8 })
      .onVisibleAreaChange([0],(isExpanding:boolean,currentRatio:number)=>{
        if(isExpanding){
          this.playControl.play()
        }
      })

      if (this.playerSession.avPlayer?.isReady) {
        ProcessBar({ avPlayer: this.playerSession.avPlayer })
          .hitTestBehavior(HitTestMode.Transparent)
      }

    }
    .width('100%')
    .height('100%')
  }


  @Builder
  shareCommentBuilder() {
    Column({ space: 5 }) {
      Image($r('app.media.share_white'))
        .width(21)
        .height(21)
      Text('分享')
        .fontSize(10)
        .fontColor($r('sys.color.font_on_primary'))
    }
  }

  @Builder
  shareBuilder() {
    Share({
      qrCodeInfo: {
        id: this.dramaInfo.id,
        type: 2,
        title: this.dramaInfo.name,
        createTime: '',
        coverUrl: this.dramaInfo.coverUrl,
        isVideo: false,
        articleFrom: this.dramaInfo.category[0] + '/' + this.dramaInfo.category[1]
      },
      shareRenderBuilder: () => {
        this.shareCommentBuilder()
      },
      onClose: () => {
        this.isShowShareSheet = !this.isShowShareSheet
      }
    })
  }

  onReEnter() {
    this.playControl.seek(0)
    this.playControl.play()
    this.registerEmitter()
    Logger.info(TAG, 'registerListener')
    this.playerSession.registerListener(this.avPlayerListener)
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
