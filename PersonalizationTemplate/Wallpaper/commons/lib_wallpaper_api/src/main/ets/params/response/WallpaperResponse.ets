import { AuthorResponse } from './AuthorResponse'

/**
 * 壁纸模型-云侧接口响应模型
 */
export interface WallpaperResponse {
  id: string,
  authorImage: string
  authorNickName: string
  url: ResourceStr
  type: string
  hotValue: number
  author: AuthorResponse
  time: string
}

//一级Tab
export interface WallpaperSuperTab {
  name: string
  id: string
  child: WallpaperChildTab[]
}

//二级Tab
export interface WallpaperChildTab {
  id: string
  name: string
}

// 桌面小组件卡片
export interface WallpaperCard {
  cardItem: CardItem[]
  total: number
}

export interface CardItem {
  cardType: number,
  cards: Card[]
}

export interface Card {
  id: number;
  cardSize: 'small' | 'medium' | 'large';
  type: 'weather' | 'woodenFish';
  data: ESObject;
}

