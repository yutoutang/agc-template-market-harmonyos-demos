import { PackageSpecResp } from './Order';

export interface CommonReq {
  // 商户Id
  storeId: string;

  // 用户Id
  userId: string;

  // 用户OpenID
  openId: string;

  // 用户UnionID。
  unionId: string;

  // 鸿蒙应用包名
  packageName: string;

  // 订单Id
  orderId: string;

  // 商品Id
  goodsId: string;

  // 商品规格字符串
  spec: string;

  // 已选商品规格
  combination: PackageSpecResp[];

  // 抵扣优惠券ID
  couponId: string;

  // 华为登录返回code
  code: string;

  // Id
  id: string;

  // 商品数量
  num: number;

  // 充值金额
  rechargeTierId: string;
}

export interface AddCarReq {
  // 商品单价
  money: number;

  // 商品id
  goodsId: string;

  // 商品数量
  num: number;

  // 商品规格
  specType: number;

  // 已选商品规格字符串
  spec: string;

  // 已选商品规格
  combination: PackageSpecResp[];

  // 商品打包费
  boxMoney: number;
}

export interface GoodsReq {
  // 商品id
  id: string;

  // 商品图片
  img: string;

  // 商品单价
  money: number;

  // 商品名称
  name: string;

  // 商品数量
  num: number;

  // 已选商品规格字符串
  spec: string;

  // 已选商品规格
  combination: PackageSpecResp[];
}

export interface AddDnOrderReq {
  tableId: string, //桌号
  money: number, //订单金额
  discount: string, //优惠金额
  mjMoney: number, //满减金额
  xyhMoney: number, //新人优惠金额
  note: string, //备注
  payType: number, //支付类型 0 华为支付
  sz: string, //购物车列表
  tableware: ResourceStr, //用餐人数
  yhqMoney: number, //优惠券金额
  couponId: string, //抵扣优惠券ID
  orderType: number, //订单使用类型 填写 0 店铺堂食
  boxMoney: number, //打包费
  reductionMoney: number, //优惠金额
  rechargeId?: string, // 充值档次
  preorderTime: string, // 预约时间
  preorderPhone: string, // 预约号码
}


export interface MyOrderReq {
  // 订单状态
  state: Array<number>,

  // 订单页码
  page: number,

  // 订单页大小
  pagesize: number
}