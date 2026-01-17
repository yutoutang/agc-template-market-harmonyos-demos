import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, RouterMap, RouterModule, SimpleOrderInfo, UIOrderPart } from 'foundation';

@Builder
export function SuccessPayBuilder() {
  SuccessPay()
}

@ComponentV2
export struct SuccessPay {
  @Local orderInfo: SimpleOrderInfo = new SimpleOrderInfo();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    const paramList: Array<SimpleOrderInfo> = RouterModule.getNavParam({ url: RouterMap.SUCCESS_PAY });
    if (paramList.length) {
      this.orderInfo = paramList[paramList.length - 1];
    }
  }

  onBook() {
    const bookInfo: Record<string, ESObject> = {
      'id': this.orderInfo.goodId,
      'title': this.orderInfo.title,
      'goodType': this.orderInfo.type,
      'orderNo': this.orderInfo.orderNo
    }
    RouterModule.push({
      url: RouterMap.BOOK_GOOD,
      param: bookInfo,
    });
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Column({ space: 12 }) {
              Image($r('app.media.ic_public_success')).width(48).height(48)
              Text('支付完成').fontSize(16).fontWeight(500)
            }.padding({ top: 20, bottom: 20 })

            Column({ space: 4 }) {
              UIOrderPart({ goodInfo: this.orderInfo })
            }
            .width('100%')
            .padding(12)
            .borderRadius(16)
            .backgroundColor(Color.White)
          }.width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
        .align(Alignment.Top)
        .scrollBar(BarState.Off)

        this.BottomOperateView()
      }
      .width('100%')
      .height('100%')
    }
    .title('支付完成')
    .backgroundColor($r('app.color.common_page_bg'))
    .onBackPressed(() => {
      RouterModule.popToName(RouterMap.MAIN);
      return true;
    })
  }

  @Builder
  BottomOperateView() {
    Row({space: 12}) {
      Text('返回首页')
        .width('50%')
        .height(40)
        .fontSize($r('sys.float.Body_L'))
        .fontColor('#e64566')
        .fontWeight(500)
        .textAlign(TextAlign.Center)
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          RouterModule.popToName(RouterMap.MAIN);
        })

      Text('立即预约')
        .width('50%')
        .height(40)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(Color.White)
        .fontWeight(500)
        .textAlign(TextAlign.Center)
        .borderRadius(20)
        .backgroundColor('#e64566')
        .onClick(() => {
          this.onBook();
        })
    }
    .width('100%')
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: 10
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
