export enum ConfigMap {
  /**
   * 高德Web API Key值
   */
  // todo替换成自己申请的高德Web API Key值
  BUS_STOP_KEY = ''

}

export enum RequestUrlMap {
  /**
   * 公交站关键字查询
   */
  BUS_STOP_NAME_URL = 'https://restapi.amap.com/v3/bus/stopname',

  /**
   * 公交线路关键字查询
   */
  BUS_LINE_NAME_URL = 'https://restapi.amap.com/v3/bus/linename',

  /**
   * 公交线路关键字查询
   */
  BUS_LINE_ID_URL = 'https://restapi.amap.com/v3/bus/lineid',

  /**
   * 公交线路关键字查询
   */
  BUS_SUBWAY_AROUND_URL = 'https://restapi.amap.com/v5/place/around',

  /**
   * 公交线路关键字查询
   */
  BUS_STOP_ID_URL = 'https://restapi.amap.com/v3/bus/stopid',

  /**
   * 公交路线规划
   */
  BUS_SUBWAY_TRANSIT_URL = 'https://restapi.amap.com/v5/direction/transit/integrated',

  /**
   * 步行路线规划
   */
  WALKING_URL = 'https://restapi.amap.com/v5/direction/walking',

  /**
   * 公交线路关键字查询
   */
  BUS_SUBWAY_DISTANCE_URL = 'https://restapi.amap.com/v3/distance',
}

export enum BusSubwayMap {
  /**
   * 公交类型
   */
  BUS_SUBWAY_TYPE_BUS = '0',

  /**
   * 地铁类型
   */
  BUS_SUBWAY_TYPE_SUBWAY = '1',

}