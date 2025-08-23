import { promptAction } from '@kit.ArkUI'
import { LineInfo } from '../models'

enum INDEX {
  START = 0,
  END
}

@ComponentV2
export struct RouteSearch {
  @Local startText: string = '' // 起点
  @Local endText: string = '' //终点
  @Param defaultStartText: string = ''

  @Monitor('defaultStartText')
  startTextChange() {
    this.startText = this.defaultStartText
  }

  @Param defaultEndText: string = ''

  @Monitor('defaultEndText')
  endTextChange() {
    this.endText = this.defaultEndText
  }

  @Param lineInfo: LineInfo[] = []

  @Monitor('lineInfo')
  lineInfoChange() {
    if (!this.lineInfo.length && this.startText.length && this.endText.length) {
      promptAction.showToast({
        message: '暂未查询到线路',
        duration: 1500,
        bottom: 80,
      })
    }
  }

  // 点击输入框触发
  @Event clickInput: (index: number)  => void = ()=>{}
  // 点击推荐卡片触发
  @Event clickListItem: (item: LineInfo) => void = ()=>{}
  // 监听输入变化
  @Event onInputChange:  (value: string, index: number) => void = ()=>{}

  @Builder
  buildSearchItem() {
    Row() {
      Image($r('app.media.greenline'))
        .height(20)
        .width(2)
        .margin({ left: '5%', right: 9 })
      Text('推荐路线')
        .fontSize(16)
        .fontWeight(400)
    }
    .width('100%')
    .margin({ top: 16, bottom: 8 })

    // 推荐结果卡片列表
    List({ space: '8vp' }) {
      ForEach(this.lineInfo, (item: LineInfo) => {
        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_buslogo'))
                .height('25vp')
                .width('25vp')
                .margin({ left: '12vp', right: '11vp' })
              Flex({ direction: FlexDirection.Column }) {
                Text(`${item.lineName}${item.direction}(${item.startStation}-${item.endStation})`)
                  .fontSize(13)
                  .margin({ top: '19vp', bottom: '12vp' })
                  .textAlign(TextAlign.Start)

                Text() {
                  Span('距你') //以下全为随机数
                  Span(item.distance).fontColor('#62B42E')
                  Span('千米').fontColor('#62B42E')
                  Span('|').fontColor('#62B42E')
                  Span('预计')
                  Span(item.countDown).fontColor('#62B42E')
                  Span('分钟').fontColor('#62B42E')
                }
                .fontSize(13)
                .textAlign(TextAlign.Start)
              }
            }

            Image($r('app.media.ic_public_right_arrow'))
              .height('16vp')
              .width('16vp')
              .margin({ right: '6vp' })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .height('74vp')
          .width('90%')
          .backgroundColor($r('app.color.background_color_white'))
          .margin({ left: '5%', right: '12vp' })
          .borderRadius(12)
          .onClick(() => {
            this.clickListItem(item)
          })
        }
      }, (item: LineInfo) => item.lineName + new Date().toString())
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          Row() {
            Image($r('app.media.circle_start'))
              .height(12)
              .width(12)
            TextInput({ text: $$this.startText, placeholder: '我的位置' })
              .caretColor($r('app.color.system_color_green'))
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .margin({ left: '8vp' })
              .onClick(() => {
                this.clickInput(INDEX.START)
              })
              .onChange((value: string) => {
                this.onInputChange(value, INDEX.START)
              })
          }

          Image($r('app.media.dashedline'))
            .height('12vp')
            .width('1vp')
            .margin({ left: '6vp' })

          Row() {
            Image($r('app.media.circle_end'))
              .height(12)
              .width(12)
            TextInput({ text: $$this.endText, placeholder: '输入终点' })
              .caretColor($r('app.color.system_color_green'))
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .margin({ left: '8vp' })
              .onClick(() => {
                this.clickInput(INDEX.END)
              })
              .onChange((value: string) => {
                this.onInputChange(value, INDEX.END)
              })
          }
        }
        .width('240vp')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)

        Image($r('app.media.change_dir'))
          .height('32vp')
          .width('32vp')
          .onClick(() => {
            let temp = this.startText
            this.startText = this.endText
            this.endText = temp
          })
      }
      .height('116vp')
      .width('90%')
      .borderRadius(16)
      .padding({ top: '14vp', left: '20vp', bottom: '14vp' })
      .backgroundColor($r('sys.color.comp_background_list_card'))

      // 卡片列表
      if (this.lineInfo.length) {
        this.buildSearchItem()
      }
    }
    .width('100%')
    .height('100%')
  }
}