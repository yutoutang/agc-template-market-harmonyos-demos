import { BaseViewModel } from 'commonlib';

@ObservedV2
export class TopicVM extends BaseViewModel {
  private static _instance: TopicVM;

  public static get instance() {
    if (!TopicVM._instance) {
      TopicVM._instance = new TopicVM();
    }
    return TopicVM._instance;
  }
}