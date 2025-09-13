import { CategoryItem, ProductSummaryItem, SubCategoryItem } from '../../types/responses/HomeConfigResponse';

const subCategoryMock: SubCategoryItem[] = [
  {
    id: '1001',
    label: '男士经典',
  },
  {
    id: '1002',
    label: '女士经典',
  },
  {
    id: '1003',
    label: '儿童',
  },
]

export class MockHomeConfig {
  static readonly categoryBarList: CategoryItem[] = [
    {
      id: '1',
      label: '精选',
      iconUrl: 'app://dev/media/category/icon1.png',
      subCategory: subCategoryMock,
    },
    {
      id: '2',
      label: '清洁用品',
      iconUrl: 'app://dev/media/category/icon2.png',
      subCategory: subCategoryMock,
    },
    {
      id: '3',
      label: '全棉用品',
      iconUrl: 'app://dev/media/category/icon3.png',
      subCategory: subCategoryMock,
    },
    {
      id: '4',
      label: '安睡香氛',
      iconUrl: 'app://dev/media/category/icon4.png',
    },
    {
      id: '5',
      label: '福利',
      subCategory: subCategoryMock,
      iconUrl: 'app://dev/media/category/icon5.png',
    },
    {
      id: '6',
      label: '运动休闲',
      iconUrl: 'app://dev/media/category/icon6.png',
    },
    {
      id: '7',
      label: '成人服装',
      iconUrl: 'app://dev/media/category/icon7.png',
    },
    {
      id: '8',
      label: '折扣商品',
      iconUrl: 'app://dev/media/category/icon8.png',
    },
    {
      id: '9',
      label: '美妆彩妆',
      iconUrl: 'app://dev/media/category/icon9.png',
    },
    {
      id: '10',
      label: '饰品首饰',
      iconUrl: 'app://dev/media/category/icon10.png',
    },
  ];
  static readonly categoryDataList: ProductSummaryItem[] = [
    {
      banner: $r('app.media.mock2_spec_white'),
      title: '经典休闲短袖',
      id: '1001_001',
      subCategoryId: '1001',
    },
    {
      banner: $r('app.media.mock2_spec_black'),
      title: '经典舒适短袖',
      id: '1001_002',
      subCategoryId: '1001',
    },
    {
      banner: $r('app.media.mock2_spec_shirt'),
      title: '经典休闲衬衫',
      subCategoryId: '1001',
      id: '1001_003',
    },
    {
      banner: $r('app.media.mock2_spec_blue'),
      title: '经典商务衬衫',
      subCategoryId: '1001',
      id: '1001_004',
    },
    {
      banner: $r('app.media.mock2_spec_white'),
      title: '经典休闲短袖',
      subCategoryId: '1001',
      id: '1001_005',
    },
    {
      banner: $r('app.media.mock2_spec_black'),
      title: '经典舒适短袖',
      subCategoryId: '1001',
      id: '1001_006',
    },
    {
      banner: $r('app.media.mock_spec_white'),
      title: '经典针织打底',
      id: '1002_001',
      subCategoryId: '1002',
    },
    {
      banner: $r('app.media.mock_spec_pink'),
      title: '时尚针织打底',
      id: '1002_002',
      subCategoryId: '1002',
    },
    {
      banner: $r('app.media.mock_spec_green'),
      title: '纯羊毛内搭',
      subCategoryId: '1002',
      id: '1002_003',
    },
    {
      banner: $r('app.media.mock_spec_stripe'),
      title: '轻商务系列',
      subCategoryId: '1002',
      id: '1002_004',
    },
    {
      banner: $r('app.media.mock_spec_white'),
      title: '经典针织打底',
      id: '1002_001',
      subCategoryId: '1002',
    },
    {
      banner: $r('app.media.mock_spec_pink'),
      title: '时尚针织打底',
      id: '1002_002',
      subCategoryId: '1002',
    },
    {
      banner: $r('app.media.mock_spec_green'),
      title: '纯羊毛内搭',
      subCategoryId: '1002',
      id: '1002_003',
    },
    {
      banner: $r('app.media.mock_spec_stripe'),
      title: '轻商务系列',
      subCategoryId: '1002',
      id: '1002_004',
    },
  ]
}
