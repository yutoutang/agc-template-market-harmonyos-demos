export interface CardItem {
  cardType: number,
  cards: Card[]
}

@ObservedV2
export class Card {
  @Trace id: number;
  @Trace type: 'weather' | 'woodenFish';
  @Trace cardSize: 'small' | 'medium' | 'large';
  @Trace data: ESObject;

  constructor(id: number, type: 'weather' | 'woodenFish', cardSize: 'small' | 'medium' | 'large', data: ESObject) {
    this.id = id;
    this.type = type;
    this.cardSize = cardSize;
    this.data = data;
  }
}

export interface ComponentDetailTitle {
  type: 'weather' | 'woodenFish',
  size: 'small' | 'medium' | 'large',
}

export interface FutureWeather {
  date: string;
  weather: string;
  lowTemp: string;
  highTemp: string;
}
