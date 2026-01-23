import { DataGenerator, VideoCard, VideoDetail } from '@ohos_agcit/children_education_datasource';
import { BreakpointType, CommonConstants, GlobalInfoModel, TagLabelCard } from '@ohos_agcit/children_education_utils';
import { AppStorageV2 } from '@kit.ArkUI';


@ComponentV2
export struct PremiumVideo {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Param premiumArray: Array<VideoCard> = [];
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    Grid() {
      ForEach(this.displayPremiumArray, (item: VideoCard, index: number) => {
        GridItem() {
          Column() {
            Row() {
              Stack({ alignContent: Alignment.TopStart }) {
                Image(item.imageUrl)
                  .height(54)
                  .width(96)
                  .borderRadius(10)
                  .id(CommonConstants.IMAGE);
                Image($r('app.media.icon_vip_top_start'))
                  .width(32)
                  .height(16)
              }

              Column({ space: 10 }) {
                Text(item.title)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(14)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .align(Alignment.TopStart);

                Row() {
                  ForEach(item.tags, (tag: string) => {
                    TagLabelCard(tag);
                  }, (tag: string) => tag);
                }
                .align(Alignment.BottomStart);
              }
              .alignSelf(ItemAlign.Center)
              .alignItems(HorizontalAlign.Start)
              .height(56)
              .width('63%')
              .margin({ left: 10 });
            }
            .width('100%')

            Blank().height(16)

            Divider()
              .width('64%')
              .alignSelf(ItemAlign.End)

            if (index !== this.premiumArray.length - 1) {
              Blank().height(16)
            }
          };
        }
        .onClick(() => {
          let detail: VideoDetail = DataGenerator.getVideoDetail(this.getUIContext());
          detail.videoCard = item;
          this.appPathStack.pushPathByName('VideoDetailListView', detail);
        });
      }, (item: VideoCard) => JSON.stringify(item));
    }
    .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
    }).getValue(this.globalInfo.currentBreakpoint)))
    .padding({
      top: '12vp',
      left: '4%',
      right: '4%',
    });
  }

  private getMaxDisplayCount(): number {
    const breakpoint = this.globalInfo.currentBreakpoint;

    switch (breakpoint) {
      case 'md':
        return 6;
      case 'lg':
        return 9;
      default: 
        return 3;
    }
  }

  private get displayPremiumArray(): VideoCard[] {
    const maxCount = this.getMaxDisplayCount();
    return this.premiumArray.slice(0, maxCount);
  }
}