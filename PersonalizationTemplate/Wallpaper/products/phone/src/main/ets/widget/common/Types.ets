/**
 * 服务卡片列表item模型
 */
export class FormItemModel {
  id: string = ''
  type: number = 0
  title: string = ''
  createTime: number = 0
  markCount: number = 0
  likeCount: number = 0
  shareCount: number = 0
  isLiked: boolean = false
  isMarked: boolean = false
  postBody: string = ''
  videoUrl: string = ''
  coverUrl: string = ''
  videoDuration: number = 0
  commentCount: number = 0
}

export class WeatherCardInfo {
  location: string = ''
  temp: string = ''
  weather: string = ''
  backgroundColorInfo?: string = ''
  textColor?: string = ''
  futureWeatherColor?: string = ''
  highTemp: string = ''
  lowTemp: string = ''
  backgroundImg?: string = ''
  backgroundImgBase64?: string = ''
  futureWeather?: FutureWeatherInfo[] = []
}

export interface FutureWeatherInfo {
  date: string;
  weather: string;
  lowTemp: string;
  highTemp: string;
}

export class WoodenFishCardInfo {
  woodenFishTitle?: string = ''
  backgroundColorInfo?: string = ''
  textColor?: string = ''
  backgroundImg?: string = ''
  soundEffect?: boolean = true
  luckValue: number = 0
  backgroundImgBase64?: string = ''
}

