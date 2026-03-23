@ObservedV2
export class FeedbackVM {
  private static _instance: FeedbackVM;
  navPathStack: NavPathStack = new NavPathStack();
  public static get instance() {
    if (!FeedbackVM._instance) {
      FeedbackVM._instance = new FeedbackVM();
    }
    return FeedbackVM._instance;
  }
}