import { common } from '@kit.AbilityKit';
import {
  AvoidAreaUtil,
  Constant,
  EventEmitName,
  HouseTabBarModule,
  Logger,
  RouterModule,
  ShortCutModule,
} from 'foundation';
import { HotHouse } from '../components/HotHouse';
import { HOT_HOUSE_TAB, SHORT_CUTS } from '../constant/Constant';
import { HomeVM } from '../viewmodel/HomeVM';

@Builder
export function HomeBuilder() {
  Home();
}

@ComponentV2
export struct Home {
  vm: HomeVM = HomeVM.instance;
  @Local searchValue: string = '';
  @Local keyword: string = '';
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.vm.loading = true;
    this.vm.init(this.getUIContext().getHostContext()!);
  }

  aboutToDisappear(): void {
    this.context.eventHub.off(EventEmitName.INIT_MAP);
  }

  @Builder
  ShortCutArea() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(SHORT_CUTS, (item: ShortCutModule) => {
        Column({ space: 6 }) {
          Image(item.icon).size({ width: 48, height: 48 });
          Text(item.title)
            .fontSize(12)
            .opacity(0.9)
            .width(50)
            .textAlign(TextAlign.Center)
            .fontColor($r('sys.color.black'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .padding({
          left: 18,
          right: 18,
          top: 12,
          bottom: 12,
        })
        .onClick(item.click);
      }, (item: ShortCutModule) => item.title.toString());
    }
    .height(96)
    .width('100%')
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16);
  }

  @Builder
  HotHouseArea() {
    Row({ space: 24 }) {
      ForEach(HOT_HOUSE_TAB, (item: HouseTabBarModule, index: number) => {
        Stack({ alignContent: Alignment.Center }) {
          if (this.vm.hotTabIndex === index) {
            Image($r('app.media.oval')).size({ width: 12, height: 12 });
          }
          Text(`${item.title}`)
            .fontSize(14).fontColor($r('sys.color.black'))
            .opacity(this.vm.hotTabIndex === index ? 0.9 : 0.6)
            .fontWeight(this.vm.hotTabIndex === index ? FontWeight.Bold : FontWeight.Regular);
        }.onClick(() => {
          this.vm.loading = true;
          this.vm.hotTabIndex = index;
          this.vm.getHouseListByIndex(this.vm.hotTabIndex);
        });
      }, (item: HouseTabBarModule, index: number) => item.title.toString());
    }.padding({ left: 8, top: 16, bottom: 16 }).width('100%').justifyContent(FlexAlign.Start);

    if (this.vm.loading) {
      LoadingProgress().width(32).height(32);
    } else {
      HotHouse({ hotHouseList: this.vm.hotHouseList, index: this.vm.hotTabIndex });
    }
  }

  @Builder
  citySearchBuilder() {
    Row({ space: 4 }) {
      Row() {
        Row() {
          Text(this.vm.currentCity)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ right: 4 })
            .fontColor($r('sys.color.black'));
          Image($r('app.media.ic_down')).size({ width: 12, height: 12 });
        }.onClick(() => {
          RouterModule.stack.pushPathByName('CitySelect', null, (popInfo: PopInfo) => {
            this.vm.currentCity = popInfo.result as string;
          });
        });

        Divider().vertical(true).height(20).margin({ left: 8, right: 8 });
        Image($r('sys.media.ohos_ic_public_search_filled')).size({ width: 16, height: 16 }).margin({ right: 8 });
        TextInput({ text: this.keyword, placeholder: '请输入你想住的地方' })
          .padding(0)
          .width(160)
          .backgroundColor(Color.Transparent)
          .onFocus(() => {
            RouterModule.push({
              url: 'HouseSearch',
            });
            // 清除焦点
            this.getUIContext().getFocusController().clearFocus();
          })
          .gesture(
            // 绑定可以重复触发的LongPressGesture
            LongPressGesture({ repeat: true })
              .onAction((event?: GestureEvent) => {
                if (event) {
                  RouterModule.push({
                    url: 'HouseSearch',
                  });
                }
              })
              .onActionEnd(() => {
                // 清除焦点
                this.getUIContext().getFocusController().clearFocus();
              }),
          );
      };
    }
    .padding(12)
    .height(40)
    .margin({ bottom: 12, top: AvoidAreaUtil.getTopHeight() })
    .backgroundColor($r('sys.color.white'))
    .borderRadius(20)
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            this.citySearchBuilder();
            this.ShortCutArea();
            this.HotHouseArea();
          };
        }.height(Constant.FULL_PERCENT).align(Alignment.TopStart).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring);
      }
      .height(Constant.FULL_PERCENT)
      .width(Constant.FULL_PERCENT)
      .backgroundColor('#F1F3F5')
      .padding(16)
      .linearGradient({
        direction: GradientDirection.Bottom,
        repeating: false,
        colors: [['#E6FFD4', 0.0], ['#F1F3F5', 0.3], ['#F1F3F5', 1]],
      });
    };
  }
}