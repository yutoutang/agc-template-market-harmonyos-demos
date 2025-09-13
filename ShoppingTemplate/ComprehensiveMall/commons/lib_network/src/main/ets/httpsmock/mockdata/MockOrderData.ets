import {
  AddressInfo,
  LogisticsItem,
  OrderItem,
  OrderSkuItem,
} from '../../types/responses/OrderResponse';

const mockSku1: OrderSkuItem = {
  productId: 'product_10001',
  skuCode: 'sku_100001',
  skuDesc: '粉色;160/80A',
  count: 1,
  banner: $r('app.media.mock_spec_pink'),
  title: '时尚轻商务系列针织打底纯羊毛内搭',
  serviceDesc: '运费险｜7天无理由',
  price: 200,
  dashPrice: 200,
};

const mockSku2: OrderSkuItem = {
  productId: 'product_10001',
  skuCode: 'sku_100004',
  skuDesc: '白色;160/80A',
  count: 2,
  banner: $r('app.media.mock_spec_white'),
  title: '时尚轻商务系列针织打底纯羊毛内搭',
  serviceDesc: '运费险｜7天无理由',
  price: 200,
  dashPrice: 200,
};

const mockAddress: AddressInfo = {
  name: '张三',
  cellphone: '12300000000',
  address: '北京市海淀区某小区',
};

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

export class MockOrderData {
  static orderList: OrderItem[] = [
    {
      orderInfo: {
        status: 1, // 已取消
        orderNo: '20231012001',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '尽快发货',
        originalPrice: 200,
        finalPrice: 180,
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
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 2, // 待发货
        orderNo: '20231012002',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        originalPrice: 200,
        finalPrice: 180,
        receivingMethod: 0,
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
      },
      logisticInfo: [],
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 3, // 待收货
        receivingMethod: 0,
        orderNo: '20231012003',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '请尽快配送',
        originalPrice: 200,
        finalPrice: 180,
        discounts: [
          {
            type: 1,
            discountPrice: 20,
          },
        ],
      },
      logisticInfo: [mockLogistic1, mockLogistic2],
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 4, // 待评价
        receivingMethod: 0,
        orderNo: '20231012004',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '请尽快配送',
        originalPrice: 200,
        finalPrice: 180,
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
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 4, // 待评价
        receivingMethod: 0,
        orderNo: '20231112004',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '请尽快配送',
        originalPrice: 600,
        finalPrice: 580,
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
      skuInfo: [mockSku1, mockSku2],
    },
    {
      orderInfo: {
        status: 6, // 退款/售后
        receivingMethod: 1,
        orderNo: '20231012005',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '商品有问题，申请退款',
        originalPrice: 200,
        finalPrice: 180,
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
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 7, // 已退款
        receivingMethod: 1,
        orderNo: '20231012006',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '商品有问题，申请退款',
        originalPrice: 200,
        finalPrice: 180,
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
      skuInfo: [mockSku1],
    },
  ];
}
