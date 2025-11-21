import { jumpDetailPage } from '@agctemplate/detail'
import { getMedia, getString, NAV_PAGE_NAME } from '@agctemplate/resources'
import { DramaInfo } from '@agctemplate/server'
import { appRouter, Logger, WindowManager } from '@agctemplate/utils'
import { PlayController, PlaySession } from 'video_swiper'
import { emitter } from '@kit.BasicServicesKit'

const TAG = '[DramaDesLayer]'

@ComponentV2
export struct DramaDesLayer {

  @Consumer('navStack') navPathStack: NavPathStack = new NavPathStack();
  @Param @Once @Require dramaInfo: DramaInfo
  @Param @Require playControl: PlayController
  @Param @Require playerSession: PlaySession
  @Local maxLine: number = 2
  @Local retractLength: number = 30
  @Local isSpread: boolean = false
  @Event onJump:Function

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if(this.isSpread) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
      }

      Row() {
        Column() {
          Row() {
            Text(this.dramaInfo.name)
              .height(21)
              .fontSize(16)
              .fontWeight(500)
              .fontColor('#fff')
            Column() {
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(21)
                .fontColor([$r('sys.color.white')])
            }
            .width(21)
            .height(21)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height(21)
          .onClick(() => {
            WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
            this.playControl.pause()
            appRouter.push({
              builderName: NAV_PAGE_NAME.DramaDetailInfoPage.name, params: {
                dramaInfo: this.dramaInfo,
                currentIndex: 0,
                changeIndex: (index: number) => {
                  this.onJump?.()
                }
              }
            })
          })

          Stack({ alignContent: Alignment.BottomEnd }) {
            Text(getString('app.string.drama_desc', this.dramaInfo.totalCount.toString(),
              (this.isSpread ? this.dramaInfo.description :
                (this.dramaInfo.description.slice(0, this.retractLength) + '...'))))
              .width('100%')
              .fontColor($r('sys.color.font_on_secondary'))
              .fontSize(12)
              .lineHeight(16)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(this.maxLine)
              .textAlign(TextAlign.Start)
              .margin({ bottom: this.isSpread ? 20 : 0 })
              .onAreaChange((oldVal, newVal) => {
                let nowWidth: number = parseInt(newVal.width.toString())
                this.retractLength = Math.floor(nowWidth / 12) * 2 - 8
              })

            Row() {
              Text(this.isSpread ? '收起' : '展开')
                .width(24)
                .lineHeight(16)
                .fontSize(12)
                .fontWeight(500)
                .fontColor('#fff')
              Column() {
                SymbolGlyph($r('sys.symbol.chevron_down'))
                  .fontSize(16)
                  .fontColor([$r('sys.color.white')])
                  .rotate({ angle: this.isSpread ? 180 : 0})
              }
              .width(16)
              .height(16)
              .justifyContent(FlexAlign.Center)
            }
            .width(40)
            .height(16)
            .onClick(() => {
              this.isSpread = !this.isSpread
              this.maxLine = this.maxLine === -1 ? 2 : -1
            })
          }
          .width('100%')
          .margin({ top: 2 })
        }
        .layoutWeight(1)
        .margin({
          left: 16,
          bottom: 12,
          right: 12,
          top: 13
        })

        Button(getString('app.string.watch_full_drama'))
          .onClick(() => {
            Logger.debug(TAG, `currentPlayTime:${this.playerSession.avPlayer?.currentTime}`)
            // 进入详情页，接续播放
            this.onJump?.()
          })
          .height(28)
          .fontSize(14)
          .fontColor('#fff')
          .backgroundColor('#EC6E45')
          .borderRadius(14)
          .margin({ bottom: 12, right: 16 })
          .id('watchFullDrama')
          .zIndex(4)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
  }
}