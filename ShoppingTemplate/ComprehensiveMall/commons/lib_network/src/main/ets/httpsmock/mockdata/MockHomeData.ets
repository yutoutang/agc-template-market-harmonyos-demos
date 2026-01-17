import {
  CategoryItem,
  ProductSummaryItem,
  SubCategoryItem,
} from '../../types/responses/HomeConfigResponse';

const subCategoryMock: SubCategoryItem[] = [
  {
    id: '1001',
    label: '女士经典',
  },
  {
    id: '1002',
    label: '男士经典',
  },
  {
    id: '1003',
    label: '儿童',
  },
];


export class MockHomeConfig {
  static readonly categoryBarList: CategoryItem[] = [
    {
      id: '1',
      label: '精选',
      iconUrl: 'icon1.png',
      subCategory: subCategoryMock,
    },
    {
      id: '2',
      label: '清洁用品',
      iconUrl: 'icon2.png',
      subCategory: subCategoryMock,
    },
    {
      id: '3',
      label: '全棉用品',
      iconUrl: 'icon3.png',
      subCategory: subCategoryMock,
    },
    {
      id: '4',
      label: '安睡香氛',
      iconUrl: 'icon4.png',
    },
    {
      id: '5',
      label: '福利',
      subCategory: subCategoryMock,
      iconUrl: 'icon5.png',
    },
    {
      id: '6',
      label: '运动休闲',
      iconUrl: 'icon6.png',
    },
    {
      id: '7',
      label: '成人服装',
      iconUrl: 'icon7.png',
    },
    {
      id: '8',
      label: '折扣商品',
      iconUrl: 'icon8.png',
    },
    {
      id: '9',
      label: '美妆彩妆',
      iconUrl: 'icon9.png',
    },
    {
      id: '10',
      label: '饰品首饰',
      iconUrl: 'icon10.png',
    },
  ];
  static readonly categoryDataList: ProductSummaryItem[] = [
    {
      banner: 'mock2_spec_white.png',
      title: '经典休闲短袖',
      id: '1002_001',
      subCategoryId: '1002',
    },
    {
      banner: 'mock2_spec_black.png',
      title: '经典舒适短袖',
      id: '1002_002',
      subCategoryId: '1002',
    },
    {
      banner: 'mock2_spec_shirt.png',
      title: '经典休闲衬衫',
      subCategoryId: '1002',
      id: '1002_003',
    },
    {
      banner: 'mock2_spec_blue.png',
      title: '经典商务衬衫',
      subCategoryId: '1002',
      id: '1002_004',
    },
    {
      banner: 'mock2_spec_white.png',
      title: '经典休闲短袖',
      subCategoryId: '1002',
      id: '1002_005',
    },
    {
      banner: 'mock2_spec_black.png',
      title: '经典舒适短袖',
      subCategoryId: '1002',
      id: '1002_006',
    },
    {
      banner: 'mock_spec_white.jpg',
      title: '经典针织打底',
      id: '1001_001',
      subCategoryId: '1001',
    },
    {
      banner: 'mock_spec_pink.jpg',
      title: '时尚针织打底',
      id: '1001_002',
      subCategoryId: '1001',
    },
    {
      banner: 'mock_spec_green.jpg',
      title: '纯羊毛内搭',
      subCategoryId: '1001',
      id: '1001_003',
    },
    {
      banner: 'mock_spec_yellow.png',
      title: '轻商务系列',
      subCategoryId: '1001',
      id: '1001_004',
    },
    {
      banner: 'mock_spec_white.jpg',
      title: '经典针织打底',
      id: '1001_001',
      subCategoryId: '1001',
    },
    {
      banner: 'mock_spec_pink.jpg',
      title: '时尚针织打底',
      id: '1001_002',
      subCategoryId: '1001',
    },
    {
      banner: 'mock_spec_green.jpg',
      title: '纯羊毛内搭',
      subCategoryId: '1001',
      id: '1001_003',
    },
    {
      banner: 'mock_spec_yellow.png',
      title: '轻商务系列',
      subCategoryId: '1001',
      id: '1001_004',
    },
  ];
  static readonly searchList: string[] = [
    '时尚轻商务系列',
    '秋季穿搭',
    '针织',
    '衬衫',
  ];
  static readonly bannerList:string[] = [
    'mock_homepage_banner1.png',
    'mock_homepage_banner2.jpg',
  ]
}
