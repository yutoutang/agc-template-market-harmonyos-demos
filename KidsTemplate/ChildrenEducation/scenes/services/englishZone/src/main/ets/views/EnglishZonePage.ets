import { DataGenerator } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, FeedTitle, NoMoreTab, TwoColumn } from '@ohos_agcit/children_education_utils';

@ComponentV2
export struct EnglishZonePage {
  private englishChildrenSongsData = DataGenerator.getEnglishChildrenSongsData(this.getUIContext());
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      List({ space: 16 }) {
        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '原版英文儿歌', () => {
            this.appPathStack.pushPathByName('HotAnimationListView', undefined);
          })
        }) {
          TwoColumn({
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

    }
  }
}