import { WeatherCardInfo, WoodenFishCardInfo } from '../../common/Types';
import { WoodenFish } from '../../components/WoodenFish';
import { Weather } from '../../components/Weather';

const localStorage = new LocalStorage()

@Entry(localStorage)
@Component
struct TrumpetCard {
  @LocalStorageProp('formId') formId: string = ''
  @LocalStorageProp('cardId') cardId: string = ''
  @LocalStorageProp('type') type: string = 'default'
  @LocalStorageProp('woodenFishData') woodenFishData: WoodenFishCardInfo = new WoodenFishCardInfo()
  @LocalStorageProp('weatherData') weatherData: WeatherCardInfo = new WeatherCardInfo()
  /*
 * The ability name.
 */
  readonly abilityName: string = 'PhoneAbility';
  /*
 * The title.
 */
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
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';
  /*
 * The width percentage setting.
 */
  readonly fullWidthPercent: string = '100%';

  build() {
    Row() {
      if (this.type === 'default') {
        Column() {
          Column() {
            Row() {
              Image($r('app.media.title_image'))
                .width(20)
                .aspectRatio(1)
                .margin({
                  right: 10
                })
              Text('小组件')
            }
            .margin({
              bottom: 10
            })
            .width(this.fullWidthPercent)
            .justifyContent(FlexAlign.Center)

            Column() {
              Text('1.长按进入编辑模式')
              Text('2.点击编辑小组件')
              Text('3.选择所需组件类型')
            }
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width(this.fullWidthPercent)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          postCardAction(this, {
            abilityName: this.abilityName,
            action: this.actionType,
            params: {
              formId: this.formId,
              targetPage: 'MyComponentPage',
              cardSize: 'small',
            }
          });
        })
      } else if (this.type === 'weather') {
        Weather({
          cardSize: 'small',
          location: this.weatherData.location,
          weather: this.weatherData.weather,
          highTemp: this.weatherData.highTemp,
          temp: this.weatherData.temp,
          lowTemp: this.weatherData.lowTemp,
          backgroundColorInfo: this.weatherData.backgroundColorInfo,
          futureWeatherColor: this.weatherData.futureWeatherColor,
          textColor: this.weatherData.textColor,
          backgroundImg: this.weatherData.backgroundImgBase64,
          futureWeather: this.weatherData.futureWeather
        })
          .onClick(() => {
            this.weatherData.backgroundImgBase64 = this.weatherData.backgroundImgBase64?.slice(0, 20)
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                cardSize: 'small',
                cardType: 'weather',
                targetPage: 'ComponentDetailPage',
                formId: this.formId,
                cardId: this.cardId,
                cardInfo: JSON.stringify(this.weatherData)
              }
            });
          })
      } else if (this.type === 'woodenFish') {
        WoodenFish({
          luckValue: 0,
          cardSize: 'small',
          backgroundColorInfo: this.woodenFishData.backgroundColorInfo,
          woodenFishTitle: this.woodenFishData.woodenFishTitle,
          textColor: this.woodenFishData.textColor,
          backgroundImg: this.woodenFishData.backgroundImgBase64
        })
      }
    }
    .height(this.fullHeightPercent)
  }
}