import { CommonConstants } from 'lib_common'
import { NavHeaderBar } from 'lib_widget'
import { DownloadTask } from 'video_interaction'
import { CachingViewModel } from '../viewmodels/CachingViewModel'

@Builder
export function CachingPageBuilder() {
  CachingPage()
}

@ComponentV2
struct CachingPage {
  @Local vm: CachingViewModel = new CachingViewModel()

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '正在缓存',
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
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
  }

  @Builder
  downloadBuilderList() {
    List({ space: 20 }) {
      if (this.vm.queueDownloader.tasks.filter(item => item.status !== 'completed')
        .length <= 0) {
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
        ForEach(
          this.vm.queueDownloader.tasks.filter(item => item.status !== 'completed'), (item: DownloadTask) => {
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

        Column() {
          Text(`${item.mediaItem.title || '未知标题'} 第${item.sectionNo}集`)
            .textAlign(TextAlign.Start)
            .width('100%')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Progress({
            value: item.receivedSize,
            total: item.totalSize,
            type: ProgressType.Linear
          })
            .value(item.receivedSize)
            .height(24)

          Row() {
            if (item.status === 'downloading') {
              Text('正在下载')
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor('#333333')
            } else if (item.status === 'pending') {
              Text('正在等待')
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor('#333333')
            } else if (item.status === 'paused') {
              Text('已暂停')
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor('#333333')
            }
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
          if (item.status === 'downloading') {
            this.vm.queueDownloader.pauseTask(item.id)
          } else if (item.status === 'paused') {
            this.vm.queueDownloader.resumeTask(item.id)
          }
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