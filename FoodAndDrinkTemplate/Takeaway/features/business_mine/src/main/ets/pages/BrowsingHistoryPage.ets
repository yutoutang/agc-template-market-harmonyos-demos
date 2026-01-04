import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { BaseStoreListCard } from '../components/BaseStoreListCard';
import { BrowsingHistoryViewModel } from '../viewmodels/BrowsingHistoryVM';

@Builder
export function BrowsingHistoryBuilder() {
  BrowsingHistoryPage()
}

@ComponentV2
struct BrowsingHistoryPage {
  @Local vm: BrowsingHistoryViewModel = new BrowsingHistoryViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '浏览历史',
        })
        BaseStoreListCard({
          list: this.vm.list,
          vm: this.vm,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.vm.queryList();
    })
  }
}