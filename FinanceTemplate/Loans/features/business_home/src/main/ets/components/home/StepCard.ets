import { StepTypes } from 'module_card_verification';
import { VerifyVM } from '../../viewmodels/VerifyVM';

@ComponentV2
export struct StepCard {
  @Param currentStepIndex: number = 0;
  @Local verifyVM: VerifyVM = new VerifyVM();

  @Builder
  StepItemBuilder(step: StepTypes, itemIndex: number) {
    Row() {
      Column({ space: 10 }) {
        Image(itemIndex === this.currentStepIndex ? step.selectedIcon :
          itemIndex < this.currentStepIndex ? step.selectedStepIcon : step.stepIcon)
          .height(24)
          .width(24)
        Text(step.title)
          .fontColor(itemIndex === this.currentStepIndex ? $r('sys.color.font_primary') :
          $r('sys.color.font_secondary'))
          .fontWeight(itemIndex === this.currentStepIndex ? FontWeight.Medium : FontWeight.Normal)
          .fontSize(13)
      }
    }
  }

  build() {
    Row() {
      ForEach(this.verifyVM.stepList, (step: StepTypes, index: number) => {
        this.StepItemBuilder(step, index)
        if (index !== 2) {
          Blank()
            .height(2)
            .backgroundColor(index < this.currentStepIndex ? '#317af7' : Color.Gray)
            .layoutWeight(1)
        }
      },
        (step: StepTypes, index: number) => step.title + index.toString(),
      )
    }.width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ left: 16, right: 16 })
  }
}