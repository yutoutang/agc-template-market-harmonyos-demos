import { AddressManageUtil } from 'address_management';
import { iData, WindowUtil } from 'lib_foundation';
import {
  AddressInfo,
  CartItemKey,
  CartPrice,
  DiscountItem,
  OrderApis,
  OrderCreateReq,
  OrderPosition,
  OrderSkuItem,
  PreOrderInfoReq,
  ShippingOption,
  ShoppingCartApis,
} from 'lib_network';
import { OrderUtil } from '../utils/OrderUtil';

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
  };
  @Trace
  city: string = '';
  @Trace
  skuList: OrderSkuItem[] = [];
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
  };
  readonly SHOP_ADDRESS: string = '江苏省南京市XX路';
  readonly SHOP_PHONE: string = '12345678';

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
        };
      }
    });
    OrderApis.getPreOrderInfo(preOrderRequest)
      .then((res) => {
        if (res.code === 0) {
          this.skuList = res.skuList;
          ShoppingCartApis.calcCartPrice({
            isMember: iData.global.userInfo.isMember,
            skuList: this.skuList,
          }).then((res) => {
            if (res.code === 0) {
              this.cartPrice = res.data;
              this.cartPrice.discountList.push({
                type: 2,
                label: '优惠券',
                discountPrice: 0,
              });
            }
          });
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
    };
    const old = this.cartPrice.discountList.find((item) => item.type === 2);
    if (old) {
      old.discountPrice = value;
    } else {
      this.cartPrice.discountList.push(discountItem);
    }
    ShoppingCartApis.calcCartPrice({
      isMember: iData.global.userInfo.isMember,
      skuList: this.skuList,
      extraDiscount: [discountItem],
    }).then((res) => {
      if (res.code === 0) {
        this.cartPrice = res.data;
      }
    });
  }

  async onSubmit() {
    if (!this.preOrderRequest) {
      return;
    }
    if (
      this.shippingIndex === ShippingOption.EXPRESS &&
        (!this.customerName || !this.customerAddress)
    ) {
      WindowUtil.toast('请选择地址');
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
        this.handleOrderCreateSuccess();
        OrderUtil.handleImmediatePayment({
          orderNo: res.orderNo,
          data: res.detail,
        });
      }
    });
  }

  handleOrderCreateSuccess() {
    const codes: CartItemKey[] = [];
    this.preOrderRequest!.items.forEach((item) => {
      codes.push({
        skuCode: item.skuCode,
        priceType: item.priceType,
      });
    });
    ShoppingCartApis.deleteSkuFromCart({
      skuList: codes,
      isRemain: false,
    });
  }
}
