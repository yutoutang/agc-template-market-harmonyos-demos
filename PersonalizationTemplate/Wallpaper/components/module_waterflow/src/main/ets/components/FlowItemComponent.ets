import { Card, CardItem, ComponentDetailTitle } from '../models/DataSource';
import { WeatherCard } from './WeatherCard';
import { WoodenFishCard } from './WoodenFishCard';


@ComponentV2
export struct FlowItemComponent {
  @Param @Require item: CardItem
  @Event
  toComponentDetail: (params: ComponentDetailTitle) => void = (params: ComponentDetailTitle) => {
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        // 天气/木鱼 小
        this.builderMinCard()
        // 天气/木鱼 中
        this.builderMediumCard()
      }
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .borderRadius(8)
      .padding(8)
      .visibility(this.item.cardType === 1 ? Visibility.Visible : Visibility.None)

      // 天气/木鱼 小 多
      this.builderMinListCard()
      // 天气/木鱼 大
      this.builderMaxCard()

    }
    .backgroundColor($r('sys.color.background_secondary'))
  }

  /**
   * 天气/木鱼 小
   */
  @Builder
  builderMinCard(){
    Row() {
      // 天气/木鱼 小
      if (this.item.cards[0].type === 'weather' && this.item.cards[0].cardSize === 'small') {
        Column() {
          WeatherCard({
            cardSize: this.item.cards[0].cardSize,
            location: this.item.cards[0].data.location,
            highTemp: this.item.cards[0].data.highTemp,
            lowTemp: this.item.cards[0].data.lowTemp,
            backgroundColorInfo: this.item.cards[0].data.backgroundColorInfo,
            textColor: this.item.cards[0].data.textColor,
            weather: this.item.cards[0].data.weather,
            temp: this.item.cards[0].data.temp,
            futureWeatherColor: this.item.cards[0].data.futureWeatherColor,
            backgroundImg: this.item.cards[0].data.backgroundImg
          })
            .onClick(() => {
              this.toComponentDetail({ type: 'weather', size: 'small' })
            })
          Text('天气-小')
            .fontSize(16)
            .height(20)
            .lineHeight(20)
            .margin({
              top: 12
            })
        }

      } else if (this.item.cards[0].type === 'woodenFish' && this.item.cards[0].cardSize === 'small') {
        Column() {
          WoodenFishCard({
            backgroundColorInfo: this.item.cards[0].data.backgroundColorInfo,
            woodenFishTitle: this.item.cards[0].data.woodenFishTitle,
            cardSize: this.item.cards[0].cardSize,
            luckValue: this.item.cards[0].data.luckValue,
            textColor: this.item.cards[0].data.textColor,
            backgroundImg: this.item.cards[0].data.backgroundImg
          })
            .onClick(() => {
              this.toComponentDetail({ type: 'woodenFish', size: 'small' })
            })
          Text('木鱼-小')
            .fontSize(16)
            .height(20)
            .lineHeight(20)
            .margin({
              top: 12
            })
        }
      }
    }
    .width('calc((100% - 12vp) / 3)')
  }
  /**
   * 天气/木鱼 中
   */
  @Builder
  builderMediumCard(){
    Row() {
      // 天气/木鱼 中
      if (this.item.cards[1].type === 'weather' && this.item.cards[1].cardSize === 'medium') {
        Column() {
          WeatherCard({
            cardSize: this.item.cards[1].cardSize,
            location: this.item.cards[1].data.location,
            futureWeatherColor: this.item.cards[1].data.futureWeatherColor,
            temp: this.item.cards[1].data.temp,
            weather: this.item.cards[1].data.weather,
            textColor: this.item.cards[1].data.textColor,
            highTemp: this.item.cards[1].data.highTemp,
            backgroundColorInfo: this.item.cards[1].data.backgroundColorInfo,
            lowTemp: this.item.cards[1].data.lowTemp,
            futureWeather: this.item.cards[1].data.futureWeather,
            backgroundImg: this.item.cards[1].data.backgroundImg
          })
            .onClick(() => {
              this.toComponentDetail({ type: 'weather', size: 'medium' })
            })
          Text('天气-中')
            .fontSize(16)
            .height(20)
            .lineHeight(20)
            .margin({
              top: 12
            })
        }
      } else if (this.item.cards[1].type === 'woodenFish' && this.item.cards[1].cardSize === 'medium') {
        Column() {
          WoodenFishCard({
            woodenFishTitle: this.item.cards[1].data.woodenFishTitle,
            backgroundImg: this.item.cards[1].data.backgroundImg,
            luckValue: this.item.cards[1].data.luckValue,
            cardSize: this.item.cards[1].cardSize,
            backgroundColorInfo: this.item.cards[1].data.backgroundColorInfo,
            textColor: this.item.cards[1].data.textColor,
          })
            .onClick(() => {
              this.toComponentDetail({ type: 'woodenFish', size: 'medium' })
            })
          Text('木鱼-中')
            .fontSize(16)
            .height(20)
            .lineHeight(20)
            .margin({
              top: 12
            })
        }
      }
    }
    .width('calc(((100% - 12vp) / 3) *2 )')
  }

  /**
   * 天气/木鱼 小  多个
   */
  @Builder
  builderMinListCard(){
    Row({ space: 12 }) {
      ForEach(this.item.cards, (item: Card) => {
        Row() {
          if (item.type === 'weather' && item.cardSize === 'small') {
            Column() {
              WeatherCard({
                cardSize: item.cardSize,
                temp: item.data.temp,
                highTemp: item.data.highTemp,
                location: item.data.location,
                weather: item.data.weather,
                textColor: item.data.textColor,
                lowTemp: item.data.lowTemp,
                futureWeatherColor: item.data.futureWeatherColor,
                backgroundColorInfo: item.data.backgroundColorInfo,
                backgroundImg: item.data.backgroundImg

              })
                .onClick(() => {
                  this.toComponentDetail({ type: 'weather', size: 'small' })
                })
              Text('天气-小')
                .fontSize(16)
                .height(20)
                .lineHeight(20)
                .margin({
                  top: 12
                })
            }
          } else if (item.type === 'woodenFish' && item.cardSize === 'small') {
            Column() {
              WoodenFishCard({
                woodenFishTitle: item.data.woodenFishTitle,
                cardSize: item.cardSize,
                luckValue: item.data.luckValue,
                textColor: item.data.textColor,
                backgroundColorInfo: item.data.backgroundColorInfo,
                backgroundImg: item.data.backgroundImg
              })
                .onClick(() => {
                  this.toComponentDetail({ type: 'woodenFish', size: 'small' })
                })
              Text('木鱼-小')
                .fontSize(16)
                .height(20)
                .lineHeight(20)
                .margin({
                  top: 12
                })
            }
          }
        }
        .width('calc((100% - 24vp) / 3)')
      }, (item: Card) => JSON.stringify(item))
    }
    .visibility(this.item.cardType === 2 ? Visibility.Visible : Visibility.None)
    .width('100%')
    .borderRadius(8)
    .padding(8)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  /**
   * 天气/木鱼 大
   */
  @Builder
  builderMaxCard(){
    Row({ space: 12 }) {
      Row() {
        if (this.item.cards[0].type === 'weather' && this.item.cards[0].cardSize === 'large') {
          Column() {
            WeatherCard({
              location: this.item.cards[0].data.location,
              backgroundColorInfo: this.item.cards[0].data.backgroundColorInfo,
              textColor: this.item.cards[0].data.textColor,
              weather: this.item.cards[0].data.weather,
              temp: this.item.cards[0].data.temp,
              highTemp: this.item.cards[0].data.highTemp,
              lowTemp: this.item.cards[0].data.lowTemp,
              cardSize: this.item.cards[0].cardSize,
              futureWeather: this.item.cards[0].data.futureWeather,
              futureWeatherColor: this.item.cards[0].data.futureWeatherColor,
              backgroundImg: this.item.cards[0].data.backgroundImg
            })
              .onClick(() => {
                this.toComponentDetail({ type: 'weather', size: 'large' })
              })
            Text('天气-大')
              .fontSize(16)
              .height(20)
              .lineHeight(20)
              .margin({
                top: 12
              })
          }
        } else if (this.item.cards[0].type === 'woodenFish' && this.item.cards[0].cardSize === 'large') {
          Column() {
            WoodenFishCard({
              backgroundColorInfo: this.item.cards[0].data.backgroundColorInfo,
              woodenFishTitle: this.item.cards[0].data.woodenFishTitle,
              textColor: this.item.cards[0].data.textColor,
              backgroundImg: this.item.cards[0].data.backgroundImg,
              cardSize: this.item.cards[0].cardSize,
              luckValue: this.item.cards[0].data.luckValue,
            })
              .onClick(() => {
                this.toComponentDetail({ type: 'woodenFish', size: 'large' })
              })
            Text('木鱼-大')
              .height(20)
              .lineHeight(20)
              .fontSize(16)
              .margin({
                top: 12
              })
          }
        }
      }
      .width('calc((100% - 12vp) / 2)')

      Row() {
        if (this.item.cards[1].type === 'weather' && this.item.cards[1].cardSize === 'large') {
          Column() {
            WeatherCard({
              cardSize: this.item.cards[1].cardSize,
              backgroundColorInfo: this.item.cards[1].data.backgroundColorInfo,
              temp: this.item.cards[1].data.temp,
              highTemp: this.item.cards[1].data.highTemp,
              textColor: this.item.cards[1].data.textColor,
              futureWeatherColor: this.item.cards[1].data.futureWeatherColor,
              backgroundImg: this.item.cards[1].data.backgroundImg,
              location: this.item.cards[1].data.location,
              weather: this.item.cards[1].data.weather,
              lowTemp: this.item.cards[1].data.lowTemp,
              futureWeather: this.item.cards[1].data.futureWeather,
            })
              .onClick(() => {
                this.toComponentDetail({ type: 'weather', size: 'large' })
              })
            Text('天气-大')
              .fontSize(16)
              .height(20)
              .lineHeight(20)
              .margin({
                top: 12
              })
          }
        } else if (this.item.cards[1].type === 'woodenFish' && this.item.cards[1].cardSize === 'large') {
          Column() {
            WoodenFishCard({
              cardSize: this.item.cards[1].cardSize,
              backgroundColorInfo: this.item.cards[1].data.backgroundColorInfo,
              textColor: this.item.cards[1].data.textColor,
              woodenFishTitle: this.item.cards[1].data.woodenFishTitle,
              luckValue: this.item.cards[1].data.luckValue,
              backgroundImg: this.item.cards[1].data.backgroundImg,
            })
              .onClick(() => {
                this.toComponentDetail({ type: 'woodenFish', size: 'large' })
              })
            Text('木鱼-大')
              .fontSize(16)
              .lineHeight(20)
              .height(20)
              .margin({
                top: 12
              })
          }
        }
      }
      .width('calc((100% - 12vp) / 2)')
    }
    .visibility(this.item.cardType === 3 ? Visibility.Visible : Visibility.None)
    .width('100%')
    .borderRadius(8)
    .padding(8)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

