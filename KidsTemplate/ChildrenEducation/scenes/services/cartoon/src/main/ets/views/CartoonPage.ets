import { DataGenerator } from '@ohos_agcit/children_education_datasource';
import {
  BreakpointType,
  CommonConstants,
  CompactCardComponent,
  FeedTitle,
  GlobalInfoModel,
  NoMoreTab,
  StandardCardComponent
} from '@ohos_agcit/children_education_utils';
import { CoreButtons } from '../components/CoreButtons';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct CartoonPage {
  private cartoonPageData = DataGenerator.getCartoonPageData(this.getUIContext());
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    Column() {
      List() {
        ListItem() {
          CoreButtons()
        }

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '<超级汽车第四季>全52集',
            () => {
              this.globalInfo.navStack.pushPathByName('PremiumInteractiveVideoListView', '<超级汽车第四季>全52集');
            })
        }) {
          StandardCardComponent({
            videoArray: this.cartoonPageData.videoType1
          })
        }
        .margin({ top: 24 })

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '<多米益智乐园2>每周更新',
            () => {
              this.globalInfo.navStack.pushPathByName('PremiumInteractiveVideoListView', '<多米益智乐园2>每周更新');
            })
        }) {
          StandardCardComponent({
            videoArray: this.cartoonPageData.videoType2
          })
        }
        .margin({ top: 24 })

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '趣味大百科',
            () => {
              this.globalInfo.navStack.pushPathByName('PremiumInteractiveVideoListView', '趣味大百科');
            })
        }) {
          CompactCardComponent({
            videoCardArray: this.cartoonPageData.videoType3
          });
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