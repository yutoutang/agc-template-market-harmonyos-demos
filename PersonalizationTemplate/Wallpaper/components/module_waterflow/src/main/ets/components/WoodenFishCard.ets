import { DecompressionToolPageVM } from '../viewmodels/DecompressionToolPageVM';

export class SoundController {
  play: () => void = () => {
  };
}

@ComponentV2
export struct WoodenFishCard {
  vm: DecompressionToolPageVM = DecompressionToolPageVM.instance
  @Param cardSize: 'small' | 'medium' | 'large' = 'medium';
  @Param luckValue: number | string = 0;
  @Param backgroundColorInfo: string = '#fff';
  @Param textColor: string = '#99000000';
  @Param woodenFishTitle: string = '好运';
  @Param backgroundImg: string = ''
  @Param soundEffect: boolean = true
  @Param controller: DecompressionToolPageVM = DecompressionToolPageVM.instance;

  async aboutToAppear(): Promise<void> {
    this.vm.context = this.getUIContext().getHostContext()
    this.vm.init()
  }

  async aboutToDisappear() {
    this.controller.clear()
  }

  getFontSize(baseSize: number): number {
    switch (this.cardSize) {
      case 'small':
        return Math.floor(baseSize * 0.8);
      case 'medium':
        return baseSize;
      case 'large':
        return Math.floor(baseSize * 1.2);
      default:
        return baseSize;
    }
  }

  build() {
    Column() {
      Column() {
        Text(`${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +${this.luckValue}`)
          .fontSize(this.getFontSize(16))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor || '#99000000');

        Row() {
          Image($r('app.media.wooden_fish'))
            .width(60)
        }
        .alignItems(VerticalAlign.Bottom)

      }
      .visibility(this.cardSize === 'small' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .aspectRatio(1)
      .padding(10)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImage(this.backgroundImg)
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius(4)
      .shadow({ radius: 2, color: '#00000010' });

      Row() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Row() {
            Text(`${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +${this.luckValue}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor || '#99000000');
          }
          .height('100%')
          .width('100%')
          .alignItems(VerticalAlign.Top)

          Row() {
            Image($r('app.media.wooden_fish'))
              .width(80)
          }
          .alignItems(VerticalAlign.Bottom)
        }

      }
      .visibility(this.cardSize === 'medium' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .aspectRatio(2)
      .padding(15)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImage(this.backgroundImg)
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius(4)
      .shadow({ radius: 2, color: '#00000010' });

      Column() {
        Text(`${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +${this.luckValue}`)
          .fontSize(this.getFontSize(16))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor || '#99000000');

        Row() {
          Image($r('app.media.wooden_fish'))
            .width(100)
        }
        .alignItems(VerticalAlign.Bottom)

      }
      .visibility(this.cardSize === 'large' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .aspectRatio(1)
      .padding(25)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImage(this.backgroundImg)
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius(4)
      .shadow({ radius: 2, color: '#00000010' });
    }
  }
}
