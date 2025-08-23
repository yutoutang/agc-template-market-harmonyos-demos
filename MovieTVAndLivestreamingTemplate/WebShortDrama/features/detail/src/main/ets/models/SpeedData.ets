@ObservedV2
export class MyStorage {
  static singleton_: MyStorage;
  static instance() {
    if(!MyStorage.singleton_) {
      MyStorage.singleton_ = new MyStorage();
    };
    return MyStorage.singleton_;
  }
  @Trace selectSpeed: string = '1.0x'
}

export const speeds: Array<string> = ['0.5x', '1.0x', '1.25x', '1.5x', '2.0x']

export const reverseSpeed: Array<string> = ['2.0x', '1.5x', '1.25x', '1.0x', '0.5x']

export const speedArr: Array<number> = [5, 1, 2, 6, 4]; //['0.5x', '1.0x', '1.25x', '1.5x', '2.0x']对应的数字