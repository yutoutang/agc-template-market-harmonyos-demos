import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';
import {
  AppointmentInfo,
  AppointState,
  BreakpointModel,
  CommonUtils,
  DialogCallBuilder,
  getAppointmentList,
  GroupOrderStatus,
  IBaseStore,
  MyGroupInfo,
  OrderType,
  Params,
  PopViewUtils,
  refund,
  RouterMap, RouterModule,
  StoreInfoModel,
  SystemSceneUtils,
} from 'foundation'

const TAG = '[BookGroupDetail]'

@Builder
export function BookGroupDetailBuilder() {
  BookGroupDetail()
}

@ComponentV2
export struct BookGroupDetail {
  @Local groupInfo: MyGroupInfo = new MyGroupInfo();
  @Local orderStatus: GroupOrderStatus = GroupOrderStatus.AVAILABLE;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local isBook: boolean = false;
  @Local storeInfo: IBaseStore | undefined = undefined

  aboutToAppear(): void {
    const paramList: Array<MyGroupInfo> = RouterModule.getNavParam({ url: RouterMap.MY_BOOK_GROUP_DETAIL });
    if (paramList.length) {
      this.groupInfo = paramList[paramList.length - 1];
      this.orderStatus = this.groupInfo.status;
    }

    if (this.groupInfo.status === GroupOrderStatus.AVAILABLE) {
      this.checkBook();
    }
    // 门店信息
    this.storeInfo = this.storeModel.storeList.find(x => x.id === this.groupInfo.groupStoreId)
  }
  @Computed
  get bookBtnText() {
    return this.isBook ? '已预约' : '立即预约';
  }

  checkBook(): void {
    // 判断是否预约
    const param = [AppointState.NEW];
    getAppointmentList(param).then((resp) => {
      const list = (resp as AppointmentInfo[] ?? []).filter((item: AppointmentInfo) => {
        return item.orderNo === this.groupInfo.orderNo;
      });
      this.isBook = list.length > 0;
    })
  }

  jumpBookPage(item: MyGroupInfo) {
    const bookInfo: Record<string, ESObject> = {
      'id': item.groupId,
      'title': item.title,
      'goodType': OrderType.GROUP,
      'orderNo': item.orderNo
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
        refund(this.groupInfo.orderNo).then(() => {
          ToastDialog.showToast({
            message: '退款成功',
            toastAlignment: DialogAlignment.Center,
          })
          this.orderStatus = GroupOrderStatus.REFUND;
          try {
            emitter.emit('refreshGroup')
          } catch (e) {
            UtilLog.error(TAG, `emit refreshGroup failed. error: ${JSON.stringify(e)}`)
          }
        });
      }
    })
  }

  openPhoneDialog() {
    const mobile = this.storeInfo?.mobile.split(',') as string[]
    PopViewUtils.showPopView<Params>(wrapBuilder(DialogCallBuilder), new Params(mobile),
      { alignment: DialogAlignment.Bottom, autoCancel: true });
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            this.TitleInfo()
            this.StoreInfo()
            this.GroupInfoCard()
            if (this.isAvailable) {
              this.QRCodeCard()
            }
            if (this.isUseUp) {
              this.UsageRecord()
            }
            this.OrderCard()

          }.alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .align(Alignment.Top)
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding,
          top: 10,
          bottom: 10
        })
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)

        if (this.orderStatus === GroupOrderStatus.AVAILABLE) {
          this.BottomView()
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('订单详情')
    .backgroundColor($r('app.color.common_page_bg'))
    .linearGradient(
      {
        angle: 180,
        colors: [['rgba(255, 208, 208, 1)', 0.1], ['rgba(241, 243, 245, 1)', 0.3]]
      })
  }

  @Computed
  get isAvailable() {
    return this.orderStatus === GroupOrderStatus.AVAILABLE;
  }

  @Computed
  get isUseUp() {
    return this.orderStatus === GroupOrderStatus.USE_UP;
  }

  @Computed
  get isRefund() {
    return this.orderStatus === GroupOrderStatus.REFUND;
  }

  @Computed
  get getTitle() {
    if (this.isRefund) {
      return '已退款';
    }
    if (this.isUseUp) {
      return '已使用';
    }
    return '待使用';
  }

  @Computed
  get getTitleIcon() {
    if (this.isRefund) {
      return $r('app.media.ic_refund');
    }
    if (this.isUseUp) {
      return $r('app.media.ic_group_finish');
    }
    return $r('app.media.ic_clock');
  }

  @Computed
  get maskPhoneNumber() {
    // 手机号脱敏
    if (this.groupInfo.contactPhone) {
      return this.groupInfo.contactPhone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
    }
    return ''
  }

  @Builder
  TitleInfo() {
    Row({ space: 10 }) {
      Image(this.getTitleIcon)
        .width(20).height(20)
      Text(this.getTitle).fontSize(18).fontWeight(500)
    }
    .padding({ bottom: 4 })
  }

  @Builder
  StoreInfo() {
    Column({ space: 8 }) {
      Row() {
        Image($r('app.media.ic_store_location')).width(40).height(40).margin({ right: 6 })
        Text(this.storeInfo?.storeName)
          .fontSize(18).fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Row({space: 12}) {
          Image($r('app.media.ic_public_location')).width(24)
            .onClick(() => {
              const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              const address = this.storeInfo?.address as string;
              const coords = this.storeInfo?.coords.split(',') as string[];
              SystemSceneUtils.jumpPetalMap(context, address, coords)
            })
          Image($r('app.media.ic_public_telephone')).width(24)
            .onClick(() => {
              this.openPhoneDialog();
            })
        }
      }
      Row({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.local')).fontSize(16).fontColor([$r('sys.color.icon_primary')])
        Text(this.storeInfo?.address)
          .fontSize(12)
          .maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({left: 12, right: 12, top: 14, bottom: 14})
    .borderRadius(16)
  }

  @Builder
  GroupInfoCard() {
    Column() {
      // 上半部分
      Row() {
        Text(this.groupInfo.title)
          .fontSize(14)
          .fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        Blank()
        Text('￥' + CommonUtils.handleCash(this.groupInfo.vipPrice))
          .fontSize(14)
          .fontWeight(500)
          .fontColor('#E84026')
          .margin({ left: 14 })
      }
      .width('100%')

      Divider().color($r('sys.color.comp_divider')).margin({top: 14, bottom: 24 })
      // 下半部分
      Column({ space: 10 }) {
        Text('套餐内容').fontSize(18).fontWeight(700)
        Row({ space: 30 }) {
          Text('适用部位').fontSize(14).fontWeight(500)
          Text(this.groupInfo.groupContent.location).fontSize(14).fontWeight(500)
        }.width('100%').alignItems(VerticalAlign.Top)

        Row({ space: 30 }) {
          Text('包含项目').fontSize(14).fontWeight(500)
          Text(this.groupInfo.groupContent.including)
            .fontSize(14)
            .fontWeight(500)
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
        }.width('100%').alignItems(VerticalAlign.Top)

        Row({ space: 30 }) {
          Text('附赠项目').fontSize(14).fontWeight(500)
          Text(this.groupInfo.groupContent.present).fontSize(14).fontWeight(500)
        }.width('100%').alignItems(VerticalAlign.Top)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({left: 12, right: 12, top: 14, bottom: 14})
    .borderRadius(16)
  }

  @Builder
  QRCodeCard() {
    Column() {
      Row() {
        Text('团购码').fontSize(18).fontWeight(700)
      }
      .width('100%')
      QRCode(this.groupInfo.groupSerialNo).width(160).height(160)
        .margin({ top: 20, bottom: 20 })
      Text(this.groupInfo.groupSerialNo).fontSize(16)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 24, bottom: 16 })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  UsageRecord() {
    Column({ space: 10 }) {
      Text('使用记录').fontSize(18).fontWeight(700)
      Column({ space: 10 }) {
        Row() {
          Text('使用时间：').fontSize(14).width(80)
          Text(CommonUtils.formatDateTime(this.groupInfo?.consumeTime)).fontSize(14)
        }

        Row() {
          Text('使用券码：').fontSize(14).width(80)
          Text(this.groupInfo.groupSerialNo).fontSize(14).decoration({ type: TextDecorationType.LineThrough })
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({left: 12, right: 12, top: 14, bottom: 14})
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  OrderCard() {
    Column({ space: 10 }) {
      Text('订单信息').fontSize(18).fontWeight(500)
      Column({ space: 10 }) {
        Row() {
          Text('订单号').fontSize(14).width(80)
          Text(this.groupInfo.orderNo).fontSize(14)
        }

        Row() {
          Text('交易方式').fontSize(14).width(80)
          Text('华为支付').fontSize(14)
        }

        Row() {
          Text('手机号码').fontSize(14).width(80)
          Text(this.maskPhoneNumber).fontSize(14)
        }

        Row() {
          Text('下单时间').fontSize(14).width(80)
          Text(CommonUtils.formatDateTime(this.groupInfo.orderTime)).fontSize(14)
        }

        Row() {
          Text('付款时间').fontSize(14).width(80)
          Text(CommonUtils.formatDateTime(this.groupInfo.payTime)).fontSize(14)
        }

        if (this.isRefund && this.groupInfo.refundTime) {
          Row() {
            Text('退款时间').fontSize(14).width(80)
            Text(CommonUtils.formatDateTime(this.groupInfo.refundTime)).fontSize(14)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: 12, right: 12, top: 24, bottom: 16 })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  BottomView() {
    Row({ space: 12 }) {
      Button() {
        Text('退款')
          .fontSize($r('sys.float.Body_M'))
          .fontColor('#E64566')
          .fontWeight(500)
          .width(56)
          .height(20)
          .textAlign(TextAlign.Center)
      }
      .width('50%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding(8)
      .onClick(() => {
        this.refundGroup();
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
      .width('50%')
      .padding(8)
      .onClick(() => {
        if (this.isBook) {
          return;
        }
        this.jumpBookPage(this.groupInfo)
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: 12,
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
