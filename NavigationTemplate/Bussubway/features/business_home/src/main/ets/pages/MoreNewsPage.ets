import { AppStorageV2 } from '@kit.ArkUI';
import { newsInformation, newsInformationInterface, NewsModel, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SetReadIcon } from '../components/SetReadIcon';

@Builder
export function MoreNewsPageBuilder() {
  MoreNewsPage()
}

@ComponentV2
struct MoreNewsPage {
  stack: NavPathStack = RouterUtils.getStack();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local newsModel: NewsModel = AppStorageV2.connect(NewsModel, () => new NewsModel())!;

  @Builder
  NewsBuilder(item: newsInformationInterface) {
    Row({ space: 8 }) {
      Image(item.image)
        .width('30%')
        .borderRadius(8)
      Column() {
        Text(item.title)
          .fontSize(14)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight('medium')
        Text(item.time)
          .fontSize(12)
          .margin({ top: 19 })
          .fontColor('#abadae')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Circle({ width: 10, height: 10 })
        .fill($r('sys.color.warning'))
        .visibility(this.newsModel.unReadNewsIds.includes(item.id) ? Visibility.Visible : Visibility.Hidden)
    }
    .onClick(() => {
      this.newsModel.unReadNewsIds = this.newsModel.unReadNewsIds.filter(unReadNewsId => unReadNewsId !== item.id)
      RouterUtils.pushPathByName(RouterMap.NEWSDETAIL_PAGE, item)
    })
    .width('100%')
  }

  @Builder
  readAllBuilder() {
    SetReadIcon({
      enable: this.newsModel.unReadNewsIds.length > 0,
      confirm: () => {
        this.newsModel.unReadNewsIds = []
      },
    })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '官方公告',
          rightPartBuilder: () => {
            this.readAllBuilder()
          },
        })
        Scroll() {
          Column({ space: 12 }) {
            List({ space: 25 }) {
              ForEach(newsInformation, (item: newsInformationInterface) => {
                this.NewsBuilder(item)
              }, (item: string, index: number) => item + index)
            }
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .divider({
              strokeWidth: 1,
              startMargin: 104,
              endMargin: 0,
            })
            .width('100%')
            .height('100%')
            .scrollBar(BarState.Off)
          }
          .alignItems(HorizontalAlign.Start)
          .borderRadius(16)
          .padding({
            top: 12,
            left: 12,
            right: 16,
            bottom: 12
          })
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
        .padding({ right: 16, left: 16, top: 8 })
        .scrollBar(BarState.Off)

      }
      .padding({
        bottom: this.windowModel.windowBottomPadding
      })
    }.hideTitleBar(true)
  }
}