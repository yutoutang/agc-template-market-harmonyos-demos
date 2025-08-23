import { RouterModule } from 'lib_foundation';
import { RouterMap } from 'module_base';

const TAG = 'IndexVM';

@ObservedV2
export class IndexVM {
  @Trace navStack: NavPathStack = RouterModule.stack;

  setInterception() {
    RouterModule.push({ url: RouterMap.SAFE_PAGE })
  }
}
