import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class AddressInfo {
  @Trace id: number = 0
  @Trace name: string = ''
  @Trace cellphone: string = ''
  @Trace province: string = ''
  @Trace city: string = ''
  @Trace area: string = ''
  @Trace detailAddress: string = ''
  @Trace isDefault: boolean = true
}

export class CurrentAppStorage {
  static addressInfo: AddressInfo = AppStorageV2.connect(AddressInfo, () => new AddressInfo())!;

  static reset() {
    CurrentAppStorage.addressInfo = new AddressInfo()
  }
}




