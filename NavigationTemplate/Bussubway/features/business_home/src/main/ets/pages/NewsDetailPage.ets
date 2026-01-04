import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { newsInformationInterface, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';

@Builder
export function NewsDetailPageBuilder() {
  NewsDetailPage()
}

@ComponentV2
struct NewsDetailPage {
  stack: NavPathStack = RouterUtils.getStack();
  @Local newsItem: newsInformationInterface | null = null;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  aboutToAppear(): void {
    this.getNewsItem();
  }

  getNewsItem() {
    this.newsItem = RouterUtils.getParamByName<newsInformationInterface>(RouterMap.NEWSDETAIL_PAGE);
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: this.newsItem?.title || ''
        })
        if (this.newsItem) {
          Scroll() {
            Column() {
              Text(this.newsItem.title)
                .fontSize(25)
              Text(this.newsItem.time)
                .fontSize(12)
                .margin({ top: 4 })
                .fontColor('#abadae')
              Image(this.newsItem.image)
                .margin({ top: 13 })
                .borderRadius(8)
                .width('100%')
              Text(this.newsItem.content)
                .fontSize(14)
                .lineSpacing(LengthMetrics.percent(1))
                .margin({ top: 12 })
            }
            .padding({
              top: 12,
              left: 12,
              right: 12,
              bottom: 13
            })
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .borderRadius(16)
            .margin({ top: 8 })
          }
          .layoutWeight(1)
          .align(Alignment.TopStart)
          .scrollBar(BarState.Off)
          .padding({ left: 16, right: 16 })
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
      }
      .padding({
        bottom: this.windowModel.windowBottomPadding
      })
    }.hideTitleBar(true)
  }
}