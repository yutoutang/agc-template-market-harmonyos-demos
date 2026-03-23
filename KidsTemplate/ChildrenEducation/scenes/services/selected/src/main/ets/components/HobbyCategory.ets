import { DataGenerator, VideoCard, VideoCollection } from '@ohos_agcit/children_education_datasource';
import { BreakpointType, CommonConstants, GlobalInfoModel } from '@ohos_agcit/children_education_utils';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct HobbyCategory {
  @Param @Once @Require hobbyCategory: Array<VideoCard>;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    Row() {
      ForEach(this.hobbyCategory, (item: VideoCard, index: number) => {
        if (index === 0) {
          this.hobbyCardBuilder(item, $r('app.media.hobby_icon_1'), $r('app.media.hobby_background_1'))
        }
        if (index !== this.hobbyCategory.length - 1) {
          Blank().width(new BreakpointType<number>({
            sm: 12,
            md: 12,
            lg: 16,
          }).getValue(this.globalInfo.currentBreakpoint))
        }
        if (index === 1) {
          this.hobbyCardBuilder(item, $r('app.media.hobby_icon_2'), $r('app.media.hobby_background_2'))
        }
      }, (item: VideoCard) => JSON.stringify(item))
    }
    .height(new BreakpointType<number>({
      sm: 64,
      md: 80,
      lg: 96,
    }).getValue(this.globalInfo.currentBreakpoint))
  }

  @Builder
  hobbyCardBuilder(card: VideoCard, image: Resource, background: Resource) {
    Row() {
      Text(card.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium);

      Image(image)
        .height(48)
        .width(48);
    }
    .layoutWeight(0.5)
    .borderRadius(12)
    .backgroundImage(background)
    .backgroundImageSize(ImageSize.FILL)
    .justifyContent(FlexAlign.SpaceBetween)
    .height('100%')
    .padding({
      left: new BreakpointType<number>({
        sm: 16,
        md: 24,
        lg: 32,
      }).getValue(this.globalInfo.currentBreakpoint),
      right: new BreakpointType<number>({
        sm: 16,
        md: 24,
        lg: 32,
      }).getValue(this.globalInfo.currentBreakpoint)
    })
    .onClick(() => {
      let detail: VideoCollection = DataGenerator.getVideoDetail(this.getUIContext());
      detail.videoCard = card;
      this.globalInfo.navStack.pushPathByName('VideoDetailListView', detail);
    });
  }
}