import { LengthMetrics } from '@kit.ArkUI';
import { RouterModule, RouterMap } from 'commonlib';
import { HomePageVM } from '../viewModels/HomePageVM';


@ComponentV2
export struct OrderBar {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, space: {main:LengthMetrics.vp(8)} }) {
      Row() {
        Column() {
          Text('参观预约').fontSize($r('sys.float.Body_M')).fontColor('#603C00').fontWeight(FontWeight.Medium)
          Column() {
            Image($r('app.media.ic_brown_arrow_right')).width(12).height(24)
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor('#D1B380')
          .justifyContent(FlexAlign.Center);
        }.height('100%').justifyContent(FlexAlign.SpaceBetween)

        Image($r('app.media.order_bar1')).width(64).height(64)
      }
      .onClick(() => {
        RouterModule.push({ url: RouterMap.ORDER_TICKET });
      })
      .height(88)
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .borderRadius(16)
      .justifyContent(FlexAlign.SpaceBetween)
      .flexGrow(1)
      .padding(12)


      Row() {
        Column() {
          Text('特展购票').fontSize($r('sys.float.Body_M')).fontColor('#603C00').fontWeight(FontWeight.Medium)
          Column() {
            Image($r('app.media.ic_brown_arrow_right')).width(12).height(24)
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor('#D1B380')
          .justifyContent(FlexAlign.Center);
        }.height('100%').justifyContent(FlexAlign.SpaceBetween)

        Image($r('app.media.order_bar2')).width(64).height(64)
      }
      .onClick(() => {
        RouterModule.push({ url: RouterMap.PERFORMANCE_PAGE });
      })
      .height(88)
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .borderRadius(16)
      .justifyContent(FlexAlign.SpaceBetween)
      .flexGrow(1)
      .padding(12)
    }
    .width('100%');
  }
}