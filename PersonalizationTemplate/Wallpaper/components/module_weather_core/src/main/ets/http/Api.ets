import { DailyWeather, HourlyWeather, RealTimeWeather, IndicesWeather } from '../common/CoreType';
import { CommonUtil } from '../utils/CommonUtil';

export class WeatherMgtApi {
  private static readonly _mockDailyWeatherList: DailyWeather[] = [
    // 昨天
    {
      time: '',
      maxTemp: 38,
      minTemp: 25,
      dayDesc: '晴',
      dayIcon: 'ic_weather_sunny_day',
      nightDesc: '多云',
      nightIcon: 'ic_weather_mostcloudy_night',
      airQuality: '优',
      rain: 10,
    },
    {
      time: '',
      maxTemp: 39,
      minTemp: 26,
      dayDesc: '晴',
      dayIcon: 'ic_weather_sunny_day',
      nightDesc: '多云',
      nightIcon: 'ic_weather_mostcloudy_night',
      airQuality: '优',
      rain: 20,
    },
    {
      time: '',
      maxTemp: 38,
      minTemp: 26,
      dayDesc: '晴',
      dayIcon: 'ic_weather_sunny_day',
      nightDesc: '晴',
      nightIcon: 'ic_weather_sunny_night',
      airQuality: '优',
      rain: 10,
    },
    {
      time: '',
      maxTemp: 38,
      minTemp: 26,
      dayDesc: '晴',
      dayIcon: 'ic_weather_sunny_day',
      nightDesc: '晴',
      nightIcon: 'ic_weather_sunny_night',
      airQuality: '优',
      rain: 10,
    },
    {
      time: '',
      maxTemp: 36,
      minTemp: 24,
      dayDesc: '多云',
      dayIcon: 'ic_weather_mostcloudy_day',
      nightDesc: '多云',
      nightIcon: 'ic_weather_mostcloudy_night',
      airQuality: '优',
      rain: 20,
    },
    {
      time: '',
      maxTemp: 37,
      minTemp: 27,
      dayDesc: '多云',
      dayIcon: 'ic_weather_mostcloudy_day',
      nightDesc: '多云',
      nightIcon: 'ic_weather_mostcloudy_night',
      airQuality: '优',
      rain: 20,
    },
    {
      time: '',
      maxTemp: 38,
      minTemp: 26,
      dayDesc: '多云',
      dayIcon: 'ic_weather_mostcloudy_day',
      nightDesc: '多云',
      nightIcon: 'ic_weather_mostcloudy_night',
      airQuality: '良',
      rain: 30,
    },
    {
      time: '',
      maxTemp: 35,
      minTemp: 25,
      dayDesc: '多云',
      dayIcon: 'ic_weather_mostcloudy_day',
      nightDesc: '阴',
      nightIcon: 'ic_weather_cloudy',
      airQuality: '差',
      rain: 40,
    },
    {
      time: '',
      maxTemp: 34,
      minTemp: 25,
      dayDesc: '小雨',
      dayIcon: 'ic_weather_lightrain',
      nightDesc: '小雨',
      nightIcon: 'ic_weather_lightrain',
      airQuality: '良',
      rain: 50,
    },
    {
      time: '',
      maxTemp: 34,
      minTemp: 24,
      dayDesc: '小雨',
      dayIcon: 'ic_weather_lightrain',
      nightDesc: '小雨',
      nightIcon: 'ic_weather_lightrain',
      airQuality: '优',
      rain: 60,
    },
    {
      time: '',
      maxTemp: 33,
      minTemp: 22,
      dayDesc: '小雨',
      dayIcon: 'ic_weather_lightrain',
      nightDesc: '中雨',
      nightIcon: 'ic_weather_rain',
      airQuality: '优',
      rain: 70,
    },
    {
      time: '',
      maxTemp: 32,
      minTemp: 22,
      dayDesc: '中雨',
      dayIcon: 'ic_weather_rain',
      nightDesc: '小雨',
      nightIcon: 'ic_weather_lightrain',
      airQuality: '优',
      rain: 80,
    },
    {
      time: '',
      maxTemp: 34,
      minTemp: 24,
      dayDesc: '小雨',
      dayIcon: 'ic_weather_lightrain',
      nightDesc: '阴',
      nightIcon: 'ic_weather_cloudy',
      airQuality: '优',
      rain: 50,
    },
    {
      time: '',
      maxTemp: 36,
      minTemp: 26,
      dayDesc: '多云',
      dayIcon: 'ic_weather_mostcloudy_day',
      nightDesc: '多云',
      nightIcon: 'ic_weather_mostcloudy_night',
      airQuality: '良',
      rain: 40,
    },
    {
      time: '',
      maxTemp: 36,
      minTemp: 27,
      dayDesc: '多云',
      dayIcon: 'ic_weather_mostcloudy_day',
      nightDesc: '晴',
      nightIcon: 'ic_weather_mostcloudy_night',
      airQuality: '良',
      rain: 20,
    },
    {
      time: '',
      maxTemp: 39,
      minTemp: 27,
      dayDesc: '晴',
      dayIcon: 'ic_weather_sunny_day',
      nightDesc: '晴',
      nightIcon: 'ic_weather_sunny_night',
      airQuality: '优',
      rain: 10,
    },
  ];
  private static readonly _mockHourlyWeatherList: HourlyWeather[] = [
    {
      time: '00:00',
      temp: 28.4,
      desc: '多云',
      icon: 'ic_weather_mostcloudy_night',
      airQuality: '优',
    },
    {
      time: '01:00',
      temp: 27.9,
      desc: '多云',
      icon: 'ic_weather_mostcloudy_night',
      airQuality: '优',
    },
    {
      time: '02:00',
      temp: 27.4,
      desc: '晴',
      icon: 'ic_weather_sunny_night',
      airQuality: '优',
    },
    {
      time: '03:00',
      temp: 27.2,
      desc: '晴',
      icon: 'ic_weather_sunny_night',
      airQuality: '优',
    },
    {
      time: '04:00',
      temp: 26.8,
      desc: '多云',
      icon: 'ic_weather_mostcloudy_night',
      airQuality: '优',
    },
    // 最低
    {
      time: '05:00',
      temp: 26,
      desc: '多云',
      icon: 'ic_weather_mostcloudy_night',
      airQuality: '优',
    },
    // 白天
    {
      time: '06:00',
      temp: 26.6,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '优',
    },
    {
      time: '07:00',
      temp: 27.4,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '优',
    },
    {
      time: '08:00',
      temp: 29.4,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '优',
    },
    {
      time: '09:00',
      temp: 34.8,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '优',
    },
    {
      time: '10:00',
      temp: 35.3,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '优',
    },
    {
      time: '11:00',
      temp: 35.5,
      desc: '多云',
      icon: 'ic_weather_mostcloudy_day',
      airQuality: '良',
    },
    {
      time: '12:00',
      temp: 36.6,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '优',
    },
    {
      time: '13:00',
      temp: 38.2,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '良',
    },
    // 最高
    {
      time: '14:00',
      temp: 39,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '良',
    },
    {
      time: '15:00',
      temp: 37.8,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '良',
    },
    {
      time: '16:00',
      temp: 36.1,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '优',
    },
    {
      time: '17:00',
      temp: 34.8,
      desc: '多云',
      icon: 'ic_weather_mostcloudy_day',
      airQuality: '优',
    },
    {
      time: '18:00',
      temp: 32.7,
      desc: '晴',
      icon: 'ic_weather_sunny_day',
      airQuality: '良',
    },
    // 晚上
    {
      time: '19:00',
      temp: 32.1,
      desc: '晴',
      icon: 'ic_weather_sunny_night',
      airQuality: '良',
    },
    {
      time: '20:00',
      temp: 30.8,
      desc: '晴',
      icon: 'ic_weather_sunny_night',
      airQuality: '优',
    },
    {
      time: '21:00',
      temp: 30.1,
      desc: '晴',
      icon: 'ic_weather_sunny_night',
      airQuality: '优',
    },
    {
      time: '22:00',
      temp: 29.4,
      desc: '晴',
      icon: 'ic_weather_sunny_night',
      airQuality: '优',
    },
    {
      time: '23:00',
      temp: 28.9,
      desc: '晴',
      icon: 'ic_weather_sunny_night',
      airQuality: '优',
    },
  ];
  private static readonly _mockIndicesWeatherList1: IndicesWeather[] = [
    {
      time: '',
      type: 1,
      name: '穿衣指数',
      level: 6,
      category: '炎热',
      text: '“穿衣指数” 是结合气象条件和人体感受的衣物选择参考指标。它参考气温、湿度、风力等因素，划分不同等级。' +
        '高指数可能对应炎热天气，建议穿透气清凉衣物；低指数多为寒冷时节，需着厚重保暖服饰，助人们穿得舒适得体。',
      icon: 'ic_indices_dress',
    },
    {
      time: '',
      type: 2,
      name: '旅游指数',
      level: 3,
      category: '较不宜',
      text: '“旅游指数” 是依据气象、环境等条件生成的出游参考指标。它综合考量气温、风力、降水、空气质量及景区人流等因素，划分不同等级。' +
        '高指数时适合出游，低指数则提示需注意天气或人流影响，助人们合理规划行程。',
      icon: 'ic_indices_travel',
    },
    {
      time: '',
      type: 3,
      name: '运动指数',
      level: 4,
      category: '不宜',
      text: '“运动指数” 是结合气象与人体舒适度给出的运动参考指标。它考量气温、湿度、风力、紫外线等因素，划分等级。' +
        '高指数适合户外剧烈运动，低指数则建议选择室内或轻度运动，帮人们科学安排锻炼。',
      icon: 'ic_indices_sport',
    },
    {
      time: '',
      type: 4,
      name: '钓鱼指数',
      level: 2,
      category: '较适宜',
      text: '“钓鱼指数” 是结合气象、水文等条件给出的钓鱼适宜度参考指标。它参考水温、气压、风力、天气状况等因素，划分不同等级。' +
        '高指数时鱼类活跃度高，适合外出垂钓；低指数则提示鱼类活动减少，建议调整钓鱼时间或地点，',
      icon: 'ic_indices_fish',
    },
    {
      time: '',
      type: 5,
      name: '感冒指数',
      level: 1,
      category: '少发',
      text: '“感冒指数” 是结合气象条件和病毒传播环境给出的感冒易发程度参考指标。高指数时感冒病毒易传播，人体易受侵袭，' +
        '需加强保暖、勤通风；低指数则提示感冒风险较低，仍需注意日常防护，帮助人们有效预防感冒。',
      icon: 'ic_indices_flu',
    },
    {
      time: '',
      type: 6,
      name: '敏感指数',
      level: 1,
      category: '少发',
      text: '“过敏指数” 是结合气象条件与致敏原浓度给出的过敏易发程度参考指标。高指数时致敏原活跃，易引发过敏反应，' +
        '需减少外出、佩戴口罩；低指数则过敏风险较低，敏感人群仍需留意环境变化，助力人们科学规避过敏困扰。',
      icon: 'ic_indices_flower',
    },
    {
      time: '',
      type: 7,
      name: '洗车指数',
      level: 1,
      category: '适宜',
      text: '“洗车指数” 是结合气象条件给出的洗车适宜度参考指标。高指数时天气晴朗少风、灰尘少，适合洗车；' +
        '低指数则可能预示降水或大风扬尘，建议暂缓洗车，帮助人们合理安排洗车时间，避免白费功夫。',
      icon: 'ic_indices_car',
    },
    {
      time: '',
      type: 8,
      name: '观星指数',
      level: 1,
      category: '适宜',
      text: '“观星指数” 是结合气象与天文条件给出的星空观测适宜度参考指标。高指数时天空晴朗少云、光污染低，适合观测星空；' +
        '低指数则可能因多云、雾霾或强光影响，建议调整观测时间或地点，助天文爱好者获得更佳观星体验。',
      icon: 'ic_indices_star',
    },
  ];
  private static readonly _mockIndicesWeatherList2: IndicesWeather[] = [
    {
      time: '',
      type: 1,
      name: '穿衣指数',
      level: 6,
      category: '炎热',
      text: '“穿衣指数” 是结合气象条件和人体感受的衣物选择参考指标。它参考气温、湿度、风力等因素，划分不同等级。' +
        '高指数可能对应炎热天气，建议穿透气清凉衣物；低指数多为寒冷时节，需着厚重保暖服饰，助人们穿得舒适得体。',
      icon: 'ic_indices_dress',
    },
    {
      time: '',
      type: 2,
      name: '旅游指数',
      level: 3,
      category: '较不宜',
      text: '“旅游指数” 是依据气象、环境等条件生成的出游参考指标。它综合考量气温、风力、降水、空气质量及景区人流等因素，划分不同等级。' +
        '高指数时适合出游，低指数则提示需注意天气或人流影响，助人们合理规划行程。',
      icon: 'ic_indices_travel',
    },
    {
      time: '',
      type: 3,
      name: '运动指数',
      level: 3,
      category: '较不宜',
      text: '“运动指数” 是结合气象与人体舒适度给出的运动参考指标。它考量气温、湿度、风力、紫外线等因素，划分等级。' +
        '高指数适合户外剧烈运动，低指数则建议选择室内或轻度运动，帮人们科学安排锻炼。',
      icon: 'ic_indices_sport',
    },
    {
      time: '',
      type: 4,
      name: '钓鱼指数',
      level: 1,
      category: '适宜',
      text: '“钓鱼指数” 是结合气象、水文等条件给出的钓鱼适宜度参考指标。它参考水温、气压、风力、天气状况等因素，划分不同等级。' +
        '高指数时鱼类活跃度高，适合外出垂钓；低指数则提示鱼类活动减少，建议调整钓鱼时间或地点，',
      icon: 'ic_indices_fish',
    },
    {
      time: '',
      type: 5,
      name: '感冒指数',
      level: 2,
      category: '较易发',
      text: '“感冒指数” 是结合气象条件和病毒传播环境给出的感冒易发程度参考指标。高指数时感冒病毒易传播，人体易受侵袭，' +
        '需加强保暖、勤通风；低指数则提示感冒风险较低，仍需注意日常防护，帮助人们有效预防感冒。',
      icon: 'ic_indices_flu',
    },
    {
      time: '',
      type: 6,
      name: '敏感指数',
      level: 2,
      category: '较易发',
      text: '“过敏指数” 是结合气象条件与致敏原浓度给出的过敏易发程度参考指标。高指数时致敏原活跃，易引发过敏反应，' +
        '需减少外出、佩戴口罩；低指数则过敏风险较低，敏感人群仍需留意环境变化，助力人们科学规避过敏困扰。',
      icon: 'ic_indices_flower',
    },
    {
      time: '',
      type: 7,
      name: '洗车指数',
      level: 2,
      category: '较适宜',
      text: '“洗车指数” 是结合气象条件给出的洗车适宜度参考指标。高指数时天气晴朗少风、灰尘少，适合洗车；' +
        '低指数则可能预示降水或大风扬尘，建议暂缓洗车，帮助人们合理安排洗车时间，避免白费功夫。',
      icon: 'ic_indices_car',
    },
    {
      time: '',
      type: 8,
      name: '观星指数',
      level: 2,
      category: '较适宜',
      text: '“观星指数” 是结合气象与天文条件给出的星空观测适宜度参考指标。高指数时天空晴朗少云、光污染低，适合观测星空；' +
        '低指数则可能因多云、雾霾或强光影响，建议调整观测时间或地点，助天文爱好者获得更佳观星体验。',
      icon: 'ic_indices_star',
    },
  ];
  private static readonly _mockIndicesWeatherList3: IndicesWeather[] = [
    {
      time: '',
      type: 1,
      name: '穿衣指数',
      level: 6,
      category: '炎热',
      text: '“穿衣指数” 是结合气象条件和人体感受的衣物选择参考指标。它参考气温、湿度、风力等因素，划分不同等级。' +
        '高指数可能对应炎热天气，建议穿透气清凉衣物；低指数多为寒冷时节，需着厚重保暖服饰，助人们穿得舒适得体。',
      icon: 'ic_indices_dress',
    },
    {
      time: '',
      type: 2,
      name: '旅游指数',
      level: 4,
      category: '不宜',
      text: '“旅游指数” 是依据气象、环境等条件生成的出游参考指标。它综合考量气温、风力、降水、空气质量及景区人流等因素，划分不同等级。' +
        '高指数时适合出游，低指数则提示需注意天气或人流影响，助人们合理规划行程。',
      icon: 'ic_indices_travel',
    },
    {
      time: '',
      type: 3,
      name: '运动指数',
      level: 4,
      category: '不宜',
      text: '“运动指数” 是结合气象与人体舒适度给出的运动参考指标。它考量气温、湿度、风力、紫外线等因素，划分等级。' +
        '高指数适合户外剧烈运动，低指数则建议选择室内或轻度运动，帮人们科学安排锻炼。',
      icon: 'ic_indices_sport',
    },
    {
      time: '',
      type: 4,
      name: '钓鱼指数',
      level: 3,
      category: '较不宜',
      text: '“钓鱼指数” 是结合气象、水文等条件给出的钓鱼适宜度参考指标。它参考水温、气压、风力、天气状况等因素，划分不同等级。' +
        '高指数时鱼类活跃度高，适合外出垂钓；低指数则提示鱼类活动减少，建议调整钓鱼时间或地点，',
      icon: 'ic_indices_fish',
    },
    {
      time: '',
      type: 5,
      name: '感冒指数',
      level: 3,
      category: '易发',
      text: '“感冒指数” 是结合气象条件和病毒传播环境给出的感冒易发程度参考指标。高指数时感冒病毒易传播，人体易受侵袭，' +
        '需加强保暖、勤通风；低指数则提示感冒风险较低，仍需注意日常防护，帮助人们有效预防感冒。',
      icon: 'ic_indices_flu',
    },
    {
      time: '',
      type: 6,
      name: '敏感指数',
      level: 3,
      category: '易发',
      text: '“过敏指数” 是结合气象条件与致敏原浓度给出的过敏易发程度参考指标。高指数时致敏原活跃，易引发过敏反应，' +
        '需减少外出、佩戴口罩；低指数则过敏风险较低，敏感人群仍需留意环境变化，助力人们科学规避过敏困扰。',
      icon: 'ic_indices_flower',
    },
    {
      time: '',
      type: 7,
      name: '洗车指数',
      level: 2,
      category: '较适宜',
      text: '“洗车指数” 是结合气象条件给出的洗车适宜度参考指标。高指数时天气晴朗少风、灰尘少，适合洗车；' +
        '低指数则可能预示降水或大风扬尘，建议暂缓洗车，帮助人们合理安排洗车时间，避免白费功夫。',
      icon: 'ic_indices_car',
    },
    {
      time: '',
      type: 8,
      name: '观星指数',
      level: 3,
      category: '较不宜',
      text: '“观星指数” 是结合气象与天文条件给出的星空观测适宜度参考指标。高指数时天空晴朗少云、光污染低，适合观测星空；' +
        '低指数则可能因多云、雾霾或强光影响，建议调整观测时间或地点，助天文爱好者获得更佳观星体验。',
      icon: 'ic_indices_star',
    },
  ];
  private static readonly _mockWindDirList: string[] =
    ['东风', '西风', '南方', '北风', '东南方', '东北风', '西南风', '西北风'];

  public static getRealTimeWeather(codes: string[]): Promise<RealTimeWeather[]> {
    const res: RealTimeWeather[] = [];
    for (let i = 0; i < codes.length; i++) {
      /**
       * 与15天的当天天气保持一致
       */
      const maxTemp = WeatherMgtApi._mockDailyWeatherList[1].maxTemp;
      const minTemp = WeatherMgtApi._mockDailyWeatherList[1].minTemp;
      const rain = WeatherMgtApi._mockDailyWeatherList[1].rain;
      /**
       * 与逐小时的当前天气保持一致
       */
      const now = WeatherMgtApi._mockHourlyWeatherList[new Date().getHours()];
      const temp = now.temp;
      const airQuality = now.airQuality;
      const desc = now.desc;
      const icon = now.icon;

      /**
       * 随机生成
       */
      const shellTemp = CommonUtil.generateRandomInRange(temp - 5, temp + 5);
      const humidity = CommonUtil.generateRandomInRange(30, 60);
      const pressure = CommonUtil.generateRandomInRange(940, 1020);
      const uv = WeatherMgtApi._isDaytime() ? CommonUtil.generateRandomInRange(1, 4) : 0;
      const windDir = WeatherMgtApi._mockWindDirList[CommonUtil.generateRandomInRange(0, 7)];
      const winSpeed = CommonUtil.generateRandomInRange(1, 4);

      res.push({
        time: new Date().toString(),
        temp,
        maxTemp,
        minTemp,
        shellTemp,
        humidity,
        rain,
        desc,
        icon,
        pressure,
        uv,
        windDir,
        winSpeed,
        airQuality,
      });
    }
    return Promise.resolve(res);
  }

  public static getWeatherIn16Days(code: string): Promise<DailyWeather[]> {
    for (let i = 0; i < WeatherMgtApi._mockDailyWeatherList.length; i++) {
      WeatherMgtApi._mockDailyWeatherList[i].time = WeatherMgtApi._getFutureDate(i - 1);
    }
    return Promise.resolve(WeatherMgtApi._mockDailyWeatherList);
  }

  public static getHourlyWeather(code: string): Promise<HourlyWeather[]> {
    const curHour = new Date().getHours();
    if (curHour) {
      const toady = WeatherMgtApi._mockHourlyWeatherList.slice(curHour);
      const nextDay = WeatherMgtApi._mockHourlyWeatherList.slice(0, curHour);
      return Promise.resolve(toady.concat(nextDay));
    }
    return Promise.resolve(WeatherMgtApi._mockHourlyWeatherList);
  }

  public static getIndicesWeather(code: string, day: 1 | 3): Promise<IndicesWeather[][]> {
    const day1 = WeatherMgtApi._getFutureDate(0)
    const day2 = WeatherMgtApi._getFutureDate(1)
    const day3 = WeatherMgtApi._getFutureDate(2)
    if (day === 1) {
      WeatherMgtApi._mockIndicesWeatherList1.forEach(weather => weather.time = day1);
      return Promise.resolve(
        [
          WeatherMgtApi._mockIndicesWeatherList1,
        ]);
    } else {
      WeatherMgtApi._mockIndicesWeatherList1.forEach(weather => weather.time = day1);
      WeatherMgtApi._mockIndicesWeatherList2.forEach(weather => weather.time = day2);
      WeatherMgtApi._mockIndicesWeatherList3.forEach(weather => weather.time = day3);
      return Promise.resolve(
        [
          WeatherMgtApi._mockIndicesWeatherList1,
          WeatherMgtApi._mockIndicesWeatherList2,
          WeatherMgtApi._mockIndicesWeatherList3,
        ])
    }
  }

  private static _isDaytime(): boolean {
    const time = new Date();
    const hours = time.getHours();
    return hours >= 6 && hours < 18;
  }

  private static _getFutureDate(offset: number): string {
    const currentDate = new Date();
    const futureTime = currentDate.getTime() + offset * 86400000;
    const futureDate = new Date(futureTime);
    const year = futureDate.getFullYear();
    const month = futureDate.getMonth() + 1;
    const day = futureDate.getDate();
    const formattedMonth = month.toString().padStart(2, '0');
    const formattedDay = day.toString().padStart(2, '0');
    return `${year}-${formattedMonth}-${formattedDay}`;
  }
}
