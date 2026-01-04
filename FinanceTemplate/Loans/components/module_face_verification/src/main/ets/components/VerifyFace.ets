import { interactiveLiveness } from '@kit.VisionKit';
import { VerifyFaceVM } from '../viewmodels/VerifyFaceVM';


@ComponentV2
export struct VerifyFace {
  @Local verifyFaceVM: VerifyFaceVM = new VerifyFaceVM()
  @Param userRealName: string = '***'
  @Event VerifyFaceCallBack: (result: interactiveLiveness.InteractiveLivenessResult, isFaceSuccess: boolean) => void =
    (result: interactiveLiveness.InteractiveLivenessResult, isFaceSuccess: boolean) => {
    }
  @Event CancelCallBack: () => void = () => {
  }

  build() {
    if (!this.verifyFaceVM.isFaceVerifyDone) {
      Column() {
        this.PrepareT0VerifyBuilder()

        Column() {
          Text('提示:请在光线充足的环境下操作，确保面部无遮挡')
            .fontSize(12)
            .lineHeight(17)
            .fontColor('#99000000')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 4 })
          this.BottomBuilder()
        }.width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ left: 10, right: 10 })
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    } else {
      if (this.verifyFaceVM.isFaceVerifySuccess) {
        this.FaceSuccessBuilder()
      } else {
        Column() {
          this.FaceFalseBuilder()
        }
        .width('100%')
        .padding({ left: 10, right: 10 })
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
  }

  @Builder
  FaceFalseBuilder() {
    Column({ space: 25 }) {
      Image($r('app.media.face_false'))
        .height(56)
        .width(56);
      Text('验证失败')
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(24)
        .textAlign(TextAlign.Center)
        .margin({ top: 10 })
        .fontWeight(FontWeight.Bold);
    }
    .height('30%')
    .justifyContent(FlexAlign.Center)

    Text('重新检测')
      .backgroundColor('#317AF7')
      .fontColor(Color.White)
      .fontSize(16)
      .lineHeight(19)
      .width('100%')
      .height(40)
      .padding({ top: 10, bottom: 10 })
      .textAlign(TextAlign.Center)
      .borderRadius(20)
      .onClick(() => {
        this.verifyFaceVM.isFaceVerifyDone = false;
        this.verifyFaceVM.startToFaceVerify(this.getUIContext(),
          (result: interactiveLiveness.InteractiveLivenessResult, isFaceSuccess: boolean) => {
            this.VerifyFaceCallBack(result, isFaceSuccess)
          })
      })
  }

  @Builder
  FaceSuccessBuilder() {
    Column() {
      Image($r('app.media.face_sucess'))
        .height(56)
        .width(56);
      Text('验证成功')
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(24)
        .textAlign(TextAlign.Center)
        .margin({ top: 10 })
        .fontWeight(FontWeight.Bold);
    }
    .height('30%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  PrepareT0VerifyBuilder() {
    Column({ space: 10 }) {
      Column() {
        Image($r('app.media.face_icon'))
          .height(56)
          .width(56)
      }.height('30%')
      .justifyContent(FlexAlign.Center)

      Column({ space: 8 }) {
        Text() {
          Span('请确保是')
            .fontColor($r('sys.color.font_primary'))
          Span('**' + this.userRealName.slice(-1))
            .fontColor('#FF317AF7')
          Span('本人操作')
            .fontColor($r('sys.color.font_primary'))
        }
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .fontSize(20)
        .lineHeight(24)

        Text('为保障您的账户安全，我们将通过摄像头采集人脸信息，仅用于实名认证和贷款申请验证，不会另作他用')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .fontSize(13)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(15)
      }

    }
    .width('100%')

    .alignItems(HorizontalAlign.Center)

  }

  @Builder
  BottomBuilder() {
    Column() {
      Text('同意并开始')
        .backgroundColor('#317AF7')
        .fontColor(Color.White)
        .fontSize(16)
        .lineHeight(19)
        .width('100%')
        .height(40)
        .padding({ top: 10, bottom: 10 })
        .textAlign(TextAlign.Center)
        .borderRadius(20)
        .onClick(() => {
          this.verifyFaceVM.startToFaceVerify(this.getUIContext(),
            (result: interactiveLiveness.InteractiveLivenessResult, isFaceSuccess: boolean) => {
              this.VerifyFaceCallBack(result, isFaceSuccess)
            })
        })
      Text('取消')
        .fontWeight(FontWeight.Bold)
        .fontSize(16)
        .lineHeight(22)
        .width('80%')
        .textAlign(TextAlign.Center)
        .fontColor('#317AF7')
        .onClick(() => {
          this.CancelCallBack()
        })
    }
  }
}
