import { TabListItem } from '../types';
import { MainEntryVM } from '../viewmodels/MainEntryVM';
import { HomePage } from 'business_home';
import { OrderPage } from 'business_order';
import { VipPage } from 'business_vip';
import { MinePage } from 'business_mine';
import { ControllerModule } from 'module_base';
import { WidgetCardVM } from '../viewmodels/WidgetCardVM';
import { emitter } from '@kit.BasicServicesKit';


@Builder
export function MainEntryBuilder() {
  MainEntry()
}

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;
  cardVm: WidgetCardVM = WidgetCardVM.instance;
  callBackFunc: () => void = async () => {
    await this.cardVm.getLatestOrder();
    await this.cardVm.updateFormInfo();
  };
  private controller: TabsController = new TabsController();

  aboutToAppear() {
    this.vm.init();
    ControllerModule.set(this.controller)
  }

  async onPageShow(): Promise<void> {
    this.cardVm.subscribeFormId()
    await this.cardVm.getLatestOrder();
    await this.cardVm.updateFormInfo();
    emitter.on('refreshCard', this.callBackFunc);
  }

  aboutToDisappear(): void {
    emitter.off('refreshCard', this.callBackFunc);
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex, controller: this.controller }) {
          TabContent() {
            HomePage()
          }
          .expandSafeArea([SafeAreaType.SYSTEM])
          .tabBar(this.tabBarBuilder(0, {
            label: '寄快递',
            icon: $r('app.media.ic_home'),
            iconChecked: $r('app.media.ic_home_selected')
          }))

          TabContent() {
            OrderPage()
          }
          .expandSafeArea([SafeAreaType.SYSTEM])
          .tabBar(this.tabBarBuilder(1, {
            label: '查快递',
            icon: $r('app.media.ic_express'),
            iconChecked: $r('app.media.ic_express_selected'),
          }))

          TabContent() {
            VipPage()
          }
          .expandSafeArea([SafeAreaType.SYSTEM])
          .tabBar(this.tabBarBuilder(2, {
            label: '会员福利',
            icon: $r('app.media.ic_vip'),
            iconChecked: $r('app.media.ic_vip_selected'),
          }))

          TabContent() {
            MinePage()
          }
          .expandSafeArea([SafeAreaType.SYSTEM])
          .tabBar(this.tabBarBuilder(3, {
            label: '我的',
            icon: $r('app.media.ic_mine'),
            iconChecked: $r('app.media.ic_mine_selected'),
          }))
        }
        .scrollable(false)
        .height('100%')
        .animationDuration(0)
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.vm.curIndex = index;
          let info: emitter.EventData = {
            data: {
              index: index
            }
          };
          emitter.emit('index', info);
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
      }
      .backgroundColor(Color.White)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  tabBarBuilder(index: number, item: TabListItem) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? '#0A59F7' :
        $r('sys.color.icon_secondary'))
        .fontSize(10)
        .margin({ top: 4 });

    }.width('100%');
  }
}