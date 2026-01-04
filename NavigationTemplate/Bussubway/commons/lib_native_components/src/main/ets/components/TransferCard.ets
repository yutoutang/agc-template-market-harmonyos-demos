import { TransferStep } from '../type/CardTypes'

// 换乘方案卡片
@ComponentV2
export struct TransferCard {
  @Param totalTimeText: string = ''
  @Param distanceText: string = ''
  @Param summaryText: string = ''
  @Param summaryText2: string = ''
  @Param steps: TransferStep[] = []
  @Param @Require onCardClick?: () => void

  @Builder
  RenderStepSeparator(index: number, total: number) {
    if (index < total - 1) {
      Text(' → ').margin({ left: 4, right: 4 })
    }
  }

  build() {
    Column() {
      // 顶部：总时长 与 距离
      Row() {
        Text(this.totalTimeText)
          .fontWeight(FontWeight.Bold)
        Row() {
          Image($r('app.media.buhang')).width(15).height(15).margin({ right: 5 })
          Text(this.distanceText)
            .fontColor('#666666')

        }.margin({ left: 10 })
      }
      .width('100%')

      // 中部：步行/公交/地铁 步骤
      Row() {
        ForEach(this.steps, (step: TransferStep, index: number) => {
          if (step.type === 'walk') {
            Row() {
              Image($r('app.media.buhang')).width(15).height(15).margin({ right: 4 })
              Text(step.text)
            }.backgroundColor('#f3f3f3')
          } else if (step.type === 'metro') {
            Text(step.badge && step.badge.length > 0 ? step.badge : step.text)
              .fontColor(Color.Black)
              .backgroundColor('#fad600')
              .padding({
                left: 10,
                right: 10,
                top: 3,
                bottom: 3
              })
              .borderRadius(8)
          } else { // bus 或其它
            Text(step.text)
              .border({ width: 1, color: '#6ab368' })
              .borderRadius(7)
              .padding({ right: 3, top: 1, bottom: 1 })
              .fontColor('#5bc159')
          }
          this.RenderStepSeparator(index, this.steps.length)
        }, (v: TransferStep) => v.text)
      }
      .width('100%')
      .margin({ top: 8, bottom: 6 })

      Row() {
        Text(this.summaryText)
          .fontColor('#333333')
        Text('|').margin({ left: 3, right: 3 })
        Text(this.summaryText2)
          .fontColor('#333333')
          .margin({ right: 5 })
        Text('上车')
      }
      .width('100%')
    }
    .height(130)
    .borderRadius(20)
    .width('100%')
    .backgroundColor(Color.White)
    .border({ width: 1, color: '#E5E5E5' })
    .borderRadius(6)
    .margin({ bottom: 15 })
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 12,
      right: 12,
      top: 10,
      bottom: 10
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick()
      }
    })
  }
}