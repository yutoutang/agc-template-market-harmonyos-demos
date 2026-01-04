/**
 * 公交线路状态枚举
 */
export enum BusLineStatus {
  /**
   * 等待发车
   */
  WAITING = 'waiting',

  /**
   * 运行中
   */
  RUNNING = 'running',

  /**
   * 即将到站
   */
  ARRIVING = 'arriving',

  /**
   * 已到站
   */
  ARRIVED = 'arrived'
}

/**
 * 站点类型枚举
 */
export enum StopType {
  /**
   * 公交站
   */
  BUS_STOP = 'bus_stop',

  /**
   * 地铁站
   */
  SUBWAY_STATION = 'subway_station'
}

/**
 * 地铁线路状态枚举
 */
export enum SubwayLineStatus {
  /**
   * 正常运行
   */
  NORMAL = 'normal',

  /**
   * 延误
   */
  DELAYED = 'delayed',

  /**
   * 停运
   */
  SUSPENDED = 'suspended',

  /**
   * 维护中
   */
  MAINTENANCE = 'maintenance'
}

export enum MapChooseType {
  TARGET = 'target',
  ORIGIN = 'origin'
}
