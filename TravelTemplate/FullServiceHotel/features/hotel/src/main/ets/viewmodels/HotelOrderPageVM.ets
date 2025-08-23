import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { paymentService } from '@kit.PaymentKit';
import { AccountUtil, FormatUtil, Logger, RouterMap, RouterModule, UserInfoModel } from 'commonlib';
import { HotelDateModel } from 'module_date_selector';
import { GetOrderDetailRequest, https, PrepayRoomRequest } from 'network';
import { CheckInData } from '../models/CheckInData';
import { HotelBookingVM } from './HotelBookingVM';

@ObservedV2
export class HotelOrderPageVM {
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Trace pageTitle: string = '';
  @Trace checkInData: CheckInData = new CheckInData();
  @Trace userInfo:UserInfoModel = AccountUtil.getUserInfo()
  hotelDateModel: HotelDateModel = HotelDateModel.instance
  private readonly hotelBookingVM: HotelBookingVM = HotelBookingVM.instance;
  private static _instance: HotelOrderPageVM;

  public static get instance() {
    if (!HotelOrderPageVM._instance) {
      HotelOrderPageVM._instance = new HotelOrderPageVM();
    }
    return HotelOrderPageVM._instance;
  }

  public async initData() {
    this.pageTitle = this.hotelBookingVM.hotelInfo.orgUnitName;
    const checkInDate = this.hotelDateModel.checkInDate;
    this.checkInData.checkInDateLabel = this.hotelDateModel.getDateLabel(checkInDate);
    this.checkInData.checkInDateDescription = this.hotelDateModel.getDateDescription(checkInDate);

    const checkOutDate = this.hotelDateModel.checkOutDate;
    this.checkInData.checkOutDateLabel = this.hotelDateModel.getDateLabel(checkOutDate);
    this.checkInData.checkOutDateDescription = this.hotelDateModel.getDateDescription(checkOutDate);

    this.checkInData.totalDays = this.hotelDateModel.totalDays;
    this.checkInData.roomCount = this.hotelDateModel.roomCount;
    let rate: number = Number(this.hotelBookingVM.roomInfo.rmRate);
    let total: number = rate * this.checkInData.roomCount * this.checkInData.totalDays;
    this.checkInData.actualPaidPrice = isNaN(total) ? '--' : total.toString();
    const roomInfo = this.hotelBookingVM.roomInfo;
    this.checkInData.roomTag = [roomInfo.roomName, roomInfo.rateName];
  }

  public async prepayRoom() {
    this.hotelBookingVM.setCheckInData({
      arrDate: FormatUtil.dateAsISO(this.hotelDateModel.checkInDate),
      depDate: FormatUtil.dateAsISO(this.hotelDateModel.checkOutDate),
      rmQty: this.checkInData.roomCount,
      nights: this.checkInData.totalDays,
      remark: this.checkInData.remark,
      guest: {
        name: this.checkInData.guestName,
        tel: this.checkInData.guestPhone,
      },
      totalOrderPrice: this.checkInData.actualPaidPrice,
      actualPaidPrice: this.checkInData.actualPaidPrice,
    });
    const data: PrepayRoomRequest | void = this.hotelBookingVM.getPrepayRequestParam();
    if (!data) {
      return;
    }
    const res = await https.prepayHotel(data);
    if (res.code === 500) {
      promptAction.showToast({ message: res.msg });
    }
    if (res.code === 0) {
      paymentService
        .requestPayment(this.context, res.data.orderStr)
        .then(() => {
          Logger.info('succeeded in paying');
        })
        .catch((error: BusinessError) => {
          promptAction.showToast({ message: '支付失败！' });
          const timer = setTimeout(() => {
            RouterModule.push({
              url: RouterMap.ORDER_DETAIL,
              param: {
                orderNo: res.data.mercOrderNo,
                orderType: 1,
                userId: data.userId,
              } as GetOrderDetailRequest,
            });
            clearTimeout(timer);
          }, 1000);
          Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        });
    }
  }
}
