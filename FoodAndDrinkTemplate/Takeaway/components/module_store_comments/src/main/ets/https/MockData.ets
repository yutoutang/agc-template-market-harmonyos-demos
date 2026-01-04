import { RatingLayoutType } from '../commons/Enums';
import { CommentItem, KeyWordItem, StoreItem } from '../commons/Types';

export class MockData {
  public static readonly COMMENT_LIST_MOCK: CommentItem[] = [
    {
      'avatar': '',
      'userName': '匿名用户10',
      'desc': '配送超快！小哥冒着大雨准时送达，包装完好无损。水煮牛肉麻辣鲜香，配菜丰富，米饭软硬适中，性价比很高。会经常回购的！',
      'star': 5,
      'date': '2024-12-05 18:25:43',
      'location': '川味坊(解放路店)'
    },
    {
      'avatar': '',
      'userName': '匿名用户9',
      'desc': '炸鸡外酥里嫩，送到还是热乎乎的。蜂蜜芥末酱给得很足，年糕Q弹。就是可乐有点漏气了，建议改进包装。',
      'star': 4,
      'date': '2024-12-05 12:15:22',
      'location': '炸鸡队长(星光城店)'
    },
    {
      'avatar': '',
      'userName': '匿名用户8',
      'desc': '寿司组合很新鲜，三文鱼厚切口感棒。配送员态度友好，就是比预计时间晚了15分钟，可能因为下雨天路滑吧。',
      'star': 4,
      'date': '2024-12-04 19:40:33',
      'location': '樱和风日料'
    },
    {
      'avatar': '',
      'userName': '匿名用户7',
      'desc': '奶茶茶味浓郁，珍珠煮得刚好。就是甜度选了少糖还是偏甜，下次试试无糖。包装很精致，没有洒漏。',
      'star': 4,
      'date': '2024-12-04 14:20:18',
      'location': '茶言观色(万达店)'
    },
    {
      'avatar': '',
      'userName': '匿名用户6',
      'desc': '黄焖鸡米饭分量足，鸡肉嫩滑入味，土豆炖得很烂。就是青菜有点黄了，建议注意食材新鲜度。总体还不错。',
      'star': 3,
      'date': '2024-12-03 20:05:57',
      'location': '杨铭宇黄焖鸡'
    },
    {
      'avatar': '',
      'userName': '匿名用户5',
      'desc': '披萨芝士拉丝超长，饼底酥脆。就是配料比图片上少，火腿片有点薄。配送准时，保温做得很好。',
      'star': 4,
      'date': '2024-12-03 18:30:41',
      'location': '必胜宅急送(中心店)'
    },
    {
      'avatar': '',
      'userName': '匿名用户4',
      'desc': '凉皮劲道，调料包分开包装很贴心。就是配的花生有点受潮，不够脆。醋包给得太多，下次记得备注少醋。',
      'star': 3,
      'date': '2024-12-02 13:15:29',
      'location': '西北风味小吃'
    },
    {
      'avatar': '',
      'userName': '匿名用户3',
      'desc': '麻辣香锅选的中辣刚好，食材新鲜，特别是午餐肉和藕片很入味。配送超时了20分钟，但小哥一直道歉态度很好。',
      'star': 4,
      'date': '2024-12-01 19:50:16',
      'location': '辣尚瘾麻辣香锅'
    },
    {
      'avatar': '',
      'userName': '匿名用户2',
      'desc': '煲仔饭锅巴香脆，腊味正宗。就是酱汁有点少，底部有点糊。配的例汤很好喝，整体分量适合女生。',
      'star': 4,
      'date': '2024-11-30 16:40:08',
      'location': '广式煲仔饭'
    },
    {
      'avatar': '',
      'userName': '匿名用户1',
      'desc': '沙拉食材新鲜，鸡胸肉不柴，酱汁选择多。就是牛油果有点生，配送速度可以再快些，蔬菜会更脆。',
      'star': 3,
      'date': '2024-11-30 11:10:05',
      'location': '轻食主义沙拉'
    }
  ]
  public static readonly HOTEL_LIST_MOCK: StoreItem[] = [
    {
      id: 101,
      name: '千和大酒店(1店)',
      type: 'HOTEL'
    },
    {
      id: 102,
      name: '千和大酒店(2店)',
      type: 'HOTEL'
    },
    {
      id: 103,
      name: '千和大酒店·中餐厅',
      type: 'RESTAURANT'
    },
    {
      id: 104,
      name: '千和大酒店·西餐厅',
      type: 'RESTAURANT'
    },
  ]
  public static readonly KEYWORD_LIST_MOCK: KeyWordItem[] = [
    {
      desc: '商家评分',
      count: 4.5,
      layoutType: RatingLayoutType.HORIZONTAL
    },
    {
      desc: '味道',
      count: 4.4,
      layoutType: RatingLayoutType.VERTICAL
    },
    {
      desc: '包装',
      count: 4.5,
      layoutType: RatingLayoutType.VERTICAL
    },
    {
      desc: '配送',
      count: 4.3,
      layoutType: RatingLayoutType.VERTICAL
    }
  ]
}

