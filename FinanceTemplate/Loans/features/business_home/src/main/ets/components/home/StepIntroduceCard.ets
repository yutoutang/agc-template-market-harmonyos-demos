import { BreakpointNameEnum, BreakpointValueEnum, CommonConstants } from 'lib_common';
import { VerifyVM } from '../../viewmodels/VerifyVM';


@ComponentV2
export struct StepIntroduceCard {
  @Local stepIntroduceVM: VerifyVM = new VerifyVM();

  build() {
    Column({ space: CommonConstants.SPACE_L }) {
      this.topHeadBuilder()
      Grid() {
        GridItem() {
          this.stepItemBuilder($r('app.media.step_1'), '身份认证', '上传身份证正反面，完成实名认证',
            $r('app.media.card_reference'))
        }

        GridItem() {
          this.stepItemBuilder($r('app.media.step_2'), '人脸验证', '完成人脸验证，确保账户安全且由本人申请',
            $r('app.media.faceIcon'))
        }

        GridItem() {
          this.stepItemBuilder($r('app.media.step_3'), '资料填写', '填写个人与贷款信息，全程加密保护隐私',
            $r('app.media.loan_icon'), false)
        }
      }
      .columnsTemplate('1fr')
      .columnsGap(16)
      .rowsGap(16)
      .padding(10)

      Text('资料提交后，系统快速审核，通过后极速放款到账')
        .width('100%')
        .textAlign(this.stepIntroduceVM.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? TextAlign.Start :
        TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize(14)
        .lineHeight(16)
        .fontColor('rgba(0, 0, 0, 0.60)')
    }
    .width('100%')
    .padding({
      left: this.stepIntroduceVM.breakPointModel.currentBreakpoint === BreakpointNameEnum.MD ?
      CommonConstants.PADDING_XXL : CommonConstants.PADDING_M,
      right: this.stepIntroduceVM.breakPointModel.currentBreakpoint === BreakpointNameEnum.MD ?
      CommonConstants.PADDING_XXL : CommonConstants.PADDING_M,
      top: CommonConstants.PADDING_L,
      bottom: CommonConstants.PADDING_M
    })
    .backgroundColor('#FFFFFF')
    .borderRadius(CommonConstants.PADDING_S)

  }

  @Builder
  topHeadBuilder() {
    Row({ space: CommonConstants.SPACE_S }) {
      Image($r('app.media.fly_left'))
        .width(10)
        .height(14)
      Text('3步获得大额资金')
        .fontSize(18)
        .lineHeight(19)
        .fontWeight(FontWeight.Bolder)
        .fontColor($r('sys.color.font_primary'))
      Image($r('app.media.fly_right'))
        .width(10)
        .height(14)
    }.width('100%')
    .padding({ left: CommonConstants.PADDING_XS, right: CommonConstants.PADDING_XS })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  stepItemBuilder(indexImg: ResourceStr, title: string, desc: string, iconReference: ResourceStr,
    isShowLine: boolean = true, isShowIndex: boolean = true) {
    Row({ space: CommonConstants.SPACE_S }) {
      Column() {
        Image(indexImg)
          .height(24)
          .width(24)

        Blank()
          .width(1)
          .margin({ top: 5, bottom: 5 })
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .visibility(isShowLine ? Visibility.Visible : Visibility.None)
          .height(this.stepIntroduceVM.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? '30%' : '60%')
      }.visibility(isShowIndex ? Visibility.Visible : Visibility.Hidden)

      Column({ space: CommonConstants.SPACE_S }) {
        if (isShowIndex) {
          Row() {
            Text(title)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .fontSize(16)
              .lineHeight(22)
          }.width('100%')
          .justifyContent(FlexAlign.Start)
        }
        Column({ space: CommonConstants.SPACE_S }) {
          Text(desc)
            .width('100%')
            .textAlign(TextAlign.Start)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(14)
            .lineHeight(16)
            .fontColor('#99000000')
          Image(iconReference)
            .width('100%')
            .objectFit(ImageFit.Contain)
            .backgroundColor(Color.White)
        }.width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)

    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
  }
}