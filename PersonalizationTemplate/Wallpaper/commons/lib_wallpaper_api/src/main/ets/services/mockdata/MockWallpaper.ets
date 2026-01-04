import { Card, CardItem } from '../../database/WallpaperType';


interface GeneratedObjectLiteralInterface_2 {
  date: string;
  weather: string;
  lowTemp: string;
  highTemp: string;
}

export class MockWallpaper {
  static recommendedCard: CardItem[] = [
    {
      cardType: 1,
      cards: [
        {
          id: 1,
          cardSize: 'small',
          type: 'weather',
          data: {
            location: '西安',
            weather: '多云',
            highTemp: '36',
            temp: '33',
            lowTemp: '30'
          }
        },
        {
          id: 3,
          type: 'weather',
          cardSize: 'medium',
          data: {
            location: '北京',
            weather: '晴',
            temp: '28',
            highTemp: '32',
            lowTemp: '20',
            futureWeather: [({
              date: this.getFutureDates()[0],
              lowTemp: '24',
              weather: '晴',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                highTemp: '25',
                lowTemp: '18'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                weather: '雨',
                lowTemp: '15',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                lowTemp: '20',
                weather: '多云',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        }
      ]
    },
    {
      cardType: 2,
      cards: [
        {
          id: 2,
          type: 'woodenFish',
          cardSize: 'small',
          data: { luckValue: 12100, woodenFishTitle: '好运' }
        },
        {
          id: 7,
          cardSize: 'small',
          type: 'weather',
          data: {
            location: '广州',
            weather: '雨',
            highTemp: '31',
            temp: '29',
            lowTemp: '26'
          }
        },
        {
          id: 8,
          type: 'weather',
          cardSize: 'small',
          data: {
            weather: '晴',
            location: '深圳',
            temp: '30',
            highTemp: '33',
            lowTemp: '27'
          }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 4,
          cardSize: 'large',
          type: 'woodenFish',
          data: { luckValue: 8888, woodenFishTitle: '功德' }
        },
        {
          id: 5,
          type: 'weather',
          cardSize: 'large',
          data: {
            location: '上海',
            weather: '阴',
            highTemp: '28',
            temp: '25',
            lowTemp: '22',
            futureWeather: [({
              date: this.getFutureDates()[0],
              lowTemp: '24',
              weather: '晴',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                lowTemp: '18',
                weather: '多云',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                weather: '雨',
                lowTemp: '15',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                lowTemp: '20',
                weather: '多云',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 9,
          type: 'woodenFish',
          cardSize: 'large',
          data: { luckValue: 9999, woodenFishTitle: '好运' }
        },
        {
          id: 11,
          type: 'weather',
          cardSize: 'large',
          data: {
            location: '杭州',
            temp: '27',
            highTemp: '30',
            lowTemp: '23',
            weather: '多云',
            futureWeather: [({
              date: this.getFutureDates()[0],
              highTemp: '28',
              weather: '晴',
              lowTemp: '24'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '18',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                highTemp: '23',
                weather: '雨',
                lowTemp: '15',
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '20',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        }
      ]
    },
    {
      cardType: 1,
      cards: [
        {
          id: 10,
          cardSize: 'small',
          type: 'woodenFish',
          data: { luckValue: 6200, woodenFishTitle: '好运' }
        },
        {
          type: 'woodenFish',
          id: 6,
          cardSize: 'medium',
          data: { luckValue: 5666, woodenFishTitle: '功德' }
        }
      ]
    },
    {
      cardType: 1,
      cards: [
        {
          cardSize: 'small',
          id: 12,
          type: 'weather',
          data: {
            temp: '22',
            highTemp: '25',
            location: '成都',
            weather: '小雨',
            lowTemp: '19'
          }
        },
        {
          id: 13,
          type: 'woodenFish',
          data: { luckValue: 7300, woodenFishTitle: '功德' },
          cardSize: 'medium'
        }
      ]
    },
    {
      cardType: 2,
      cards: [
        {
          id: 14,
          type: 'weather',
          data: {
            location: '武汉',
            temp: '31',
            highTemp: '34',
            weather: '晴',
            lowTemp: '28'
          },
          cardSize: 'small',
        },
        {
          id: 15,
          type: 'woodenFish',
          cardSize: 'small',
          data: { luckValue: 4800, woodenFishTitle: '好运' }
        },
        {
          cardSize: 'small',
          data: {
            location: '南京',
            weather: '阴',
            temp: '26',
            highTemp: '29',
            lowTemp: '23'
          },
          id: 16,
          type: 'weather',
        }
      ]
    },
    {
      cards: [
        {
          id: 19,
          type: 'woodenFish',
          cardSize: 'small',
          data: { luckValue: 3900, woodenFishTitle: '好运' }
        },
        {
          id: 20,
          type: 'weather',
          data: {
            location: '天津',
            weather: '多云',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              lowTemp: '24',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '18',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                lowTemp: '15',
                weather: '雨',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '20',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ],
            temp: '25',
            lowTemp: '21',
            highTemp: '28'

          },
          cardSize: 'medium'
        }
      ],
      cardType: 1
    },
    {
      cardType: 2,
      cards: [
        {
          cardSize: 'small',
          id: 21,
          type: 'weather',
          data: {
            location: '沈阳',
            weather: '晴',
            temp: '20',
            highTemp: '23',
            lowTemp: '16'
          }
        },
        {
          data: {
            location: '哈尔滨',
            weather: '晴',
            temp: '18',
            highTemp: '21',
            lowTemp: '14'
          },
          id: 22,
          type: 'weather',
          cardSize: 'small',
        },
        {
          id: 23,
          type: 'woodenFish',
          data: { luckValue: 8200, woodenFishTitle: '好运' },
          cardSize: 'small'
        }
      ]
    },
    {
      cardType: 1,
      cards: [
        {
          id: 1,
          type: 'weather',
          cardSize: 'small',
          data: {
            temp: '33',
            highTemp: '36',
            lowTemp: '30',
            location: '西安',
            weather: '多云',
          }
        },
        {
          id: 3,
          type: 'weather',
          cardSize: 'medium',
          data: {
            location: '北京',
            temp: '28',
            highTemp: '32',
            weather: '晴',
            lowTemp: '20',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              lowTemp: '24',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '18',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                weather: '雨',
                lowTemp: '15',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '20',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          type: 'weather',
          id: 17,
          cardSize: 'large',
          data: {
            location: '重庆',
            weather: '晴',
            temp: '24',
            highTemp: '27',
            lowTemp: '22',
            futureWeather: [({
              weather: '晴',
              lowTemp: '24',
              highTemp: '28',
              date: this.getFutureDates()[0],
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '18',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                weather: '雨',
                date: this.getFutureDates()[2],
                lowTemp: '15',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                weather: '多云',
                lowTemp: '20',
                date: this.getFutureDates()[3],
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        },
        {
          id: 18,
          type: 'woodenFish',
          cardSize: 'large',
          data: { woodenFishTitle: '功德', luckValue: 1560 }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 24,
          type: 'woodenFish',
          cardSize: 'large',
          data: { luckValue: 1230, woodenFishTitle: '功德' }
        },
        {
          cardSize: 'large',
          id: 25,
          type: 'woodenFish',
          data: { luckValue: 1450, woodenFishTitle: '好运' }
        }
      ]
    },
    {
      cards: [
        {
          id: 2,
          type: 'woodenFish',
          cardSize: 'small',
          data: { luckValue: 12100, woodenFishTitle: '好运' }
        },
        {
          id: 7,
          data: {
            location: '广州',
            weather: '雨',
            temp: '29',
            highTemp: '31',
            lowTemp: '26'
          },
          type: 'weather',
          cardSize: 'small',
        },
        {
          id: 8,
          type: 'weather',
          cardSize: 'small',
          data: {
            location: '深圳',
            weather: '晴',
            temp: '30',
            highTemp: '33',
            lowTemp: '27'
          }
        }
      ],
      cardType: 2,
    },
    {
      cardType: 1,
      cards: [
        {
          id: 10,
          type: 'woodenFish',
          cardSize: 'small',
          data: { luckValue: 6201, woodenFishTitle: '好运' }
        },
        {
          id: 6,
          type: 'woodenFish',
          cardSize: 'medium',
          data: { luckValue: 5666, woodenFishTitle: '好运' }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 4,
          type: 'woodenFish',
          cardSize: 'large',
          data: { luckValue: 8818, woodenFishTitle: '功德' }
        },
        {
          id: 5,
          type: 'weather',
          cardSize: 'large',
          data: {
            location: '上海',
            weather: '阴',
            highTemp: '28',
            temp: '25',
            lowTemp: '22',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              lowTemp: '25',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '18',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                weather: '雨',
                highTemp: '23',
                lowTemp: '16',
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '21',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 9,
          type: 'woodenFish',
          cardSize: 'large',
          data: { luckValue: 999, woodenFishTitle: '功德' }
        },
        {
          id: 11,
          type: 'weather',
          cardSize: 'large',
          data: {
            location: '杭州',
            weather: '多云',
            temp: '27',
            highTemp: '30',
            lowTemp: '23',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              lowTemp: '21',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '19',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                weather: '雨',
                lowTemp: '16',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '17',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        }
      ]
    },
    {
      cardType: 1,
      cards: [
        {
          id: 12,
          type: 'weather',
          cardSize: 'small',
          data: {
            location: '成都',
            weather: '小雨',
            temp: '28',
            highTemp: '25',
            lowTemp: '19'
          }
        },
        {
          id: 13,
          type: 'woodenFish',
          data: { luckValue: 7302, woodenFishTitle: '好运' },
          cardSize: 'medium',
        }
      ]
    },
    {
      cardType: 2,
      cards: [
        {
          id: 14,
          type: 'weather',
          cardSize: 'small',
          data: {
            location: '武汉',
            weather: '晴',
            highTemp: '34',
            temp: '31',
            lowTemp: '28'
          }
        },
        {
          id: 15,
          type: 'woodenFish',
          cardSize: 'small',
          data: { luckValue: 5800, woodenFishTitle: '好运' }
        },
        {
          id: 16,
          type: 'weather',
          cardSize: 'small',
          data: {
            location: '南京',
            weather: '阴',
            temp: '27',
            highTemp: '30',
            lowTemp: '23'
          }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 17,
          type: 'weather',
          cardSize: 'large',
          data: {
            location: '重庆',
            weather: '雨',
            temp: '24',
            highTemp: '27',
            lowTemp: '22',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              lowTemp: '24',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '晴',
                lowTemp: '25',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                weather: '晴',
                lowTemp: '25',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '晴',
                lowTemp: '25',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        },
        {
          id: 18,
          type: 'woodenFish',
          cardSize: 'large',
          data: { luckValue: 1566, woodenFishTitle: '功德' }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 24,
          cardSize: 'large',
          data: { luckValue: 1233, woodenFishTitle: '功德' },
          type: 'woodenFish'
        },
        {
          type: 'woodenFish',
          id: 25,
          cardSize: 'large',
          data: { luckValue: 1450, woodenFishTitle: '好运' }
        }
      ]
    },
    {
      cardType: 1,
      cards: [
        {
          type: 'woodenFish',
          cardSize: 'small',
          data: { luckValue: 3900, woodenFishTitle: '好运' },
          id: 19
        },
        {
          type: 'weather',
          id: 20,
          cardSize: 'medium',
          data: {
            location: '天津',
            weather: '多云',
            temp: '25',
            highTemp: '28',
            lowTemp: '21',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              highTemp: '28',
              lowTemp: '20',
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '21',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                lowTemp: '20',
                weather: '雨',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '20',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        }
      ]
    },
    {
      cardType: 2,
      cards: [
        {
          data: {
            location: '沈阳',
            weather: '晴',
            temp: '20',
            highTemp: '23',
            lowTemp: '16'
          },
          id: 21,
          cardSize: 'small',
          type: 'weather'
        },
        {
          id: 22,
          cardSize: 'small',
          type: 'weather',
          data: {
            location: '哈尔滨',
            weather: '晴',
            temp: '19',
            highTemp: '21',
            lowTemp: '14'
          }
        },
        {
          cardSize: 'small',
          id: 23,
          type: 'woodenFish',
          data: { luckValue: 8320, woodenFishTitle: '好运' }
        }
      ]
    }
  ]
  static weatherCard: CardItem[] = [
    {
      cardType: 1,
      cards: [
        {
          id: 1,
          type: 'weather',
          cardSize: 'small',
          data: {
            location: '上海',
            weather: '阴',
            temp: '29',
            lowTemp: '22',
            highTemp: '32'
          }
        },
        {
          id: 2,
          type: 'weather',
          cardSize: 'medium',
          data: {
            location: '成都',
            weather: '多云',
            lowTemp: '19',
            temp: '23',
            highTemp: '27',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              lowTemp: '24',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '25',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                weather: '雨',
                lowTemp: '25',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '25',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        }
      ]
    },
    {
      cardType: 2,
      cards: [
        {
          id: 5,
          type: 'weather',
          cardSize: 'small',
          data: {
            weather: '雨',
            location: '广州',
            temp: '30',
            highTemp: '35',
            lowTemp: '25'
          }
        },
        {
          id: 6,
          type: 'weather',
          cardSize: 'small',
          data: {
            location: '深圳',
            weather: '晴',
            highTemp: '33',
            temp: '31',
            lowTemp: '26'
          }
        },
        {
          id: 7,
          type: 'weather',
          cardSize: 'small',
          data: {
            location: '南京',
            weather: '多云',
            temp: '30',
            highTemp: '30',
            lowTemp: '21'
          }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 3,
          cardSize: 'large',
          type: 'weather',
          data: {
            location: '北京',
            temp: '25',
            highTemp: '30',
            weather: '晴',
            lowTemp: '18',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              lowTemp: '24',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '18',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                weather: '雨',
                lowTemp: '15',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '21',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        },
        {
          id: 4,
          type: 'weather',
          cardSize: 'large',
          data: {
            location: '杭州',
            weather: '小雨',
            temp: '24',
            highTemp: '28',
            lowTemp: '20',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              lowTemp: '23',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[1],
                weather: '多云',
                lowTemp: '23',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                lowTemp: '22',
                weather: '雨',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '24',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        }
      ]
    }
  ]
  static woodenFishCard: CardItem[] = [
    {
      cardType: 1,
      cards: [
        {
          id: 1,
          type: 'woodenFish',
          cardSize: 'small',
          data: { luckValue: 8586, woodenFishTitle: '好运' }
        },
        {
          id: 2,
          type: 'woodenFish',
          data: { luckValue: 9695, woodenFishTitle: '功德' },
          cardSize: 'medium'
        }
      ]
    },
    {
      cardType: 2,
      cards: [
        {
          id: 4,
          type: 'woodenFish',
          data: { luckValue: 6636, woodenFishTitle: '好运' },
          cardSize: 'small',
        },
        {
          id: 5,
          type: 'woodenFish',
          data: { luckValue: 7525, woodenFishTitle: '好运' },
          cardSize: 'small',
        },
        {
          id: 6,
          cardSize: 'small',
          data: { luckValue: 9322, woodenFishTitle: '功德' },
          type: 'woodenFish',
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 3,
          cardSize: 'large',
          data: { luckValue: 1688, woodenFishTitle: '好运' },
          type: 'woodenFish'
        },
        {
          id: 22,
          cardSize: 'large',
          data: { woodenFishTitle: '功德', luckValue: 1866 },
          type: 'woodenFish'
        }
      ]
    }
  ]
  static otherCard: CardItem[] = [
    {
      cardType: 1,
      cards: [
        {
          id: 1,
          data: {
            location: '南京',
            temp: '26',
            weather: '多云',
            highTemp: '30',
            lowTemp: '21'
          },
          type: 'weather',
          cardSize: 'small',
        },
        {
          id: 2,
          type: 'woodenFish',
          cardSize: 'medium',
          data: { luckValue: 3555, woodenFishTitle: '好运' }
        }
      ]
    },
    {
      cardType: 2,
      cards: [
        {
          id: 5,
          cardSize: 'small',
          data: { luckValue: 8333, woodenFishTitle: '好运' },
          type: 'woodenFish'
        },
        {
          type: 'weather',
          id: 6,
          cardSize: 'small',
          data: {
            location: '武汉',
            weather: '小雨',
            temp: '23',
            highTemp: '29',
            lowTemp: '20'
          }
        },
        {

          type: 'weather',
          cardSize: 'small',
          id: 7,
          data: {
            location: '南京',
            weather: '多云',
            temp: '24',
            highTemp: '30',
            lowTemp: '21'
          }
        }
      ]
    },
    {
      cardType: 3,
      cards: [
        {
          id: 3,
          type: 'weather',
          cardSize: 'large',
          data: {
            location: '杭州',
            weather: '晴',
            temp: '29',
            highTemp: '31',
            lowTemp: '22',
            futureWeather: [({
              date: this.getFutureDates()[0],
              highTemp: '28',
              weather: '晴',
              lowTemp: '25'
            } as GeneratedObjectLiteralInterface_2),
              ({
                weather: '多云',
                date: this.getFutureDates()[1],
                lowTemp: '24',
                highTemp: '25'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[2],
                weather: '雨',
                lowTemp: '25',
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                weather: '多云',
                date: this.getFutureDates()[3],
                lowTemp: '24',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          }
        },
        {
          id: 4,
          data: {
            temp: '28',
            highTemp: '33',
            location: '重庆',
            weather: '阴',
            lowTemp: '23',
            futureWeather: [({
              date: this.getFutureDates()[0],
              weather: '晴',
              lowTemp: '24',
              highTemp: '28'
            } as GeneratedObjectLiteralInterface_2),
              ({
                weather: '多云',
                lowTemp: '18',
                highTemp: '25',
                date: this.getFutureDates()[1]
              } as GeneratedObjectLiteralInterface_2),
              ({
                weather: '雨',
                lowTemp: '15',
                date: this.getFutureDates()[2],
                highTemp: '23'
              } as GeneratedObjectLiteralInterface_2),
              ({
                date: this.getFutureDates()[3],
                weather: '多云',
                lowTemp: '16',
                highTemp: '26'
              } as GeneratedObjectLiteralInterface_2)
            ]
          },
          type: 'weather',
          cardSize: 'large',
        }
      ]
    }
  ]
  static myComponentSmallCard: Card[] = [
    {
      id: 18,
      type: 'woodenFish',
      cardSize: 'small',
      data: { luckValue: 9555, woodenFishTitle: '功德' }
    },
    {
      id: 19,
      type: 'weather',
      cardSize: 'small',
      data: {
        weather: '晴',
        location: '杭州',
        temp: '27',
        highTemp: '31',
        lowTemp: '23'
      }
    },
    {
      id: 20,
      type: 'weather',
      cardSize: 'small',
      data: {
        weather: '多云',
        location: '南京',
        temp: '26',
        highTemp: '30',
        lowTemp: '24'
      }
    },
    {
      id: 21,
      cardSize: 'small',
      data: { luckValue: 4988, woodenFishTitle: '好运' },
      type: 'woodenFish'
    },
    {
      id: 22,
      type: 'weather',
      cardSize: 'small',
      data: {
        location: '成都',
        weather: '小雨',
        highTemp: '25',
        temp: '22',
        lowTemp: '19'
      }
    },
    {
      id: 23,
      type: 'woodenFish',
      cardSize: 'small',
      data: { luckValue: 12300, woodenFishTitle: '功德' }
    },
    {
      cardSize: 'small',
      data: {
        location: '武汉',
        weather: '阴',
        temp: '29',
        highTemp: '32',
        lowTemp: '29'
      },
      id: 24,
      type: 'weather',
    },
    {
      id: 25,
      cardSize: 'small',
      type: 'woodenFish',
      data: { luckValue: 8300, woodenFishTitle: '好运' }
    },
    {
      id: 26,
      type: 'weather',
      cardSize: 'small',
      data: {
        location: '重庆',
        temp: '24',
        weather: '晴',
        highTemp: '27',
        lowTemp: '22'
      }
    },
    {
      type: 'weather',
      id: 27,
      cardSize: 'small',
      data: {
        location: '天津',
        weather: '晴',
        highTemp: '28',
        temp: '25',
        lowTemp: '21'
      }
    },
    {
      cardSize: 'small',
      id: 28,
      type: 'woodenFish',
      data: { luckValue: 7900, woodenFishTitle: '功德' }
    },
    {
      data: {
        location: '沈阳',
        weather: '多云',
        temp: '20',
        highTemp: '23',
        lowTemp: '16'
      },
      id: 29,
      type: 'weather',
      cardSize: 'small',
    },
    {
      id: 30,
      type: 'woodenFish',
      cardSize: 'small',
      data: { luckValue: 15300, woodenFishTitle: '好运' }
    },
    {
      id: 31,
      type: 'weather',
      cardSize: 'small',
      data: {
        location: '深圳',
        weather: '雨',
        highTemp: '33',
        temp: '30',
        lowTemp: '28'
      }
    },
    {
      id: 32,
      type: 'woodenFish',
      cardSize: 'small',
      data: { luckValue: 9100, woodenFishTitle: '功德' }
    },
    {
      id: 33,
      type: 'weather',
      cardSize: 'small',
      data: {
        location: '西安',
        weather: '晴',
        temp: '31',
        highTemp: '35',
        lowTemp: '28'
      }
    },
    {
      id: 34,
      cardSize: 'small',
      type: 'woodenFish',
      data: { luckValue: 6700, woodenFishTitle: '好运' }
    },
    {
      id: 35,
      type: 'weather',
      cardSize: 'small',
      data: {
        weather: '雨',
        location: '青岛',
        temp: '23',
        highTemp: '26',
        lowTemp: '21'
      }
    }
  ]
  static myComponentMediumCard: Card[] = [
    {
      id: 36,
      cardSize: 'medium',
      type: 'woodenFish',
      data: { luckValue: 9120, woodenFishTitle: '功德' }
    },
    {
      id: 37,
      type: 'weather',
      cardSize: 'medium',
      data: {
        location: '苏州',
        weather: '多云',
        temp: '24',
        highTemp: '28',
        lowTemp: '21',
        futureWeather: [({
          date: this.getFutureDates()[0],
          weather: '晴',
          lowTemp: '24',
          highTemp: '28'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            weather: '多云',
            lowTemp: '19',
            highTemp: '25'
          } as GeneratedObjectLiteralInterface_2),
          ({
            weather: '雨',
            date: this.getFutureDates()[2],
            lowTemp: '19',
            highTemp: '23'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[3],
            weather: '多云',
            lowTemp: '20',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ]
      }
    },
    {
      id: 38,
      type: 'woodenFish',
      cardSize: 'medium',
      data: { luckValue: 450, woodenFishTitle: '好运' }
    },
    {
      type: 'weather',
      id: 39,
      cardSize: 'medium',
      data: {
        weather: '多云',
        temp: '30',
        highTemp: '34',
        location: '长沙',
        lowTemp: '27',
        futureWeather: [({
          weather: '晴',
          date: this.getFutureDates()[0],
          lowTemp: '24',
          highTemp: '28'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            lowTemp: '18',
            highTemp: '25',
            weather: '多云'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[2],
            lowTemp: '15',
            highTemp: '23',
            weather: '雨',
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[3],
            weather: '多云',
            lowTemp: '20',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ]
      }
    },
    {
      id: 40,
      cardSize: 'medium',
      data: { luckValue: 500, woodenFishTitle: '功德' },
      type: 'woodenFish'
    },
    {
      id: 41,
      type: 'weather',
      data: {
        location: '昆明',
        temp: '21',
        highTemp: '25',
        weather: '晴',
        lowTemp: '18',
        futureWeather: [({
          date: this.getFutureDates()[0],
          weather: '晴',
          lowTemp: '25',
          highTemp: '28'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            weather: '多云',
            lowTemp: '18',
            highTemp: '25'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[2],
            weather: '雨',
            lowTemp: '15',
            highTemp: '23'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[3],
            weather: '多云',
            lowTemp: '20',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ]
      },
      cardSize: 'medium',

    },
    {
      id: 42,
      data: { luckValue: 7230, woodenFishTitle: '好运' },
      type: 'woodenFish',
      cardSize: 'medium',
    },
    {
      id: 43,
      type: 'weather',
      cardSize: 'medium',
      data: {
        location: '郑州',
        weather: '阴',
        futureWeather: [({
          date: this.getFutureDates()[0],
          weather: '晴',
          lowTemp: '24',
          highTemp: '28'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            weather: '多云',
            lowTemp: '18',
            highTemp: '25'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[2],
            weather: '雨',
            lowTemp: '15',
            highTemp: '23'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[3],
            weather: '多云',
            lowTemp: '20',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ],
        temp: '27',
        highTemp: '31',
        lowTemp: '23',
      }
    },
    {
      id: 44,
      type: 'woodenFish',
      cardSize: 'medium',
      data: { luckValue: 950, woodenFishTitle: '功德' }
    },
    {
      id: 45,
      type: 'weather',
      cardSize: 'medium',
      data: {
        location: '大连',
        weather: '阴',
        highTemp: '25',
        temp: '22',
        lowTemp: '20',
        futureWeather: [({
          date: this.getFutureDates()[0],
          weather: '晴',
          lowTemp: '25',
          highTemp: '28'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            weather: '多云',
            lowTemp: '18',
            highTemp: '25'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[2],
            weather: '雨',
            lowTemp: '25',
            highTemp: '23'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[3],
            lowTemp: '20',
            weather: '多云',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ]
      }
    }
  ]
  static myComponentLargeCard: Card[] = [
    {
      data: { luckValue: 28500, woodenFishTitle: '好运' },
      id: 46,
      type: 'woodenFish',
      cardSize: 'large'
    },
    {
      id: 47,
      cardSize: 'large',
      data: {
        location: '哈尔滨',
        weather: '晴',
        temp: '19',
        highTemp: '23',
        lowTemp: '15',
        futureWeather: [({
          date: this.getFutureDates()[0],
          weather: '晴',
          lowTemp: '24',
          highTemp: '28'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            lowTemp: '18',
            weather: '多云',
            highTemp: '25'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[2],
            lowTemp: '15',
            weather: '雨',
            highTemp: '23'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[3],
            weather: '多云',
            lowTemp: '16',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ]
      },
      type: 'weather'
    },
    {
      id: 48,
      type: 'woodenFish',
      cardSize: 'large',
      data: { luckValue: 23600, woodenFishTitle: '好运' }
    },
    {
      id: 49,
      cardSize: 'large',
      data: {
        temp: '28',
        highTemp: '32',
        location: '厦门',
        weather: '多云',
        lowTemp: '24',
        futureWeather: [({
          date: this.getFutureDates()[0],
          lowTemp: '24',
          highTemp: '28',
          weather: '晴'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            weather: '多云',
            lowTemp: '18',
            highTemp: '25'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[2],
            weather: '雨',
            lowTemp: '15',
            highTemp: '23'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[3],
            weather: '多云',
            lowTemp: '16',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ]
      },
      type: 'weather',
    },
    {
      type: 'woodenFish',
      id: 50,
      cardSize: 'large',
      data: { luckValue: 26900, woodenFishTitle: '好运' }
    },
    {
      type: 'weather',
      id: 51,
      cardSize: 'large',
      data: {
        location: '贵阳',
        weather: '小雨',
        temp: '20',
        lowTemp: '17',
        highTemp: '24',
        futureWeather: [({
          date: this.getFutureDates()[0],
          weather: '晴',
          lowTemp: '24',
          highTemp: '28'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            lowTemp: '18',
            weather: '多云',
            highTemp: '25'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[2],
            lowTemp: '15',
            weather: '雨',
            highTemp: '23'
          } as GeneratedObjectLiteralInterface_2),
          ({
            lowTemp: '20',
            date: this.getFutureDates()[3],
            weather: '多云',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ]
      }
    },
    {
      type: 'woodenFish',
      cardSize: 'large',
      id: 52,
      data: { luckValue: 23705, woodenFishTitle: '功德' }
    },
    {
      id: 53,
      cardSize: 'large',
      type: 'weather',
      data: {
        location: '乌鲁木齐',
        temp: '26',
        highTemp: '30',
        weather: '晴',
        lowTemp: '18',
        futureWeather: [({
          date: this.getFutureDates()[0],
          weather: '晴',
          lowTemp: '24',
          highTemp: '28'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            weather: '多云',
            lowTemp: '23',
            highTemp: '25'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[2],
            weather: '雨',
            lowTemp: '26',
            highTemp: '23'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[3],
            weather: '多云',
            lowTemp: '20',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ]
      }
    },
    {
      id: 54,
      type: 'woodenFish',
      cardSize: 'large',
      data: { luckValue: 69200, woodenFishTitle: '功德' }
    },
    {
      id: 55,
      type: 'weather',
      cardSize: 'large',
      data: {
        location: '海口',
        weather: '雨',
        highTemp: '35',
        temp: '31',
        lowTemp: '27',
        futureWeather: [({
          date: this.getFutureDates()[0],
          weather: '晴',
          lowTemp: '24',
          highTemp: '28'
        } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[1],
            weather: '多云',
            lowTemp: '23',
            highTemp: '25'
          } as GeneratedObjectLiteralInterface_2),
          ({
            date: this.getFutureDates()[2],
            weather: '雨',
            lowTemp: '23',
            highTemp: '23'
          } as GeneratedObjectLiteralInterface_2),
          ({
            weather: '多云',
            date: this.getFutureDates()[3],
            lowTemp: '24',
            highTemp: '26'
          } as GeneratedObjectLiteralInterface_2)
        ]
      }
    }
  ]

  static getFutureDates(): string[] {
    const result: string[] = [];
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const today = new Date();
    for (let i = 1; i <= 4; i++) {
      const targetDate = new Date(today);
      targetDate.setDate(today.getDate() + i);
      const dayIndex = targetDate.getDay();
      const weekday = weekdays[dayIndex];

      if (i === 1) {
        result.push('明天');
      } else {
        result.push(weekday);
      }
    }
    return result;
  }
}