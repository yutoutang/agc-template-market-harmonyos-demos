import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { BaseStoreListCard } from '../components/BaseStoreListCard';
import { FollowViewModel } from '../viewmodels/FollowVM';

@Builder
export function FollowPageBuilder() {
  FollowPage()
}

@ComponentV2
struct FollowPage {
  @Local vm: FollowViewModel = new FollowViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的关注',
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