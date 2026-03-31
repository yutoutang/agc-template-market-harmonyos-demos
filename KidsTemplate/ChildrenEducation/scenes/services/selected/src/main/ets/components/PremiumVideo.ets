import { DataGenerator, VideoCard, VideoCollection } from '@ohos_agcit/children_education_datasource';
import { BreakpointType, CommonConstants, GlobalInfoModel, TagLabelCard } from '@ohos_agcit/children_education_utils';
import { AppStorageV2 } from '@kit.ArkUI';


@ComponentV2
export struct PremiumVideo {
  @Param premiumArray: Array<VideoCard> = [];
  stackWidth: number = 96
  @Local dividerWidth: number = 0
  @Local rowWidth: number = 0
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
                  .borderRadius(10)
                  .aspectRatio(16 / 9)
                Image($r('app.media.icon_vip_top_start'))
                  .width(32)
                  .height(16)
              }

              Column() {
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
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.SpaceBetween)
              .height(56)
              .margin({ left: 10 })
            }
            .width('100%')
            .onAreaChange((_, area) => {
              this.rowWidth = Number(area.width)
              this.calcDividerWidth()
            })

            Row() {
              Divider().width(this.dividerWidth).strokeWidth('1px')
            }
            .justifyContent(FlexAlign.End)
            .height(16)
            .width('100%')
          }
          .justifyContent(FlexAlign.Center)
          .height(88)
        }
        .onClick(() => {
          let detail: VideoCollection = DataGenerator.getVideoDetail(this.getUIContext());
          detail.videoCard = item;
          this.globalInfo.navStack.pushPathByName('VideoDetailListView', detail);
        });
      }, (item: VideoCard) => JSON.stringify(item));
    }
    .width('100%')
    .columnsGap(new BreakpointType<number>({
      sm: 8,
      md: 12,
      lg: 16,
    }).getValue(this.globalInfo.currentBreakpoint))
    .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
    }).getValue(this.globalInfo.currentBreakpoint)))
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

  private calcDividerWidth() {
    if (this.rowWidth <= 0 || this.stackWidth <= 0) {
      return
    }

    const margin = 12
    const width = this.rowWidth - this.stackWidth - margin

    if (Math.abs(width - this.dividerWidth) > 1) {
      this.dividerWidth = width
    }
  }
}