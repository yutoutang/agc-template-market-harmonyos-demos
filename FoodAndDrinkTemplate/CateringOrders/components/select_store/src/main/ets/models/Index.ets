@ObservedV2
export class MapLocation {
  @Trace id: string = ''
  @Trace title: string = ''
  @Trace icon: string = ''
  @Trace latitude: number = 0
  @Trace longitude: number = 0
}


@ObservedV2
export class StoreInfo {
  id: string = ''
  @Trace name: string = ''
  address: string = ''
  // 营业开始时间
  time1: string = ''
  // 营业结束时间
  time2: string = ''
  // 电话
  tel: string = ''
  @Trace logo: string = ''
  // 位置坐标
  coordinates: string = ''
  // 距离
  @Trace distance: number = 0
  @Trace distanceStr: string = ''
}