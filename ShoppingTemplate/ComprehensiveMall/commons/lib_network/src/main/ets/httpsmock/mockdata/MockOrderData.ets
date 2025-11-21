import {
  AddressInfo,
  LogisticsItem,
  OrderExpressInfo,
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
  city:'北京市',
  latitude:39.95,
  longitude:116.30
};


const mockLogistic1: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 1,
  desc: '您提交了订单，请等待商家确认',
  time: '2025-03-01 09:00:00',
};

const mockLogistic2: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 2,
  desc: '快递员已取包裹，即将开始运输',
  time: '2025-03-01 17:00:00',
};

const mockLogistic3: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 3,
  desc: '您的包裹正在快马加鞭运输中',
  time: '2025-03-02 10:00:00',
};

const mockLogistic4: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 3,
  desc: '派件交给【华为快递员，联系电话：10000000000】，正在派送途中（如 有任何问题可优先联系我！）',
  time: '2025-03-02 20:00:00',
};

const mockLogistic5: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 4,
  desc: '您的商品已签收，如有疑问请电话联系快递员。',
  time: '2025-03-03 10:00:00',
};

export const mockExpress: OrderExpressInfo = {
  orderId: '',
  expressName: 'XX快递',
  expressNo: 'HW12345678',
  sendPosition: '南京市',
  getPosition: '北京市',
  origins: {
    latitude: 31.975,
    longitude: 118.78,
  },
  destination: {
    latitude: 31.976,
    longitude: 118.86,
  },
  waypoints: [
    { longitude: 118.78, latitude: 31.982 },
    { longitude: 118.79, latitude: 31.985 },
    { longitude: 118.80, latitude: 31.978 },
  ],
}

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
      logisticInfo: [],
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
      logisticInfo: [mockLogistic1],
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
      logisticInfo: [mockLogistic3, mockLogistic2, mockLogistic1],
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
        mockLogistic5,
        mockLogistic4,
        mockLogistic3,
        mockLogistic2,
        mockLogistic1,
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
        mockLogistic5,
        mockLogistic4,
        mockLogistic3,
        mockLogistic2,
        mockLogistic1,
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
        {
          icon: $r('app.media.ic_car'),
          status: 4,
          desc: '您的商品已由本人到店领取。',
          time: '2025-03-03 10:00:00',
        }
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
        mockLogistic5,
        mockLogistic4,
        mockLogistic3,
        mockLogistic2,
        mockLogistic1,
      ],
      skuInfo: [mockSku1],
    },
  ];
  static  DEFAULT_LATITUDE = 31.97;
  static  DEFAULT_LONGITUDE = 118.75;
}
