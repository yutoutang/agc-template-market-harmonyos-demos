import { BaseViewModel } from 'commonlib';

@ObservedV2
export class MineVM extends BaseViewModel {
  private static _instance: MineVM;
  public static get instance() {
    if (!MineVM._instance) {
      MineVM._instance = new MineVM();
    }
    return MineVM._instance;
  }
}