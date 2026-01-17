import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  AppointmentInfo,
  AppointState,
  getAppointmentList,
  UIEmpty,
  CurAppInfo,
  cancelAppointment,
  IUpdateAppointmentRequest,
  updateAppointmentInfo,
  CommonConstants,
  BreakpointModel,
  BreakpointNameEnum} from 'foundation';
import { TabTypeEnum } from './NavBarListView';
import { ReservationCard } from 'reservation_card';
import { LoadingStatus } from '../common/Constant';

const TAG = '[AppointmentContentView]';

@ComponentV2
export struct AppointmentContentView {
  @Param systemLanguage: string = '';
  @Param tabType: TabTypeEnum = TabTypeEnum.ALL;
  @Param currentType: TabTypeEnum = TabTypeEnum.ALL;
  @Local isRefreshing: boolean = false;
  @Local appointInfoList: AppointmentInfo[] = [];
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local loadingStatus: LoadingStatus = LoadingStatus.OFF;

  @Monitor('currentType')
  onChangeTabTypeWatch() {
    if (this.tabType === this.currentType) {
      this.getAppointInfoList()
    }
  }

  @Computed
  get listLanes() {
    const currentBreakpoint = this.breakPointModel.currentBreakpoint;
    switch (currentBreakpoint) {
      case BreakpointNameEnum.SM:
        return 1;
      case BreakpointNameEnum.MD:
        return 2
      default:
        return 3
    }
  }

  aboutToAppear(): void {
    if (this.tabType === this.currentType) {
      this.loadingStatus = LoadingStatus.LOADING;
      this.getAppointInfoList()
    }
  }

  getAppointInfoList() {
    const param = [AppointState.NEW, AppointState.CANCEL, AppointState.OVER_TIME, AppointState.FINISH];
    getAppointmentList(param).then((resp) => {
      const list = (resp as AppointmentInfo[]).map(v => {
        if (v.reserveTime <= new Date().getTime()) {
          v.state = AppointState.OVER_TIME;
        }
        return new AppointmentInfo(v);
      });
      // 按照预约时间升序
      list.sort((a: AppointmentInfo, b: AppointmentInfo) => {
        return a.reserveTime - b.reserveTime;
      })
      if (this.currentType === TabTypeEnum.ALL) {
        this.appointInfoList = list
      } else {
        this.appointInfoList = list.filter((item: AppointmentInfo) => item.state === this.currentType as number)
      }
      this.loadingStatus = this.appointInfoList.length > 0 ? LoadingStatus.SUCCESS : LoadingStatus.EMPTY;
      Logger.info(TAG, 'getAppointInfoList success');
    }).catch((error: BusinessError) => {
      this.appointInfoList = [];
      this.loadingStatus = LoadingStatus.EMPTY;
      Logger.error(TAG, 'getAppointInfoList error:' + JSON.stringify(error));
    }).finally(() => {
      setTimeout(() => {
        this.isRefreshing = false;
      }, 200);
    });
  }

  build() {
    Column() {
      if (this.loadingStatus === LoadingStatus.LOADING) {
        Column({ space: 10 }) {
          LoadingProgress()
            .width(72)
            .height(72)
        }
        .width(CommonConstants.FULL_PERCENT)
      } else if (this.loadingStatus === LoadingStatus.EMPTY) {
        UIEmpty({
          emptyDesc: $r('app.string.empty_history'),
          emptyIcon: $r('app.media.ic_appointment_empty'),
          imgSize: { width: 98, height: 99 }
        })
      } else if (this.loadingStatus === LoadingStatus.SUCCESS) {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List({ space: 10 }) {
            ForEach(this.appointInfoList, (v: AppointmentInfo) => {
              ListItem() {
                ReservationCard({
                  appointInfo: v,
                  themeColor: $r('app.color.common_theme_color'),
                  entityIds: CurAppInfo.PUSH_TEMPLATE_ID,
                  systemLanguage: this.systemLanguage,
                  cancelReservation: () => {
                    cancelAppointment(v.id).then(() => {
                      ToastDialog.showToast({ message: '取消成功' });
                      this.appointInfoList = [];
                      this.loadingStatus = LoadingStatus.LOADING;
                      this.getAppointInfoList();
                    })
                  },
                  updateReservation: (setSchedule: number, setSubscription: number) => {
                    const data: IUpdateAppointmentRequest = {
                      reserveId: v.id,
                      setSchedule: setSchedule,
                      setSubscription: setSubscription,
                    };
                    updateAppointmentInfo(data);
                  },
                  refreshReservation: () => {
                    this.appointInfoList = [];
                    this.loadingStatus = LoadingStatus.LOADING;
                    this.getAppointInfoList();
                  },
                })
              }
            }, (v: AppointmentInfo) => JSON.stringify(v))
          }
          .width(CommonConstants.FULL_PERCENT)
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
          .lanes(this.listLanes, 12)
          .padding({
            left: this.breakPointModel.pagePadding,
            right: this.breakPointModel.pagePadding,
            bottom: 20,
          })
        }
        .layoutWeight(1)
        .onRefreshing(() => {
          this.getAppointInfoList();
        })
      }
    }
  }
}