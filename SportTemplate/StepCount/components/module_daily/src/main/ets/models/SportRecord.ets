/**
 * 每天运动记录（简化版，仅包含 module_daily 需要的字段）
 */
export interface SportRecord {
  //日
  day: number
  //月
  month: number
  //年
  year: number
  //当日总消耗
  totalDeplete: number
  //当日目标
  totalTarget: SportTarget | null
  //当日总距离 单位 米
  totalDistance: number
  //当日总步数
  totalStepCount: number

}

export interface SportTarget {

  //目标距离
  distance: number
  //目标步数
  stepCount: number
  //目标时长
  timeLength: number
  //目标消耗
  deplete: number
}


