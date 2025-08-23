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
  @Trace num: number = 0
  specType?: string = ''
  @Trace spec?: string = ''
  @Trace combination?: PackageSpec[] = []
  money: string = ''
}

@ObservedV2
export class MyCar {
  @Trace boxMoney?: number
  @Trace carGoods: Array<CarGoodsInfo> = []
  @Trace num?: number
  @Trace money?: number
}