import { RouterUtils } from 'lib_common'
import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  vm: IndexVM = new IndexVM();

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

  build() {
    Navigation(RouterUtils.getStack()) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return this.vm.customNavContentTransitionCallback(from, to, operation)
    })
  }
}