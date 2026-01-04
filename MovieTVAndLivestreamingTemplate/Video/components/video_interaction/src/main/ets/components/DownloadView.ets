import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { MediaItemModel } from '../model/MediaItemModel';
import { DownloadStatus, UrlModel } from '../model/DownloadModel';
import { QueueDownloader } from '../utils/QueueDownloader';


@ComponentV2
export struct DownloadView {
  @Local queueDownloader: QueueDownloader = PersistenceV2.connect(QueueDownloader,
    () => new QueueDownloader(this.getUIContext().getHostContext() as Context))!;
  // 当前视频信息
  @Param @Require mediaItem: MediaItemModel
  @Local isAllDownload: boolean = false
  // 下载url对象
  @Local urlList: UrlModel[] = []
  @Event goDownloadPage?: () => void
  @Event exitDownloadShow?: () => void

  aboutToAppear(): void {
    this.mediaItem.videoUrl.forEach((url, index) => {
      // 判断下载队列里面是否有对应集数的下载任务
      const task = this.queueDownloader.tasks.find((item) => {
        return item.videoId === this.mediaItem.videoId && item.url.url === url && item.sectionNo === index + 1
      })
      let status = DownloadStatus.Cancel
      if (task) {
        if (task.status === 'pending' || task.status === 'downloading') {
          status = DownloadStatus.Loading
        } else if (task.status === 'completed') {
          status = DownloadStatus.Complete
        }
      }
      this.urlList.push(new UrlModel(this.mediaItem.videoId + url, status, url as string))
    })
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.mediaItem.title).fontColor('#E6000000').fontSize(20).lineHeight(24)
      }.width('100%').height(40)

      Grid() {
        ForEach(this.urlList, (item: UrlModel, index: number) => {
          GridItem() {
            Stack() {
              Text(`${index + 1}`).fontColor('#E6000000')
              if (item.status === DownloadStatus.Loading) {
                Image($r('app.media.arrow_down_circle'))
                  .width(12)
                  .height(12)
                  .position({ bottom: 2, right: 2 })
              } else if (item.status === DownloadStatus.Complete) {
                Image($r('app.media.down_complete_circle'))
                  .width(12)
                  .height(12)
                  .position({ bottom: 2, right: 2 })
              }
            }
            .width('100%')
            .borderRadius(4)
            .aspectRatio(1)
            .backgroundColor('#0D000000')
            .onClick(() => {

              if (item.status === DownloadStatus.Cancel) {
                promptAction.showToast({
                  message: '已加入缓存列表'
                })
                item.status = DownloadStatus.Loading
                item.taskId = this.queueDownloader.addTask(item, this.mediaItem, index + 1)
              } else if (item.status === DownloadStatus.Loading) {
                promptAction.showToast({
                  message: '已取消缓存本视频'
                })
                item.status = DownloadStatus.Cancel
                this.queueDownloader.cancelTask(item.taskId ?? '')
              }
            })
          }
        }, (item: UrlModel) => JSON.stringify(item))
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      GridRow({
        columns: 2,
        gutter: 12
      }) {
        GridCol() {
          Button(this.isAllDownload ? '取消下载' : '全部下载')
            .width('100%')
            .height(40)
            .width(156)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              promptAction.showToast({
                message: '已加入缓存列表'
              })
              this.urlList.forEach((item: UrlModel, index: number) => {
                if (item.status === DownloadStatus.Cancel) {
                  item.status = DownloadStatus.Loading
                  item.taskId = this.queueDownloader.addTask(item, this.mediaItem, index + 1)
                }
              })
            })
        }

        GridCol() {
          Button('查看我的缓存')
            .width('100%')
            .height(40)
            .width(156)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.goDownloadPage?.()
              this.exitDownloadShow?.()
            })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F2')
    .padding({
      top: 20,
      bottom: 32,
      left: 16,
      right: 16
    })
  }
}