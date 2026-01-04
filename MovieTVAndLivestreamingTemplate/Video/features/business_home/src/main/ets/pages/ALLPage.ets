import { CommonConstants, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { VideoModel } from 'lib_video_api';
import { AppStorageV2 } from '@kit.ArkUI';
import { AllViewModel } from '../viewmodels/AllViewModel';
import { channelList, TabInfo } from '../model/TabInfoModel';

@Builder
export function ALLPageBuilder() {
  ALLPage()
}

@ComponentV2
struct ALLPage {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local vm: AllViewModel = new AllViewModel();

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: '全部剧集' })
      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            this.categoryHotBuilder()
            this.contentTypeBuilder(this.vm.contentTypeList)
            this.videoTypeBuilder(this.vm.videoTypeList)
            this.countryBuilder(this.vm.countryList)
            this.yearBuilder(this.vm.yearList)
          }
          .alignItems(HorizontalAlign.Start)

          this.contentBuilder()
        }
        .width('100%')
      }
      .onReachEnd(() => {
        // 只有在有更多数据且不在加载中时才触发加载更多
        if (this.vm.hasMore && !this.vm.isLoadingMore) {
          this.vm.loadMore();
        }
      })
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .padding({
        left: CommonConstants.PADDING_PAGE,
        right: CommonConstants.PADDING_PAGE,
        top: 16,
        bottom: this.windowModel.windowBottomPadding
      })
    }
    .hideTitleBar(true)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.background_primary'))
    .padding({

      bottom: this.windowModel.windowBottomPadding
    })
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .hideTitleBar(true)
  }

  @Builder
  contentBuilder() {
    Column() {
      // 内容网格
      GridRow({ columns: 2, gutter: 8 }) {
        ForEach(this.vm.filteredVideoList, (item: VideoModel) => {
          GridCol() {
            Column({ space: 8 }) {
              Stack() {
                Image(item.coverUrl)
                  .width('100%')
                  .aspectRatio(16 / 9)
                  .borderRadius(8)
                Row() {
                  Text('')
                  Text(`全${item.videoUrl?.length || 0}集`)
                    .fontColor('#FFFFFFFF')
                    .fontSize(8)
                    .lineHeight(9)
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .padding(4)
              }
              .alignContent(Alignment.Bottom)

              Text(item.title)
                .fontColor('#E6000000')
                .fontSize(14)
                .lineHeight(16)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')

              Text(item.synopsis || '')
                .fontColor('#99000000')
                .fontSize(10)
                .lineHeight(11)
                .width('100%')
                .textAlign(TextAlign.Start)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .onClick(() => {
              const param: Record<string, Object> = { 'videoId': item.videoId };
              RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
            })
          }
        }, (item: VideoModel) => JSON.stringify(item))
      }

      // 加载状态指示器 - 只在有数据时显示
      if (this.vm.filteredVideoList.length > 0) {
        Column({ space: 8 }) {
          // 加载中：转圈动画 + 文字
          if (this.vm.isLoadingMore) {
            Row() {
              Text('加载中...')
                .fontSize(14)
                .fontColor('#99000000')
                .margin({ left: 8 })
            }
            .justifyContent(FlexAlign.Center)
            .padding(16)
          } else if (!this.vm.hasMore) {
            Text('已加载完所有数据')
              .fontSize(14)
              .fontColor('#99000000')
              .padding(16)
          } else if (this.vm.hasMore && !this.vm.isLoadingMore) {
            Text('上拉加载更多')
              .fontSize(12)
              .fontColor('#CCCCCC')
              .padding(16)
          }
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      } else if (!this.vm.isRefreshing) {
        Column() {
          Text('暂无数据')
            .fontSize(16)
            .fontColor('#999999')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .padding(60)
      }
    }
    .width('100%')
  }

  @Builder
  videoTypeBuilder(categoryList: string[]) {
    List({ space: 12 }) {
      ForEach(categoryList, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(item)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.vm.videoTypeIndex === index ? '#FFFFFF' : '#333333')
              .padding({ left: 4, right: 4 })
          }
          .backgroundColor(this.vm.videoTypeIndex === index ? '#FFFD603E' : '')
          .borderRadius(20)
          .padding({
            left: 16,
            right: 16,
            top: 6,
            bottom: 6
          })
          .onClick(() => {
            this.vm.videoTypeIndex = index;
            this.vm.videoTypeChange(item);
          })
        }
        .margin({ top: 4, bottom: 4 })
      }, (item: string, index: number) => item + index)
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  categoryHotBuilder() {
    List({ space: 12 }) {
      ForEach(channelList.slice().reverse(), (item: TabInfo, index: number) => {
        ListItem() {
          Row() {
            Text(item.text)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.vm.hotIndex === index ? '#FFFFFF' : '#333333')
              .padding({ left: 4, right: 4 })
          }
          .backgroundColor(this.vm.hotIndex === index ? '#FFFD603E' : '')
          .borderRadius(20)
          .padding({
            left: 16,
            right: 16,
            top: 6,
            bottom: 6
          })
          .onClick(() => {
            this.vm.hotIndex = index;
            this.vm.hotChange(item.id);
          })
        }
        .margin({ top: 4, bottom: 4 })
      }, (item: TabInfo) => JSON.stringify(item))
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  contentTypeBuilder(categoryList: string[]) {
    List({ space: 12 }) {
      ForEach(categoryList, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(item)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.vm.contentTypeIndex === index ? '#FFFFFF' : '#333333')
              .padding({ left: 4, right: 4 })
          }
          .backgroundColor(this.vm.contentTypeIndex === index ? '#FFFD603E' : '')
          .borderRadius(20)
          .padding({
            left: 16,
            right: 16,
            top: 6,
            bottom: 6
          })
          .onClick(() => {
            this.vm.contentTypeIndex = index;
            this.vm.contentTypeChange(item);
          })
        }
        .margin({ top: 4, bottom: 4 })
      }, (item: string, index: number) => item + index)
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  countryBuilder(categoryList: string[]) {
    List({ space: 12 }) {
      ForEach(categoryList, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(item)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.vm.countryIndex === index ? '#FFFFFF' : '#333333')
              .padding({ left: 4, right: 4 })
          }
          .backgroundColor(this.vm.countryIndex === index ? '#FFFD603E' : '')
          .borderRadius(20)
          .padding({
            left: 16,
            right: 16,
            top: 6,
            bottom: 6
          })
          .onClick(() => {
            this.vm.countryIndex = index;
            this.vm.countryChange(item);
          })
        }
        .margin({ top: 4, bottom: 4 })
      }, (item: string, index: number) => item + index)
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  yearBuilder(categoryList: string[]) {
    List({ space: 12 }) {
      ForEach(categoryList, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(item)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.vm.yearIndex === index ? '#FFFFFF' : '#333333')
              .padding({ left: 4, right: 4 })
          }
          .backgroundColor(this.vm.yearIndex === index ? '#FFFD603E' : '')
          .borderRadius(20)
          .padding({
            left: 16,
            right: 16,
            top: 6,
            bottom: 6
          })
          .onClick(() => {
            this.vm.yearIndex = index;
            this.vm.yearChange(item);
          })
        }
        .margin({ top: 4, bottom: 4 })
      }, (item: string, index: number) => item + index)
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }
}
