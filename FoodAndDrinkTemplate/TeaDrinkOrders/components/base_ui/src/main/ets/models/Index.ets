@ObservedV2
export class MapLocation {
  @Trace id: string = ''
  @Trace title: string = ''
  @Trace icon: string = ''
  @Trace latitude: number = 0
  @Trace longitude: number = 0
}

@ObservedV2
export class PackageSpec {
  @Trace specId?: string = ''
  @Trace specValId?: string = ''
  @Trace specName?: string = ''
  @Trace specLogo?: string = ''
  @Trace specVal?: string = ''
  @Trace specNum?: number = 0
}

@ObservedV2
export class CarGoodsInfo {
  id: string = ''
  goodsId?: string = ''
  logo?: string = ''
  name?: string = ''
  type?: string = ''
  @Trace num: number = 0
  specType?: string = ''
  @Trace spec?: string = ''
  @Trace combination?: PackageSpec[] = []
  money: string = ''
  boxMoney?: string = ''
  number?: string = ''
  isCheck?: boolean = true
}

@ObservedV2
export class GoodsOfOrder {
  id: string = ''
  logo: string = ''
  money: string = ''
  name: string = ''
  num: number = 0
  specType: string = ''
  spec: string = ''
  combination?: PackageSpec[]
}