import { BaseViewModel, CommonConstants } from 'lib_common';
import { StoreModel } from 'lib_takeaway_api';
import { emptyBuilder } from 'lib_widget';
import { BrowsingHistoryViewModel } from '../viewmodels/BrowsingHistoryVM';
import { FollowViewModel } from '../viewmodels/FollowVM';
import { UniformStoreCard } from 'lib_native_components';

@ComponentV2
export struct BaseStoreListCard {
  @Require @Param list: StoreModel[];
  @Require @Param vm: FollowViewModel | BrowsingHistoryViewModel | BaseViewModel;

  build() {
    Column() {
      Column() {
        List({ space: CommonConstants.SPACE_M }) {
          ForEach(this.list, (v: StoreModel) => {
            ListItem() {
              this.contentItemBuilder(v)
            }
          }, (v: StoreModel) => v.id)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height('86%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          top: CommonConstants.SPACE_XS,
        })
      }
      .padding({ top: CommonConstants.SPACE_M })
      .layoutWeight(1)
      .visibility(this.list.length ? Visibility.Visible : Visibility.None)
      .backgroundColor($r('sys.color.gray_01'))

      Column() {
        emptyBuilder({
          fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
        })
      }
      .layoutWeight(1)
      .visibility(this.list.length ? Visibility.None : Visibility.Visible)
      .padding({
        bottom: 100,
      })
    }
  }

  @Builder
  contentItemBuilder(v: StoreModel) {
    Row() {
      UniformStoreCard({
        storeInfo: v,
        customStyle: {
          bodyFg: 16 * this.vm.settingInfo.fontSizeRatio,
        },
      })
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}