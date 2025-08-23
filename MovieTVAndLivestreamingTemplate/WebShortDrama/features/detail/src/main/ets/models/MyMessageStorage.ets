@ObservedV2
export class MyMessageStorage {
  static singleton: MyMessageStorage;

  static instance() {
    if (!MyMessageStorage.singleton) {
      MyMessageStorage.singleton = new MyMessageStorage();
    }
    ;
    return MyMessageStorage.singleton;
  }

  @Trace isShowCommentSheet: boolean = false
  @Trace scrollIndex: number = 0
  @Trace moreList: Array<number> = []
  @Trace isSpread: boolean = false
  @Trace showFlag: boolean = false
}