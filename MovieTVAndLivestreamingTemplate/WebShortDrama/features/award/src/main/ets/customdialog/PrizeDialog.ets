import PrizeData from '../model/PrizeData'
import StyleConstants from '../constants/StyleConstants'
import CommonConstants from '../constants/CommonConstants'
import { getColor, getString } from '@agctemplate/resources'

@CustomDialog
export default struct PrizeDialog {
  private controller?: CustomDialogController

  build() {
    Column() {
      PrizeComponent({
        controllerCallback: () => {
          this.controller?.close()
        }
      })
    }
  }
}

@ComponentV2
export struct PrizeComponent {
  @Consumer('prizeData') prizeData: PrizeData | null = null
  @Consumer('enableFlag') enableFlag: boolean = true
  @Event controllerCallback: () => void = () => {
  }

  build() {
    Column() {
      Image(this.prizeData!.imageSrc !== undefined ? this.prizeData!.imageSrc : '')
        .width(90)
        .height(90)
        .margin({
          top: 55,
          bottom: 48
        })
        .rotate({
          x: 0,
          y: 0,
          z: 1,
          angle: CommonConstants.TRANSFORM_ANGLE
        })

      Text(this.prizeData!.message)
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })

      Text(getString('app.string.confirm'))
        .fontColor(getColor('app.color.text_font_color'))
        .fontWeight(StyleConstants.FONT_WEIGHT)
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.controllerCallback()
          this.enableFlag = true
        })
    }
    .backgroundColor(getColor('app.color.dialog_background'))
    .width(StyleConstants.FULL_PERCENT)
    .height(277)
  }
}