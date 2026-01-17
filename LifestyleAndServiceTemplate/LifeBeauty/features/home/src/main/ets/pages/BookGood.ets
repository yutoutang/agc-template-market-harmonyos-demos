import { AppStorageV2 } from '@kit.ArkUI';
import {
  CommonConstants,
  createAppointmentInfo,
  ICreateAppointmentRequest,
  PopViewUtils,
  RouterMap,
  RouterModule,
  BreakpointModel,
  OrderType,
} from 'foundation';
import { IFormData, ReservationForm } from 'reservation_form';
import { BookSuccessParam, DialogBookSuccessBuilder } from '../components/DialogBookSuccess';
import { HomeBaseVM } from '../viewmodel/HomeBaseVM';

@Builder
export function BookGoodBuilder() {
  BookGood()
}

@ComponentV2
export struct BookGood {
  @Local goodTitle: string = '';
  @Local goodId: string = '';
  @Local goodType: OrderType = OrderType.SINGLE_CARD;
  @Local orderNo: string = ''
  @Local isSubmitLoading: boolean = false;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  homeVM: HomeBaseVM = HomeBaseVM.instance;

  aboutToAppear(): void {
    const paramList: Array<Record<string, ESObject>> = RouterModule.getNavParam({ url: RouterMap.BOOK_GOOD });
    if (paramList.length) {
      const data: Record<string, ESObject> = paramList[paramList.length - 1];
      this.goodId = data.id as string;
      this.goodTitle = data.title as string;
      this.goodType = data.goodType as OrderType;
      this.orderNo = data.orderNo as string
    }
  }

  build() {
    NavDestination() {
      Column() {
        ReservationForm({
          projectName: this.goodTitle,
          themeColor: '#E64566',
          btnLabel: '立即预约',
          storeList: this.homeVM.storeList,
          isSubmitLoading: this.isSubmitLoading,
          submitForm: (formData: IFormData) => {
            this.isSubmitLoading = true;
            const data: ICreateAppointmentRequest = {
              goodId: this.goodId.toString(),
              name: formData.name,
              phone: formData.phone,
              reserveTime: formData.reserveTime.toString(),
              remarks: formData.remarks,
              numbers: formData.numbers,
              storeId: formData.storeId,
              goodType: this.goodType,
              orderNo: this.orderNo,
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
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding,
        top: 10,
        bottom: 10
      })
    }
    .title('预约', { backgroundColor: $r('app.color.common_page_bg') })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  openBookSuccessDialog() {
    PopViewUtils.showPopView<BookSuccessParam>(wrapBuilder(DialogBookSuccessBuilder), new BookSuccessParam(),
      { alignment: DialogAlignment.Center });
  }
}
