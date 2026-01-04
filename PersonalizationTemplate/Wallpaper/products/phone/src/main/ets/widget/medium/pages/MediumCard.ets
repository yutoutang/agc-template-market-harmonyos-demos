import { WoodenFish } from '../../components/WoodenFish';
import { Weather } from '../../components/Weather';
import { WeatherCardInfo, WoodenFishCardInfo } from '../../common/Types';

const localStorage = new LocalStorage()

@Entry(localStorage)
@Component
struct MediumCard {
  @LocalStorageProp('type') type: string = 'default'
  @LocalStorageProp('formId') formId: string = ''
  @LocalStorageProp('woodenFishData') woodenFishData: WoodenFishCardInfo = new WoodenFishCardInfo()
  @LocalStorageProp('weatherData') weatherData: WeatherCardInfo = new WeatherCardInfo()
  @LocalStorageProp('cardId') cardId: string = ''
  readonly title: string = 'Hello World';
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The message.
   */
  readonly message: string = 'add detail';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'PhoneAbility';

  build() {
    Row() {
      if (this.type === 'default') {
        Column() {
          Column() {
            Row() {
              Image($r('app.media.title_image'))
                .width(22)
                .aspectRatio(1)
                .margin({
                  right: 10
                })
              Text('小组件')
                .fontSize(20)
            }
            .margin({
              bottom: 4
            })
            .width(this.fullWidthPercent)
            .justifyContent(FlexAlign.Center)

            Column() {
              Text('1.长按进入编辑模式')
                .fontSize(20)
              Text('2.点击编辑小组件')
                .fontSize(20)
              Text('3.选择所需组件类型')
                .fontSize(20)
            }
            .padding(12)
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width(this.fullWidthPercent)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          postCardAction(this, {
            action: this.actionType,
            params: {
              targetPage: 'MyComponentPage',
              formId: this.formId,
              cardSize: 'medium',
            },
            abilityName: this.abilityName,
          });
        })
      } else if (this.type === 'weather') {
        Weather({
          cardSize: 'medium',
          weather: this.weatherData.weather,
          location: this.weatherData.location,
          temp: this.weatherData.temp,
          highTemp: this.weatherData.highTemp,
          lowTemp: this.weatherData.lowTemp,
          textColor: this.weatherData.textColor,
          futureWeather: this.weatherData.futureWeather,
          futureWeatherColor: this.weatherData.futureWeatherColor,
          backgroundImg: this.weatherData.backgroundImgBase64,
          backgroundColorInfo: this.weatherData.backgroundColorInfo,
        })
          .onClick(() => {
            this.weatherData.backgroundImgBase64 = this.weatherData.backgroundImgBase64?.slice(0, 20)
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                targetPage: 'ComponentDetailPage',
                formId: this.formId,
                cardId: this.cardId,
                cardSize: 'medium',
                cardType: 'weather',
                cardInfo: JSON.stringify(this.weatherData)
              }
            });
          })
          .margin({
            top: -8
          })
      } else if (this.type === 'woodenFish') {
        WoodenFish({
          luckValue: 0,
          cardSize: 'medium',
          woodenFishTitle: this.woodenFishData.woodenFishTitle,
          textColor: this.woodenFishData.textColor,
          backgroundImg: this.woodenFishData.backgroundImgBase64,
          backgroundColorInfo: this.woodenFishData.backgroundColorInfo,
        })
          .margin({
            top: -8
          })
      }
    }
    .height(this.fullHeightPercent)
  }
}