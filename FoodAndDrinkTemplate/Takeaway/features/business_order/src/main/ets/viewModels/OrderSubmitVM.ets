import { BaseViewModel } from 'lib_common';
import {
  AddrMgtApi,
  CarGoodsInfo,
  CouponsServiceApi,
  MessageServiceApi,
  MyCartServiceApi,
  OrderInfo,
  OrderItem,
  OrderServiceApi,
  SubmitOrderItem
} from 'lib_takeaway_api';
import { IAddrInfo } from 'lib_takeaway_api/src/main/ets/database/IAddrType';
import { StoreResponse } from 'lib_takeaway_api/src/main/ets/params/response/StoreResponse';

@ObservedV2
export class OrderSubmitVM extends BaseViewModel {
  @Trace
  submitOrderItem: SubmitOrderItem | undefined = undefined;
  @Trace isLoading: boolean = false;
  @Trace isRefreshing: boolean = false;
  // 店铺信息
  @Trace storeInfo: StoreResponse | undefined = undefined
  // 外卖地址
  @Trace addressInfo: IAddrInfo | undefined = undefined
  // 配送方式
  @Trace receivingMethod: number = 0 //0: 外卖  1: 到店自提
  // 地址
  @Trace address: string = ''
  // 距离
  @Trace distance: number = 0
  // 联系方式
  @Trace phone: string = ''
  // 联系人
  @Trace name: string = ''
  // 外卖配送时间
  @Trace sendTime: string = ''
  // 红包优惠金额
  @Trace couponMoney: number = 0
  // 红包id
  @Trace couponId: string = ''
  // 购物车商品信息
  @Trace goodsInfoList: CarGoodsInfo[] = []
  // 购物车商品id
  @Trace goodsCarIds: string[] = []
  // 运费
  @Trace deliveryFee: number = 0
  // 订单总金额
  @Trace totalPrice: number = 0
  // 订单商品总数量
  @Trace totalNum: number = 0
  // 订单支付金额
  @Trace payMoney: number = 0
  // 支付方式
  @Trace payType: number = 0
  // 订单备注
  @Trace remark: string = ''
  // 是否展示选择地址弹窗
  @Trace isShowAddress: boolean = false;
  // 是否展示送达时间弹窗
  @Trace isShowDeliveryTime: boolean = false;
  // 是否展示红包弹窗
  @Trace isShowCoupon: boolean = false;
  // 是否展示支付弹窗
  @Trace isShowPay: boolean = false;
  // 是否展示备注弹窗
  @Trace isShowRemark: boolean = false;

  /**
   * 创建订单
   */
  createOrder(payType: number, payFlag: boolean, receivingMethod: number) {
    let carGoodsList: CarGoodsInfo[] = JSON.parse(JSON.stringify(this.goodsInfoList));
    let carGoodsIdList: string[] = []
    carGoodsList.forEach((carGoodsInfo: CarGoodsInfo) => {
      carGoodsIdList.push(carGoodsInfo.id)
    })
    let orderInfo: OrderInfo = {
      status: 0,
      orderNo: Date.now().toString(),
      addressInfo: JSON.parse(JSON.stringify(this.addressInfo)),
      orderTime: Date.now(),
      remark: this.remark,
      originalPrice: receivingMethod === 0 ? (this.totalPrice + this.deliveryFee) : this.totalPrice,
      finalPrice: this.payMoney,
      deliveryFee: this.deliveryFee,
      payModel: '',
      discounts: [],
      remainingTime: payFlag ? undefined : Date.now() + 15 * 60 * 1000,
      receivingMethod: receivingMethod,
      deliveryTime: this.receivingMethod === 0 ? this.sendTime === '' ? '尽快送达' : this.sendTime : '',
    }
    if (this.storeInfo) {
      let orderItem: OrderItem = {
        orderInfo: orderInfo,
        logisticInfo: [],
        carGoodsInfo: carGoodsList,
        storeInfo: this.storeInfo,
      }
      if (payFlag) {
        // 支付成功
        orderItem.orderInfo.status = 2
        OrderServiceApi.creatOrder(orderItem)
        MyCartServiceApi.batchDeleteCar(carGoodsIdList)
        MessageServiceApi.addOrderMessage(orderItem.orderInfo, this.userInfoModel)
        orderItem.orderInfo.payModel = '在线支付'
      } else {
        // 支付失败
        OrderServiceApi.creatOrder(orderItem)
        MyCartServiceApi.batchDeleteCar(carGoodsIdList)
        MessageServiceApi.addOrderMessage(orderItem.orderInfo, this.userInfoModel)
      }
      CouponsServiceApi.useCoupons(this.couponId)
    }

  }

  /**
   * 初始化下单页面
   * @param param
   */
  initSubmitOrder(param: SubmitOrderItem) {
    this.receivingMethod = 0
    this.submitOrderItem = param
    this.storeInfo = param.storeInfo
    this.goodsInfoList = param.carGoodsList
    let goodsTotalNum = 0
    let goodsTotalMoney = 0
    let goodsCarIds: string[] = []
    this.couponMoney = 0
    this.couponId = ''
    this.goodsInfoList.forEach((carGoodsInfo: CarGoodsInfo) => {
      goodsTotalNum += carGoodsInfo.num
      goodsTotalMoney += carGoodsInfo.num * carGoodsInfo.money
      goodsCarIds.push(carGoodsInfo.id)
    })
    this.addressInfo = AddrMgtApi.defaultAddress()
    this.phone = this.addressInfo?.cellphone || ''
    this.name = this.addressInfo?.name || ''
    this.address =
      ((this.addressInfo?.province || '') + (this.addressInfo?.city || '') + (this.addressInfo?.area || '') +
        (this.addressInfo?.detailAddress || ''))
    this.deliveryFee = this.storeInfo?.deliveryFee || 0
    this.distance = this.storeInfo?.distance || 0
    this.totalNum = goodsTotalNum
    this.totalPrice = goodsTotalMoney
    this.payMoney = this.totalPrice + (this.storeInfo?.deliveryFee || 0) - this.couponMoney
    this.isShowAddress = false
    this.isShowDeliveryTime = false
    this.isShowCoupon = false
    this.isShowPay = false
  }
}