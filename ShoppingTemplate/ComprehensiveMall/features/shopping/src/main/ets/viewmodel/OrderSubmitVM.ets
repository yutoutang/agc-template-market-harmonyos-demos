import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { paymentService } from '@kit.PaymentKit';
import { RouterMap, routerStack } from 'lib_foundation';
import {
  AddressInfo,
  OrderApis,
  OrderCreateReq,
  OrderPosition,
  OrderSkuItem,
  PreOrderInfoReq,
} from 'lib_network';
import { getDefaultAddress } from 'module_address_manage';
import { CartApi } from 'module_shopping_cart';
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
  city:string = ''
  @Trace
  skuList: OrderSkuItem[] = [];
  @Trace
  totalPrice: number = 0;
  @Trace
  discountPrice: number = 0;
  @Trace
  discountId: string = '';
  @Trace
  remark: string = '';
  @Trace
  remarkCache: string = '';
  @Trace
  preOrderRequest: PreOrderInfoReq | undefined = undefined;
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

  @Computed
  get totalDashPrice() {
    if (this.skuList.length) {
      return this.skuList.reduce((a, b) => a + b.dashPrice * b.count, 0);
    }
    return 0;
  }

  @Computed
  get finalPrice() {
    return this.totalPrice - this.discountPrice;
  }

  async initData(preOrderRequest: PreOrderInfoReq) {
    this.isLoading = true;
    this.preOrderRequest = preOrderRequest;
    getDefaultAddress().then((res) => {
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
          this.totalPrice = res.totalPrice;
        }
      })
      .finally(() => {
        this.isLoading = false;
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
        originalPrice: this.totalPrice,
        finalPrice: this.finalPrice,
        receivingMethod: this.shippingIndex,
        discounts: [
          {
            type: 0,
            discountPrice: this.discountPrice,
          },
        ],
      },
    };
    OrderApis.createOrder(data).then((res) => {
      if (res.code === 0) {
        paymentService
          .requestPayment(getContext() as common.UIAbilityContext, res.orderStr)
          .then(() => {
          })
          .catch(() => {
          })
          .finally(() => {
            const codes: string[] = [];
            this.preOrderRequest!.items.forEach((item) => {
              codes.push(item.skuCode);
            });
            CartApi.deleteCartProduct(codes, false);
            routerStack.replacePathByName(RouterMap.ORDER_INFO, res.orderNo);
          });
      }
    });
  }
}
