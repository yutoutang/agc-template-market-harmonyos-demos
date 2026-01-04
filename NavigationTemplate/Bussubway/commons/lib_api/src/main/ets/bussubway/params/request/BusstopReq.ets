export interface BusbaseReq {
  key?: string
}

/**
 * 公交站关键字查询请求
 */
export interface BusstopSearchReq extends BusbaseReq {
  // 关键字
  keywords: string
  // 城市
  city: string
  // 每页记录数据
  offset: number
  // 当前页面
  page: number
}

/**
 * 公交站线路查询请求
 */
export interface BuslineSearchReq extends BusbaseReq {
  // 关键字
  keywords: string
  // 城市
  city: string
  // 每页记录数据
  offset: number
  // 当前页面
  page: number
  // 返回基本+详细信息
  extensions: string
}

/**
 * 公交站线路查询请求
 */
export interface BuslineIdSearchReq extends BusbaseReq {
  // 关键字
  id: string
  // 返回基本+详细信息
  extensions: string
}

/**
 * 公交站线路查询请求
 */
export interface StopIdSearchReq extends BusbaseReq {
  // 关键字
  id: string
}

/**
 * 公交站线路查询请求
 */
export interface BusSubwayAroundReq extends BusbaseReq {
  // 指定地点类型
  types: string
  // 中心点坐标
  location: string
  // 搜索半径
  radius: number
  // 当前分页展示的数据条数
  page_size: number
  // 请求第几分页
  page_num: number
}

/**
 * 公交路线规划API请求
 */
export interface TransitSearchReq extends BusbaseReq {
  // 指定地点类型
  origin: string
  // 中心点坐标
  destination: string
  // 起点所在城市
  city1: string
  // 目的地所在城市
  city2: string
  // 搜索策略
  strategy: number
  // 扩展字段
  show_fields?: string
}

/**
 * 公交路线规划API请求
 */
export interface WorkSearchReq extends BusbaseReq {
  // 指定地点类型
  origin: string
  // 中心点坐标
  destination: string
  // 扩展字段
  show_fields?: string
}

/**
 * 步行距离测量
 */
export interface DistanceSearchReq extends BusbaseReq {
  // 出发点
  origins: string
  // 目的地
  destination: string
  // 路径计算的方式和方法,3：步行规划距离（仅支持5km之间的距离）
  type?: number
}