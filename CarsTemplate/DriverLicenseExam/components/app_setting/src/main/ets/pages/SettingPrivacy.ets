import { CommonConstants } from '../constants/CommonConstants';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { NavHeaderBar } from '../components/NavHeaderBar';
import { SettingCard } from '../components/SettingCard';
import { SettingPrivacyVM } from '../viewmodels/SettingPrivacyVM'

@Builder
export function SettingPrivacyBuilder() {
  SettingPrivacy()
}

@ComponentV2
struct SettingPrivacy {
  @Local vm: SettingPrivacyVM = new SettingPrivacyVM();
  @Local bottomRectHeight: number = 0;
  @Local topRectHeight: number = 0;

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Column() {
        if (this.vm.configInfo.isSheet) {
          this.coreView()
        } else {
          GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
            GridCol({
              span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
              offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
            }) {
              this.coreView()
            }
          }
          .layoutWeight(1)
        }
      }
      .padding({
        left:16,
        right:16
      })

    }
    .padding({
      top:px2vp(this.topRectHeight),
      bottom: px2vp(this.bottomRectHeight)
    })
    .title('隐私设置')
    .backgroundColor(this.vm.configInfo.isSheet ? $r('app.color.page_bg') : $r('sys.color.background_secondary'))
  }

  @Builder
  coreView() {
    Scroll() {
      Column({ space: CommonConstants.SPACE_M }) {
        SettingCard({ list: this.vm.list1 })
        SettingCard({ list: this.vm.list2 })
      }
      .padding({
        top: CommonConstants.PADDING_M,
      })
    }
    .attributeModifier(this.vm.scrollModifier)
  }
}