export enum RequestUrl {
  USER_BIND_PHONE = '/api/user/bindPhone',
  USER_CANCEL_PHONE = '/api/user/cancelPhone',
  USER_GET_INFO = '/api/user/getInfo',
  USER_LOGIN = '/api/user/login',
  HOME_RECOMMEND_LIST = '/api/home/getRecommendList',
  ORDER_LIST_INFO = '/api/order/getListInfo',
  ORDER_TICKET_DETAIL = '/api/order/getTicketDetail',
  PERFORMANCE_INFO = '/api/performance/getInfo',
  //  免费约展时间信息
  ORDER_DAY_TICKET = '/api/order/getDayTicket',
  //  讲解服务
  EXPLAIN = '/api/home/getExplain',
  //  省博介绍
  INTRODUCE_TEXT = '/api/home/getIntroduceText',
  //  停车缴费
  PARKING_TEXT = '/api/home/getParkingText',
  //  隐私政策
  PRIVACY_TEXT = '/api/mine/getPrivacyText',
  //  取消订单
  CANCEL_ORDER = '/api/order/cancel',
  //  免费约展
  ORDER_FREE = '/api/order/free',
  //  付费约展时间信息
  BUY_TIME_TICKET = '/api/order/getTimeTicket',
  //   票种信息
  TICKET_TYPE_INFO = '/api/ticket/getTypeInfo',
  //   付费约展预支付
  BUY_TICKET = '/api/ticket/prepay',
  //   更新用户信息
  UPDATE_USERINFO = '/api/user/update',
  //  获取顶部banner图片资源
  BANNER_IMG = '/api/img/getBanner',
  //  交通信息
  TRAFFIC_DETAIL = '/api/traffic/detail',
  //  讲解服务余票信息
  EXPLAIN_TICKET = '/api/explain/ticket',
  //  讲解服务订单
  EXPLAIN_ORDERS='/api/explain/orders',
  //  讲解服务预支付
  EXPLAIN_PREPAY='/api/explain/prepay',
  //  获取珍品信息
  TREASURE_INFO = '/api/treasure',
  //  获取图片资源
  CLOUD_URL = '/api/cloud',
  //  获取活动信息
  ACTIVE_INFO = '/api/active',
  //  活动订单预支付
  ACTIVE_PREPAY = '/api/active/prepay',
  //  获取活动订单
  ACTIVE_ORDERS = '/api/active/orders',
  //  取消活动订单
  CANCEL_ACTIVE_ORDER = '/api/cancel/activeOder',
  //  取消讲解订单
  CANCEL_EXPLAIN_ORDER = '/api/cancel/explainOrder',
  //  重新支付订单
  REPAY_ORDER = '/api/repay/order'
}



