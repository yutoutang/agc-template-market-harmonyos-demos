import { BreakpointModel, FormatCount } from 'lib_common';
import { Share } from 'lib_widget';
import { ImageLongTakeDelegate } from 'module_transition';
import { ImagePreviewVM } from '../viewmodel/ImagePreviewVM';

@Builder
export function ImagePreviewPageBuilder() {
  ImagePreviewPage();
}

@ComponentV2
struct ImagePreviewPage {
  @Local imagePreviewVM: ImagePreviewVM = new ImagePreviewVM()
  @Local imagePointModel: BreakpointModel = new BreakpointModel()

  async aboutToAppear() {
    this.imagePreviewVM.setSystemBarProperty()
  }

  aboutToDisappear(): void {
    this.imagePreviewVM.resetSystemBarProperty()
  }

  @Builder
  shareBuilder() {
    Share({
      shareData: {
        recordId: this.imagePreviewVM.curFeedCardInfo.id,
        title: this.imagePreviewVM.curFeedCardInfo.title,
        createTime: this.imagePreviewVM.curFeedCardInfo.createTime,
        coverUrl: this.imagePreviewVM.handlerCoverImage,
      },
      shareRenderBuilder: () => {
        this.shareCommentBuilder()
      },
    })
  }

  @Builder
  shareCommentBuilder() {
    Column({ space: 5 }) {
      Image($r('app.media.image_forward'))
        .width(21)
        .height(21)
      Text(FormatCount.formatToK(this.imagePreviewVM.curFeedCardInfo.shareCount))
        .fontSize(10 * this.imagePreviewVM.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_on_primary'))
    }
  }

  @Builder
  authorBuilder() {
    Flex({ alignItems: ItemAlign.Center }) {
      Row({ space: 4 }) {
        Image(this.imagePreviewVM.curFeedCardInfo.author.authorIcon)
          .width(24 * this.imagePreviewVM.settingInfo.fontSizeRatio)
          .height(24 * this.imagePreviewVM.settingInfo.fontSizeRatio)
          .borderRadius(12 * this.imagePreviewVM.settingInfo.fontSizeRatio)
          .clip(true)
        Text(this.imagePreviewVM.curFeedCardInfo.author.authorNickName)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize(16 * this.imagePreviewVM.settingInfo.fontSizeRatio)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: 'calc(100% - 44vp)' })
      }

      Row() {
        Text() {
          Span(this.imagePreviewVM.getWatch ? '已关注' : '关注')
        }
        .fontSize(14 * this.imagePreviewVM.settingInfo.fontSizeRatio)
        .fontColor(this.imagePreviewVM.getWatch ? $r('app.color.app_theme') : $r('sys.color.font_on_primary'))
        .onClick(() => {
          this.imagePreviewVM.watchOperation()
        })
      }
      .width(72)
      .height(28)
      .margin({ left: 16 })
      .backgroundColor(this.imagePreviewVM.getWatch ? $r('sys.color.background_primary') : $r('app.color.app_theme'))
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
      .visibility(this.imagePreviewVM.isFeedSelf ? Visibility.None : Visibility.Visible)
    }
    .visibility(this.imagePreviewVM.isExpand ? Visibility.None : Visibility.Visible)
  }

  @Builder
  operationBuilder() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 5 }) {
        Row() {
          Image(this.imagePreviewVM.isExpand ? $r('app.media.down') : $r('app.media.up')).width(17).height(9)
        }
        .width(24)
        .height(24)
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('sys.color.comp_background_tertiary'))

        Text(this.imagePreviewVM.isExpand ? '收起' : '展开').fontColor($r('sys.color.font_on_primary'))
          .fontSize(16 * this.imagePreviewVM.settingInfo.fontSizeRatio)
      }
      .onClick(() => {
        this.imagePreviewVM.toggleExpand()
      })

      Row({ space: 25 }) {
        Column({ space: 5 }) {
          Image($r('app.media.image_comment')).width(20).height(20)
          Text(this.imagePreviewVM.curFeedCardInfo.commentCount?.toString())
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10 * this.imagePreviewVM.settingInfo.fontSizeRatio)
        }
        .onClick(() => {
          this.imagePreviewVM.backToFirstPage()
          setTimeout(() => {
            this.imagePreviewVM.onAddComment()
          }, 300)
        })

        Column({ space: 5 }) {
          Image(this.imagePreviewVM.curFeedCardInfo.isLiked ? $r('app.media.like_active') :
            $r('app.media.preview_like'))
            .width(23)
            .height(20)
          Text(this.imagePreviewVM.curFeedCardInfo.likeCount?.toString())
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10 * this.imagePreviewVM.settingInfo.fontSizeRatio)
        }
        .onClick(() => {
          this.imagePreviewVM.newsLike()
        })

        this.shareBuilder()
      }
      .visibility(!this.imagePreviewVM.isExpand ? Visibility.Visible : Visibility.None)
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Swiper() {
          ForEach(this.imagePreviewVM.imageList, (item: string, index: number) => {
            ImageLongTakeDelegate({
              componentId: this.imagePreviewVM.componentId,
              newsId: this.imagePreviewVM.curFeedCardInfo.id,
              imageUrl: item,
              backToFirstPage: () => {
                this.imagePreviewVM.backToFirstPage()
              },
            })
          }, (item: string) => item)
        }
        .transition(TransitionEffect.opacity(0.99))
        .width('100%')
        .height('100%')
        .clip(false)
        .index(this.imagePreviewVM.selectedIndex)
        .onChange((index: number) => {
          this.imagePreviewVM.selectedIndex = index;
          this.imagePreviewVM.onIndexChange(index);
        })
        .onAnimationStart((_: number, targetIndex: number) => {
          this.imagePreviewVM.onIndexChange(targetIndex);
        })
        .indicator(false)

        if (this.imagePreviewVM.showImagePreviewLayer && !this.imagePreviewVM.isExpand) {
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            this.authorBuilder()
            Blank()

            Column() {
              Text(`${this.imagePreviewVM.selectedIndex + 1} / ${this.imagePreviewVM.imageList.length}`)
                .fontColor($r('sys.color.font_primary'))
                .fontSize(12)
                .constraintSize({ minWidth: 50 })
                .textAlign(TextAlign.Center)
            }
            .backgroundColor($r('sys.color.background_secondary'))
            .borderRadius(16)
            .padding(4)
          }
          .padding({ left: this.imagePointModel.pagePadding, right: this.imagePointModel.pagePadding })
          .margin({ top: 36 })
        }

        if (this.imagePreviewVM.showImagePreviewLayer) {
          Column() {
            this.operationBuilder()
          }
          .position({ bottom: 28 })
          .padding({ left: this.imagePointModel.pagePadding, right: this.imagePointModel.pagePadding })
        }
      }
    }
    .width('100%')
    .height('100%')
    .mode(NavDestinationMode.DIALOG)
    .onReady((context: NavDestinationContext) => {
      this.imagePreviewVM.getNavigationParams(context)
    })
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.imagePreviewVM.backToFirstPage();
      return true;
    })
    .transition(TransitionEffect.opacity(0.99))
  }
}