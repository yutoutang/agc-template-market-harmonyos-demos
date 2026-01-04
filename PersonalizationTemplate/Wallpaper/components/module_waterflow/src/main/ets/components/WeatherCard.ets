import { FutureWeather } from '../models/DataSource';

@ComponentV2
export struct WeatherCard {
  @Param backgroundImg: string = ''
  @Param futureWeather: FutureWeather[] = []
  @Param cardSize: 'small' | 'medium' | 'large' = 'medium';
  @Param weather: string = '';
  @Param location: string = '';
  @Param highTemp: string = '';
  @Param temp: string = '';
  @Param lowTemp: string = '';
  @Param backgroundColorInfo: string = '#fff';
  @Param futureWeatherColor: string = '#99000000'
  @Param textColor: string = '#000';
  controller: TextClockController = new TextClockController();

  getWeatherImage(weather: string) {
    switch (weather) {
      case '阴':
        return $r('app.media.ic_weather_cloudy');
      case '小雨':
        return $r('app.media.ic_rainy');
      case '中雨':
        return $r('app.media.ic_rainy');
      case '多云':
        return $r('app.media.ic_weather_cloudy');
      case '雨':
        return $r('app.media.ic_rainy');
      case '晴':
        return $r('app.media.ic_sunny');
      default:
        return $r('app.media.ic_sunny');
    }
  }

  build() {
    Column() {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.local_fill'))
              .fillColor($r('sys.color.icon_secondary'))
              .width(10)
            Text(this.location)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontSize($r('sys.float.Caption_S'))
              .fontColor($r('sys.color.font_primary'))
          }
          .margin({
            right: 4
          })
          .width('23%')

          Row({ space: 5 }) {
            TextClock({ timeZoneOffset: -8, controller: this.controller })
              .format('MM-dd')
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_S'))
            TextClock({ timeZoneOffset: -8, controller: this.controller })
              .fontSize($r('sys.float.Body_S'))
              .format('EEEE')
              .fontColor($r('sys.color.font_primary'))
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Column() {
            Row() {
              Text(`${this.temp}`)
                .fontWeight(FontWeight.Bold)
                .fontSize($r('sys.float.Title_L'))
                .fontColor(this.textColor);
              Text('   ℃')
                .fontSize($r('sys.float.Body_S'))
                .fontColor(this.textColor);
            }
            .alignItems(VerticalAlign.Bottom)

            Row() {
              Text(this.weather)
                .fontColor(this.textColor)
                .fontSize($r('sys.float.Caption_S'))
              Text(`| ${this.lowTemp}°/ ${this.highTemp}°`)
                .fontSize($r('sys.float.Caption_S'))
                .fontColor(this.textColor);
            }

          }
          .alignItems(HorizontalAlign.Start)

          Row() {
            Image(this.getWeatherImage(this.weather))
              .width(30)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        Row() {
          TextClock({ timeZoneOffset: -8, controller: this.controller })
            .format('HH:mm')// 24小时制：HH:mm
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.textColor);
        }
        .backgroundColor($r('sys.color.comp_background_gray'))
        .borderRadius(4)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .visibility(this.cardSize === 'small' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceBetween)
      .aspectRatio(1)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImageSize(ImageSize.FILL)
      .backgroundImage(this.backgroundImg)
      .borderRadius(4)
      .padding(5)
      .shadow({ radius: 2, color: '#00000010' });

      Column() {
        Row() {
          Row() {
            Column() {
              Row() {
                Text(`${this.temp}`)
                  .fontSize($r('sys.float.Title_L'))
                  .fontColor(this.textColor)
                  .fontWeight(FontWeight.Bold)
                Text('   ℃')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor(this.textColor);
              }
              .alignItems(VerticalAlign.Bottom)

              Row() {
                Text(this.weather)
                  .fontSize($r('sys.float.Caption_S'))
                  .fontColor(this.textColor);
                Text(`| ${this.lowTemp}°/ ${this.highTemp}°`)
                  .fontSize($r('sys.float.Caption_S'))
                  .fontColor(this.textColor);
              }

            }
            .alignItems(HorizontalAlign.Start)

            Row() {
              Image(this.getWeatherImage(this.weather))
                .width(30)
            }
            .margin({
              right: 15
            })
          }
          .width('50%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          Column() {
            Row() {
              Row() {
                Image($r('app.media.local_fill'))
                  .width(10)
                  .fillColor($r('sys.color.icon_secondary'))
                Text(this.location)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .fontSize($r('sys.float.Caption_S'))
                  .fontColor($r('sys.color.font_primary'))
              }
              .margin({
                right: 4
              })
              .width('23%')

              Row({ space: 5 }) {
                TextClock({ timeZoneOffset: -8, controller: this.controller })
                  .format('MM-dd')
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_S'))
                TextClock({ timeZoneOffset: -8, controller: this.controller })
                  .format('EEEE')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_primary'))
              }
            }
            .width('49%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              TextClock({ timeZoneOffset: -8, controller: this.controller })
                .format('HH:mm')
                .fontSize($r('sys.float.Body_L'))
                .fontColor(this.textColor);
            }
            .backgroundColor($r('sys.color.comp_background_gray'))
            .borderRadius(4)
            .width('49%')
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          ForEach(this.futureWeather, (item: FutureWeather) => {
            Column() {
              Text(item.date)
                .fontSize($r('sys.float.Caption_S'))
                .fontColor(this.futureWeatherColor);
              Image(this.getWeatherImage(item.weather))
                .width(16)
              Text(item.weather)
                .fontColor(this.futureWeatherColor)
                .fontSize($r('sys.float.Caption_S'))
              Text(`${item.lowTemp}°/${item.highTemp}°`)
                .fontSize($r('sys.float.Caption_S'))
                .fontColor(this.futureWeatherColor);
            }
            .width('25%')
          }, (item: FutureWeather) => item.date + '_' + item.weather)
        }
        .width('100%')
        .backgroundColor('#05000000')
        .padding(2)
        .borderRadius(4)
        .justifyContent(FlexAlign.SpaceBetween)

      }
      .visibility(this.cardSize === 'medium' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .aspectRatio(2)
      .padding(5)
      .borderRadius(4)
      .backgroundImage(this.backgroundImg)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImageSize(ImageSize.FILL)
      .shadow({ radius: 2, color: '#00000010' });

      Column() {
        Row() {
          Row() {
            Image($r('app.media.local_fill'))
              .width(12)
              .fillColor($r('sys.color.font_secondary'))
            Text(this.location)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
          }
          .margin({
            right: 4
          })
          .width('40%')

          Row({ space: 5 }) {
            TextClock({ timeZoneOffset: -8, controller: this.controller })
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .format('MM-dd')
            TextClock({ timeZoneOffset: -8, controller: this.controller })
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .format('EEEE')
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Column() {
            Row() {
              Text(`${this.temp}`)
                .fontSize($r('sys.float.Display_S'))
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor);
              Text('   ℃')
                .fontSize($r('sys.float.Body_S'))
                .fontColor(this.textColor);
            }
            .alignItems(VerticalAlign.Bottom)

            Row() {
              Text(this.weather)
                .fontSize($r('sys.float.Caption_M'))
                .fontColor(this.textColor);
              Text(`| ${this.lowTemp}°/ ${this.highTemp}°`)
                .fontSize($r('sys.float.Caption_M'))
                .fontColor(this.textColor);
            }

          }
          .alignItems(HorizontalAlign.Start)

          Row() {
            Image(this.getWeatherImage(this.weather))
              .width(36)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        Row() {
          TextClock({ timeZoneOffset: -8, controller: this.controller })
            .format('HH:mm')
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.textColor);
        }
        .backgroundColor($r('sys.color.comp_background_gray'))
        .borderRadius(4)
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Row() {
          ForEach(this.futureWeather, (item: FutureWeather) => {
            Column() {
              Text(item.date)
                .fontSize($r('sys.float.Caption_S'))
                .fontColor(this.futureWeatherColor);
              Image(this.getWeatherImage(item.weather))
                .width(16)
              Text(item.weather)
                .fontSize($r('sys.float.Caption_S'))
                .fontColor(this.futureWeatherColor);
              Text(`${item.lowTemp}°/${item.highTemp}°`)
                .fontSize($r('sys.float.Caption_S'))
                .fontColor(this.futureWeatherColor);
            }
            .width('25%')
          }, (item: FutureWeather) => JSON.stringify(item))
        }
        .backgroundColor('#05000000')
        .padding(2)
        .borderRadius(4)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .visibility(this.cardSize === 'large' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceBetween)
      .aspectRatio(1)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImage(this.backgroundImg)
      .backgroundImageSize(ImageSize.FILL)
      .padding(5)
      .borderRadius(4)
      .shadow({ radius: 2, color: '#00000010' });
    }
  }
}
