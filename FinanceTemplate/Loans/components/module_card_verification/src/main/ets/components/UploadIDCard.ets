import { promptAction } from '@kit.ArkUI';
import { IDCardInfo, CardQualityEnum } from '../models/IDCardInfoType';
import { CameraVerifyDialog } from './CameraVerifyDialog';

@ComponentV2
export struct uploadIDCard {
  @Local imgFront: ResourceStr = ''
  @Local imgBack: ResourceStr = ''
  @Local myIdCardInfo: IDCardInfo | undefined = undefined
  @Local isFront: boolean = true
  @Local isShowUpAgain: boolean = false
  @Event callBackCardInfo: (info: IDCardInfo) => void
  controller: CustomDialogController = new CustomDialogController({
    builder: CameraVerifyDialog({
      isFront: this.isFront,
      onBackCode: (cardInfo: IDCardInfo) => {
        this.onBackCode(cardInfo)
      },
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom,
  });

  checkCardQuality(cardInfo: IDCardInfo, name: string, func: () => void) {
    if (cardInfo?.reflectionProbability) {
      if (parseFloat(cardInfo.reflectionProbability) >= CardQualityEnum.reflectionRate) {
        promptAction.showToast({ message: name + '拍摄闪光亮点过大，请重新上传', duration: 2000 })
        func()
        return
      }
    }
    if (cardInfo?.clarityProbability) {
      if (parseFloat(cardInfo.clarityProbability) <= CardQualityEnum.clarityRate) {
        promptAction.showToast({ message: name + '照片不清晰，请重新上传', duration: 2000 })
        func()
        return
      }
    }
    if (cardInfo?.occlusionProbability) {
      if (parseFloat(cardInfo.occlusionProbability) >= CardQualityEnum.occlusionRate) {
        promptAction.showToast({ message: name + '照片有遮挡，请重新上传', duration: 2000 })
        func()
        return
      }
    }
    if (cardInfo?.completenessProbability) {
      if (parseFloat(cardInfo.completenessProbability) <= CardQualityEnum.completenessRate) {
        promptAction.showToast({ message: name + '拍摄不完整，请重新上传', duration: 2000 })
        func()
        return
      }
    }
  }

  getFrontCardInfo(cardInfo: IDCardInfo) {
    let info: IDCardInfo = new IDCardInfo(
      cardInfo?.name ?? '',
      cardInfo?.sex ?? '',
      cardInfo?.nationality ?? '',
      cardInfo?.address ?? '',
      cardInfo?.birth ?? '',
      cardInfo?.idNumber ?? '',
      cardInfo?.cardImageUri ?? '',
      cardInfo?.originalImageUri ?? '',
      cardInfo?.cardImageUri ?? '', //正面识别到的卡片照片-非原照片（原照片元素较杂）
      this.myIdCardInfo?.backImageUri ?? '', //背面识别到的卡片照片-非原照片（原照片元素较杂）-这里先不赋值
      this.myIdCardInfo?.authority ?? '',
      this.myIdCardInfo?.validPeriod ?? '',
    )
    return info
  }

  onBackCode(cardInfo: IDCardInfo) {
    if (this.isFront) {
      this.imgFront = cardInfo?.cardImageUri ?? ''
      this.myIdCardInfo = this.getFrontCardInfo(cardInfo)
      this.checkCardQuality(cardInfo, '卡证人像面', () => {
        this.imgFront = ''
      })
    } else {
      this.imgBack = cardInfo?.cardImageUri ?? ''
      this.myIdCardInfo = this.getBackCardInfo(cardInfo)
      this.checkCardQuality(cardInfo, '卡证国徽面', () => {
        this.imgBack = ''
      })
    }
    this.callBackCardInfo(this.myIdCardInfo)
  }

  getBackCardInfo(cardInfo: IDCardInfo) {

    let info: IDCardInfo = new IDCardInfo(
      this.myIdCardInfo?.name ?? '',
      this.myIdCardInfo?.sex ?? '',
      this.myIdCardInfo?.nationality ?? '',
      this.myIdCardInfo?.address ?? '',
      this.myIdCardInfo?.birth ?? '',
      this.myIdCardInfo?.idNumber ?? '',
      this.myIdCardInfo?.cardImageUri ?? '',
      this.myIdCardInfo?.originalImageUri ?? '',
      this.myIdCardInfo?.frontImageUri ?? '', //正面识别到的卡片照片-非原照片（原照片元素较杂）
      cardInfo.cardImageUri ?? '', //背面识别到的卡片照片-非原照片（原照片元素较杂）
      cardInfo?.authority ?? '',
      cardInfo?.validPeriod ?? '',
    )
    return info
  }

  build() {
    Column({ space: 15 }) {
      Text('请上传本人身份证的正反面照片')
        .fontWeight(FontWeight.Bold)
        .fontSize(18)
        .lineHeight(21)
        .fontColor('rgba(0, 0, 0, 0.90)')
        .width('100%')
        .textAlign(TextAlign.Start)
      this.TopUploadBuilder()
    }.width('100%')
  }

  @Builder
  MenuBuilder() {
    Column() {
      Menu() {
        MenuItemGroup() {
          MenuItem({ startIcon: $r('app.media.camera_again_icon'), content: '重新上传证件', labelInfo: '' })
            .onClick(() => {
              this.controller.open()
              this.isShowUpAgain = false
            })
        }
      }
    }
  }

  @Builder
  TopUploadBuilder() {
    Column({ space: 16 }) {
      Column() {
        if (this.imgFront) {
          Image(this.imgFront)
            .height('100%')
            .aspectRatio(1.58 / 1)
            .objectFit(ImageFit.Contain)
        } else {
          Stack() {
            Image($r('app.media.front_card_icon'))
              .aspectRatio(1.58 / 1)
              .height(150)
              .objectFit(ImageFit.Contain)
            Column({ space: 16 }) {
              Image($r('app.media.camare_icon'))
                .height(40)
                .aspectRatio(1)
                .objectFit(ImageFit.Contain)
              Text('上传身份证人像面')
                .fontColor('rgba(0, 0, 0, 0.90)')
                .fontSize(12)
                .lineHeight(14)
            }
          }
        }
      }
      .aspectRatio(1.58 / 1)
      .height(150)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .bindContextMenu(!!this.isShowUpAgain, this.MenuBuilder, {
        onDisappear: () => {
          this.isShowUpAgain = false
        }
      })
      .onClick(() => {
        this.isFront = true
        if (this.imgFront !== '') {
          this.isShowUpAgain = true
          return
        }
        this.controller.open()
      })

      Column() {
        if (this.imgBack) {
          Image(this.imgBack)
            .height('100%')
            .aspectRatio(1.58 / 1)
            .objectFit(ImageFit.Contain)
        } else {
          Stack() {
            Image($r('app.media.back_card_icon'))
              .aspectRatio(1.58 / 1)
              .height(150)
              .objectFit(ImageFit.Contain)

            Column({ space: 16 }) {
              Image($r('app.media.camare_icon'))
                .height(40)
                .aspectRatio(1)
                .objectFit(ImageFit.Contain)

              Text('上传身份证国徽面')
                .fontColor('rgba(0, 0, 0, 0.90)')
                .fontSize(12)
                .lineHeight(14)
            }
          }
        }

      }
      .aspectRatio(1.58 / 1)
      .height(150)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.isFront = false
        if (this.imgBack !== '') {
          this.isShowUpAgain = true
          return
        }
        this.controller.open()
      })

      this.BottomBuilder()
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .padding({
      left: 12,
      right: 12,
      bottom: 16,
      top: 16
    })
  }

  @Builder
  BottomBuilder() {
    Column({ space: 15 }) {

      Text('拍摄照片要求')
        .padding({ left: 10, right: 10, top: 16 })
        .width('100%')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .fontSize(14)
        .lineHeight(20)
        .fontColor('rgba(0, 0, 0, 0.90)')

      Row() {
        this.ImgStandardBuilder($r('app.media.right_card'), '标准拍照', true)
        this.ImgStandardBuilder($r('app.media.wrong_card_not_all'), '边框缺失', false)
        this.ImgStandardBuilder($r('app.media.wrong_card_not_clear'), '照片模糊', false)
        this.ImgStandardBuilder($r('app.media.wrong_card_high_light'), '闪光强烈', false)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
  }

  @Builder
  ImgStandardBuilder(card: ResourceStr, text: string, isRight: boolean) {
    Column({ space: 15 }) {
      Image(card)
        .width('100%')
        .aspectRatio(4 / 3)
      Row({ space: 5 }) {

        Text(text)
          .fontColor(isRight ? '' : 'rgba(0,0,0,0.5)')
          .fontSize(12)
      }
    }.width('20%')
  }
}