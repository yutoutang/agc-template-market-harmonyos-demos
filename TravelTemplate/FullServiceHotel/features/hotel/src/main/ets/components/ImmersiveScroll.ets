import { RouterModule } from 'commonlib';

@ComponentV2
export struct ImmersiveScroll {
  @Param
  title: string = '';
  @Param
  topBannerHeight: number = 50;
  @Param
  color: ResourceColor | undefined = undefined;
  @BuilderParam
  primaryContentBuilder: () => void;
  @Local
  localOpacity: number = 0;
  private readonly RATIOS: number[] = Array(1001).fill(0).map((_: number, i: number) => i * 0.001);

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll() {
        Stack({ alignContent: Alignment.TopStart }) {
          this.visibleAreaBuilder();
          this.primaryContentBuilder();
        };
      }
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

      this.topBannerBuilder();
    }
    .width('100%')
    .backgroundColor(this.color);
  }

  @Builder
  topBannerBuilder() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(40)
        .margin({ left: 16 })
        .onClick(() => RouterModule.pop());

      Text(this.title)
        .height(this.topBannerHeight)
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Bold)
        .fontSize($r('app.string.font_size_20'))
        .translate({ y: 0.5 })
        .margin({ left: 16 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width('100%')
    .backgroundColor($r('app.color.background_color_transparent'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }

  @Builder
  visibleAreaBuilder() {
    Column()
      .width('100%')
      .height('18%')
      .onVisibleAreaChange(this.RATIOS, (_: boolean, currentRatio: number) => {
        if (currentRatio < 0.1) {
          this.localOpacity = 1;
        } else if (currentRatio > 0.9) {
          this.localOpacity = 0;
        } else {
          let localOpacityValue: number = 1 - (currentRatio - 0.1) / 0.8;
          this.localOpacity = parseFloat(localOpacityValue.toFixed(2));
        }
      });
  }
}