/**
 * 导航实时位置
 */
@ObservedV2
export class RealTimeLatLng {
  /**
   * 实时位置段索引
   */
  @Trace segmentIndex?: number
  /**
   * 实时位置段类型 working、bus
   */
  @Trace segmentType?: string
  /**
   *实时位置经度
   */
  longitude?: number
  /**
   *  实时位置纬度
   */
  latitude?: number
}