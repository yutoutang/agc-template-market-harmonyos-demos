import { BaseViewModel } from 'commonlib';

@ObservedV2
export class HomeVM extends BaseViewModel {
  private static _instance: HomeVM;
  public static get instance() {
    if (!HomeVM._instance) {
      HomeVM._instance = new HomeVM();
    }
    return HomeVM._instance;
  }
}