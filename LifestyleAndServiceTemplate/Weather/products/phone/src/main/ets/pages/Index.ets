import { WidgetUtil } from 'business_home';
import { RouterModule } from 'lib_foundation';
import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  vm: IndexVM = new IndexVM();

  aboutToAppear(): void {
    // 拦截
    this.vm.checkSafeAgreed();
    // 初始化
    this.vm.init();
    // 订阅卡片增删
    WidgetUtil.subscribeFormId(getContext());
  }

  build() {
    Navigation(RouterModule.stack) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
  }
}