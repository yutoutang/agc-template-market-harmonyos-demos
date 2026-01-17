import { PersistenceV2 } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { BusinessError } from '@kit.BasicServicesKit'
import { FormatCount, Logger, RouterMap, RouterUtils, SettingModel, TimeUtils } from 'lib_common'
import { Share } from 'lib_widget'
import { ImagePreview, PreviewVerticalAlign } from 'module_imagepreview'
import { handlerCoverImage } from '../utils/Utils'
import NewsFeedVM from '../viewmodel/NewsFeedVM'
import { FeedBreakPointVM } from '../viewmodel/FeedBreakPointVM'

class Native {
  preview = (srcList: string[], index: number) => {
  }
}

const TAG = '[NewsContent]';

@ComponentV2
export struct NewsContent {
  @Param fontSizeRatio: number = 1
  @Param newsFeedVM: NewsFeedVM = new NewsFeedVM()
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  webViewController: webview.WebviewController = new webview.WebviewController();
  @Local nativeObj: Native = new Native();
  @Local isExpand: boolean = false
  @Event onAddLike: () => void = () => {
  }
  @Event onAddWatch: () => void = () => {
  }
  @Event onComment: () => void = () => {
  }
  @Local timer: number = 0
  @Local richTextHeight: number = 300
  @Local newsBreakPoint: FeedBreakPointVM = new FeedBreakPointVM()

  @Monitor('settingInfo.darkSwitch')
  darkSwitch() {
    this.webViewController.runJavaScript(`setWebFontColor(${this.settingInfo.darkSwitch})`)
      .catch((e: BusinessError) => {
        Logger.error(TAG, 'runJavaScript fail, error: ' + JSON.stringify(e));
      });
  }

  expandAnimation() {
    if (this.timer) {
      clearTimeout(this.timer)
    }
    this.getUIContext().animateTo({
      duration: 500,
      curve: Curve.EaseOut,
      playMode: PlayMode.Normal,
    }, () => {
      this.isExpand = true
      this.timer = setTimeout(() => {
        this.isExpand = false
      }, 2000)
    })
  }

  @Builder
  authorBuilder() {
    Flex({ alignItems: ItemAlign.Center }) {
      Row({ space: 4 }) {
        Image(this.newsFeedVM.articleDetails.author.authorIcon).width(24).height(24).borderRadius(12).clip(true)
        Text(this.newsFeedVM.articleDetails.author.authorNickName)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize(16 * this.fontSizeRatio)
      }

      Row() {
        Text() {
          Span(this.newsFeedVM.isWatch() ? '已关注' : '关注')
        }
        .fontSize(14 * this.fontSizeRatio)
        .fontColor(this.newsFeedVM.isWatch() ? $r('app.color.app_theme') : $r('sys.color.font_on_primary'))
        .onClick(() => {
          this.onAddWatch()
        })
      }
      .width(72)
      .height(28)
      .margin({ left: 16 })
      .backgroundColor(this.newsFeedVM.isWatch() ? $r('sys.color.background_primary') : $r('app.color.app_theme'))
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
      .visibility(!this.newsFeedVM.isFeedSelf ? Visibility.Visible : Visibility.None)
    }
    .visibility(this.isExpand ? Visibility.None : Visibility.Visible)
  }

  @Builder
  operationBuilder() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 5 }) {
        Row() {
          Image(this.isExpand ? $r('app.media.down') : $r('app.media.up')).width(17).height(9)
        }
        .width(24).height(24)
        .borderRadius(12)
        .backgroundColor($r('sys.color.comp_background_tertiary'))

        Text(this.isExpand ? '收起' : '展开').fontColor($r('sys.color.font_on_primary'))
          .fontSize(16 * this.fontSizeRatio)
      }
      .onClick(() => {
        this.getUIContext().animateTo({
          duration: 500,
          curve: Curve.EaseOut,
          playMode: PlayMode.Normal,
        }, () => {
          this.isExpand = !this.isExpand
        })
      })

      Row({ space: 25 }) {
        Column({ space: 5 }) {
          Image($r('app.media.image_comment')).width(20).height(20)
          Text(this.newsFeedVM.articleDetails.commentCount?.toString())
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10 * this.fontSizeRatio)
        }
        .onClick(() => {
          ImagePreview.hide()
          this.onComment()
        })

        Column({ space: 5 }) {
          Image(this.newsFeedVM.articleDetails.isLiked ? $r('app.media.like_active') : $r('app.media.preview_like'))
            .width(23)
            .height(20)
          Text(this.newsFeedVM.articleDetails.likeCount?.toString())
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10 * this.fontSizeRatio)
        }
        .onClick(() => {
          this.onAddLike()
        })

        this.shareBuilder()
      }
      .visibility(!this.isExpand ? Visibility.Visible : Visibility.None)
    }
  }

  aboutToAppear(): void {
    this.nativeObj.preview = this.preview
  }

  preview = (srcList: string[], index: number) => {
    ImagePreview.show(this.getUIContext(), srcList, {
      indexPosition: PreviewVerticalAlign.Top,
      startIndex: index,
      authorBuilder: () => {
        this.authorBuilder()
      },
      operationBuilder: () => {
        this.operationBuilder()
      },
      onCloseExpand: () => {
        this.expandAnimation()
      },
    })
  }

  @Builder
  shareCommentBuilder() {
    Column({ space: 5 }) {
      Image($r('app.media.image_forward'))
        .width(21)
        .height(21)
      Text(FormatCount.formatToK(this.newsFeedVM.articleDetails.shareCount))
        .fontSize(10 * this.fontSizeRatio)
        .fontColor($r('sys.color.font_on_primary'))
    }
  }

  @Builder
  shareBuilder() {
    Share({
      shareData: {
        recordId: this.newsFeedVM.articleDetails.id,
        title: this.newsFeedVM.articleDetails.title,
        subTitle: this.newsFeedVM.articleDetails.articleFrom,
        createTime: this.newsFeedVM.articleDetails.createTime,
        coverUrl: handlerCoverImage(this.newsFeedVM.articleDetails),
      },
      shareRenderBuilder: () => {
        this.shareCommentBuilder()
      },
    })
  }

  @Computed
  get setWebFontSize() {
    if (this.settingInfo.fontSizeRatio < 1) {
      return this.settingInfo.fontSizeRatio
    } else if (this.settingInfo.fontSizeRatio > 1) {
      return this.settingInfo.fontSizeRatio * 2
    }
    return this.settingInfo.fontSizeRatio * 1.2
  }

  @Builder
  authorInfoBuilder() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Row({ space: 4 }) {
        Image(this.newsFeedVM.articleDetails.author.authorIcon)
          .width(40)
          .height(40)
          .borderRadius(20)
          .clip(true)
          .accessibilityText(this.newsFeedVM.articleDetails.author.authorNickName + '头像')
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.newsFeedVM.articleDetails.author.authorId)
          })
        Column({ space: 4 }) {
          Text(this.newsFeedVM.articleDetails.author.authorNickName)
            .fontSize(14 * this.fontSizeRatio)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .constraintSize({ maxWidth: 'calc(100% - 44vp)' })
          Text(TimeUtils.formatDate(this.newsFeedVM.articleDetails.createTime))
            .fontSize(12 * this.fontSizeRatio)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .alignItems(HorizontalAlign.Start)
      }

      Row() {
        Text() {
          Span(this.newsFeedVM.isWatch() ? '已关注' : '关注')
        }
        .fontSize(14 * this.fontSizeRatio)
        .fontColor(this.newsFeedVM.isWatch() ? $r('app.color.app_theme') : $r('sys.color.font_on_primary'))
        .onClick(() => {
          this.newsFeedVM.watchOperation()
        })
      }
      .width(72)
      .height(28)
      .margin({ left: 16 })
      .visibility(!this.newsFeedVM.isFeedSelf ? Visibility.Visible : Visibility.None)
      .backgroundColor(this.newsFeedVM.isWatch() ? $r('sys.color.comp_background_tertiary') : $r('app.color.app_theme'))
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
    }
    .margin({ top: 12, bottom: 12 })
  }

  build() {
    Column() {
      Column() {
        Column() {
          Text(this.newsFeedVM.articleDetails.title)
            .fontSize(20 * this.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .padding({
        top: 8,
        bottom: 8,
      })
      .backgroundColor($r('sys.color.background_primary'))

      Column() {
        this.authorInfoBuilder()
      }
      .backgroundColor($r('sys.color.background_primary'))

      Column() {
        Web({
          src: '',
          controller: this.webViewController,
          renderMode: RenderMode.SYNC_RENDER,
        })
          .fileAccess(false)
          .layoutMode(WebLayoutMode.FIT_CONTENT)
          .geolocationAccess(false)
          .defaultFontSize(14 * this.setWebFontSize)
          .backgroundColor($r('sys.color.background_primary'))
          .accessibilityGroup(true)
          .onControllerAttached(() => {
            try {
              this.webViewController.loadData(
                this.newsFeedVM.setRichToHtml(),
                'text/html',
                'UTF-8',
              );
              this.webViewController.registerJavaScriptProxy(this.nativeObj, 'native', ['preview']);
            } catch (error) {
              Logger.error(TAG,
                `ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
          })
          .onPageEnd(async () => {
            this.webViewController.runJavaScript(`getSize()`)
              .then((result: string) => {
                let res: Record<string, number> = JSON.parse(result)
                this.richTextHeight = this.getUIContext().px2vp(res.height) * 1.2
              }).catch((e: BusinessError) => {
              Logger.error(TAG, 'runJavaScript fail, error: ' + JSON.stringify(e));
            });
            this.webViewController.runJavaScript(`setWebFontColor(${this.settingInfo.darkSwitch})`)
              .catch((e: BusinessError) => {
                Logger.error(TAG, 'runJavaScript fail, error: ' + JSON.stringify(e));
              });
          })
      }
    }
    .padding({
      left: this.newsBreakPoint.breakpointModel.pagePadding,
      right: this.newsBreakPoint.breakpointModel.pagePadding,
    })
    .backgroundColor($r('sys.color.background_primary'))
  }
}