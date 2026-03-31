import { DataGenerator, VideoCard, VideoCollection } from '@ohos_agcit/children_education_datasource';
import {
  BreakpointType,
  CommonConstants,
  GlobalInfoModel,
  VideoCover
} from '@ohos_agcit/children_education_utils';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct AudioStoryZone {
  @Param audioStoryArray: Array<VideoCard> = [];
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    Grid() {
      ForEach(this.audioStoryArray, (item: VideoCard) => {
        GridItem() {
          VideoCover({
            imageUrl: item.imageUrl,
            isVip: item.isVip,
            updateCount: item.updateCount,
            totalCount: item.totalCount,
            ratio: 1
          })
        }
        .aspectRatio(1)
        .onClick(() => {
          let detail: VideoCollection = DataGenerator.getAudioDetail(this.getUIContext());
          detail.videoCard = item;
          this.globalInfo.navStack.pushPathByName('AudioDetailListView', detail);
        });
      }, (item: VideoCard) => JSON.stringify(item));
    }
    .rowsGap(new BreakpointType<number>({
      sm: 8,
      md: 12,
      lg: 16,
    }).getValue(this.globalInfo.currentBreakpoint))
    .columnsGap(new BreakpointType<number>({
      sm: 8,
      md: 12,
      lg: 16,
    }).getValue(this.globalInfo.currentBreakpoint))
    .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
      sm: 3,
      md: 4,
      lg: 5,
    }).getValue(this.globalInfo.currentBreakpoint)))
    .width(CommonConstants.FULL_PERCENT)
  }
}