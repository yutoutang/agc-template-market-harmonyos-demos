import { FutureWeather } from 'module_waterflow';

@ComponentV2
export struct Weather {
  @Param cardSize: 'small' | 'medium' | 'large' = 'medium';
  @Param location: string = '';
  @Param temp: string = '';
  @Param weather: string = '';
  @Param backgroundImg: string = ''
  @Param futureWeather: FutureWeather[] = []
  @Param highTemp: string = '';
  @Param lowTemp: string = '';
  @Param textColor: string = '#000';
  @Param backgroundColorInfo: string = '#fff';
  @Param futureWeatherColor: string = '#99000000'
  @Local locationColor: string = '#99000000'
  @Local clockBagColor: string = '#fff1f3f5'
  @Local secondTextColor: string = '#000'
  controller: TextClockController = new TextClockController();

  getWeatherImage(weather: string) {
    switch (weather) {
      case '雨':
        return $r('app.media.ic_rainy');
      case '阴':
        return $r('app.media.ic_weather_cloudy');
      case '多云':
        return $r('app.media.ic_weather_cloudy');
      case '小雨':
        return $r('app.media.ic_rainy');
      case '中雨':
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
              .width(12)
              .fillColor(this.locationColor)
            Text(this.location)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontSize($r('sys.float.Body_S'))
              .fontColor(this.locationColor)
          }
          .margin({
            right: 10
          })
          .width('23%')

          Row({ space: 5 }) {
            TextClock({ timeZoneOffset: -8, controller: this.controller })
              .fontSize($r('sys.float.Body_L'))
              .fontColor(this.locationColor)
              .format('MM-dd')
            TextClock({ timeZoneOffset: -8, controller: this.controller })
              .fontSize($r('sys.float.Body_L'))
              .fontColor(this.locationColor)
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
                .fontColor(this.textColor || this.secondTextColor);
              Text('   ℃')
                .fontSize($r('sys.float.Subtitle_S'))
                .fontColor(this.textColor || this.secondTextColor);
            }
            .alignItems(VerticalAlign.Bottom)

            Row() {
              Text(this.weather)
                .fontSize($r('sys.float.Subtitle_S'))
                .fontColor(this.textColor || this.secondTextColor);
              Text(`| ${this.lowTemp}°/ ${this.highTemp}°`)
                .fontSize($r('sys.float.Subtitle_S'))
                .fontColor(this.textColor || this.secondTextColor);
            }
          }
          .alignItems(HorizontalAlign.Start)

          Row() {
            Image(this.getWeatherImage(this.weather))
              .width(34)
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          TextClock({ timeZoneOffset: -8, controller: this.controller })
            .fontSize($r('sys.float.Body_L'))
            .format('HH:mm')// 24小时制：HH:mm
            .fontColor(this.textColor || this.secondTextColor);
        }
        .padding(5)
        .backgroundColor(this.clockBagColor)
        .borderRadius(4)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .visibility(this.cardSize === 'small' ? Visibility.Visible : Visibility.None)

      .width('100%')
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImage(this.backgroundColorInfo ? '' : 'data:image/jpeg;base64,' + this.backgroundImg)
      .backgroundImageSize(ImageSize.FILL)
      .aspectRatio(1)
      .padding(12)
      .borderRadius(4)
      .justifyContent(FlexAlign.SpaceBetween)
      .shadow({ radius: 2, color: '#00000010' });

      Column() {
        Row() {
          Row() {
            Column() {
              Row() {
                Text(`${this.temp}`)
                  .fontWeight(FontWeight.Bold)
                  .fontSize($r('sys.float.Display_S'))
                  .fontColor(this.textColor || this.secondTextColor);
                Text('   ℃')
                  .fontSize($r('sys.float.Subtitle_S'))
                  .fontColor(this.textColor || this.secondTextColor);
              }
              .alignItems(VerticalAlign.Bottom)

              Row() {
                Text(this.weather)
                  .fontColor(this.textColor || this.secondTextColor)
                  .fontSize($r('sys.float.Subtitle_S'))
                Text(`| ${this.lowTemp}°/ ${this.highTemp}°`)
                  .fontSize($r('sys.float.Subtitle_S'))
                  .fontColor(this.textColor || this.secondTextColor);
              }

            }
            .alignItems(HorizontalAlign.Start)

            Row() {
              Image(this.getWeatherImage(this.weather)).width(36)
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
                  .width(16)
                  .fillColor(this.locationColor)
                Text(this.location)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor(this.locationColor)
              }
              .margin({
                right: 4
              })
              .width('23%')

              Row({ space: 5 }) {
                TextClock({ timeZoneOffset: -8, controller: this.controller })
                  .fontSize($r('sys.float.Body_L'))
                  .format('MM-dd')
                  .fontColor(this.locationColor)
                TextClock({ timeZoneOffset: -8, controller: this.controller })
                  .format('EEEE')
                  .fontColor(this.locationColor)
                  .fontSize($r('sys.float.Body_L'))
              }
            }
            .width('49%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              TextClock({ timeZoneOffset: -8, controller: this.controller })
                .fontColor(this.textColor || this.secondTextColor)
                .format('HH:mm')
                .fontSize($r('sys.float.Body_L'))
            }
            .width('49%')
            .backgroundColor(this.clockBagColor)
            .borderRadius(4)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          ForEach(this.futureWeather, (item: FutureWeather) => {
            Column() {
              Text(item.date)
                .fontSize($r('sys.float.Body_S'))
                .fontColor(this.futureWeatherColor || this.locationColor);
              Image(this.getWeatherImage(item.weather))
                .width(18)
              Text(item.weather)
                .fontColor(this.futureWeatherColor || this.locationColor)
                .fontSize($r('sys.float.Body_S'))

              Text(`${item.lowTemp}°/${item.highTemp}°`)
                .fontSize($r('sys.float.Body_S'))
                .fontColor(this.futureWeatherColor || this.locationColor);
            }
            .width('25%')
          }, (item: FutureWeather) => JSON.stringify(item))
        }
        .padding(5)
        .margin({
          bottom: 5
        })
        .width('100%')
        .backgroundColor('#05000000')
        .borderRadius(4)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .visibility(this.cardSize === 'medium' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .aspectRatio(2)
      .backgroundImage(this.backgroundColorInfo ? '' : 'data:image/jpeg;base64,' + this.backgroundImg)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius(4)
      .padding(12)
      .shadow({ radius: 2, color: '#00000010' });

      Column() {
        Row() {
          Row() {
            Image($r('app.media.local_fill'))
              .width(16)
              .fillColor(this.locationColor)
            Text(this.location)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontSize($r('sys.float.Body_L'))
              .fontColor(this.locationColor)
          }
          .margin( {
            right: 4
          })
          .width('50%')

          Row({ space: 5 }) {
            TextClock({ controller: this.controller, timeZoneOffset: -8 })
              .format('MM-dd')
              .fontSize($r('sys.float.Body_L'))
              .fontColor(this.locationColor)
            TextClock({ controller: this.controller, timeZoneOffset: -8 })
              .format('EEEE')
              .fontSize($r('sys.float.Body_L'))
              .fontColor(this.locationColor)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Column() {
            Row() {
              Text(`${this.temp}`)
                .fontSize($r('sys.float.Display_L'))
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor || this.secondTextColor);
              Text('   ℃')
                .fontSize($r('sys.float.Display_S'))
                .fontColor(this.textColor || this.secondTextColor);
            }
            .alignItems(VerticalAlign.Bottom)

            Row() {
              Text(this.weather)
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor(this.textColor || this.secondTextColor);
              Text(`| ${this.lowTemp}°/ ${this.highTemp}°`)
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor(this.textColor || this.secondTextColor);
            }

          }
          .alignItems(HorizontalAlign.Start)

          Row() {
            Image(this.getWeatherImage(this.weather))
              .width(46)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        Row() {
          TextClock({ timeZoneOffset: -8, controller: this.controller })
            .format('HH:mm')
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.textColor || this.secondTextColor);
        }
        .padding(10)
        .backgroundColor(this.clockBagColor)
        .borderRadius(4)
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Row() {
          ForEach(this.futureWeather, (item: FutureWeather) => {
            Column() {
              Text(item.date)
                .fontSize($r('sys.float.Body_S'))
                .fontColor(this.futureWeatherColor || this.locationColor);
              Image(this.getWeatherImage(item.weather))
                .width(20)
              Text(item.weather)
                .fontSize($r('sys.float.Body_S'))
                .fontColor(this.futureWeatherColor || this.locationColor);
              Text(`${item.lowTemp}°/${item.highTemp}°`)
                .fontSize($r('sys.float.Body_S'))
                .fontColor(this.futureWeatherColor || this.locationColor);
            }
            .width('25%')
          }, (item: FutureWeather) => JSON.stringify(item))
        }
        .width('100%')
        .padding(8)
        .backgroundColor('#05000000')
        .borderRadius(4)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .visibility(this.cardSize === 'large' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .height('100%')
      .width('100%')
      .backgroundImage(this.backgroundColorInfo ? '' : 'data:image/jpeg;base64,' + this.backgroundImg)
      .backgroundImageSize(ImageSize.FILL)
      .padding(12)
      .borderRadius(4)
      .shadow({ radius: 2, color: '#00000010' });
    }

  }
}
