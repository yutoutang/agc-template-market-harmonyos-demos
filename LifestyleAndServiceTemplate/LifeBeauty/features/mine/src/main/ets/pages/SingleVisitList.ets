import { AppStorageV2 } from '@kit.ArkUI';
import {
  CommonUtils,
  UIEmpty,
  getMySingleVisitCardList,
  IMySingleCardInfo,
  IUseRecord,
  PopViewUtils,
  BreakpointModel,
  BreakpointNameEnum,
  RouterModule,
  RouterMap,
  AppointState,
  getAppointmentList,
  AppointmentInfo,
  OrderType,
  IUpdateAppointmentRequest,
  updateAppointmentInfo,
  updateMySingleCard,
  getStoreList,
} from 'foundation';
import { DialogQRCodeBuilder, QRCodeParams } from '../components/DialogQRCode';
import { NavBarListView, NavItemInfo, TabTypeEnum } from '../components/NavBarListView';

@Builder
export function SingleCardVisitListBuilder() {
  SingleCardVisitList()
}


@ComponentV2
export struct SingleCardVisitList {
  @Local tabType: TabTypeEnum = TabTypeEnum.ALL;
  @Local selectedTabIndex: number = 0;
  private controller: TabsController = new TabsController()
  tabNavList: NavItemInfo[] = [
    { id: TabTypeEnum.ALL, label: '全部' },
    { id: TabTypeEnum.UNUSED, label: '待使用' },
    { id: TabTypeEnum.USED, label: '已使用' },
  ]

  build() {
    NavDestination() {
      Column() {
        // 自定义tabbar
        NavBarListView({
          options: this.tabNavList,
          tabType: this.tabType,
          onChangeTabType: (index: number) => {
            this.tabType = this.tabNavList[index].id;
            this.selectedTabIndex = index;
          },
        })
        Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.selectedTabIndex }) {
          ForEach(this.tabNavList, (item: NavItemInfo) => {
            TabContent() {
              SingleVisitContentView({
                tabType: item.id,
                currentType: this.tabType,
              })
            }
          }, (item: NavItemInfo) => JSON.stringify(item))
        }
        .width('100%')
        .layoutWeight(1)
        .barHeight(0)
        .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
          this.tabType = this.tabNavList[targetIndex].id;
        })
        .onChange((index: number) => {
          this.selectedTabIndex = index;
        })
      }
    }
    .title('次卡')
    .backgroundColor($r('app.color.common_page_bg'))
  }
}

@ComponentV2
struct SingleVisitContentView {
  @Param tabType: TabTypeEnum = TabTypeEnum.ALL;
  @Param currentType: TabTypeEnum = TabTypeEnum.ALL;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local singleList: IMySingleCardInfo[] = [];
  @Local isBook: boolean = false;

  @Monitor('currentType')
  onChangeTabTypeWatch() {
    if (this.tabType === this.currentType) {
      this.getSingleVisitList();
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
      this.getSingleVisitList();
    }
  }

  getSingleVisitList() {
    getMySingleVisitCardList().then(async (resp) => {
      const list = resp as IMySingleCardInfo[];
      if (this.currentType === TabTypeEnum.UNUSED) {
        this.singleList = list.filter((item: IMySingleCardInfo) => item.leftNums > 0)
      } else if (this.currentType === TabTypeEnum.USED) {
        this.singleList = list.filter((item: IMySingleCardInfo) => item.leftNums === 0)
      } else {
        this.singleList = list;
      }
    })
  }

  build() {
    if (this.singleList.length) {
      List({ space: 10 }) {
        ForEach(this.singleList, (item: IMySingleCardInfo) => {
          ListItem() {
            SingleVisitCard({
              item: item,
              refresh: () => {
                this.getSingleVisitList()
              },
            })
          }
        }, (v: IMySingleCardInfo, index: number) => JSON.stringify(v) + index)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .lanes(this.listLanes, 12)
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding,
        bottom: 10,
      })
    } else {
      UIEmpty({
        emptyDesc: '暂无次卡记录',
        emptyIcon: $r('app.media.ic_single_empty'),
        imgSize: { width: 120, height: 120 },
      })
    }
  }
}


@ComponentV2
struct SingleVisitCard {
  @Param @Require item: IMySingleCardInfo;
  @Event refresh: () => void;
  @Local isBook: boolean = false;
  @Local currentAppointment: AppointmentInfo | undefined = undefined

  @Computed
  get bookBtnText() {
    return this.isBook ? '已预约' : '立即预约';
  }

  aboutToAppear(): void {
    getAppointmentList([AppointState.NEW]).then((resp) => {
      const bookList = (resp as AppointmentInfo[] ?? []).filter((item: AppointmentInfo) => {
        // 未超期
        const isNotOverTime = item.reserveTime > new Date().getTime();
        return item.orderNo.toString() === this.item.singleCardSerialNo &&
          isNotOverTime && !item.completedTime;
      });
      this.isBook = bookList.length > 0;
      this.currentAppointment = bookList[0];
    })
  }

  jumpBookPage(item: IMySingleCardInfo) {
    const bookInfo: Record<string, ESObject> = {
      'id': item.singleCardId,
      'title': item.title,
      'goodType': OrderType.SINGLE_CARD,
      'orderNo': item.singleCardSerialNo,
    }
    RouterModule.push({
      url: RouterMap.BOOK_GOOD,
      param: bookInfo,
    });
  }

  // 模拟核销操作
  async mockSingleCardUse() {
    if (this.isBook && this.currentAppointment) {
      const data: IUpdateAppointmentRequest = {
        reserveId: this.currentAppointment.id,
        setSchedule: this.currentAppointment.setSchedule,
        setSubscription: this.currentAppointment.setSubscription,
        completedTime: new Date().getTime(),
      };
      // 预约完成
      updateAppointmentInfo(data);
      // 查询门店
      const storeList = await getStoreList();
      const storeInfo = storeList.find(v => v.id === this.currentAppointment?.storeId);
      const param: IMySingleCardInfo = JSON.parse(JSON.stringify(this.item));
      param.usageRecord.push({
        useTime: new Date().getTime(),
        storeName: storeInfo?.storeName ?? '',
      })
      if (this.item.leftNums > 0) {
        param.leftNums = this.item.leftNums - 1;
      }
      updateMySingleCard(param).then((result: ESObject) => {
        this.refresh?.()
      })
    }
  }

  build() {
    Column() {
      Row() {
        Text(this.item.title).fontSize(16).fontWeight(500)
        Blank()
        Text(`可用次数：${this.item.leftNums}次`)
          .fontSize(14)
          .fontWeight(500)
          .fontColor(this.item.leftNums > 0 ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
      }
      .width('100%')

      Row() {
        Column({ space: 8 }) {
          Text(`适用项目：${this.item.availableProName}`).fontSize(14)
          Text('有效期：' +
            (this.item.availablePeriod === -1 ? '永久有效' : CommonUtils.formatDateTime(this.item.availablePeriod)))
            .fontSize(14)
          Text('适用门店：全国所有门店').fontSize(14)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Image(this.item.leftNums > 0 ? $r('app.media.ic_public_qrcode') : $r('app.media.ic_public_qrcode_disable'))
          .width(48)
          .height(48)
          .enabled(this.item.leftNums > 0)
          .onClick(() => {
            PopViewUtils.showPopView<QRCodeParams>(wrapBuilder(DialogQRCodeBuilder),
              new QRCodeParams(this.item.singleCardSerialNo),
              { alignment: DialogAlignment.Center, autoCancel: true });

            // 模拟次卡使用
            setTimeout(() => {
              this.mockSingleCardUse()
            }, 200)
          })
      }
      .width('100%')
      .margin({ top: 14 })

      Divider().color($r('sys.color.comp_divider'))
        .margin({ top: 12 })

      if (this.item.leftNums > 0) {
        Row() {
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
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4,
          })
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

      if (this.item.usageRecord.length) {
        Column({ space: 8 }) {
          Text('使用记录：').fontSize(12)
          ForEach(this.item.usageRecord, (v: IUseRecord) => {
            Row({ space: 10 }) {
              Text(CommonUtils.formatDate(v.useTime, 'YYYY/MM/DD HH:mm')).fontSize(12)
              Text(v.storeName).fontSize(12).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
          }, (item: IUseRecord) => JSON.stringify(item))
        }
        .width('100%')
        .margin({ top: 12 })
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12,
    })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}