import { FilterTagAndList, SearchItem, SearchWordItem } from '../types/Type';

/**
 * Mock数据类
 */
export const HOT_SEARCH_MOCK: SearchItem[] = [
  {
    title: '苹果',
    episodes: 108,
    // 最后一次更新的集数
    latestUpdate: 6,
    tags: ['权谋','重生','家庭'],
    index: '1',
    id: 'fruit-1',
    image: $r('app.media.startIcon'),
    intro: '口感脆甜，富含维生素C，富含蛋白质，口感鲜嫩',
    price: 5.99,
    type: 'fruit',
    classId: 'fruit',
  },
  {
    title: '牛肉',
    episodes: 108,
    // 最后一次更新的集数
    latestUpdate: 6,
    tags: ['权谋','重生','家庭'],
    index: '2',
    id: 'meat-1',
    image: $r('app.media.startIcon'),
    intro: '富含蛋白质，口感鲜嫩，口感脆甜，富含维生素',
    type: 'meat',
    classId: 'meat'
  },
  {
    title: '菠菜',
    episodes: 108,
    // 最后一次更新的集数
    latestUpdate: 6,
    tags: ['权谋','重生','家庭'],
    index: '3',
    id: 'vegetable-2',
    image: $r('app.media.startIcon'),
    intro: '富含铁质，口感鲜嫩',
    type: 'vegetable',
    classId: 'vegetable'
  },
  {
    title: '鸡肉',
    episodes: 108,
    // 最后一次更新的集数
    latestUpdate: 6,
    tags: ['权谋','重生','家庭'],
    index: '4',
    id: 'meat-2',
    image: $r('app.media.startIcon'),
    intro: '口感鲜美，富含蛋白质',
    type: 'meat',
    classId: 'meat'
  },
  {
    title: '橙子',
    episodes: 108,
    // 最后一次更新的集数
    latestUpdate: 6,
    tags: ['权谋','重生','家庭'],
    index: '5',
    id: 'fruit-3',
    image: $r('app.media.startIcon'),
    intro: '富含维生素C，口感酸甜',
    type: 'fruit',
    classId: 'fruit'
  },
  {
    title: '葡萄',
    episodes: 108,
    // 最后一次更新的集数
    latestUpdate: 6,
    tags: ['权谋','重生','家庭'],
    index: '6',
    id: 'fruit-4',
    image: $r('app.media.startIcon'),
    intro: '口感酸甜，富含多种维生素',
    type: 'fruit',
    classId: 'fruit'
  },
  {
    title: '草莓',
    episodes: 108,
    // 最后一次更新的集数
    latestUpdate: 6,
    tags: ['权谋','重生','家庭'],
    index: '7',
    id: 'fruit-5',
    image: $r('app.media.startIcon'),
    intro: '口感酸甜，富含抗氧化物质',
    type: 'fruit',
    classId: 'fruit'
  },
  {
    title: '西瓜',
    episodes: 108,
    // 最后一次更新的集数
    latestUpdate: 6,
    tags: ['权谋','重生','家庭'],
    index: '8',
    id: 'fruit-6',
    image: $r('app.media.startIcon'),
    intro: '口感脆甜，富含维生素C',
    type: 'fruit',
    classId: 'fruit'
  },
  {
    title: '香蕉',
    episodes: 108,
    // 最后一次更新的集数
    latestUpdate: 6,
    tags: ['权谋','重生','家庭'],
    index: '9',
    id: 'fruit-2',
    image: $r('app.media.startIcon'),
    intro: '富含钾元素，口感软甜',
    type: 'fruit',
    classId: 'fruit'
  }
];

export const SEARCH_RESULTS_MOCK: FilterTagAndList[] = [
  {
    label: '古装',
    id: 'fruit',
    itemList: [
      {
        title: '苹果',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '1',
        id: 'fruit-1',
        image: $r('app.media.startIcon'),
        intro: '口感脆甜，富含维生素C',
        price: 5.99
      },
      {
        title: '香蕉',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '2',
        id: 'fruit-2',
        image: $r('app.media.startIcon'),
        intro: '富含钾元素，口感软甜'
      },
      {
        title: '橙子',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '3',
        id: 'fruit-3',
        image: $r('app.media.startIcon'),
        intro: '富含维生素C，口感酸甜'
      },
      {
        title: '葡萄',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '4',
        id: 'fruit-4',
        image: $r('app.media.startIcon'),
        intro: '口感酸甜，富含多种维生素'
      },
      {
        title: '草莓',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '5',
        id: 'fruit-5',
        image: $r('app.media.startIcon'),
        intro: '口感酸甜，富含抗氧化物质'
      },
      {
        title: '西瓜',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '6',
        id: 'fruit-6',
        image: $r('app.media.startIcon'),
        intro: '口感脆甜，富含维生素C'
      },
      {
        title: '苹果',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '7',
        id: 'fruit-7',
        image: $r('app.media.startIcon'),
        intro: '口感脆甜，富含维生素C',
        price: 5.99
      },
      {
        title: '香蕉',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '8',
        id: 'fruit-8',
        image: $r('app.media.startIcon'),
        intro: '富含钾元素，口感软甜'
      },
      {
        title: '橙子',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '9',
        id: 'fruit-9',
        image: $r('app.media.startIcon'),
        intro: '富含维生素C，口感酸甜'
      },
      {
        title: '葡萄',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '10',
        id: 'fruit-10',
        image: $r('app.media.startIcon'),
        intro: '口感酸甜，富含多种维生素'
      },
      {
        title: '草莓',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '11',
        id: 'fruit-11',
        image: $r('app.media.startIcon'),
        intro: '口感酸甜，富含抗氧化物质'
      }
    ]
  },
  {
    label: '家庭',
    id: 'vegetable',
    itemList: [
      {
        title: '胡萝卜',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '1',
        id: 'vegetable-1',
        image: $r('app.media.startIcon'),
        intro: '富含维生素A，口感脆甜'
      },
      {
        title: '菠菜',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '2',
        id: 'vegetable-2',
        image: $r('app.media.startIcon'),
        intro: '富含铁质，口感鲜嫩'
      }
    ]
  },
  {
    label: '年代',
    id: 'meat',
    itemList: [
      {
        title: '牛肉',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '1',
        id: 'meat-1',
        image: $r('app.media.startIcon'),
        intro: '富含蛋白质，口感鲜嫩'
      },
      {
        title: '鸡肉',
        episodes: 108,
        // 最后一次更新的集数
        latestUpdate: 6,
        tags: ['权谋','重生','家庭'],
        index: '2',
        id: 'meat-2',
        image: $r('app.media.startIcon'),
        intro: '口感鲜美，富含蛋白质'
      }
    ]
  },
  {
    label: '穿越',
    id: 'meat1',
    itemList: []
  },
  {
    label: '职场',
    id: 'meat2',
    itemList: []
  },
  {
    label: '重生',
    id: 'meat3',
    itemList: []
  },
  {
    label: '权谋',
    id: 'meat4',
    itemList: []
  },
  {
    label: '情感',
    id: 'meat5',
    itemList: []
  },
  {
    label: '悬疑',
    id: 'meat6',
    itemList: []
  },
  {
    label: '搞笑',
    id: 'meat7',
    itemList: []
  }
];

export const GUESS_LIKE_LIST1: SearchWordItem[] = [
  {
    content: '单行展示，超长文本截断',
    id: '001'
  },
  {
    content: '推荐词A',
    id: '002'
  },
  {
    content: '推荐词B',
    id: '003'
  },
  {
    content: '推荐词C',
    id: '004'
  },
];

export const GUESS_LIKE_LIST2: SearchWordItem[] = [
  {
    content: '推荐词A',
    id: '002'
  },
  {
    content: '推荐词B',
    id: '003'
  },
  {
    content: '单行展示，超长文本截断',
    id: '001'
  },
  {
    content: '推荐词C',
    id: '004'
  },
  {
    content: '推荐词D',
    id: '005'
  }
];

export const HISTORY_MOCK: SearchWordItem[] = [
  // {
  //   content: '单行展示，超长文本截断',
  //   id: '001'
  // },
  // {
  //   content: '推荐词A',
  //   id: '002'
  // },
  // {
  //   content: '推荐词B',
  //   id: '003'
  // },
  // {
  //   content: '推荐词C',
  //   id: '004'
  // },
  // {
  //   content: '推荐词推荐词推荐词推荐词超长推荐词',
  //   id: '008'
  // }
];