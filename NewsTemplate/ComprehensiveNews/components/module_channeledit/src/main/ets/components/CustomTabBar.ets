import { TabInfo } from '../model/Model';
import { CommonModifier } from '@kit.ArkUI';

@ComponentV2
export struct CustomTabBar {
  @Param @Require currentIndex: number;
  @Param myChannels: TabInfo[] = []
  @Event onIndexChange: (index: number, item: TabInfo) => void = () => {}
  @Param fontSizeRatio: number = 1
  @Local tabBarModifier: CommonModifier = new CommonModifier();
  @Param listScroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.tabBarModifier.align(Alignment.Start);
  }

  @Builder
  tabBuilder(index: number, item: TabInfo) {
    Column() {
      Column({ space: 8 }) {
        Text(item.text)
          .fontColor(this.currentIndex === index ? '#007DFF' : $r('sys.color.icon_secondary'))
          .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
          .fontSize(16 * this.fontSizeRatio)
        Row()
          .width(16)
          .height(2)
          .backgroundColor('#5C79D9')
          .visibility(this.currentIndex === index ? Visibility.Visible : Visibility.None)
      }
      .margin({ right: 16 })
    }
  }

  build() {
    List({ space: 16, scroller: this.listScroller }) {
      ForEach(this.myChannels, (item: TabInfo, index: number) => {
        ListItem() {
          Column() {
            Column({ space: 8 }) {
              Text(item.text)
                .fontColor(this.currentIndex === index ? '#007DFF' : $r('sys.color.icon_secondary'))
                .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
                .fontSize(16 * this.fontSizeRatio)
              Row()
                .width(16)
                .height(2)
                .backgroundColor('#5C79D9')
                .visibility(this.currentIndex === index ? Visibility.Visible : Visibility.None)
            }
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .onClick(() => {
            this.listScroller.scrollToIndex(index, true, ScrollAlign.CENTER)
            this.onIndexChange(index, item)
          })
          .justifyContent(FlexAlign.Center)
          .height('100%')
        }
      }, (item: TabInfo, index: number) => index + JSON.stringify(item))
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
  }
}
