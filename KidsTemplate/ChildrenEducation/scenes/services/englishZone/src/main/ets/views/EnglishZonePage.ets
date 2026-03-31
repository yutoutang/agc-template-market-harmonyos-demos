import { DataGenerator } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, FeedTitle, NoMoreTab, CompactCardComponent, GlobalInfoModel, BreakpointType } from '@ohos_agcit/children_education_utils';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct EnglishZonePage {
  private englishChildrenSongsData = DataGenerator.getEnglishChildrenSongsData(this.getUIContext());
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    Column() {
      List() {
        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '原版英文儿歌', () => {
            this.globalInfo.navStack.pushPathByName('HotAnimationListView', '原版英文儿歌');
          })
        }) {
          CompactCardComponent({
            videoCardArray: this.englishChildrenSongsData
          })
        }

        ListItem() {
          NoMoreTab($r('app.string.reach_bottom'))
        }
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
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
}