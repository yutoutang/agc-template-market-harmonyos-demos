import { DailyWeather, HourlyWeather, IndicesWeather, RealTimeWeather } from '../common/CoreType';
import { WeatherMgtApi } from '../http/Api';

/**
 * 天气核心Utils
 */
export class WeatherUtils {
  /**
   * 获取实时天气
   * @param code:行政区码
   * @returns 实时天气
   */
  public static getRealTimeWeathers(codes: string[]): Promise<RealTimeWeather[]> {
    return WeatherMgtApi.getRealTimeWeather(codes);
  }

  /**
   * 获取逐小时天气
   * @param code:行政区码
   * @returns 逐小时天气
   */
  public static getHourlyWeathers(code: string): Promise<HourlyWeather[]> {
    return WeatherMgtApi.getHourlyWeather(code);
  }

  /**
   * 获取16天内天气(包含昨天)
   * @param code
   * @returns 16天内天气
   */
  public static getDailyWeathers(code: string): Promise<DailyWeather[]> {
    return WeatherMgtApi.getWeatherIn16Days(code);
  }

  /**
   * 获取天气指数
   * @param code
   * @returns 天气指数
   */
  public static getIndicesWeathers(code: string, day: 1 | 3): Promise<IndicesWeather[][]> {
    return WeatherMgtApi.getIndicesWeather(code, day);
  }
}