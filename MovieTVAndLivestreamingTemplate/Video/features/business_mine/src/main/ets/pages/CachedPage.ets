import { CommonConstants, RouterMap, RouterUtils } from 'lib_common'
import { NavHeaderBar } from 'lib_widget'
import { DownloadTask, DownloadView, MediaItemModel } from 'video_interaction'
import { CachedViewModel } from '../viewmodels/CachedViewModel'

@Builder
export function CachedPageBuilder() {
  CachedPage()
}

@ComponentV2
struct CachedPage {
  @Local vm: CachedViewModel = new CachedViewModel()
  @Local downloadShowSheet: boolean = false

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: this.vm.title,
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
        })

        Column() {
          Scroll() {
            this.downloadBuilderList()
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .width('100%')


          if (!this.vm.isEditMode) {
            this.toolBarBuilder()
          } else {
            Column() {
              Text('缓存更多剧集')
                .height(40)
                .width(150)
                .textAlign(TextAlign.Center)
                .fontColor($r('app.color.app_theme'))
                .backgroundColor($r('sys.color.background_tertiary'))
                .borderRadius(20)
            }.bindSheet(this.downloadShowSheet, this.downloadSheet(), {
              height: SheetSize.MEDIUM,
              dragBar: false,
              preferType: SheetType.CENTER
            })
            .onClick(() => {
              this.downloadShowSheet = !this.downloadShowSheet;
            })
          }
        }
        .layoutWeight(1)
        .padding(12)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context: NavDestinationContext) => {
      if (context.pathInfo.param) {
        const params = context.pathInfo.param as Record<string, Object>
        const title = params.title as string
        this.vm.title = title
        this.vm.init()
      }
    })
  }

  @Builder
  downloadSheet() {
    DownloadView({
      mediaItem: new MediaItemModel({
        videoId: this.vm.video.videoId,
        type: this.vm.video.contentType,
        title: this.vm.video.title,
        coverUrl: this.vm.video.coverUrl,
        videoUrl: this.vm.video.videoUrl,
        createTime: this.vm.video.createTime,
        isLike: this.vm.video.isLiked,
        likeCount: this.vm.video.likeCount,
        isMark: this.vm.video.isMarked,
        commentCount: this.vm.video.commentCount,
      }),
      goDownloadPage: () => {
        RouterUtils.pushPathByName(RouterMap.MINE_CACHE_PAGE)
      },
      exitDownloadShow: () => {
        this.downloadShowSheet = false
      }
    })
  }

  @Builder
  downloadBuilderList() {
    List({ space: 20 }) {
      if (this.vm.queueDownloader.tasks.length <= 0) {
        ListItem() {
          Column({ space: 10 }) {
            Image($r('app.media.ic_empty_content')).width(120).height(120)
            Text('暂无缓存内容')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
        }
      } else {
        ForEach(this.vm.queueDownloader.cachedTasks.find(item => item.title === this.vm.title)?.tasks,
          (item: DownloadTask) => {
            ListItem() {
              this.downloadItemBuilder(item)
            }
          }, (item: DownloadTask) => JSON.stringify(item))
      }
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  downloadItemBuilder(item: DownloadTask) {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Row({ space: 10 }) {
        Checkbox()
          .width(18)
          .select(this.vm.toDeleteList.includes(item.id))
          .shape(CheckBoxShape.CIRCLE)
          .onChange((value: boolean) => {
            this.vm.onChange(value, item)
          })
          .visibility(!this.vm.isEditMode ? Visibility.Visible : Visibility.None)
        Image(item.mediaItem?.coverUrl)
          .width(100)
          .height(60)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        Column({ space: 10 }) {
          Text(item.mediaItem?.title || '未知标题')
            .textAlign(TextAlign.Start)
            .width('100%')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row() {
            Text(`第${item.sectionNo || 0}集`)
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('#333333')
            Text(`${(item.totalSize / 1024 / 1024).toFixed(2)}MB`)
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('#333333')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .layoutWeight(1)
      }
      .borderRadius(8)
      .onClick(() => {
        if (this.vm.isEditMode) {
          const param: Record<string, Object> = {
            'videoId': item.videoId,
            'index': item.sectionNo - 1,
          }
          RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param)
        }
      })
    }

  }

  @Builder
  rightPartBuilder() {
    Row() {
      if (this.vm.isEditMode) {
        Image($r('app.media.ic_Default'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.isEditMode = !this.vm.isEditMode
          })
      } else {
        Text('取消')
          .fontColor('#99000000')
          .fontSize(14)
          .onClick(() => {
            this.vm.isEditMode = !this.vm.isEditMode
          })
      }
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
    .visibility(this.vm.queueDownloader.tasks.length > 0 ? Visibility.Visible : Visibility.None)

  }

  @Builder
  toolBarBuilder() {
    Row() {
      Column({ space: CommonConstants.SPACE_XS }) {
        Button(this.vm.allSelected ? '取消全选' : '全选')
          .width(156)
          .height(40)
          .fontColor($r('sys.color.font_tertiary'))
          .backgroundColor($r('sys.color.font_on_primary'))
      }
      .width(CommonConstants.HALF_PERCENT)
      .padding(CommonConstants.PADDING_XS)
      .onClick(() => {
        this.vm.deleteAllConfirm(this.vm.queueDownloader)
      })

      Column({ space: CommonConstants.SPACE_XS }) {
        Button('删除')
          .width(156)
          .height(40)
      }
      .width(CommonConstants.HALF_PERCENT)
      .padding(CommonConstants.PADDING_XS)
      .onClick(() => {
        this.vm.deleteConfirm()
      })
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}