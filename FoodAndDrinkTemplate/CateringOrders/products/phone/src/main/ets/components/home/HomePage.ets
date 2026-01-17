import { AppStorageV2 } from '@kit.ArkUI';
import { AppInfoModel, Constants, GridRowColSetting, WindowModel } from 'common/Index';
import { HomeBannerComp } from './HomeBannerComp';
import { HomeCardComp } from './HomeCardComp';
import { HomeHeaderComp } from './HomeHeaderComp';

@ComponentV2
export struct HomePage {
  @Consumer('currentIndex') currentIndex: number = 0
  @Local appInfoModel: AppInfoModel = AppStorageV2.connect(AppInfoModel, () => new AppInfoModel())!;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local breakpoint: string = '';

  aboutToAppear() {
  }

  build() {
    GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
      GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
        Column() {
          HomeHeaderComp({ breakpoint: this.breakpoint })
          Scroll() {
            Column({ space: 4 }) {
              HomeBannerComp({ breakpoint: this.breakpoint, bannerList: this.appInfoModel.bannerList })
              HomeCardComp({ breakpoint: this.breakpoint })
            }
            .height(Constants.FULL_SIZE)
            .width(Constants.FULL_SIZE)

          }.width('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ top: this.windowModel.getWindowTopHeight() })
        .backgroundColor($r('sys.color.background_secondary'))
      }
    }.onBreakpointChange((bp) => {
      this.breakpoint = bp;
    })

  }
}
