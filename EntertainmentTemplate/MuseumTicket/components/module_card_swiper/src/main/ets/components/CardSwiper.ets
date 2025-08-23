import { CardItem } from '../types/Index';

@ComponentV2
export struct CardSwiper {
  @Param cardList: CardItem[] = [];
  @Param centerWidth: number = 94;
  @Param centerHeight: number = 127;
  @Param smallWidth: number = 90;
  @Param smallHeight: number = 115;
  // 记录每个图片的Y轴缩放情况
  @Local allScaleY: number[] = [];
  // 记录每个图片的X轴缩放情况
  @Local allScaleX: number[] = [];
  //  Y轴缩放比例
  @Local ratioY: number = 0;
  //  X轴缩放比例
  @Local ratioX: number = 0;
  // 当前索引
  @Local currentIndex: number = 0;
  // x轴因缩放产生的偏移
  @Local offsetX: number = 0;
  // 图片间隔
  private marginX: number = 12;
  private controller: SwiperController = new SwiperController();
  @Event onChange: (index: number) => void = () => {

  };

  handleScaleData(): void {
    if (this.centerWidth > this.smallWidth && this.centerHeight > this.smallHeight) {
      this.ratioY = (this.centerHeight - this.smallHeight) / this.centerHeight;
      this.ratioX = (this.centerWidth - this.smallWidth) / this.centerWidth;
      this.allScaleX = new Array(this.cardList.length).fill(1 - this.ratioX);
      this.allScaleY = new Array(this.cardList.length).fill(1 - this.ratioY);
      this.allScaleY[0] = 1;
      this.allScaleX[0] = 1;
      this.offsetX = this.centerWidth - this.smallWidth;
    }
  }

  aboutToAppear(): void {
    this.handleScaleData();
  }

  build() {
    Column({ space: 12 }) {
      Swiper(this.controller) {
        ForEach(this.cardList, (item: CardItem, index) => {
          Image(item.img)
            .borderRadius(8)
            .scale({ x: this.allScaleX[index], y: this.allScaleY[index] })
            .margin({ left: (this.marginX - this.offsetX) / 2, right: (this.marginX - this.offsetX) / 2 })
            .onClick(() => {
              this.controller.changeIndex(index, true);
            });
        }, (item: CardItem) => item.title + item.label);
      }
      .displayMode(SwiperDisplayMode.STRETCH)
      .width(this.centerWidth * 3 + this.marginX * 2)
      .prevMargin(this.centerWidth + this.marginX - this.offsetX)
      .nextMargin(this.centerWidth + this.marginX - this.offsetX)
      .height(this.centerHeight)
      .indicator(false)
      .autoPlay(false)
      .loop(true)
      .customContentTransition({
        timeout: 1000,
        transition: (proxy: SwiperContentTransitionProxy) => {
          // 计算缩放比例
          let scaleY = 1 - (Math.abs(proxy.position)) * this.ratioY;
          this.allScaleY[(proxy.index) % (this.allScaleY.length)] = scaleY;
          let scaleX = 1 - (Math.abs(proxy.position)) * this.ratioX;
          this.allScaleX[(proxy.index) % (this.allScaleX.length)] = scaleX;
        },
      })
      .onAnimationStart((index, targetIndex) => {
        this.currentIndex = targetIndex;
      })
      .onChange((index: number) => {
        this.onChange(index);
      });

      Column({ space: 4 }) {
        Text(this.cardList[this.currentIndex].title)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'));
        Text(this.cardList[this.currentIndex].label)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'));
      };

    };
  }
}
