import { LengthMetrics } from '@kit.ArkUI';
import { BaseMineCustomerServiceQA } from 'lib_takeaway_api/src/main/ets/database/MineCustomerServiceQAType';
import { NavHeaderBar } from 'lib_widget';

@Builder
export function MineCustomerServiceDetailPageBuilder() {
  MineCustomerServiceDetailPage()
}

@ComponentV2
export struct MineCustomerServiceDetailPage {
  @Local item: BaseMineCustomerServiceQA | undefined = undefined;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '问题详情',
        })
      }

      Scroll() {
        Column() {
          if (this.item?.isRichText) {
            RichText(this.item?.content as string)
              .size({ width: '100%', height: '100%' })
              .layoutWeight(1)

          } else {
            Text(this.item?.title)
              .fontSize(18)
              .fontColor($r('sys.color.black'))
              .fontWeight(FontWeight.Bold)

            if (this.item?.image) {
              Image(this.item?.image)
                .margin({ top: 13 })
                .borderRadius(8)
                .width('100%')
            }
            Text(this.item?.content)
              .fontSize(15)
              .fontColor($r('sys.color.black'))
              .fontWeight(FontWeight.Normal)
              .letterSpacing(1)
              .lineSpacing(LengthMetrics.percent(1))
              .margin({ top: 12 })
          }

        }
        .padding({
          top: 12,
          left: 12,
          right: 12,
          bottom: 13
        })
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .borderRadius(16)
        .margin({ top: 8 })
        .backgroundColor($r('app.color.background_color_white'))
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
      .edgeEffect(EdgeEffect.Spring)
      .padding({ left: 16, right: 16 })
    }
    .backgroundColor($r('app.color.phone_background_color'))
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onReady((context) => {
      this.item = context.pathInfo.param as BaseMineCustomerServiceQA | undefined;
    })
  }
}