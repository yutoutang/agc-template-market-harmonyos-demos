export enum RequestUrlMap {
  /**
   * 初始化配置
   */
  COMMON_HOME_CONFIG = 'common/home/config',
  COMMON_CATEGORY_PRODUCT = 'common/category/product',
  /**
   * 商品
   */
  PRODUCT_LIST = 'product/list',
  PRODUCT_COLLECT = 'product/collect',
  PRODUCT_COLLECT_STATUS = 'product/collect/status',
  PRODUCT_COLLECTED_LIST = 'product/collect/list',
  PRODUCT_VIEW_HISTORY = 'product/view-history',
  PRODUCT_VIEW_HISTORY_LIST = 'product/view-history/list',
  /**
   * 订单
   */
  ORDER_PRE_INFO = 'order/pre-info',
  ORDER_LIST = 'order/list',
  ORDER_DETAIL = 'order/detail',
  ORDER_UPDATE = 'order/detail',
  ORDER_DELETE = 'order/detail',
  ORDER_CREATE = 'order/detail',
  ORDER_EXPRESS = 'order/express',
  ORDER_ADD_COMMENT = 'order/comment',
  ORDER_PREPAY = 'order/prepay',
  /**
   * 会员
   */
  USER_POINTS = 'user/points',
  USER_POINTS_DETAIL = 'user/points-detail',
  USER_POINTS_PRODUCT = 'user/points/product-list',
  USER_POINTS_REDEMPTION = 'user/points/product-redemption'
}
