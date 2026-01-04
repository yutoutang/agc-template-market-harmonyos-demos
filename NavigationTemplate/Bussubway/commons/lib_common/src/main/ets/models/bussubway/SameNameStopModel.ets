/**
 * 同名站点模型
 */
@ObservedV2
export class SameNameStopModel {
  // 站点Id
  @Trace id?: string
  // 站点名称
  @Trace name?: string
  // 站点经纬度
  @Trace location?: string
  // 同名站点
  @Trace sameNameStopList: SameNameStop[] = []
}

/**
 * 同名站点
 */
@ObservedV2
export class SameNameStop {
  // 同名站点经纬度
  @Trace location?: string
  // 同名站点经纬度
  @Trace sameNameStopLineList: SameNameStopLine[] = []
}

/**
 * 同名站点路线
 */
@ObservedV2
export class SameNameStopLine {
  // 同名站点经纬度
  @Trace id?: string
  // 始发站
  @Trace start_stop?: string
  // 终点站
  @Trace end_stop?: string
  // 线路名称
  @Trace name?: string
}