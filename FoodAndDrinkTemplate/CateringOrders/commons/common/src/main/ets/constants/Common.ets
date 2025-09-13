export class Constants {
  // 接口请求超时时间
  static readonly REQUEST_TIME_OUT = 3 * 1000
  static readonly FULL_SIZE = '100%'
  // 用户授权成功
  static readonly USER_GRANT_SUCCESS = 0
  // 必选品
  static readonly GOODS_MUST = 1
  // 店铺休息
  static readonly STORE_REST = 1
  // 优惠券领取状态 5 已领取
  static readonly COUPON_STATE_COLLECT = '5'
  // 页面边距
  static readonly BORDER_WIDTH = 16
  static readonly GOOD_TYPE_HOT = '1'
  static readonly RICH_TEXT_URI = 'resource://rawfile/richtext.html'
  static readonly MID_DAY_TIME = '12:00'
}

export class CommonUrl {
  // todo mock图片url前缀，真实图片地址可以按业务需求指定
  static readonly CLOUD_STORAGE_URL = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/test-1pvkp/'
}

export enum StoreType {
  SCAN_TYPE = 1,
  PICK_NUM_TYPE
}

export enum PayType {
  HUAWEI_PAY = 1,
  WALLET,
}

// 订单状态
export enum DnState {
  // 全部
  ALL = 0,
  // 待支付
  TO_BE_PAID = 1,
  // 已完成
  COMPLETED = 2,
  // 已取消
  CANCELED = 3,
}

// 订单列表tab
export enum OrderListEnum {
  // 全部
  ALL = 0,
  // 待支付
  TO_BE_PAID,
  // 已完成
  COMPLETED,
  // 已取消
  CANCELED,
}

// 商品类别
export enum GoodsSpecEnum {
  // 正常
  NORMAL = 1,
  // 选规格
  SPEC_TYPE = 2,
  // 选套餐
  PACKAGE_TYPE = 3,
}

// 订单类型
export enum OrderTypeEnum {
  // 到店自取
  PICK_SELF = 0,
  // 外卖配送
  TAKEAWAY_DELIVERY = 1,
}

// 订单详情行枚举
export enum OrderDetailRowEnum {
  XYH_MONEY = 0,
  MJ_MONEY,
  YHQ_MONEY,
  BOX_MONEY,
  PAY_TYPE,
  REAL_PAY,
  ORDER_TIME,
  ORDER_ID,
  TABLE_INFO,
  ORDER_TYPE,
  TABLEWARE,
  REMARK,
}

// 订单状态
export enum OrderStateEnum {
  All = 0,
  noFinished,
  finished,
  AfterSales
}

export enum RouterMap {
  //  首页
  HOME_PAGE = 'HomePage',
  // 点餐页面
  ORDER_PAGE = 'OrderPage',
  // 商户信息
  MERCHANT_DETAIL_PAGE = 'MerchantDetailPage',
  //  菜品详情
  GOODS_DETAIL_PAGE = 'GoodsDetailPage',
  // 确认订单
  CONFIRM_ORDER_PAGE = 'ConfirmOrderPage',
  // 常见问题
  FREQUENT_QUESTION_PAGE = 'FrequentQuestionPage',
  // 订单详情
  ORDER_DETAIL_PAGE = 'OrderDetailPage',
  // 商户位置地图
  HW_MAP_PAGE = 'HwMapPage',
  // 问题详情
  ANSWER_PAGE = 'AnswerPage',
  // 选择优惠券
  SELECT_COUPON_PAGE = 'SelectCouponPage',
  // 我的优惠券
  MY_COUPONS_PAGE = 'MyCouponsPage',
  // 订单备注页面
  REMARKS_PAGE = 'RemarksPage',
  // 图片预览
  PREVIEW_IMAGE_PAGE = 'PreviewImagePage',
  // 选择商户
  SELECT_STORE_PAGE = 'SelectStorePage',
  // 超值加购
  SNACK_SIZED_DEAL_PAGE = 'SnackSizedDealPage',
  // 我的钱包
  MY_WALLET_PAGE = 'MyWalletPage',
  // 超值加购
  RECHARGE_RECORD_PAGE = 'RechargeRecordPage',
  // 储值协议
  WALLET_TERMS_PAGE = 'WalletTermsPage',
  // 确认弹窗
  CONFIRM_DIALOG = 'CommonConfirmDialog',
}