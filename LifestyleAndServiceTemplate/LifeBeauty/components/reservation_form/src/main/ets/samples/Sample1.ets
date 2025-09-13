import { IFormData } from '../common/Type';
import { ReservationForm } from '../components/ReservationForm';

@Entry
@ComponentV2
struct Sample1 {
  @Local isSubmitLoading: boolean = false;

  build() {
    NavDestination() {
      Column() {
        ReservationForm({
          projectName: '猫眼美甲',
          btnLabel: '立即预约',
          isSubmitLoading: this.isSubmitLoading,
          submitForm: (formData: IFormData) => {
            console.log('form data: ' + JSON.stringify(formData));
            this.isSubmitLoading = true;
            setTimeout(() => {
              this.isSubmitLoading = false;
              this.getUIContext().getPromptAction().showToast({ message: '提交成功' });
            }, 200);
          },
        })
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .title('预约', { backgroundColor: Color.White })
  }
}