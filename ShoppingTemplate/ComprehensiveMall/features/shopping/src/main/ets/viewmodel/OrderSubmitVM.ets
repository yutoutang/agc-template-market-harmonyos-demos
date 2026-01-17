import { UtilLog } from '@hw-agconnect/util-log';
import { AddressManageUtil } from 'address_management';
import { CashierPicker, PaymentType, aggregatedPaymentService } from 'aggregated_payment';
import { iData, RouterMap, routerStack, WindowUtil } from 'lib_foundation';
import {
  AddressInfo,
  OrderApis,
  OrderCreateReq,
  OrderPosition,
  OrderSkuItem,
  PreOrderInfoReq,
} from 'lib_network';
import { CartApi, CartPrice, DiscountItem } from 'module_shopping_cart';
import { ToastDialog as promptAction, ToastDialog } from '@hw-agconnect/ui-toast'
import { ShippingOption } from '../commons/Enums';

@ObservedV2
export class OrderSubmitVM {
  @Trace
  isLoading: boolean = false;
  @Trace
  shippingIndex: ShippingOption = ShippingOption.EXPRESS;
  @Trace
  customerAddress: string = '请填写收件人地址';
  @Trace
  customerName: string = '请填写收件人信息';
  @Trace
  customerPhone: string = '';
  @Trace
  getPosition: OrderPosition = {
    latitude: 0,
    longitude: 0,
  }
  @Trace
  city: string = ''
  @Trace
  skuList: OrderSkuItem[] = [];
  // @Trace
  // totalPrice: number = 0;
  // @Trace
  // discountPrice: number = 0;
  @Trace
  discountId: string = '';
  @Trace
  remark: string = '';
  @Trace
  remarkCache: string = '';
  @Trace
  preOrderRequest: PreOrderInfoReq | undefined = undefined;
  @Trace
  cartPrice: CartPrice = {
    finalPrice: 0,
    originalPrice: 0,
    discountList: [],
  }
  readonly SHOP_ADDRESS: string = '江苏省南京市XX路';
  readonly SHOP_PHONE: string = '12345678';
  cashierPicker: CashierPicker = new CashierPicker(WindowUtil.globalUIContext)
    .onRealPayment(async (type: PaymentType) => {
      await this.startPayment(type)
    })
    .onWillDismiss((reason: DismissReason) => {
      if (reason !== DismissReason.TOUCH_OUTSIDE) {
        this.cashierPicker.close();
      }
    });

  @Computed
  get ShippingLabel() {
    return this.shippingIndex === ShippingOption.EXPRESS
      ? '快递发货'
      : '到店自提';
  }

  @Computed
  get totalProductCount() {
    if (this.skuList.length) {
      return this.skuList.reduce((a, b) => a + b.count, 0);
    }
    return 0;
  }


  async initData(preOrderRequest: PreOrderInfoReq) {
    this.isLoading = true;
    this.preOrderRequest = preOrderRequest;
    AddressManageUtil.getDefaultAddress().then((res) => {
      if (res) {
        this.customerName = res.name;
        this.customerPhone = res.phone;
        this.customerAddress =
          res.province + res.city + res.district + res.street + res.detail;
        this.city = res.city;
        this.getPosition = {
          latitude: res.latitude,
          longitude: res.longitude,
        }
      }
    });
    OrderApis.getPreOrderInfo(preOrderRequest)
      .then((res) => {
        if (res.code === 0) {
          this.skuList = res.skuList;
          CartApi.calcCartPrice({
            isMember: iData.global.userInfo.isMember,
            skuList: this.skuList,
          }).then((res) => {
            this.cartPrice = res
            this.cartPrice.discountList.push({
              type: 2,
              label: '优惠券',
              discountPrice: 0,
            })
          })
        }
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  addCouponDiscount(value: number) {
    const discountItem: DiscountItem = {
      type: 2,
      label: '优惠券',
      discountPrice: value,
    }
    const old = this.cartPrice.discountList.find((item) => item.type === 2)
    if (old) {
      old.discountPrice = value
    } else {
      this.cartPrice.discountList.push(discountItem)
    }
    CartApi.calcCartPrice({
      isMember: iData.global.userInfo.isMember,
      skuList: this.skuList,
      extraDiscount: [discountItem],
    }).then((res) => {
      this.cartPrice = res;
    })
  }

  async onSubmit() {
    if (!this.preOrderRequest) {
      return;
    }
    if (
      this.shippingIndex === ShippingOption.EXPRESS &&
        (!this.customerName || !this.customerAddress)
    ) {
      promptAction.showToast({ message: '请选择地址' });
      return;
    }
    this.createOrder();
  }

  // todo: 创建订单，此处为mock实现
  async createOrder() {
    const addressInfo: AddressInfo =
      this.shippingIndex === ShippingOption.EXPRESS
        ? {
        name: this.customerName,
        cellphone: this.customerPhone,
        address: this.customerAddress,
      }
        : {
        name: this.customerName,
        cellphone: this.SHOP_PHONE,
        address: this.SHOP_ADDRESS,
      };
    addressInfo.latitude = this.getPosition.latitude;
    addressInfo.longitude = this.getPosition.longitude;
    addressInfo.city = this.city;
    const data: OrderCreateReq = {
      skuList: this.skuList,
      orderInfo: {
        addressInfo,
        remark: this.remark,
        originalPrice: this.cartPrice.originalPrice,
        finalPrice: this.cartPrice.finalPrice,
        receivingMethod: this.shippingIndex,
        discounts: this.cartPrice.discountList,
      },
    };
    OrderApis.createOrder(data).then((res) => {
      if (res.code === 0) {
        this.cashierPicker
          .reset()
          .setAmount(this.cartPrice.finalPrice * 100)
          .open()

        aggregatedPaymentService.registerPaymentCallback(
          (type: PaymentType, isSuccess: boolean) => {
            if (!isSuccess) {
              ToastDialog.showToast({ message: '本地调试阶段，模拟支付成功回调' })
            }
            this.handlePaymentSuccess(res.orderNo)
            this.cashierPicker.close()
          },
        );
      }
    });
  }

  async startPayment(type: PaymentType) {
    // todo: 根据支付类型向服务器请求支付所需参数
    try {
      if (type === PaymentType.ALIPAY) {
        /**
         * 请求拉起支付宝
         *
         * 临时测试时，orderInfo 不推荐传入空字符串，这会导致跳转至支付宝行为仅仅是跳转，不会有支付相关的交互
         * 未安装支付宝且参数真实时，SDK 会尝试使用 this.navPathStack 跳转至 H5 页面继续支付，该参数可不传
         */
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: 'ORDER_INFO' }, routerStack);
      } else if (type === PaymentType.HUAWEI) {
        /**
         * 请求拉起华为支付
         */
        aggregatedPaymentService.requestPaymentByHuawei(WindowUtil.globalUIContext, { orderStr: '' });
      } else if (type === PaymentType.WECHAT) {
        /**
         * 请求拉起微信支付
         *
         * 微信支持获取拉起结果，如果拉起成功，则可以进一步尝试等待支付回调。如果拉起失败，则不会有支付回调。
         */
        const isWeChatOpenSuccess: boolean =
          await aggregatedPaymentService.requestPaymentByWeChat(WindowUtil.globalUIContext, {
            partnerId: '',
            prepayId: '',
            nonceStr: '',
            timeStamp: '',
            sign: '',
          });
        if (!isWeChatOpenSuccess) {
          ToastDialog.showToast({ message: '微信拉起失败' });
        }
      }
    } catch (err) {
      UtilLog.error('[OrderSubmitVM]', 'start payment failed. error: ' + JSON.stringify(err))
    }
  }

  handlePaymentSuccess(orderNo: string) {
    const codes: string[] = [];
    this.preOrderRequest!.items.forEach((item) => {
      codes.push(item.skuCode);
    });
    CartApi.deleteSkuFromCart({
      skuList: codes,
      isRemain: false,
    });
    routerStack.replacePathByName(RouterMap.ORDER_INFO, orderNo);
  }
}
