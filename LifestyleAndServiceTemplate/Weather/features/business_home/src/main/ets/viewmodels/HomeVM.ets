import { AppStorageMap, LocationInfo, WindowUtil } from 'lib_foundation';
import { CityManager } from 'module_city_manage';
import { BroadCastUtil, VoiceType } from 'module_voice_broadcast';
import { DailyWeather, HourlyWeather, IndicesWeather, RealTimeWeather, WeatherUtils } from 'module_weather_core';
import { WidgetUtil } from '../utils/WidgetUtil';

@ObservedV2
export class HomeVM {
  @Trace rate: number = 0;
  @Trace location: LocationInfo = { name: '北京', code: '110100' };
  @Trace realTimeWeather: RealTimeWeather | undefined;
  @Trace hourlyWeathers: HourlyWeather[] = [];
  @Trace dailyWeathers: DailyWeather[] = [];
  @Trace indicesWeathers: IndicesWeather[][] = [];
  private static _instance: HomeVM;
  scrollerController: Scroller = new Scroller();
  swiperController: SwiperController = new SwiperController();
  topPadding: number = 536;

  @Monitor('location')
  private _change() {
    WidgetUtil.setLocation(this.location, getContext());
    WidgetUtil.updateWeatherInfo(getContext());
    WeatherUtils.getRealTimeWeathers([this.location.code]).then(res => {
      this.realTimeWeather = res[0];
      AppStorage.setOrCreate(AppStorageMap.REALTIME_WEATHER, this.realTimeWeather);
    });
    WeatherUtils.getHourlyWeathers(this.location.code).then(res => this.hourlyWeathers = res);
    WeatherUtils.getDailyWeathers(this.location.code).then(res => this.dailyWeathers = res);
    WeatherUtils.getIndicesWeathers(this.location.code, 3).then(res => {
      this.indicesWeathers = res;
      AppStorage.setOrCreate(AppStorageMap.INDICES, this.indicesWeathers);
    });
  }

  public static get instance() {
    if (!HomeVM._instance) {
      HomeVM._instance = new HomeVM();
    }
    return HomeVM._instance;
  }

  public async init() {
    const res = await CityManager.applyLocationPermission();
    this.location = { name: res.name, code: res.code };
  }

  public scroll() {
    const temp =
      this.scrollerController.currentOffset().yOffset / (this.topPadding - WindowUtil.getAvoidArea().top - 56);
    if (temp >= 1) {
      this.rate = 1;
    } else {
      this.rate = temp;
    }

    if (this.rate > 0.5) {
      this.swiperController.changeIndex(1, true);
    } else {
      this.swiperController.changeIndex(0, true);
    }
  }

  /**
   * 播报能力
   * 英文播报更多内容前,自行翻译
   */
  public speak() {
    let text = '';
    const tempRound = this.realTimeWeather!.temp.toFixed();
    if (BroadCastUtil.getCurVoiceType() !== VoiceType.US_FEMALE) {
      text = `实时气温 ${tempRound}摄氏度,
             最高气温 ${this.realTimeWeather!.maxTemp}摄氏度,
             最低气温 ${this.realTimeWeather!.minTemp}摄氏度`;
    } else {
      text = `The real-time temperature is ${tempRound} degrees Celsius,
              the maximum temperature is ${this.realTimeWeather!.maxTemp} degrees Celsius,
              the minimum temperature is ${this.realTimeWeather!.minTemp} degrees Celsius`;
    }
    BroadCastUtil.speak(text);
  }
}