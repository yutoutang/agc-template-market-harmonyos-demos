/**
 * 壁纸数据库字段
 */

export interface BaseWallpaper {
  id: string
  url: string
  authorImage: string
  authorNickName: string
  typeId: string
  hotValue: number
  time: string
}

//一级Tab
export interface WallpaperSuperTab {
  id: string
  text: string
  child: WallpaperChildTab[]
}

//二级Tab
export interface WallpaperChildTab {
  id: string
  text: string
}

export interface MarkWallpaper {
  markImage: ResourceStr,
  markTitle: string,
  markTags: string[],
  authorAvatar: ResourceStr,
  authorName: string,
  markTime: string
}


// 桌面小组件卡片
export interface CardItem {
  cardType: number,
  cards: Card[]
}

export interface Card {
  id: number;
  type: 'weather' | 'woodenFish';
  cardSize: 'small' | 'medium' | 'large';
  data: ESObject;
}

export interface AddMyComponentInfo {
  type: 'weather' | 'woodenFish';
  cardSize: 'small' | 'medium' | 'large';
  data: ESObject;
}