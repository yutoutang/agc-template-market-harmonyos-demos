import { DataGenerator } from '@ohos_agcit/children_education_datasource';
import {
  BreakpointType,
  CommonConstants,
  CompactCardComponent,
  FeedTitle,
  GlobalInfoModel,
  NoMoreTab
} from '@ohos_agcit/children_education_utils';
import { SingStory } from '../components/SingStory';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ChinesePage {
  private chinesePageData = DataGenerator.getChinesePageData(this.getUIContext());
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    Column() {
      List() {
        ListItemGroup({
          header: FeedTitle('app.media.feed_head_premium', '听故事 学叙事', () => {
            this.globalInfo.navStack.pushPathByName('PremiumInteractiveVideoListView', '听故事 学叙事');
          }),
        }) {
          SingStory({
            singStory: this.chinesePageData.singStory,
          });
        };

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '三字经 磨耳朵', () => {
            this.globalInfo.navStack.pushPathByName('PremiumInteractiveVideoListView', '三字经 磨耳朵');
          }),
        }) {
          CompactCardComponent({
            videoCardArray: this.chinesePageData.threeCharacter,
            showVideoType: true
          });
        };

        ListItem() {
          NoMoreTab($r('app.string.reach_bottom'));
        };
      }
      .scrollBar(BarState.Off);
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
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
  }
}