import { RealTimeWeather, WeatherUtils } from 'module_weather_core';
import { IPosition } from '../types/Types';
import { Loading } from '../utils/Loading';
import { PositionUtl } from '../utils/PostionUtil';
import { CityManager } from '../utils/Utils';

@ObservedV2
export class ManagedVM {
  @Trace edit: boolean = false;
  @Trace postionList: IPosition[] = PositionUtl.getPostionList();
  @Trace minePosition: IPosition = { name: '北京', code: '110100' };
  @Trace mineWeather: RealTimeWeather | undefined;
  @Trace otherWeathers: RealTimeWeather[] = [];
  private static _instance: ManagedVM;

  public static get instance() {
    if (!ManagedVM._instance) {
      ManagedVM._instance = new ManagedVM();
    }
    return ManagedVM._instance;
  }

  public init(ctx: UIContext) {
    this.resetSelectedParams();
    Loading.init(ctx);
    Loading.open();
    Promise.all([this._getMinePositionAndWeather(), this._getOtherPostionAndWeather()]).then(() => {
      Loading.close();
    });
  }

  public resetSelectedParams() {
    this.edit = false;
    this.minePosition = { name: '北京', code: '110100' };
    this.mineWeather = undefined;
    this.otherWeathers = [];
  }

  private async _getMinePositionAndWeather() {
    this.minePosition = await CityManager.applyLocationPermission();
    this.mineWeather = (await WeatherUtils.getRealTimeWeathers([this.minePosition.code]))[0];
  }

  private async _getOtherPostionAndWeather() {
    this.otherWeathers = await WeatherUtils.getRealTimeWeathers(this.postionList.map(item => item.code));
  }
}