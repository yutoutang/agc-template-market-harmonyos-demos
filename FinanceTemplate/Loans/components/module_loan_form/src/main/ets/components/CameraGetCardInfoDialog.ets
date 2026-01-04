import { CallbackParam, CardRecognition, CardSide, CardType, ShootingMode } from '@kit.VisionKit'
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'CardRecognitionPage'

//卡证识别页

@CustomDialog
export struct CameraGetCardInfoDialog {
  controller?: CustomDialogController
  @State cardDataSource: Record<string, string>[] = []
  onBackCode: (value: string) => void = () => {
  }

  build() {

    NavDestination() {
      CardRecognition({
        // 此处选择身份证类型
        supportType: CardType.CARD_BANK,
        cardSide: CardSide.FRONT,
        cardRecognitionConfig: {
          defaultShootingMode: ShootingMode.AUTO,
          isPhotoSelectionSupported: false,
        },
        callback: ((params: CallbackParam) => {
          hilog.info(0x0001, TAG, `params code: ${params.code}`)
          if (params.code === -1) {
            this.controller?.close()
            return
          }
          hilog.info(0x0001, TAG, `params cardType: ${params.cardType}`)
          if (params.cardInfo?.front !== undefined) {
            this.cardDataSource.push(params.cardInfo?.front)
          }

          if (params.cardInfo?.back !== undefined) {
            this.cardDataSource.push(params.cardInfo?.back)
          }

          if (params.cardInfo?.main !== undefined) {
            this.cardDataSource.push(params.cardInfo?.main)
          }
          hilog.info(0x0001, TAG, `params cardInfo front: ${JSON.stringify(params.cardInfo)}`)
          hilog.info(0x0001, TAG, `params cardInfo back: ${JSON.stringify(params.cardInfo)}`)
          let bankNumber: string = ''
          bankNumber = params.cardInfo?.main?.bankNum ?? ''
          this.onBackCode(bankNumber)
          this.controller?.close()
        })
      })
    }
    .width('100%')
    .height('100%')
    .position({ left: 50, top: 200 })
    .width(300)
    .height(300)
    .mode(NavDestinationMode.DIALOG)
    .hideBackButton(true)
  }

  @Builder
  cardDataShowBuilder() {
    List() {
      ForEach(this.cardDataSource, (cardData: Record<string, string>) => {
        ListItem() {
          Column() {
            Image(cardData.cardImageUri)
              .objectFit(ImageFit.Contain)
              .width(100)
              .height(100)

            Text(JSON.stringify(cardData))
              .width('100%')
              .fontSize(12)
          }
        }
      }, (cardData: Record<string, string>) => JSON.stringify(cardData))
    }
    .listDirection(Axis.Vertical)
    .alignListItem(ListItemAlign.Center)
    .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
    .margin({
      top: 50
    })
    .width('100%')
    .height('100%')
  }
}