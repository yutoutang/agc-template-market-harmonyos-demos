import { ReviewMediaType } from '../commons/Enums';
import { ProductInfo, ProductReviewItem } from '../commons/Types';

export const PRODUCT_ITEM1: ProductInfo = {
  id: 'product_10001',
  banners: [
    $r('app.media.mock_spec_pink'),
    $r('app.media.mock_spec_white'),
    $r('app.media.mock_spec_yellow'),
  ],
  price: '188',
  dashPrice: '200',
  sales: '已售 3000+',
  title: '时尚轻商务系列针织打底纯羊毛内搭',
  tags: ['退货包邮费最高减￥5'],
  logistics: [
    {
      icon: $r('app.media.ic_truck'),
      content: '48小时内发货 | 免运费',
    },
  ],
  service: [{ icon: $r('app.media.ic_heart'), content: '运费险｜7天无理由' }],
  pictures: [
    $r('app.media.mock_spec_pink'),
    $r('app.media.mock_spec_white'),
    $r('app.media.mock_spec_yellow'),
    $r('app.media.mock_spec_green'),
  ],
  selectionInfo: {
    defaultBanner: $r('app.media.mock_spec_pink'),
    basicPrice: '188',
    priceRange: '188-200',
    priceRemark: '实付',
    totalPriceRemark: '共实付',
    services: ['运费险｜7天无理由', '48小时内发货'],
    skuItems: [
      {
        skuCode: 'sku_100001',
        specs: { 'size': 'uuid_160_80A', 'color': 'uuid_pink' },
        stock: 10,
        price: 188,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100002',
        specs: { 'size': 'uuid_165_84A', 'color': 'uuid_pink' },
        stock: 10,
        price: 188,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100003',
        specs: { 'size': 'uuid_170_88A', 'color': 'uuid_pink' },
        stock: 10,
        price: 188,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100004',
        specs: { 'size': 'uuid_160_80A', 'color': 'uuid_white' },
        stock: 10,
        price: 200,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100005',
        specs: { 'size': 'uuid_165_84A', 'color': 'uuid_white' },
        stock: 0,
        price: 200,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100006',
        specs: { 'size': 'uuid_170_88A', 'color': 'uuid_white' },
        stock: 0,
        price: 200,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100007',
        specs: { 'size': 'uuid_160_80A', 'color': 'uuid_stripe' },
        stock: 0,
        price: 200,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100008',
        specs: { 'size': 'uuid_165_84A', 'color': 'uuid_stripe' },
        stock: 0,
        price: 200,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100009',
        specs: { 'size': 'uuid_170_88A', 'color': 'uuid_stripe' },
        stock: 0,
        price: 200,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100010',
        specs: { 'size': 'uuid_160_80A', 'color': 'uuid_green' },
        stock: 0,
        price: 200,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100011',
        specs: { 'size': 'uuid_165_84A', 'color': 'uuid_green' },
        stock: 0,
        price: 200,
        dashPrice: 200,
      },
      {
        skuCode: 'sku_100012',
        specs: { 'size': 'uuid_170_88A', 'color': 'uuid_green' },
        stock: 0,
        price: 200,
        dashPrice: 200,
      },
    ],
    specOptions: [
      {
        key: 'size',
        label: '尺码',
        values: [
          { id: 'uuid_160_80A', text: '160/80A' },
          { id: 'uuid_165_84A', text: '165/84A' },
          { id: 'uuid_170_88A', text: '170/88A' },
        ],
      },
    ],
    specOptionWithImage: {
      key: 'color',
      label: '颜色',
      values: [
        {
          id: 'uuid_pink',
          text: '粉色',
          image: $r('app.media.mock_spec_pink'),
        },
        {
          id: 'uuid_white',
          text: '白色',
          image: $r('app.media.mock_spec_white'),
        },
        {
          id: 'uuid_stripe',
          text: '黄色',
          image: $r('app.media.mock_spec_yellow'),
        },
        {
          id: 'uuid_green',
          text: '绿色',
          image: $r('app.media.mock_spec_green'),
        },
      ],
    },
  },
};

export const PRODUCT_ITEM2: ProductInfo = {
  id: 'product_20001',
  banners: [],
  price: '98',
  dashPrice: '128',
  sales: '已售 5000+',
  title: '休闲简约经典商务衬衫T恤日系风高级感',
  tags: ['7天无理由'],
  logistics: [
    { icon: $r('app.media.ic_truck'), content: '24小时发货' },
  ],
  service: [{ icon: $r('app.media.ic_heart'), content: '运费险｜7天无理由' }],
  pictures: [
    $r('app.media.mock2_spec_white'),
    $r('app.media.mock2_spec_shirt'),
    $r('app.media.mock2_spec_blue'),
    $r('app.media.mock2_spec_black'),
  ],
  selectionInfo: {
    defaultBanner: $r('app.media.mock2_spec_white'),
    basicPrice: '98',
    priceRange: '98-128',
    priceRemark: '实付',
    totalPriceRemark: '共实付',
    services: ['运费险｜7天无理由', '48小时内发货'],
    skuItems: [
      {
        skuCode: 'sku_200001',
        specs: { 'size': 'S', 'color': 'uuid_black' },
        stock: 10,
        price: 98,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200002',
        specs: { 'size': 'M', 'color': 'uuid_black' },
        stock: 10,
        price: 98,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200003',
        specs: { 'size': 'L', 'color': 'uuid_black' },
        stock: 10,
        price: 98,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200004',
        specs: { 'size': 'S', 'color': 'uuid_white' },
        stock: 10,
        price: 128,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200005',
        specs: { 'size': 'M', 'color': 'uuid_white' },
        stock: 0,
        price: 128,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200006',
        specs: { 'size': 'L', 'color': 'uuid_white' },
        stock: 0,
        price: 128,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200007',
        specs: { 'size': 'S', 'color': 'uuid_blue' },
        stock: 0,
        price: 128,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200008',
        specs: { 'size': 'M', 'color': 'uuid_blue' },
        stock: 10,
        price: 128,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200009',
        specs: { 'size': 'L', 'color': 'uuid_blue' },
        stock: 0,
        price: 128,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200010',
        specs: { 'size': 'S', 'color': 'uuid_shirt' },
        stock: 0,
        price: 128,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200011',
        specs: { 'size': 'M', 'color': 'uuid_shirt' },
        stock: 0,
        price: 128,
        dashPrice: 128,
      },
      {
        skuCode: 'sku_200012',
        specs: { 'size': 'L', 'color': 'uuid_shirt' },
        stock: 0,
        price: 128,
        dashPrice: 128,
      },
    ],
    specOptions: [
      {
        key: 'size',
        label: '尺码',
        values: [
          { id: 'S', text: 'S' },
          { id: 'M', text: 'M' },
          { id: 'L', text: 'L' },
        ],
      },
    ],
    specOptionWithImage: {
      key: 'color',
      label: '颜色',
      values: [
        {
          id: 'uuid_black',
          text: '黑色',
          image: $r('app.media.mock2_spec_black'),
        },
        {
          id: 'uuid_white',
          text: '白色',
          image: $r('app.media.mock2_spec_white'),
        },
        {
          id: 'uuid_blue',
          text: '浅蓝色长袖',
          image: $r('app.media.mock2_spec_blue'),
        },
        {
          id: 'uuid_shirt',
          text: '深蓝色长袖',
          image: $r('app.media.mock2_spec_shirt'),
        },
      ],
    },
  },
};

export function getProductListMock(): ProductInfo[] {
  let arr: ProductInfo[] = [];
  for (let index = 0; index < 8; index++) {
    const element = JSON.parse(JSON.stringify(PRODUCT_ITEM1)) as ProductInfo;
    element.id = `product_1000${index + 1}`;
    const bannerList: ResourceStr[] = [
      $r('app.media.mock_spec_pink'),
      $r('app.media.mock_spec_white'),
      $r('app.media.mock_spec_yellow'),
      $r('app.media.mock_spec_green'),
    ];
    const first = bannerList.splice(index % 4, 1);
    bannerList.unshift(...first);
    element.banners = bannerList;
    arr.push(element);
  }
  for (let index = 0; index < 8; index++) {
    const element = JSON.parse(JSON.stringify(PRODUCT_ITEM2)) as ProductInfo;
    element.id = `product_2000${index + 1}`;
    const bannerList: ResourceStr[] = [
      $r('app.media.mock2_spec_black'),
      $r('app.media.mock2_spec_blue'),
      $r('app.media.mock2_spec_shirt'),
      $r('app.media.mock2_spec_white'),
    ];
    const first = bannerList.splice(index % 4, 1);
    bannerList.unshift(...first);
    element.banners = bannerList;
    arr.push(element);
  }
  return arr;
}

export const REVIEW_ITEM_MOCK1: ProductReviewItem = {
  productId: 'product_10001',
  userAvatar: $r('app.media.ic_default_avatar'),
  userName: '张**',
  skuCode: 'sku_100012',
  skuDesc: ['170/88A', '绿色'],
  rating: 5,
  date: 1704220800000, // 2023-11-01 00:00:00
  content:
  '这款针织打底衫质量非常棒，纯羊毛材质，穿着舒适，保暖性很好。适合商务场合，搭配西装外套也很合适。',
  mediaList: [],
};

export const REVIEW_ITEM_MOCK2: ProductReviewItem = {
  productId: 'product_10001',
  userAvatar: $r('app.media.ic_default_avatar'),
  userName: '李**',
  skuCode: 'sku_100005',
  skuDesc: ['165/84A', '白色'],
  rating: 4,
  date: 1703616000000, // 2023-10-25 00:00:00
  content:
  '颜色很百搭，颜色看起来很高级。版型修身，穿上显得很精神。不过稍微有点紧身，建议选大一码。',
  mediaList: [],
};

export const REVIEW_ITEM_MOCK3: ProductReviewItem = {
  productId: 'product_10001',
  userAvatar: $r('app.media.ic_default_avatar'),
  userName: '小**',
  skuCode: 'sku_100004',
  skuDesc: ['160/80A', '白色'],
  rating: 5,
  date: 1704393600000, // 2023-11-02 00:00:00
  content:
  '深蓝色非常显气质，适合秋冬季节。羊毛材质柔软，洗涤后不易起球，质量上乘。',
  mediaList: [],
};
