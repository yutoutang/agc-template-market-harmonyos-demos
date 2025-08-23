import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources'
import { DramaInfo } from '@agctemplate/server'
import { appRouter, WindowManager } from '@agctemplate/utils'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'

@ComponentV2
export struct BannerPanel {
  @Param @Require bannerList: Array<DramaCoverVM>
  @Param @Require inPage: string
  @Local curIndex: number = 0
  @Local scrolling: boolean = false

  build() {
    Column() {
      Row() {
        Swiper() {
          ForEach(this.bannerList, (banner: DramaCoverVM) => {
            Row() {
              Stack() {
                Image(banner.imagePath)
                  .height(138)
                  .width(104)
                  .borderRadius(8)
                if (this.inPage === 'new') {
                  Image(getMedia('app.media.new'))
                    .width(28)
                    .height(16)
                    .position({ left: 76 })
                } else if (this.inPage === 'vip') {
                  Image(getMedia('app.media.vip'))
                    .width(28)
                    .height(16)
                    .position({ left: 76 })
                }
              }

              Column() {
                Text(banner.title)
                  .width('100%')
                  .height(19)
                  .fontWeight(500)
                  .fontColor('#e6000000')
                  .margin({ bottom: 8 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Row() {
                  ForEach(banner.tags, (tag: string) => {
                    Text(tag)
                      .width(28)
                      .height(16)
                      .backgroundColor('#0d000000')
                      .fontSize(10)
                      .fontWeight(400)
                      .fontColor('#e6000000')
                      .textAlign(TextAlign.Center)
                      .margin({ right: 8 })
                      .borderRadius(4)
                  }, (tag: string) => tag)
                }

                Text(banner.description)
                  .fontColor($r('sys.color.mask_secondary'))
                  .font({ weight: 400, size: 14 })
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 8 })
              }
              .width(200)
              .height(99)
              .margin({ left: 12, top: 19.5, right: 12, bottom: 19.5 })
              .alignItems(HorizontalAlign.Start)
            }
            .onClick(() => {
              onDramaClick(banner,
                () => {
                  WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                })
            })
          }, (banner: DramaCoverVM, index: number) => banner.dramaId + index)
        }
        .width('100%')
        .height('100%')
        .borderRadius(8)
        .loop(true)
        .autoPlay(true)
        .indicator(false)
        .onAnimationStart((_, targetIndex: number) => {
          if (!this.scrolling) {
            this.curIndex = targetIndex;
          }
        })
        .onGestureSwipe(() => {
          this.scrolling = true
        })
        .onChange((index: number) => {
          this.curIndex = index
          this.scrolling = false
        })
      }
      .borderRadius(8)
      .width('100%')
      .height(138)
      .backgroundColor('#fff')

      Row() {
        ForEach(this.bannerList, (_: string, index: number) => {
          Column()
            .width(this.curIndex === index ? 15 : 5)
            .height(5)
            .borderRadius(5)
            .margin(5)
            .backgroundColor(this.curIndex === index ?
            $r('sys.color.alert') : $r('sys.color.comp_background_secondary'))
        }, (item: string) => item)
      }
      .height(32)
    }
  }
}


export function onDramaClick(option: DramaCoverVM, callback?: (popInfo: PopInfo) => void) {
  appRouter.push({
    builderName: NAV_PAGE_NAME.ShortDramaDetailPage.name,
    params: {
      dramaInfo: new DramaInfo({ id: option.dramaId })
    }, popCallback: callback
  })
}