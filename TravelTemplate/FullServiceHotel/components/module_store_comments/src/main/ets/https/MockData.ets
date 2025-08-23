import { CommentItem, KeywordItem, StoreItem } from '../commons/Types';

const COMMENT_MOCK1: CommentItem = {
  avatar: '',
  userName: '',
  desc: '房间挺好阳台打大靠海，前台小姐姐服务很好，满意不错',
  star: 5,
  date: '2024-11-29 14:16:51',
  location: '千和大酒店(1店)',
};

const COMMENT_MOCK2: CommentItem = {
  avatar: '',
  userName: '',
  desc: '小区和酒店同享一片海，天气冷了不适合下海，无边泳池也玩不了了，酒店环境不错，除设施老点其他都好，服务也不错，海边骑车最远走到这里，还不错的酒店',
  star: 4,
  date: '2024-11-30 11:10:05',
  location: '千和大酒店(2店)',
};

export class MockData {
  public static readonly COMMENT_LIST_MOCK: CommentItem[] = [
    COMMENT_MOCK1,
    COMMENT_MOCK2,
    COMMENT_MOCK1,
    COMMENT_MOCK2,
    COMMENT_MOCK1,
    COMMENT_MOCK2,
    COMMENT_MOCK1,
    COMMENT_MOCK2,
    COMMENT_MOCK1,
    COMMENT_MOCK2,
  ]

  public static readonly HOTEL_LIST_MOCK:StoreItem[] = [
    {
      id:101,
      name:'千和大酒店(1店)',
      type:'HOTEL'
    },
    {
      id:102,
      name:'千和大酒店(2店)',
      type:'HOTEL'
    },
    {
      id:103,
      name:'千和大酒店·中餐厅',
      type:'RESTAURANT'
    },
    {
      id:104,
      name:'千和大酒店·西餐厅',
      type:'RESTAURANT'
    },
  ]

  public static readonly KEYWORD_LIST_MOCK:KeywordItem[] = [
    {
      desc:'服务周到',
      count:4.0,
    },
    {
      desc:'环境卫生',
      count:4.4,
    },
    {
      desc:'设施设备',
      count:4.5,
    },
    {
      desc:'综合体验',
      count:4.3,
    }
  ]
}

