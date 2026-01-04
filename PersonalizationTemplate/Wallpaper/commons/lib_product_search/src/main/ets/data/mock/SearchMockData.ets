import { ImageInfo } from 'module_wallpaper_details';
import { HotSearchItem } from '../../commons/Types';

export class SearchMockData {
  // 热搜数据
  static hotSearchList: HotSearchItem[] = [
    { label: '森林', hotRate: 125 },
    { label: '天气', hotRate: 118 },
    { label: '爱豆', hotRate: 98 },
    { label: '动漫人物', hotRate: 87 },
    { label: '木鱼', hotRate: 76 },
    { label: '日出', hotRate: 65 },
    { label: '萌宠', hotRate: 54 },
    { label: '星空', hotRate: 43 },
    { label: '城市', hotRate: 32 },
    { label: '油画', hotRate: 21 }
  ];
  // 猜你喜欢
  static guessLikeList: string[] = [
    '动态效果',
    '相册',
    '照片',
    '表情电量',
    '答案之书',
    '动漫壁纸',
    '科幻壁纸',
    '小清新',
    '卡片'
  ];
  static PREFIX_URL: string = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-5xjsz';
  static allWallpapers: ImageInfo[] = [
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F12.png?token=8216c028-bd4e-404b-80a1-ac5af73028b8',
      src: 'first_wallpaper_video.mp4',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '爱豆',
      hotValue: 465,
      time: 1758332621000,
      keywords: '#动态效果,#森林',
      like: false,
      isVideo: true
    },
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F1.png?token=f0dca9d4-ff84-4b23-8575-7f0009b67357',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '爱豆',
      hotValue: 465,
      time: 1758332621000,
      keywords: '#森林,#湖泊',
      like: false,
    },
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F27.png?token=f6ee5f75-9b34-4d6d-a3ad-f2e7243ac320',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '爱豆',
      hotValue: 465,
      time: 1758332621000,
      keywords: '#爱豆,#日出',
      like: false
    },
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F26.png?token=93eb56dc-0a47-4092-bf1f-66d0a35d1ae7',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      type: '爱豆',
      hotValue: 323,
      time: 1759200713928,
      keywords: '#雪景,#森林',
      like: false
    },
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F25.png?token=7bdb5d62-7b5d-4ec3-a09b-e69cf1eebece',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      type: '爱豆',
      hotValue: 434,
      time: 1758332621000,
      keywords: '#爱豆,#日出',
      like: false
    }, {
    id: '',
    url: SearchMockData.PREFIX_URL +
      '/wallpapaer%2Fpicture%2F24.png?token=7d3d365d-5493-461c-bc1b-2c6a8d051313',
    userAvatar: SearchMockData.PREFIX_URL +
      '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
    userName: '今日小编',
    type: '动漫',
    hotValue: 454,
    time: 1759200713928,
    keywords: '#爱豆,#动漫人物',
    like: false
  },
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F23.png?token=514c6f66-e8f7-484a-9185-c1ee7dc72a7e',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      type: '动漫',
      hotValue: 976,
      time: 1759200713928,
      keywords: '#爱豆,#日落',
      like: false
    },
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F22.png?token=7903895f-e5bc-4e03-a33f-fd692c5eb443',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      type: '动漫',
      hotValue: 646,
      time: 1758332621000,
      keywords: '#油画,#星空',
      like: false
    },
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F21.png?token=c8fd1736-ad5b-4e6b-ba22-834d8590214f',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '萌宠',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#星空',
      like: false
    },
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F20.png?token=d2fc3797-6362-4d59-b627-c4fe5631ef7a',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      type: '萌宠',
      hotValue: 435,
      time: 1759200713928,
      keywords: '#萌宠,#日落',
      like: false
    },
    {
      id: '',
      url: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F19.png?token=43f45e30-e3bd-4bd1-84b3-2e0fbf4ab6e9',
      userAvatar: SearchMockData.PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      type: '萌宠',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      like: false
    },
  ]

  static getWallpaperList(sortBy: string, limit: number, page: number): ImageInfo[] {

    const total = limit * page;

    let list = SearchMockData.allWallpapers.slice(5, 11);

    list = list.slice(limit * (page - 1), list.length < total ? list.length : total)

    if (sortBy === 'hot') {
      // 热度降序
      return [...list].sort((a, b) => b.hotValue - a.hotValue);
    } else {
      // 时间降序
      return [...list].sort((a, b) => b.time - a.time);
    }
  }

  // 精确匹配关键词
  static searchWallpapersByKeyword(keyword: string): ImageInfo[] {
    const lowerKeyword = keyword.toLowerCase();
    const matchedWallpapers: ImageInfo[] =
      SearchMockData.allWallpapers.filter((wallpaper: ImageInfo): boolean => {
        const keywordArray: string[] = wallpaper.keywords.split(',');
        const hasExactMatch: boolean = keywordArray.some((kw: string): boolean => {
          return kw.trim().toLowerCase().includes(lowerKeyword);
        });
        return hasExactMatch;
      });
    return matchedWallpapers;
  }

  // 关键词是否存在 不存在显示 暂无相关壁纸
  static hasKeyword(keyword: string): boolean {
    const lowerKeyword = keyword.toLowerCase();
    const inHotSearch: boolean = SearchMockData.hotSearchList.some((item: HotSearchItem): boolean => {
      return item.label.toLowerCase().includes(lowerKeyword);
    });
    if (inHotSearch) {
      return true;
    }
    const inGuessLike: boolean = SearchMockData.guessLikeList.some((item: string): boolean => {
      return item.toLowerCase().includes(lowerKeyword);
    });
    if (inGuessLike) {
      return true;
    }
    const inWallpapers: boolean = SearchMockData.allWallpapers.some((wallpaper: ImageInfo): boolean => {
      const keywordArray: string[] = wallpaper.keywords.split(',');
      return keywordArray.some((kw: string): boolean => {
        return kw.trim().toLowerCase().includes(lowerKeyword);
      });
    });
    return inWallpapers;
  }

  // 所有可搜索的关键词列表
  static getAllSearchableKeywords(): string[] {
    const allKeywords: Set<string> = new Set();
    SearchMockData.hotSearchList.forEach((item: HotSearchItem) => {
      allKeywords.add(item.label);
    });
    SearchMockData.guessLikeList.forEach((item: string) => {
      allKeywords.add(item);
    });
    SearchMockData.allWallpapers.forEach((wallpaper: ImageInfo) => {
      const keywordArray: string[] = wallpaper.keywords.split(',');
      keywordArray.forEach((kw: string) => {
        allKeywords.add(kw.trim());
      });
    });
    return Array.from(allKeywords);
  }
}