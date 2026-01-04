import { CommonConstants, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { CustomerServicePage } from 'module_customer_service';

@Builder
export function CustomerServiceBuilder() {
  CustomerService()
}

@ComponentV2
struct CustomerService {
  @Local isShowStatue: boolean = false;
  build() {
    NavDestination() {
      NavHeaderBar({
        title: '客服小燕',
        secTitle: this.isShowStatue ? '已接入' : '未接入',
      })
        .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
      Scroll() {
        Column() {
          Scroll() {
            Column({ space: CommonConstants.SPACE_M }) {
              CustomerServicePage({
                customerServicecancelCallBack: () => {
                  RouterUtils.pop();
                },
                customerServiceConfirmCallBack: () => {
                  this.isShowStatue = true;
                }
              })
            }
          }
          .layoutWeight(1)
        }
      }.layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
    }
    .hideTitleBar(true)
    .height('100%')
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
  }
}
