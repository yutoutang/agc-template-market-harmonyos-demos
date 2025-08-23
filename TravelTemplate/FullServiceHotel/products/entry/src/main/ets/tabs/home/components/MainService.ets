import { CallDialog } from 'module_call_dialog';
import { ServiceLink } from '../commons/Constants';
import { ServiceItem } from '../commons/Types';
import { HomePageVM } from '../viewModels/HomePageVM';
import { CommonConstants } from 'commonlib';

@ComponentV2
export struct MainService {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Column({ space: 12 }) {
      Grid() {
        ForEach(this.vm.twoPicsService, (item: ServiceItem) => {
          GridItem() {
            this.mainServiceCardBuilder(item);
          };
        }, (item: ServiceItem) => JSON.stringify(item));
      }
      .columnsTemplate('1fr 1fr')
      .commonGridStyle()

      Grid() {
        ForEach(this.vm.threePicsService, (item: ServiceItem) => {
          GridItem() {
            this.mainServiceCardBuilder(item);
          };
        }, (item: ServiceItem) => JSON.stringify(item));
      }
      .columnsTemplate('1fr 1fr 1fr')
      .commonGridStyle()

      Grid() {
        ForEach(this.vm.iconServiceList, (item: ServiceItem) => {
          GridItem() {
            this.otherServiceListBuilder(item);
          };
        }, (item: ServiceItem) => JSON.stringify(item));
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .commonGridStyle()
    };

  }

  @Builder
  mainServiceCardBuilder(item: ServiceItem) {
    Column() {
      if (item.link === ServiceLink.CONTACT_US) {
        CallDialog({
          phoneNumber: CommonConstants.TEL_NUMBER,
        }) {
          Image(item.image)
            .width('100%')
            .objectFit(ImageFit.Fill)
        }
      } else {
        Image(item.image)
          .width('100%')
          .objectFit(ImageFit.Fill)
      }
    }
    .borderRadius($r('app.string.border_radius_16'))
    .clip(true)
    .onClick(() => {
      this.vm.jumpToServicePage(item.link);
    });
  }

  @Builder
  otherServiceListBuilder(item: ServiceItem) {
    Column() {
      Image(item.image)
        .width(32)
        .height(32)
        .objectFit(ImageFit.Fill)
        .margin({
          bottom: $r('app.string.margin_s'),
        });
      Text(item.title)
        .fontSize($r('app.string.font_size_14'));
    }
    .onClick(() => {
      this.vm.jumpToServicePage(item.link);
    });
  }
}

@Extend(Grid)
function commonGridStyle() {
  .columnsGap($r('app.string.margin_s'))
  .rowsGap($r('app.string.margin_s'))
  .scrollBar(BarState.Off)
}