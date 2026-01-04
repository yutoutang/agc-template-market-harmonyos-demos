import { RouterUtils } from 'lib_common'
import { PlayerVM } from 'recorded_player';
import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  vm: IndexVM = new IndexVM();
  @Local playerVM: PlayerVM = PlayerVM.instance;

  aboutToAppear(): void {
    this.vm.setInterception();
    this.vm.redirect();
    this.vm.navDestinationListener()
    this.vm.windowStageEventListener()
    this.vm.registerBreakpointListener(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.vm.unregisterBreakpointListener();
  }

  onPageHide(): void {
    if (this.vm.isPlayPage) {
      // todo 退出任务操作
    }
  }

  build() {
    Navigation(RouterUtils.getStack()) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
    .id(this.playerVM.navId)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return this.vm.customNavContentTransitionCallback(from, to, operation)
    })
  }
}