import { getVideoList, MyConfig, VideoItem, VideoParams } from 'commons';
import { JSON } from '@kit.ArkTS';

@Component
export default struct ExcitingVideos {
  @Consume('pageStack') pageStack: NavPathStack
  @State list: VideoItem[] = []
  @State currentIndex: number = 0
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageLink('videoArticleList') videoArticleList: VideoItem[] = []

  aboutToAppear(): void {
    this.list = this.videoArticleList
    this.getData()
  }

  getData() {
    getVideoList().then((res) => {
      if (res.data) {
        res.data = res.data.sort((a, b) => {
          return a.order - b.order
        })
        let list: VideoItem[] = []
        res.data.forEach((itemData) => {
          list.push(new VideoItem(itemData))
        })
        this.list = list
        this.videoArticleList = this.list
      }
    })
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Bottom }) {
          Swiper() {
            ForEach(this.list, (item: VideoItem, index?: number) => {
              Column() {
                Column() {
                  Column() {
                    Stack() {
                      Image(MyConfig.URL + item.coverImageRealPath)
                        .width('100%')
                        .height('100%')
                        .borderRadius(19)
                      Column() {
                        Image(MyConfig.URL+ 'home2%2Ficon_play.png?token=2fa41e49-ed83-4470-bd07-81e2db9f6e76')
                          .width(46).onClick(() => {
                          this.pageStack.pushPath({
                            name: 'MyVideoPlayer',
                            param: new VideoParams(item.summary, item.coverImageRealPath)
                          })
                        })
                      }
                      .width('100%')
                      .height('100%')
                      .backgroundColor('#1a000000')
                      .borderRadius(19)
                      .justifyContent(FlexAlign.Center)
                    }
                    .margin({
                      top: 14
                    })
                    .height(166)
                    .width('100%')

                    Stack({ alignContent: Alignment.Bottom }) {
                      Column() {
                        Text(item.title)
                          .width('100%')
                          .fontSize(14)
                          .fontColor('#000000')
                          .lineHeight(20)
                          .height(40)
                          .maxLines(2)
                          .textOverflow({
                            overflow: TextOverflow.Ellipsis
                          })
                          .textAlign(TextAlign.Center)
                      }.padding({
                        bottom: 17
                      })

                      if (this.currentIndex === index) {
                        Row() {
                          Column().width(70).height(4).backgroundColor('#F2403D').borderRadius(2)
                        }.margin({
                          bottom: 6
                        })
                      }
                    }
                    .padding({
                      top: 12
                    })

                  }
                  .padding({ left: 14, right: 14 })
                  .shadow({
                    radius: vp2px(15),
                    color: '#0a000000',
                    offsetX: 0,
                    offsetY: vp2px(4)
                  })
                  .borderRadius(20)
                }.padding({
                  top: 12,
                  bottom: 16
                }).height(270)
              }.margin({
                left: this.currentBreakpoint === 'sm' ? 0 : 2,
                right: this.currentBreakpoint === 'sm' ? 0 : 2
              })
              .padding({
                bottom: 17
              }).width(this.currentBreakpoint === 'sm' ? '100%' : 178)
            }, (item: VideoItem) => JSON.stringify(item))
          }
          .onChange((index: number) => {
            this.currentIndex = index
          })
          .width('100%')
          .indicator(this.list.length > 1 ? new DotIndicator()
            .bottom(0)
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(12)
            .selectedItemHeight(6)
            .color($r('sys.color.comp_background_secondary'))
            .selectedColor($r('sys.color.comp_background_emphasize')) : false)
          .prevMargin(this.currentBreakpoint === 'sm' ? 79 : 0)
          .nextMargin(this.currentBreakpoint === 'sm' ? 79 : 0)
          .displayCount(this.currentBreakpoint === 'sm' ? 1 : 3)
          .itemSpace(12)
          .loop(true)
          .cachedCount(10)
        }
        .width('100%')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
  }
}