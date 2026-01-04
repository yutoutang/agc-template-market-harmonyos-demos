import { CarGoodsInfo } from '../../params/response/GoodsResponse';
import { StoreResponse } from '../../params/response/StoreResponse';
import { LogisticsItem, OrderItem } from '../../params/response/OrderResponse';
import { AddrMgtApi } from '../AddrMgtService';
import { MockStore } from './MockStore';


export const mockStore1: StoreResponse = MockStore.storeList[0]

export const mockStore2: StoreResponse = MockStore.storeList[1]


const mockLogistic1: LogisticsItem = {
  icon: 'app://dev/media/icon/ic_car.svg',
  status: 1,
  desc: '您提交了订单，请等待系统确认',
  time: '2025-03-01 09:00:00',
};

const mockLogistic2: LogisticsItem = {
  icon: 'app://dev/media/icon/ic_car.svg',
  status: 2,
  desc: '您的订单已发货',
  time: '2025-03-01 09:05:00',
};

const mockLogistic3: LogisticsItem = {
  icon: 'app://dev/media/icon/ic_car.svg',
  status: 3,
  desc: '预计XX月XX日送达',
  time: '2025-03-01 10:00:00',
};

const mockLogistic4: LogisticsItem = {
  icon: 'app://dev/media/icon/ic_car.svg',
  status: 4,
  desc: '您的商品已签收',
  time: '2025-03-02 10:00:00',
};
const cardGoodsInfo1: CarGoodsInfo = {
  id: '001',
  goodsId: '1',
  name: '圆形面包',
  logo: 'CateringOrderTemplate/good_logo1.png',
  num: 1,
  specType: 2,
  spec: '植物奶油/蔗糖/9寸',
  combination: [],
  discount: '',
  money: 16.4,
  money2: 16.4,
  boxMoney: 1,
  isMust: 0,
  isCheck: false
};

const cardGoodsInfo2: CarGoodsInfo = {
  id: '002',
  name: '冰橙美式咖啡',
  logo: 'CateringOrderTemplate/good_logo2.png',
  money: 25,
  money2: 25,
  specType: 1,
  num: 1,
  isMust: 0,
  boxMoney: 1,
  discount: '',
  goodsId: '2',
  spec: '',
  combination: [],
  isCheck: false
};

export class MockOrderData {
  static orderList: OrderItem[] = [
    {
      orderInfo: {
        status: 1, // 已取消
        orderNo: '20231012001',
        addressInfo: AddrMgtApi.getAddressMock(),
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '尽快发货',
        originalPrice: 21.4,
        finalPrice: 21.4,
        deliveryFee: 5.0,
        payModel: '华为支付',
        deliveryTime: '2023-10-12 10:20:00',
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
        refundTime: '2023-10-13 10:00:00',
        receivingMethod: 0,
      },
      logisticInfo: [
        mockLogistic1,
        mockLogistic2,
        mockLogistic3,
        mockLogistic4,
      ],
      carGoodsInfo: [cardGoodsInfo1],
      storeInfo: mockStore1,
    },
    {
      orderInfo: {
        status: 2, // 待发货
        orderNo: '20231012002',
        addressInfo: AddrMgtApi.getAddressMock(),
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        originalPrice: 46.4,
        finalPrice: 46.4,
        deliveryFee: 5.0,
        receivingMethod: 0,
        payModel: '支付宝支付',
        deliveryTime: '2023-10-12 10:20:00',
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
      },
      logisticInfo: [],
      carGoodsInfo: [cardGoodsInfo1, cardGoodsInfo2],
      storeInfo: mockStore1
    },
    {
      orderInfo: {
        status: 3, // 待收货
        receivingMethod: 0,
        orderNo: '20231012003',
        addressInfo: AddrMgtApi.getAddressMock(),
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '请尽快配送',
        originalPrice: 46.4,
        finalPrice: 46.4,
        deliveryFee: 5.0,
        payModel: '微信支付',
        deliveryTime: '2023-10-12 10:20:00',
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
      },
      logisticInfo: [mockLogistic1, mockLogistic2],
      carGoodsInfo: [cardGoodsInfo1],
      storeInfo: mockStore1
    },
    {
      orderInfo: {
        status: 4, // 待评价
        receivingMethod: 0,
        orderNo: '20231012004',
        addressInfo: AddrMgtApi.getAddressMock(),
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '请尽快配送',
        originalPrice: 46.4,
        finalPrice: 46.4,
        deliveryFee: 5.0,
        payModel: '微信支付',
        deliveryTime: '2023-10-12 10:20:00',
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
      },
      logisticInfo: [
        mockLogistic1,
        mockLogistic2,
        mockLogistic3,
        mockLogistic4,
      ],
      carGoodsInfo: [cardGoodsInfo1, cardGoodsInfo2],
      storeInfo: mockStore1
    },
    {
      orderInfo: {
        status: 4, // 待评价
        receivingMethod: 0,
        orderNo: '20231112004',
        addressInfo: AddrMgtApi.getAddressMock(),
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '请尽快配送',
        originalPrice: 21.4,
        finalPrice: 21.4,
        deliveryTime: '2023-10-12 10:20:00',
        deliveryFee: 5.0,
        payModel: '微信支付',
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
      },
      logisticInfo: [
        mockLogistic1,
        mockLogistic2,
        mockLogistic3,
        mockLogistic4,
      ],
      carGoodsInfo: [cardGoodsInfo1],
      storeInfo: mockStore2
    },
    {
      orderInfo: {
        status: 6, // 退款/售后
        receivingMethod: 1,
        orderNo: '20231012005',
        addressInfo: AddrMgtApi.getAddressMock(),
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '商品有问题，申请退款',
        originalPrice: 46.4,
        finalPrice: 46.4,
        deliveryFee: 5.0,
        payModel: '微信支付',
        deliveryTime: '2023-10-12 10:20:00',
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
        refundTime: '2023-10-13 10:00:00',
      },
      logisticInfo: [
        mockLogistic1,
        mockLogistic2,
        mockLogistic3,
        mockLogistic4,
      ],
      carGoodsInfo: [cardGoodsInfo1, cardGoodsInfo2],
      storeInfo: mockStore2
    },
    {
      orderInfo: {
        status: 7, // 已退款
        receivingMethod: 1,
        orderNo: '20231012006',
        addressInfo: AddrMgtApi.getAddressMock(),
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '商品有问题，申请退款',
        originalPrice: 21.4,
        finalPrice: 21.4,
        deliveryFee: 4.0,
        payModel: '微信支付',
        deliveryTime: '2023-10-12 10:20:00',
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
        refundTime: '2023-10-13 10:00:00',
      },
      logisticInfo: [
        mockLogistic1,
        mockLogistic2,
        mockLogistic3,
        mockLogistic4,
      ],
      carGoodsInfo: [cardGoodsInfo1],
      storeInfo: mockStore2
    },
    {
      orderInfo: {
        status: 0, // 待付款
        orderNo: '20231012011',
        addressInfo: AddrMgtApi.getAddressMock(),
        orderTime: Date.now(), // 2023-10-12 00:00:00
        remark: '尽快发货',
        originalPrice: 16.4,
        finalPrice: 16.4,
        deliveryFee: 0.0,
        deliveryTime: '2023-10-12 10:20:00',
        payModel: '微信支付',
        remainingTime: Date.now() + 15 * 60 * 1000,
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
        refundTime: '2023-10-13 10:00:00',
        receivingMethod: 0,
      },
      logisticInfo: [
        mockLogistic1,
        mockLogistic2,
        mockLogistic3,
        mockLogistic4,
      ],
      carGoodsInfo: [cardGoodsInfo1],
      storeInfo: mockStore1,
    },
  ];
}
