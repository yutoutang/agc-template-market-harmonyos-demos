// 用于存储部分图片资源的云存储域名
// todo:替换域名
export const CLOUD_STORAGE_URL = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/cloud-urahf/';

// 请求URL枚举
export enum RequestUrl {
  /**
   * 用户相关
   */
  URL_USER_LOGIN = '/api/user/login',
  URL_USER_INFO = '/api/user/info',
  URL_USER_ASSOCIATE = '/api/user/associate',
  URL_USER_DISASSOCIATE = '/api/user/disassociate',
  /**
   * 用户常用地址
   */
  URL_ADDRESS_GET = '/api/user/address/get',
  URL_ADDRESS_ADD = '/api/user/address/add',
  URL_ADDRESS_UPDATE = '/api/user/address/update',
  URL_ADDRESS_DELETE = '/api/user/address/delete',

  /**
   * 车牌相关
   */
  URL_LICENSE_LIST = '/api/license/list',
  URL_LICENSE_DEFAULT_GET = '/api/license/default',
  URL_LICENSE_DEFAULT_SET = '/api/license/default/set',
  URL_LICENSE_ADD = '/api/license/add',
  URL_LICENSE_DELETE = '/api/license/delete',

  /**
   * 订单相关
   */
  URL_ORDER_QUERY = '/api/order/query',
  URL_ORDER_PAY = '/api/order/pay',
  URL_ORDER_LIST = '/api/order/list',
  URL_ORDER_DELETE = '/api/order/delete',

  /**
   * 首页配置
   */
  URL_BANNER_GET = '/api/common/banner',

  /**
   * 车场信息
   */
  URL_DETAIL_GET = '/api/park/detail',
}


