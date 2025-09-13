import {
  CommonConstants,
  createAppointmentInfo,
  ICreateAppointmentRequest,
  GoodInfo,
  PopViewUtils,
  RouterMap,
  RouterModule,
} from 'foundation';
import { IFormData, ReservationForm } from 'reservation_form';
import { BookSuccessParam, DialogBookSuccessBuilder } from '../components/DialogBookSuccess';

@Builder
export function BookGoodBuilder() {
  BookGood()
}

@ComponentV2
export struct BookGood {
  @Local goodInfo: GoodInfo = new GoodInfo();
  @Local isSubmitLoading: boolean = false;

  aboutToAppear(): void {
    const paramList: Array<GoodInfo> = RouterModule.getNavParam({ url: RouterMap.BOOK_GOOD });
    if (paramList.length) {
      this.goodInfo = paramList[paramList.length - 1];
    }
  }

  build() {
    NavDestination() {
      Column() {
        ReservationForm({
          projectName: this.goodInfo.title,
          themeColor: '#E64566',
          btnLabel: '立即预约',
          isSubmitLoading: this.isSubmitLoading,
          submitForm: (formData: IFormData) => {
            this.isSubmitLoading = true;
            const data: ICreateAppointmentRequest = {
              goodId: this.goodInfo.id.toString(),
              name: formData.name,
              phone: formData.phone,
              reserveTime: formData.reserveTime.toString(),
              remarks: formData.remarks,
              numbers: formData.numbers,
            };
            createAppointmentInfo(data).then(() => {
              this.openBookSuccessDialog();
              this.isSubmitLoading = false;
            }).catch(() => {
              this.isSubmitLoading = false;
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.book_error_tip') });
            })
          },
        })
          .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding(10)
    }
    .title('预约', { backgroundColor: Color.White })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  openBookSuccessDialog() {
    PopViewUtils.showPopView<BookSuccessParam>(wrapBuilder(DialogBookSuccessBuilder), new BookSuccessParam(),
      { alignment: DialogAlignment.Center });
  }
}
