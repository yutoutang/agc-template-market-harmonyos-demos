import { TitleBar } from 'commonlib';
import { PageSwiper } from 'module_page_swiper';
import { TreasurePageVM } from '../viewModels/TreasurePageVM';

@Builder
export function TreasurePageBuilder() {
  TreasurePage();
}


@ComponentV2
struct TreasurePage {
  vm: TreasurePageVM = TreasurePageVM.instance;

  aboutToAppear(): void {
    this.vm.getDefaultIndex();
    this.vm.getTreasureInfo();
    this.vm.getCloudUrl();
  }

  aboutToDisappear(): void {
    this.vm.intCount++;
  }

  build() {
    NavDestination() {
      Stack() {
        PageSwiper({
          swiperData: this.vm.swiperData,
          isShowTips: this.vm.intCount <= 0,
          defaultIndex: this.vm.defaultIndex,
          sheetBg: this.vm.cloudUrl.sheetBg,
          onBackgroundChange: (isScale) => {
              this.vm.isScale = isScale
          },
        });
        TitleBar({ text: this.vm.isScale ? '' : '馆藏珍品' });
      }.alignContent(Alignment.Top);

    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .hideTitleBar(true)
    .systemBarStyle({
      statusBarContentColor: '#FFFFFF',
    });

  }
}

