import { CustomTabBar } from '../components/CustomTabBar';
import { OrderPageBuilder } from 'order';
import { OrderListPageBuilder } from 'order_list';
import { PersonalCenterPageBuilder } from 'personal_center';
import {
  Constants,
  FormCard,
  HomePageRouter,
  OrderDetailRouter,
  RouterMap,
  RouterModule,
  TabBarType,
  WindowModel,
} from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  @Provider('currentIndex') currentIndex: number = 0;
  @Provider('refreshData') refreshData: boolean = false;
  @Local formCard: FormCard = AppStorageV2.connect(FormCard, () => new FormCard())!
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  aboutToAppear(): void {
    this.getParams();
  }

  @Monitor('formCard.id')
  formCardChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      let currentName: string[] = RouterModule.getStack().getAllPathName()
      if (currentName.length && currentName[currentName.length-1] === 'OrderDetailPage') {
        RouterModule.replace(this.formCard.url, { orderId: this.formCard.orderId } as OrderDetailRouter);
      } else {
        RouterModule.push(this.formCard.url, { orderId: this.formCard.orderId } as OrderDetailRouter);
      }
      this.formCard.id = 0
    }
  }

  getParams() {
    let params = RouterModule.getNavParam<HomePageRouter>(RouterMap.HOME_PAGE);
    if (params) {
      this.currentIndex = params.index ?? 0;
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Flex({
          direction: FlexDirection.Column,
        }) {
          Tabs({ index: this.currentIndex }) {
            TabContent() {
              wrapBuilder(OrderPageBuilder).builder();
            };

            TabContent() {
              wrapBuilder(OrderListPageBuilder).builder();
            };

            TabContent() {
              wrapBuilder(PersonalCenterPageBuilder).builder();
            };
          }
          .layoutWeight(1)
          .barHeight(0)
          .scrollable(false)
          .onChange((index) => {
            this.currentIndex = index;
          });

          CustomTabBar();
        }
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE);
      };
    }.hideTitleBar(true).padding({ bottom: this.windowModel.getWindowBottomHeight() })
    .onShown(() => {
      if (this.currentIndex === TabBarType.ORDER) {
        this.refreshData = true
      }
    })

  }
}