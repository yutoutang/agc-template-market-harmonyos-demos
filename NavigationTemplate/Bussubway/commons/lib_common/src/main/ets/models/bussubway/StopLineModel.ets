import { HashSet } from '@kit.ArkTS'

/**
 * 公交地铁基础类
 */
@ObservedV2
export class StopLineBase {
  // 公交地铁类型
  @Trace busSubwayType?: string
  // 站点线路Id
  @Trace id?: string
  // 站点线路名称
  @Trace name?: string
  // 线路经纬度
  @Trace polyline?: string
}

/**
 * 站点模型
 */
@ObservedV2
export class StopModel extends StopLineBase {
  // 坐标
  @Trace location?: string
  @Trace buslines?: Busline[]
}

/**
 * 站点线路
 */
@ObservedV2
export class Busline {
  // 公交地铁类型
  @Trace busSubwayType?: string
  // 线路ID
  @Trace id?: string
  // 坐标
  @Trace location?: string
  // 线路名称
  @Trace name?: string
  // 线路经纬度
  @Trace polyline?: string
  // 始发站
  @Trace startStop?: string
  // 终点站
  @Trace endStop?: string
  // 首班车时间
  @Trace startTime?: string
  // 末班车时间
  @Trace endTime?: string
  // 反向线路 id
  @Trace direc?: string
  // 起步价
  @Trace basicPrice?: string
  // 全程票价
  @Trace totalPrice?: string
  // 发车间隔
  @Trace interval?: string
  // 途径站
  @Trace busstops?: Busstop[]
  // 颜色
  @Trace color?: string
}

/**
 * 线路模型
 */
@ObservedV2
export class LineModel extends StopLineBase {
  // 首发站
  @Trace startStop?: string
  // 末站
  @Trace endStop?: string
  // 首班车时间
  @Trace startTime?: string
  // 末班车时间
  @Trace endTime?: string
  // 颜色
  @Trace uicolor?: string
  // 反向线路 id
  @Trace direc?: string
  // 起步价
  @Trace basicPrice?: string
  // 全程票价
  @Trace totalPrice?: string
  // 途径站
  @Trace busstops?: Busstop[]
  // 发车间隔
  @Trace interval?: string
}

/**
 * 站点线路
 */
@ObservedV2
export class Busstop {
  // 公交站名
  @Trace id?: string
  // 公交站名
  @Trace name?: string
  // 公交站经纬度
  @Trace location?: string
  // 换乘线路名称
  @Trace transferLines?: TransferLine[]
}

/**
 * 换乘线路
 */
@ObservedV2
export class TransferLine {
  // 名称
  @Trace name?: string
  // 颜色
  @Trace color?: string
}
