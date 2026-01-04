import { BaseViewModel, BreakpointModel, RouterMap, RouterUtils } from 'lib_common';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class DesktopViewModel extends BaseViewModel {
  @Trace formCardRouter: FormCardRouterModel =
    AppStorageV2.connect(FormCardRouterModel, () => new FormCardRouterModel())!;
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  editJumpMyComponent() {
    RouterUtils.pop();
  }

  jumpTutorial() {
    RouterUtils.pushPathByName(RouterMap.TUTORIAL_PAGE);
  }

  jumpMyComponent() {
    RouterUtils.pushPathByName(RouterMap.MY_COMPONENT_PAGE);
  }

  jumpComponentDetail(params: ComponentDetailTitle) {
    RouterUtils.pushPathByName(RouterMap.COMPONENT_DETAIL_PAGE, params);
  }

  jumpLogin() {
    RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE);
  }
}

export interface ComponentDetailTitle {
  type: 'weather' | 'woodenFish',
  isMyComponent?: boolean,
  size: 'small' | 'medium' | 'large',
  componentInfo?: WeatherCardInfo | WoodenFishCardInfo,
  id?: number
}

export interface CardSize {
  size: 'small' | 'medium' | 'large',
  type: 'weather' | 'woodenFish',
}

@ObservedV2
export class WeatherCardInfo {
  @Trace location: string = ''
  @Trace temp: string = ''
  @Trace weather: string = ''
  @Trace textColor?: string = ''
  @Trace backgroundColorInfo?: string = ''
  @Trace backgroundImgBase64?: string = ''
  @Trace futureWeatherColor?: string = ''
  @Trace backgroundImg?: string = ''
  @Trace highTemp: string = ''
  @Trace lowTemp: string = ''
  @Trace futureWeather?: FutureWeatherInfo[] = []

  constructor(params: WeatherCardParams) {
    this.temp = params.temp;
    this.textColor = params.textColor ?? '#000';
    this.backgroundImgBase64 = params.backgroundImgBase64 ?? '';
    this.futureWeatherColor = params.futureWeatherColor ?? '#99000000';
    this.highTemp = params.highTemp;
    this.lowTemp = params.lowTemp;
    this.futureWeather = params.futureWeather ?? [];
    this.backgroundColorInfo = params.backgroundColorInfo ?? '#fff';
    this.location = params.location;
    this.weather = params.weather;
    this.backgroundImg = params.backgroundImg ?? '';
  }
}

@ObservedV2
export class WoodenFishCardInfo {
  @Trace textColor?: string = ''
  @Trace backgroundImg?: string = ''
  @Trace woodenFishTitle?: string = ''
  @Trace backgroundColorInfo?: string = ''
  @Trace backgroundImgBase64?: string = ''
  @Trace soundEffect?: boolean = true
  @Trace luckValue: number = 0

  constructor(params: WoodenFishCardParams) {
    this.woodenFishTitle = params.woodenFishTitle;
    this.backgroundImg = params.backgroundImg ?? '';
    this.backgroundColorInfo = params.backgroundColorInfo ?? '#fff';
    this.textColor = params.textColor ?? '#99000000';
    this.backgroundImgBase64 = params.backgroundImgBase64;
    this.soundEffect = params.soundEffect ?? true;
    this.luckValue = params.luckValue;
  }
}


export interface FutureWeatherInfo {
  date: string;
  lowTemp: string;
  weather: string;
  highTemp: string;
}

export interface WeatherCardParams {
  location: string;
  backgroundImgBase64?: string; // 可选参数，有默认值
  weather: string;
  temp: string;
  textColor?: string; // 可选参数，有默认值
  highTemp: string;
  futureWeather?: FutureWeatherInfo[];
  backgroundColorInfo?: string; // 可选参数，有默认值
  futureWeatherColor?: string; // 可选参数，有默认值
  backgroundImg?: string; // 可选参数，有默认值
  lowTemp: string;
}

export interface WoodenFishCardParams {
  woodenFishTitle?: string;
  backgroundImgBase64?: string;
  backgroundColorInfo?: string;
  backgroundImg?: string;
  soundEffect?: boolean;
  textColor?: string;
  luckValue: number;
}

@ObservedV2
export class FormCardRouterModel {
  @Trace id: number = 0
  @Trace pageUrl: string = ''
  @Trace cardId: string | number = ''
  @Trace cardInfo: string = ''
  @Trace newsType: number = 0
  @Trace targetPage: string = ''
  @Trace formId: string = ''
  @Trace newsId: string = ''
  @Trace cardSize: 'small' | 'medium' | 'large' = 'small'
  @Trace cardType: 'weather' | 'woodenFish' = 'weather'
}