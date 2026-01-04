import { ImageInfo } from 'module_wallpaper_details';
import { WallpaperSuperTab } from '../../database/WallpaperType';

const PREFIX_URL: string = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-5xjsz';

export class MockWallpaperList {
  //主页Tab数据
  static tabs: WallpaperSuperTab[] = [
    { id: '0', text: '推荐', child: [] },
    { id: '1', text: '爱豆', child: [] },
    {
      id: '2',
      text: '动漫',
      child: [{ id: '3', text: '火影忍者' }, { id: '4', text: '海贼王' }]
    },
    {
      id: '7',
      text: '萌宠',
      child: []
    },
    { id: '10', text: '游戏', child: [] },
    { id: '13', text: '风景', child: [] }]
  //推荐
  static listByIdIs0: ImageInfo[] = [
    {
      id: '',
      src: 'first_wallpaper_video.mp4',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F12.png?token=8216c028-bd4e-404b-80a1-ac5af73028b8',
      userName: '今日小编',
      type: '爱豆',
      time: 1758332621000,
      hotValue: 465,
      keywords: '#动态效果',
      isVideo: true,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F1.png?token=f0dca9d4-ff84-4b23-8575-7f0009b67357',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      hotValue: 465,
      userName: '今日小编',
      type: '爱豆',
      time: 1758332621000,
      like: false,
      keywords: '#动漫人物,#油画'
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F19.png?token=43f45e30-e3bd-4bd1-84b3-2e0fbf4ab6e9',
      userName: '昨日小编',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      type: '爱豆',
      hotValue: 323,
      like: false,
      time: 1759200713928,
      keywords: '#森林,#日出'
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F6.png?token=b92eff91-820f-482f-acb1-aa9d79c97a75',
      like: false,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      type: '爱豆',
      hotValue: 434,
      time: 1758332621000,
      keywords: ''
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F7.png?token=8b2c35c3-0cdd-40f9-9a55-a0a8bafc125f',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      type: '动漫',
      time: 1759200713928,
      hotValue: 454,
      keywords: '#动漫人物',
      like: false,
      userName: '今日小编'
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F10.png?token=5ab21fee-b1fb-451b-9293-bbddc38faa6f',
      userName: '昨日小编',
      type: '动漫',
      keywords: '#动漫人物',
      hotValue: 976,
      time: 1759200713928,
      like: false,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a'
    },
    {
      id: '',
      userName: '未来小编',
      type: '动漫',
      hotValue: 646,
      time: 1758332621000,
      keywords: '#动漫人物',
      like: false,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F11.png?token=7604ee6d-aa3a-48e5-abf7-b0f1fcc9808d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a'
    },
    {
      id: '',
      userName: '今日小编',
      type: '动漫',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#动漫人物',
      like: false,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F27.png?token=f6ee5f75-9b34-4d6d-a3ad-f2e7243ac320',
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F13.png?token=e0bc38fb-9a12-41a6-b5a3-f337d916cd16',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      type: '动漫',
      hotValue: 632,
      time: 1759200713928,
      keywords: '#动漫人物',
      userName: '昨日小编',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      hotValue: 565,
      time: 1758332621000,
      keywords: '#动漫人物',
      like: false,
      type: '动漫',
    },
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      userName: '今日小编',
      type: '动漫',
      time: 1758332621000,
      hotValue: 562,
      keywords: '#动漫人物',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      type: '动漫',
      keywords: '#动漫人物',
      hotValue: 345,
      time: 1759200713928,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F17.png?token=14d912a9-fea9-4f44-8043-6ba57f190265',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      hotValue: 236,
      time: 1758332621000,
      userName: '未来小编',
      type: '动漫',
      keywords: '#动漫人物',
      like: false
    }
  ]
  // 爱豆
  static listByIdIs1: ImageInfo[] = [
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '爱豆',
      keywords: '#爱豆,#星空',
      like: false,
      hotValue: 465,
      time: 1758332621000,
    },
    {
      id: '',
      like: false,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F19.png?token=43f45e30-e3bd-4bd1-84b3-2e0fbf4ab6e9',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      type: '爱豆',
      hotValue: 323,
      time: 1759200713928,
      keywords: '#星空,#日出'
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F20.png?token=d2fc3797-6362-4d59-b627-c4fe5631ef7a',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      hotValue: 434,
      time: 1758332621000,
      like: false,
      userName: '未来小编',
      type: '爱豆',
      keywords: '#日出,#城市'
    },
    {
      id: '',
      like: false,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '爱豆',
      time: 1758332621000,
      hotValue: 234,
      keywords: '#萌宠,#雪景'
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      hotValue: 234,
      time: 1759200713928,
      keywords: '#萌宠,#油画',
      type: '爱豆',
      like: false
    },
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userName: '未来小编',
      type: '爱豆',
      time: 1758332621000,
      hotValue: 234,
      keywords: '#萌宠,#城市',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '爱豆',
      like: false,
      time: 1758332621000,
      hotValue: 234,
      keywords: '#萌宠,#雪景'
    },
    {
      userName: '前天小编',
      type: '爱豆',
      hotValue: 234,
      time: 1759200713928,
      keywords: '#萌宠,#油画',
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      userName: '21世纪小编',
      type: '爱豆',
      like: false
    },
    {
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      userName: '昨日小编',
      type: '爱豆',
      hotValue: 234,
      time: 1759200713928,
      keywords: '#萌宠,#油画',
      like: false,
      id: ''
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      userName: '未来小编',
      type: '爱豆',
      like: false
    },
    {
      id: '',
      userName: '今日小编',
      type: '爱豆',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#雪景',
      like: false,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
    },
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      userName: '前天小编',
      type: '爱豆',
      keywords: '#萌宠,#油画',
      like: false,
      hotValue: 234,
      time: 1759200713928,
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      hotValue: 234,
      userName: '21世纪小编',
      type: '爱豆',
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      type: '爱豆',
      hotValue: 234,
      userName: '昨日小编',
      time: 1759200713928,
      keywords: '#萌宠,#油画',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      time: 1758332621000,
      type: '爱豆',
      hotValue: 234,
      keywords: '#萌宠,#城市',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      type: '爱豆',
      hotValue: 234,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      time: 1758332621000,
      keywords: '#萌宠,#雪景',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      hotValue: 234,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '前天小编',
      type: '爱豆',
      time: 1759200713928,
      keywords: '#萌宠,#油画',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      keywords: '#萌宠,#城市',
      hotValue: 234,
      time: 1758332621000,
      type: '爱豆',
      userName: '21世纪小编',
      like: false
    }
  ]
  // 动漫
  static listByIdIs3: ImageInfo[] = [
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F21.png?token=c8fd1736-ad5b-4e6b-ba22-834d8590214f',
      userName: '今日小编',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      type: '动漫',
      hotValue: 454,
      time: 1759200713928,
      keywords: '#动漫人物',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F22.png?token=7903895f-e5bc-4e03-a33f-fd692c5eb443',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      like: false,
      type: '动漫',
      hotValue: 976,
      time: 1759200713928,
      keywords: '#动漫人物',
    },
    {
      id: '',
      type: '动漫',
      hotValue: 646,
      time: 1758332621000,
      keywords: '#动漫人物',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F23.png?token=514c6f66-e8f7-484a-9185-c1ee7dc72a7e',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      like: false
    },
    {
      id: '',
      time: 1758332621000,
      keywords: '#萌宠,#雪景',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '动漫',
      hotValue: 234,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      type: '动漫',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '前天小编',
      hotValue: 234,
      time: 1759200713928,
      keywords: '#萌宠,#油画',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      keywords: '#萌宠,#城市',
      like: false,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      type: '动漫',
      hotValue: 234,
      time: 1758332621000,
    },
    {
      id: '',
      type: '动漫',
      hotValue: 454,
      time: 1759200713928,
      keywords: '#动漫人物',
      like: false,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F21.png?token=c8fd1736-ad5b-4e6b-ba22-834d8590214f',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F22.png?token=7903895f-e5bc-4e03-a33f-fd692c5eb443',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      hotValue: 976,
      userName: '昨日小编',
      type: '动漫',
      time: 1759200713928,
      keywords: '#动漫人物',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F23.png?token=514c6f66-e8f7-484a-9185-c1ee7dc72a7e',
      userName: '未来小编',
      type: '动漫',
      hotValue: 646,
      time: 1758332621000,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      keywords: '#动漫人物',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#雪景',
      like: false,
      type: '动漫'
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      type: '动漫',
      hotValue: 234,
      time: 1759200713928,
      userName: '前天小编',
      keywords: '#萌宠,#油画',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      hotValue: 234,
      time: 1758332621000,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      type: '动漫',
      keywords: '#萌宠,#城市',
      like: false
    }
  ]
  // 动漫
  static listByIdIs4: ImageInfo[] = [
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F24.png?token=7d3d365d-5493-461c-bc1b-2c6a8d051313',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      time: 1758332621000,
      hotValue: 224,
      type: '动漫',
      keywords: '#动漫人物',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F25.png?token=7bdb5d62-7b5d-4ec3-a09b-e69cf1eebece',
      type: '动漫',
      hotValue: 632,
      userName: '昨日小编',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      time: 1759200713928,
      keywords: '#动漫人物',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F26.png?token=93eb56dc-0a47-4092-bf1f-66d0a35d1ae7',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      keywords: '#动漫人物',
      type: '动漫',
      hotValue: 565,
      time: 1758332621000,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F25.png?token=7bdb5d62-7b5d-4ec3-a09b-e69cf1eebece',
      type: '动漫',
      hotValue: 253,
      userName: '动漫小编',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      keywords: '#动漫人物',
      time: 1759200713928,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F24.png?token=7d3d365d-5493-461c-bc1b-2c6a8d051313',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '动漫小编',
      time: 1758332621000,
      hotValue: 264,
      type: '动漫',
      keywords: '#动漫人物',
      like: false
    },
  ]
  static listByIdIs5: ImageInfo[] = [
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F27.png?token=f6ee5f75-9b34-4d6d-a3ad-f2e7243ac320',
      type: '动漫',
      hotValue: 562,
      time: 1758332621000,
      keywords: '#动漫人物',
      like: false
    },
    {
      id: '',
      keywords: '#动漫人物',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F1.png?token=f0dca9d4-ff84-4b23-8575-7f0009b67357',
      userName: '昨日小编',
      type: '动漫',
      hotValue: 345,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      time: 1759200713928,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F6.png?token=b92eff91-820f-482f-acb1-aa9d79c97a75',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      time: 1758332621000,
      keywords: '#萌宠,#星空',
      type: '萌宠',
      hotValue: 234,
      like: false
    }
  ]
  // 萌宠
  static listByIdIs7: ImageInfo[] = [
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      hotValue: 234,
      time: 1758332621000,
      type: '萌宠',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F6.png?token=b92eff91-820f-482f-acb1-aa9d79c97a75',
      keywords: '#萌宠,#星空',
      like: false
    },
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F7.png?token=8b2c35c3-0cdd-40f9-9a55-a0a8bafc125f',
      userName: '昨日小编',
      type: '萌宠',
      time: 1759200713928,
      keywords: '#萌宠,#日落',
      hotValue: 435,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F10.png?token=5ab21fee-b1fb-451b-9293-bbddc38faa6f',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      time: 1758332621000,
      hotValue: 232,
      keywords: '#萌宠,#城市',
      type: '萌宠',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F11.png?token=7604ee6d-aa3a-48e5-abf7-b0f1fcc9808d',
      hotValue: 231,
      time: 1758332621000,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '萌宠',
      keywords: '#萌宠,#雪景',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F12.png?token=8216c028-bd4e-404b-80a1-ac5af73028b8',
      keywords: '#萌宠,森林',
      like: false,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      type: '萌宠',
      hotValue: 241,
      time: 1759200713928
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F13.png?token=e0bc38fb-9a12-41a6-b5a3-f337d916cd16',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      type: '萌宠',
      keywords: '#萌宠,#湖泊',
      userName: '未来小编',
      hotValue: 238,
      time: 1758332621000,
      like: false
    },
    {
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      id: '',
      type: '萌宠',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#雪景',
      like: false
    },
    {
      like: false,
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      type: '萌宠',
      time: 1759200713928,
      hotValue: 234,
      keywords: '#萌宠,#油画'
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userName: '未来小编',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      type: '萌宠',
      time: 1758332621000,
      hotValue: 238,
      keywords: '#萌宠,#城市',
      like: false
    },
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      type: '萌宠',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F6.png?token=b92eff91-820f-482f-acb1-aa9d79c97a75',
      userName: '今日小编',
      hotValue: 236,
      time: 1758332621000,
      keywords: '#萌宠,#星空',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F7.png?token=8b2c35c3-0cdd-40f9-9a55-a0a8bafc125f',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      type: '萌宠',
      keywords: '#萌宠,#日落',
      hotValue: 435,
      time: 1759200713928,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F10.png?token=5ab21fee-b1fb-451b-9293-bbddc38faa6f',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      type: '萌宠',
      time: 1758332621000,
      hotValue: 236,
      keywords: '#萌宠,#城市',
      like: false
    },
    {
      id: '',
      userName: '今日小编',
      time: 1758332621000,
      keywords: '#萌宠,#雪景',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F11.png?token=7604ee6d-aa3a-48e5-abf7-b0f1fcc9808d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      type: '萌宠',
      hotValue: 239,
      like: false
    },
    {
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F12.png?token=8216c028-bd4e-404b-80a1-ac5af73028b8',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      id: '',
      userName: '昨日小编',
      like: false,
      type: '萌宠',
      hotValue: 230,
      time: 1759200713928,
      keywords: '#萌宠,森林',
    },
    {
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F13.png?token=e0bc38fb-9a12-41a6-b5a3-f337d916cd16',
      type: '萌宠',
      hotValue: 231,
      time: 1758332621000,
      keywords: '#萌宠,#湖泊',
      like: false
    },
    {
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      type: '萌宠',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#雪景',
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      like: false
    },
    {
      userName: '昨日小编',
      type: '萌宠',
      hotValue: 234,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      time: 1759200713928,
      keywords: '#萌宠,#油画',
      like: false
    },
    {
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      type: '萌宠',
      hotValue: 234,
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      like: false
    }
  ]
  // 游戏
  static listByIdIs10: ImageInfo[] = [
    {
      id: '',
      type: '游戏',
      hotValue: 264,
      time: 1758332621000,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F17.png?token=14d912a9-fea9-4f44-8043-6ba57f190265',
      userName: '今日小编',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      keywords: '#森林,#爱豆',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      time: 1759200713928,
      hotValue: 234,
      keywords: '#城市,#日出',
      userName: '昨日小编',
      type: '游戏',

      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F19.png?token=43f45e30-e3bd-4bd1-84b3-2e0fbf4ab6e9',
      type: '游戏',
      hotValue: 254,
      time: 1758332621000,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      keywords: '#星空,#湖泊',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F14.png?token=e6070688-1377-41a2-9e72-dacd59761f5a',
      type: '萌宠',
      hotValue: 214,
      time: 1758332621000,
      keywords: '#萌宠,#雪景',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      like: false
    },
    {
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      type: '萌宠',
      hotValue: 284,
      userName: '昨日小编',
      time: 1759200713928,
      keywords: '#萌宠,#油画',
      like: false,
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F15.png?token=7e61408d-0d2f-4bab-9392-3e1c83cc03ff',
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      userName: '未来小编',
      type: '萌宠',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      like: false
    },
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      type: '游戏',
      hotValue: 234,
      time: 1759200713928,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      userName: '昨日小编',
      keywords: '#城市,#日出',
      like: false
    },
    {
      id: '',
      hotValue: 234,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      userName: '昨日小编',
      time: 1759200713928,
      type: '游戏',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      keywords: '#城市,#日出',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      time: 1759200713928,
      type: '游戏',
      keywords: '#城市,#日出',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      hotValue: 234,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      hotValue: 234,
      userName: '昨日小编',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      type: '游戏',
      keywords: '#城市,#日出',
      time: 1759200713928,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      type: '游戏',
      keywords: '#城市,#日出',
      time: 1759200713928,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      hotValue: 234,
      like: false
    },
    {
      id: '',
      userName: '昨日小编',
      hotValue: 234,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      time: 1759200713928,
      keywords: '#城市,#日出',
      like: false,
      type: '游戏'
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      hotValue: 234,
      type: '游戏',
      time: 1759200713928,
      keywords: '#城市,#日出',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      hotValue: 234,
      type: '游戏',
      time: 1759200713928,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      keywords: '#城市,#日出',
      like: false
    },
    {
      id: '',
      userName: '昨日小编',
      type: '游戏',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F18.png?token=3843ef53-24ba-49ac-83fe-2c54249a9f8d',
      keywords: '#城市,#日出',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      hotValue: 234,
      time: 1759200713928,
      like: false
    }
  ]
  // 风景
  static listByIdIs13: ImageInfo[] = [
    {
      id: '',
      userName: '今日小编',
      type: '风景',
      hotValue: 244,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F20.png?token=d2fc3797-6362-4d59-b627-c4fe5631ef7a',
      time: 1758332621000,
      keywords: '#森林,#湖泊',
      like: false
    },
    {
      id: '',
      time: 1759200713928,
      keywords: '#湖泊,#雪景',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F21.png?token=c8fd1736-ad5b-4e6b-ba22-834d8590214f',
      userName: '昨日小编',
      type: '风景',
      hotValue: 231,
      like: false
    },
    {
      time: 1758332621000,
      keywords: '#城市,#油画',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F22.png?token=7903895f-e5bc-4e03-a33f-fd692c5eb443',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      id: '',
      userName: '未来小编',
      hotValue: 230,
      type: '风景',
      like: false
    },
    {
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      type: '爱豆',
      like: false,
      hotValue: 236,
    },
    {
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userName: '21世纪小编',
      type: '爱豆',
      id: '',
      hotValue: 239,
      keywords: '#萌宠,#城市',
      time: 1758332621000,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      hotValue: 237,
      time: 1758332621000,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      keywords: '#萌宠,#城市',
      userName: '21世纪小编',
      type: '爱豆',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      type: '爱豆',
      hotValue: 234,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userName: '21世纪小编',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      type: '爱豆',
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      type: '爱豆',
      hotValue: 220,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      keywords: '#萌宠,#城市',
      time: 1758332621000,
      like: false
    },
    {
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      time: 1758332621000,
      type: '爱豆',
      hotValue: 234,
      keywords: '#萌宠,#城市',
      like: false
    },
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      type: '爱豆',
      like: false,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
    },
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',

      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      like: false,
      type: '爱豆',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d'
    },
    {
      id: '',
      keywords: '#萌宠,#城市',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      hotValue: 234,
      time: 1758332621000,
      like: false,
      type: '爱豆',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
    },
    {
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userName: '21世纪小编',
      type: '爱豆',
      hotValue: 234,
      id: '',
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      like: false,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      time: 1758332621000,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      type: '爱豆',
      userName: '21世纪小编',
      hotValue: 234,
      like: false,
      keywords: '#萌宠,#城市',
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userName: '21世纪小编',
      keywords: '#萌宠,#城市',
      type: '爱豆',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      time: 1758332621000,
      like: false,
      hotValue: 234,
    },
    {
      id: '',
      hotValue: 234,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      type: '爱豆',
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      like: false
    },
    {
      id: '',
      userName: '21世纪小编',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      type: '爱豆',
      time: 1758332621000,
      hotValue: 234,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      keywords: '#萌宠,#城市',
      like: false
    },
    {
      id: '',
      userName: '21世纪小编',
      type: '爱豆',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      hotValue: 234,
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      like: false,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
    },
    {
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      userName: '21世纪小编',
      type: '爱豆',
      keywords: '#萌宠,#城市',
      time: 1758332621000,
      like: false,
      hotValue: 234
    },
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      type: '爱豆',
      hotValue: 234,
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      keywords: '#萌宠,#城市',
      like: false,
      userName: '21世纪小编',
      time: 1758332621000,
    },
    {
      id: '',
      keywords: '#萌宠,#城市',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      type: '爱豆',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      hotValue: 234,
      time: 1758332621000,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      like: false,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      type: '爱豆',
      time: 1758332621000,
      keywords: '#萌宠,#城市',
      hotValue: 234
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F16.png?token=2fb5ad81-bfb5-41c5-9f8f-fb0ea20df60d',
      keywords: '#萌宠,#城市',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '21世纪小编',
      hotValue: 234,
      time: 1758332621000,
      type: '爱豆',
      like: false
    }
  ]
  // 萌宠
  static listByHotPage1: ImageInfo[] = [
    {
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      type: '爱豆',
      hotValue: 465,
      time: 1758332621000,
      userName: '今日小编',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F23.png?token=514c6f66-e8f7-484a-9185-c1ee7dc72a7e',
      keywords: '#动漫人物,#爱豆',
      like: false
    },
    {
      keywords: '#爱豆,#油画',
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F24.png?token=7d3d365d-5493-461c-bc1b-2c6a8d051313',
      like: false,
      time: 1759200713928,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
      type: '爱豆',
      hotValue: 323
    },
    {
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F25.png?token=7bdb5d62-7b5d-4ec3-a09b-e69cf1eebece',
      time: 1758332621000,
      id: '',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      hotValue: 434,
      keywords: '#爱豆,#城市',
      like: false,
      type: '爱豆',
    },
    {
      id: '',
      keywords: '#动漫人物,#星空',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F26.png?token=93eb56dc-0a47-4092-bf1f-66d0a35d1ae7',
      type: '动漫',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
      userName: '今日小编',
      hotValue: 454,
      time: 1759200713928,
      like: false
    },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F27.png?token=f6ee5f75-9b34-4d6d-a3ad-f2e7243ac320',
      time: 1759200713928,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      type: '动漫',
      like: false,
      hotValue: 976,
      keywords: '#动漫人物,#城市',
      userName: '昨日小编'
    },
    {
      id: '',
      hotValue: 646,
      keywords: '#动漫人物,#日出',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F1.png?token=f0dca9d4-ff84-4b23-8575-7f0009b67357',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      type: '动漫',
      time: 1758332621000,
      like: false
    }, {
    id: '',
    url: PREFIX_URL +
      '/wallpapaer%2Fpicture%2F6.png?token=b92eff91-820f-482f-acb1-aa9d79c97a75',
    userName: '今日小编',
    hotValue: 234,
    userAvatar: PREFIX_URL +
      '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
    time: 1758332621000,
    type: '动漫',
    like: false,
    keywords: '#动漫人物,#雪景',
  },
    {
      id: '',
      userName: '昨日小编',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F7.png?token=8b2c35c3-0cdd-40f9-9a55-a0a8bafc125f',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      type: '动漫',
      time: 1759200713928,
      hotValue: 632,
      keywords: '#动漫人物,#日落',
      like: false
    },
    {
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F10.png?token=5ab21fee-b1fb-451b-9293-bbddc38faa6f',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      type: '动漫',
      keywords: '#动漫人物,#城市',
      like: false,
      hotValue: 565,
      time: 1758332621000,
      id: ''
    }, {
    id: '',
    url: PREFIX_URL +
      '/wallpapaer%2Fpicture%2F11.png?token=7604ee6d-aa3a-48e5-abf7-b0f1fcc9808d',
    hotValue: 562,
    type: '动漫',
    time: 1758332621000,
    userAvatar: PREFIX_URL +
      '/wallpapaer%2Fpicture%2F2.png?token=6766417f-7aaa-4207-8c6e-819b4414fc5b',
    userName: '今日小编',
    keywords: '#动漫人物,#油画',
    like: false
  },
    {
      id: '',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F12.png?token=8216c028-bd4e-404b-80a1-ac5af73028b8',
      type: '动漫',
      hotValue: 345,
      keywords: '#动漫人物,#日落',
      time: 1759200713928,
      like: false,
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F8.png?token=57973a49-9d88-4d37-98a4-01fd5641fc3a',
      userName: '昨日小编',
    },
    {
      id: '',
      keywords: '#动漫人物,#油画',
      url: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F13.png?token=e0bc38fb-9a12-41a6-b5a3-f337d916cd16',
      type: '动漫',
      userAvatar: PREFIX_URL +
        '/wallpapaer%2Fpicture%2F9.png?token=65ab37d1-6cbd-4f17-a83e-7a3bc67aaf2a',
      userName: '未来小编',
      hotValue: 236,
      time: 1758332621000,
      like: false
    }]
}