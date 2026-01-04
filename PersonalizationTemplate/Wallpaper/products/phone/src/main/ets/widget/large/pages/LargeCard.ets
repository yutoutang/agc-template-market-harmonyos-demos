import { WoodenFish } from '../../components/WoodenFish';
import { Weather } from '../../components/Weather';
import { WeatherCardInfo, WoodenFishCardInfo } from '../../common/Types';

const localStorage = new LocalStorage()

@Entry(localStorage)
@Component
struct LargeCard {
  @LocalStorageProp('formId') formId: string = ''
  @LocalStorageProp('type') type: string = 'default'
  @LocalStorageProp('woodenFishData') woodenFishData: WoodenFishCardInfo = new WoodenFishCardInfo()
  @LocalStorageProp('cardId') cardId: string = ''
  @LocalStorageProp('weatherData') weatherData: WeatherCardInfo = new WeatherCardInfo()
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
   * The ability name.
   */
  readonly abilityName: string = 'PhoneAbility';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  build() {
    Row() {
      if (this.type === 'default') {
        Column() {
          Column() {
            Row() {
              Image($r('app.media.title_image'))
                .width(28)
                .aspectRatio(1)
                .margin({
                  right: 10
                })
              Text('小组件')
                .fontSize(24)
            }
            .margin({
              bottom: 16
            })
            .width(this.fullWidthPercent)
            .justifyContent(FlexAlign.Center)

            Column() {
              Text('1.长按进入编辑模式')
                .fontSize(24)
              Text('2.点击编辑小组件')
                .fontSize(24)
              Text('3.选择所需组件类型')
                .fontSize(24)
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
            abilityName: this.abilityName,
            params: {
              targetPage: 'MyComponentPage',
              formId: this.formId,
              cardSize: 'large',
            }
          });
        })
      } else if (this.type === 'weather') {
        Weather({
          cardSize: 'large',
          location: this.weatherData.location,
          weather: this.weatherData.weather,
          temp: this.weatherData.temp,
          highTemp: this.weatherData.highTemp,
          lowTemp: this.weatherData.lowTemp,
          backgroundColorInfo: this.weatherData.backgroundColorInfo,
          textColor: this.weatherData.textColor,
          futureWeatherColor: this.weatherData.futureWeatherColor,
          backgroundImg: this.weatherData.backgroundImgBase64,
          futureWeather: this.weatherData.futureWeather
        })
          .onClick(() => {
            this.weatherData.backgroundImgBase64 = this.weatherData.backgroundImgBase64?.slice(0, 20)
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                formId: this.formId,
                cardSize: 'large',
                cardId: this.cardId,
                cardType: 'weather',
                cardInfo: JSON.stringify(this.weatherData),
                targetPage: 'ComponentDetailPage',
              }
            });
          })
      } else if (this.type === 'woodenFish') {
        WoodenFish({
          cardSize: 'large',
          woodenFishTitle: this.woodenFishData.woodenFishTitle,
          backgroundColorInfo: this.woodenFishData.backgroundColorInfo,
          textColor: this.woodenFishData.textColor,
          luckValue: 0,
          backgroundImg: this.woodenFishData.backgroundImgBase64,
        })
      }
    }
    .height(this.fullHeightPercent)
  }
}