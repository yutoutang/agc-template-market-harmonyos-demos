import { interactiveLiveness } from '@kit.VisionKit';
import { CommonConfirmDialog, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { StepCard } from '../components/home/StepCard';
import { VerifyVM } from '../viewmodels/VerifyVM';
import { IDCardInfo, VerifyCard } from 'module_card_verification';
import { VerifyFace } from 'module_face_verification';
import { LoanForm, LoanFormVM } from 'module_loan_form';
import { UnderReviewCard } from '../components/home/UnderReviewCard';
import { LoanProduct } from 'lib_loan_api';

@Builder
export function VerifyPageBuilder() {
  VerifyPage()
}

@ComponentV2
export struct VerifyPage {
  @Local currentStepIndex: number = 0;
  @Local myIdCardInfo: IDCardInfo | undefined = undefined
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local verifyVM: VerifyVM = new VerifyVM();

  aboutToAppear() {
    let param: Record<string, Object> = RouterUtils.getParamByName(RouterMap.VERIFY_PAGE) as Record<string, Object>;

    if (param.rate) {
      this.verifyVM.fixedAnnualRate =
        (RouterUtils.getParamByName(RouterMap.VERIFY_PAGE) as Record<string, number>).rate
    }
    if (param.repayment) {
      let tempParma: LoanProduct = param.repayment as LoanProduct
      this.verifyVM.fixedAnnualRate = tempParma.annualInterestRate
      // 审核中 0 和 审核未通过 2 跳转到额度申请页面
      if (tempParma.loanStatus === 0) {
        this.currentStepIndex = 2
        this.verifyVM.isDoneStep = true
      } else if (tempParma.loanStatus === 2) {
        this.currentStepIndex = 0
      }
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          this.titleBuilder()

          this.contentBuilder()

          this.buttonBuilder()
        }
        .padding({ left: 16, right: 16 })
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .hideTitleBar(true)
    .height('100%')
    .padding({ bottom: this.windowModel.windowBottomPadding })
    .backgroundColor('#F1F3F5')
    .onBackPressed(() => {
      if (!this.verifyVM.isDoneStep) {
        this.verifyVM.BackConfirm()
        return true
      } else {
        return false
      }

    })
  }

  @Builder
  titleBuilder() {
    NavHeaderBar({
      title: '额度申请',
      showBackBtn: true,
      needNoPadding: true,
      onBack: () => {
        if (!this.verifyVM.isDoneStep) {
          this.verifyVM.BackConfirm()
        } else {
          RouterUtils.pop()
        }
      }
    })
  }

  @Builder
  contentBuilder() {
    if (this.verifyVM.isDoneStep) {
      UnderReviewCard()
    } else {
      StepCard({ currentStepIndex: this.currentStepIndex })
      if (this.currentStepIndex === 0) {
        VerifyCard({
          verifyCallBack: (info: IDCardInfo) => {
            this.verifyCall(info)
          }
        })
      }
      if (this.currentStepIndex === 1) {
        VerifyFace({
          userRealName: this.verifyVM.cardPersonName ?? '',
          CancelCallBack: () => {
            this.dialogShow()
          },
          VerifyFaceCallBack: (result: interactiveLiveness.InteractiveLivenessResult, isFaceSuccess: boolean) => {
            //拿到检测成功的活体检测结果相关数据 result 做业务处理  result.livenessType 为0表示这次检测主体为活体 mPixelMap为人脸图片
            if (result.livenessType === 0) {
              //人脸检测通过-进入下一步的资料填写
              this.verifyVM.isFaceDone = true
            }
          }
        })
      }
      if (this.currentStepIndex === 2) {
        Column() {
          LoanForm({
            idCardName: this.verifyVM.cardPersonName ?? '',
            idCardNumber: this.verifyVM.cardPersonId ?? '',
            maxLoanAmount: this.verifyVM.maxLoanAmount,
            LoanFormCallBack: (loanFormVMData: LoanFormVM) => {
              if (loanFormVMData && loanFormVMData.userRealName !== '') {
                this.verifyVM.isDoneStep = true
                this.verifyVM.addLoadRecord(loanFormVMData, this.verifyVM.fixedAnnualRate)
              }
            }
          })
        }
        .layoutWeight(1)
      }
    }
  }

  @Builder
  buttonBuilder() {
    if (this.currentStepIndex === 0 || (this.currentStepIndex === 1 && this.verifyVM.isFaceDone)) {
      Blank()
        .layoutWeight(1)
    }

    if (this.currentStepIndex === 0 || (this.currentStepIndex === 1 && this.verifyVM.isFaceDone)) {
      Text('下一步')
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
          switch (this.currentStepIndex) {
            case 0:
              if (this.myIdCardInfo !== undefined) {
                this.verifyVM.VerifyNextFunc(this.myIdCardInfo, (isComplete: boolean) => {
                  if (isComplete) {
                    this.currentStepIndex = 1
                  }
                })
              } else {
                promptAction.showToast({ message: '请填完成身份证信息' })
              }
              break;
            case 1:
              if (this.verifyVM.isFaceDone) {
                this.currentStepIndex = 2
              }
              break;
            case 2:
              this.currentStepIndex = 3
          }
        })
    }
  }

  verifyCall(info: IDCardInfo) {
    this.myIdCardInfo = info
    this.verifyVM.VerifyNextFunc(this.myIdCardInfo, (isComplete: boolean) => {
      this.verifyVM.isIDCardDone = isComplete
      this.verifyVM.cardPersonName = info.name ?? ''
      this.verifyVM.cardPersonId = info.idNumber ?? ''
    })
  }

  dialogShow() {
    CommonConfirmDialog.show({
      primaryTitle: '是否返回首页？',
      content: '将不会保留您此次编辑的内容',
      secBtnV: '返回',
      priBtnFg: 'rgba(0, 0, 0, 0.60)',
      secBtnFg: '#FF317AF7',
      confirm: () => {
        RouterUtils.pop()
      },
    });
  }
}

