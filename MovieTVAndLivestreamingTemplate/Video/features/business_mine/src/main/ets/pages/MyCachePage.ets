import { CommonConstants, RouterMap, RouterUtils } from 'lib_common'
import { VideoResponse } from 'lib_video_api'
import { NavHeaderBar } from 'lib_widget'
import { DownloadFile, DownloadTask } from 'video_interaction'
import { MyCacheVM } from '../viewmodels/MyCacheVM'

@Builder
export function MyCachePageBuilder() {
  MyCachePage()
}

@ComponentV2
struct MyCachePage {
  @Local vm: MyCacheVM = new MyCacheVM()
  @Local data: string[] = []
  @Local bgColors: Color[] =
    [Color.Red, Color.Orange, Color.Yellow, Color.Green, Color.Pink, Color.Grey, Color.Blue, Color.Brown]

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的缓存',
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
        })
        Column() {
          Scroll() {
            Column({ space: 20 }) {
              this.downloadBuilderList()
              this.moreGrid()
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .width('100%')
          .padding(16)
          .edgeEffect(EdgeEffect.Spring)

          if (!this.vm.isEditMode) {
            this.toolBarBuilder()
          }
        }
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onReady(context => {
      this.vm.init()
    })
  }

  @Builder
  moreGrid() {
    Column({ space: 10 }) {
      Text('相关内容')
        .width('100%')
        .fontColor('#E6000000')
        .fontSize(18)
        .lineHeight(21)
        .fontWeight(FontWeight.Bold)
      GridRow({
        columns: 3,
        gutter: { x: 8, y: 12 }
      }) {
        ForEach(this.vm.relatedVideoList, (video: VideoResponse) => {
          GridCol() {
            Column({ space: 4 }) {
              Image(video.coverUrl).width('100%').aspectRatio(0.75).borderRadius(8)
              Text(video.title)
                .fontColor('#E6000000')
                .fontSize(14)
                .lineHeight(16)
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Clip })
                .wordBreak(WordBreak.BREAK_ALL)
              Text(video.subTitle)
                .fontColor('#99000000')
                .fontSize(10)
                .lineHeight(11)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Clip })
                .wordBreak(WordBreak.BREAK_ALL)
            }.alignItems(HorizontalAlign.Start)
            .onClick(() => {
              const param: Record<string, Object> = {
                'videoId': video.videoId
              }
              RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
            })
          }
        }, (video: VideoResponse) => JSON.stringify(video))
      }.width('100%')
    }
    .visibility(!this.vm.isEditMode ? Visibility.None : Visibility.Visible)
  }

  @Builder
  downloadBuilderList() {
    Column({ space: 20 }) {
      if (this.vm.queueDownloader.tasks.length <= 0) {
        Column({ space: 10 }) {
          Image($r('app.media.ic_empty_content')).width(120).height(120)
          Text('没有缓存视频')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        if ((this.vm.queueDownloader.tasks.filter(item => item.status !== 'completed')).length > 0) {
          this.cachingBuilder(this.vm.queueDownloader.tasks.filter(item => item.status !== 'completed')[0])
        }
        ForEach(this.vm.queueDownloader.cachedTasks, (item: DownloadFile) => {
          this.downloadItemBuilder(item)
        }, (item: DownloadFile) => JSON.stringify(item))
      }
    }
  }

  @Builder
  cachingBuilder(item: DownloadTask) {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Row({ space: 12 }) {
        Checkbox()
          .width(18)
          .select(this.vm.toDeleteList.includes('caching'))
          .shape(CheckBoxShape.CIRCLE)
          .onChange((value: boolean) => {
            this.vm.onChange(value, 'caching')
          })
          .visibility(!this.vm.isEditMode ? Visibility.Visible : Visibility.None)

        Stack() {
          Row() {

          }
          .width(88)
          .height(45)
          .backgroundColor('#1A000000')
          .borderRadius(8)
          .offset({ y: -15 })

          Image(item.mediaItem?.coverUrl)
            .width('100%')
            .height('100%')
            .borderRadius(8)
          Image($r('app.media.icon_down_circle')).width(24).height(24)
        }
        .width(100)
        .height(60)

        Column() {
          Text('正在缓存')
            .textAlign(TextAlign.Start)
            .width('100%')
            .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .maxLines(2) // 最多2行，超出省略
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row() {
            Text(`共${(this.vm.queueDownloader.tasks.filter(item => item.status !== 'completed')).length}个任务`)
              .fontSize(10 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('#333333')
            Text(`${(item.totalSize / 1024 / 1024).toFixed(2)}MB`)
              .fontSize(10 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('#333333')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Progress({
            value: item.receivedSize,
            total: item.totalSize,
            type: ProgressType.Linear
          })
            .value(item.receivedSize)
            .height(24)

          Text('正在下载')
            .fontSize(10 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('#333333')
            .width('100%')
        }
        .layoutWeight(1)
      }
      .borderRadius(8)
      .onClick(() => {
        if (this.vm.isEditMode) {
          RouterUtils.pushPathByName(RouterMap.MINE_CACHING_PAGE)
        }
      })
    }
  }

  @Builder
  downloadItemBuilder(item: DownloadFile) {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Row({ space: 10 }) {
        Checkbox()
          .width(18)
          .select(this.vm.toDeleteList.includes(item.title))
          .shape(CheckBoxShape.CIRCLE)
          .onChange((value: boolean) => {
            this.vm.onChange(value, item.title)
          })
          .visibility(!this.vm.isEditMode ? Visibility.Visible : Visibility.None)

        Image(item.icon)
          .width(100)
          .height(60)
          .borderRadius(8)

        Column({ space: 10 }) {
          Text(item.title || '未知标题')
            .textAlign(TextAlign.Start)
            .width('100%')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .maxLines(2) // 最多2行，超出省略
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${item.tasks.length}个视频`)
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('#333333')
            .width('100%')
        }
        .layoutWeight(1)

      }
      .onClick(() => {
        if (this.vm.isEditMode) {
          const param: Record<string, Object> = {
            'title': item.title
          }
          RouterUtils.pushPathByName(RouterMap.MINE_CACHED_PAGE, param)
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
        this.vm.deleteAllConfirm()
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