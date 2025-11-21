import { MapComponent } from '@kit.MapKit';
import { routerStack } from 'lib_foundation';
import { LogisticsItem, OrderItem } from 'lib_network';
import { OrderUtil } from '../utils/OrderUtil';
import { OrderExpressInfoVM } from '../viewModels/OrderExpressInfoVM';

@Builder
export function buildOrderExpressInfoPage() {
  OrderExpressInfoPage()
}

@ComponentV2
export struct OrderExpressInfoPage {
  @Local
  showExpress:boolean = true

  vm: OrderExpressInfoVM = new OrderExpressInfoVM(this.getUIContext())


  aboutToAppear(): void {
    this.vm.initMap(
      () => {
        this.buildCustomInfoWindow('发', this.vm.expressInfo!.sendPosition)
      },
      () => {
        this.buildCustomInfoWindow('收', this.vm.expressInfo!.getPosition)
      },
    )
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        MapComponent({
          mapOptions: this.vm.mapOptions,
          mapCallback: this.vm.callback,
        })
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.background_color_grey'))
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .bindSheet($$this.showExpress, this.buildLogisticInfoSheet(), {
        preferType: SheetType.BOTTOM,
        showClose: false,
        dragBar: false,
        backgroundColor:$r('app.color.background_color_white'),
        enableOutsideInteractive: true,
        detents: [200, SheetSize.MEDIUM],
        onWillDismiss: (action) => {
          if(action.reason === DismissReason.PRESS_BACK){
            routerStack.pop()
          }
        },
      })
    }
    .onReady((context) => {
      const param = context.pathInfo.param as OrderItem | undefined
      if (param) {
        this.vm.initData(param)
      }
    })
    .onShown(() => {
      if (this.vm.mapController) {
        this.vm.mapController.show();
      }
      this.showExpress = true
    })
    .onHidden(() => {
      if (this.vm.mapController) {
        this.vm.mapController.hide();
      }
      this.showExpress = false
    })
    .title('物流详情')

  }

  @Builder
  buildLogisticInfoSheet() {
    Column() {
      if (this.vm.expressInfo) {
        Row() {
          Text(this.vm.expressInfo.expressName + ' ' + this.vm.expressInfo.expressNo)
            .fontSize(14)
            .fontColor($r('app.color.font_color_level1'))
            .margin({
              top: 12,
              bottom: 16,
            })
          Text('复制')
            .fontSize($r('app.float.font_size_10'))
            .borderWidth(1)
            .borderColor($r('app.color.theme_color'))
            .fontColor($r('app.color.theme_color'))
            .borderRadius($r('app.float.border_radius_capsule'))
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            })
            .backgroundColor($r('app.color.background_color_white'))
            .onClick(() => {
              OrderUtil.copyOrderNumber(this.vm.expressInfo!.expressNo)
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }

      if (this.vm.orderItem?.logisticInfo) {
        Column() {
          ForEach(this.vm.orderItem.logisticInfo, (node: LogisticsItem, index: number) => {
            Flex({ alignItems: ItemAlign.Start }) {
              Column() {
                Circle()
                  .width(12)
                  .height(12)
                  .fill(index === 0 ? $r('app.color.theme_color') : $r('app.color.background_color_white'))
                  .stroke(index === 0 ? $r('app.color.theme_color') : $r('sys.color.comp_divider'))

                if (index !== this.vm.orderItem!.logisticInfo.length - 1) {
                  Column()
                    .width(2)
                    .height(48)
                    .borderWidth({ right: 1 })
                    .borderColor($r('sys.color.comp_divider'))
                    .borderStyle(BorderStyle.Dashed)
                    .margin({ left: -1 })
                }
              }

              Column() {
                Row() {
                  Text(OrderUtil.getLogisticStatusLabel(node.status))
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(index === 0 ? $r('app.color.theme_color') : $r('sys.color.font_primary'))
                    .margin({ right: 12 })
                  Text(node.time)
                    .fontSize(12)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(index === 0 ? $r('app.color.theme_color') : $r('app.color.font_color_level3'))
                }
                .margin({ bottom: 4 })

                Text(node.desc)
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('app.color.font_color_level2'))
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 8 })
              .flexGrow(1)
            }
            .width('100%')
          }, (item: LogisticsItem) => JSON.stringify(item))
        }
        .padding({
          bottom: $r('app.float.space_xl'),
        })
      }
    }
    .padding($r('app.float.space_l'))
    .backgroundColor($r('app.color.background_color_white'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildCustomInfoWindow(title: string, name: string) {
    Row() {
      Row() {
        Text(title)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.font_color_level1_invert'))
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .height('100%')
      .width(24)
      .backgroundColor($r('app.color.theme_color'))

      Row() {
        Text(name)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(56)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.background_color_grey'))
    }
    .width(80)
    .height(32)
    .borderRadius(8)
    .clip(true)
  }
}