import { AppStorageV2 } from '@kit.ArkUI';
import { emitter, pasteboard } from '@kit.BasicServicesKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { UtilLog } from '@hw-agconnect/util-log';
import {
  BreakpointModel,
  BreakpointNameEnum,
  CommonConstants,
  getMyGroupList,
  GroupOrderStatus,
  MyGroupInfo,
  UIEmpty,
  OrderType,
  UIOrderPart,
  RouterModule,
  RouterMap,
  refund,
  AppointState,
  getAppointmentList,
  AppointmentInfo} from 'foundation';
import { LoadingStatus } from '../common/Constant';
import { TabTypeEnum } from './NavBarListView';

const TAG = '[GroupListContentView]'

@ComponentV2
export struct GroupListContentView {
  @Param tabType: TabTypeEnum = TabTypeEnum.ALL;
  @Param currentType: TabTypeEnum = TabTypeEnum.ALL;
  @Local isRefreshing: boolean = false;
  @Local list: MyGroupInfo[] = [];
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local loadingStatus: LoadingStatus = LoadingStatus.OFF;
  tabTypeMap: TabTypeEnum[] = [TabTypeEnum.UNUSED, TabTypeEnum.USED, TabTypeEnum.REFUNDED];

  @Monitor('currentType')
  onChangeTabTypeWatch() {
    if (this.tabType === this.currentType) {
      this.queryList()
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
      this.queryList();

      try {
        emitter.on('refreshGroup', () => {
          this.queryList();
        })
      } catch (e) {
        UtilLog.error(TAG, `refreshGroup emitter failed. error: ${JSON.stringify(e)}`)
      }
    }
  }

  queryList() {
    const status = this.tabTypeMap.findIndex((v) => v === this.currentType);
    getMyGroupList(status).then((resp) => {
      this.isRefreshing = false;
      const tempList = resp as MyGroupInfo[];
      this.list = tempList;

      this.loadingStatus = tempList.length > 0 ? LoadingStatus.SUCCESS : LoadingStatus.EMPTY;
    }).catch(() => {
      this.list = [];
      this.loadingStatus = LoadingStatus.EMPTY;
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
          emptyDesc: '暂无团购记录',
          emptyIcon: $r('app.media.ic_appointment_empty'),
          imgSize: { width: 98, height: 99 }
        })
      } else if (this.loadingStatus === LoadingStatus.SUCCESS) {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List({ space: 10 }) {
            ForEach(this.list, (item: MyGroupInfo) => {
              ListItem() {
                GroupCardItemView({
                  item: item,
                  refresh: () => {
                    this.queryList();
                  }
                })
              }
            }, (item: MyGroupInfo, index: number) => JSON.stringify(item) + index)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height('100%')
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
          this.queryList();
        })
      }
    }
  }
}

@ComponentV2
struct GroupCardItemView {
  @Param @Require item: MyGroupInfo;
  @Event refresh: () => void;
  @Local isBook: boolean = false;

  @Computed
  get orderTextNo() {
    return `订单号：${this.item.orderNo}`
  }
  @Computed
  get statusText() {
    if (this.item.status === GroupOrderStatus.REFUND) {
      return '已退款';
    }
    if (this.item.status === GroupOrderStatus.USE_UP) {
      return '已使用';
    }

    return '待使用';
  }
  @Computed
  get isAvailable() {
    return this.item.status === GroupOrderStatus.AVAILABLE;
  }

  @Computed
  get bookBtnText() {
    return this.isBook ? '已预约' : '立即预约';
  }

  aboutToAppear(): void {
    // 判断是否预约
    const param = [AppointState.NEW];
    getAppointmentList(param).then((resp) => {
      const list = (resp as AppointmentInfo[] ?? []).filter((item: AppointmentInfo) => {
        // 未超期
        const isNotOverTime = item.reserveTime > new Date().getTime();
        return item.orderNo.toString() === this.item.orderNo && isNotOverTime;
      });
      this.isBook = list.length > 0;
    })
  }

  copy() {
    try {
      const pasteboardData =
        pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.item.orderNo)
      const systemPasteboard = pasteboard.getSystemPasteboard()
      systemPasteboard.setDataSync(pasteboardData)
      ToastDialog.showToast({ message: '复制成功', toastAlignment: DialogAlignment.Center })
    } catch (e) {
      UtilLog.error(TAG, `createData failed. error: ${JSON.stringify(e)}}`)
    }
  }

  jumpBookPage(item: MyGroupInfo) {
    const bookInfo: Record<string, ESObject> = {
      'id': item.groupId,
      'title': item.title,
      'goodType': OrderType.GROUP,
      'orderNo': this.item.orderNo
    }
    RouterModule.push({
      url: RouterMap.BOOK_GOOD,
      param: bookInfo,
    });
  }

  // 退款
  refundGroup() {
    UIDialog.open({
      titleOptions:{
        primaryTitle: '温馨提醒',
      },
      contentBuilder: () => {
        this.refundContentView()
      },
      showConfirmButton: true,
      showCancelButton: true,
      confirmButtonOptions: {
        buttonFontColor: '#E64566'
      },
      cancelButtonOptions: {
        buttonFontColor: $r('sys.color.font_primary')
      },
      onConfirm: async () => {
        await UIDialog.closeLast();
        refund(this.item.orderNo).then(() => {
          ToastDialog.showToast({
            message: '退款成功',
            toastAlignment: DialogAlignment.Center,
          })
          this.refresh?.();
        });
      }
    })
  }

  build() {
    Column() {
      Row({space: 4}) {
        Text(this.orderTextNo).fontSize(14).fontColor($r('sys.color.font_primary'))
        SymbolGlyph($r('sys.symbol.plus_square_on_square'))
          .fontSize(18)
          .fontColor([$r('sys.color.icon_primary')])
          .onClick(() => {
            this.copy()
          })

        Blank()

        Text(this.statusText)
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .fontColor(this.isAvailable ? $r('sys.color.font_primary') : $r('app.color.common_grey'))
      }
      .width('100%')
      Column() {
        UIOrderPart({
          goodInfo: {
            type: OrderType.GROUP,
            id: this.item.groupId,
            title: this.item.title,
            subTitle: this.item.subTitle,
            vipPrice: this.item.vipPrice,
            image: this.item.images[0] ?? '',
            price: this.item.price
          },
        })
      }
      .width('100%')
      .margin({ top: 24 })
      .onClick(() => {
        RouterModule.push({ url: RouterMap.MY_BOOK_GROUP_DETAIL, param: this.item });
      })

      if (this.isAvailable) {
        Divider().color($r('sys.color.comp_divider')).margin({top: 14})
        Row({ space: 4 }) {
          Button() {
            Text('退款')
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#E64566')
              .fontWeight(500)
              .width(56)
              .height(20)
              .textAlign(TextAlign.Center)
          }
          .backgroundColor('#F2F2F2')
          .padding({
            top: 4,
            bottom: 4,
            left: 8,
            right: 8,
          })
          .onClick(() => {
            this.refundGroup()
          })
          // 立即预约
          Button() {
            Text(this.bookBtnText)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(500)
              .fontColor($r('sys.color.font_on_primary'))
              .width(56)
              .height(20)
              .textAlign(TextAlign.Center)
          }
          .backgroundColor($r('app.color.common_theme_color'))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .onClick(() => {
            if (this.isBook) {
              return;
            }
            this.jumpBookPage(this.item)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 14,
      bottom: 12
    })
  }

  @Builder
  refundContentView() {
    Column({ space: 10 }) {
      Text('您是否要申请退款？')
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))

      Text('如果您确认申请退款，商家会在24小时内完成退款，相关费用返还支付账号并短信通知您')
        .fontSize(14)
        .fontWeight(400)
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 24, right: 24})
  }
}