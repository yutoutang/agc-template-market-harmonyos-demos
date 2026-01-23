import { DataGenerator, VideoCard } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, CommonOneColumn, Title } from '@ohos_agcit/children_education_utils';

@Builder
export function HotAnimationBuilder() {
  HotAnimationListView();
}


@ComponentV2
struct HotAnimationListView {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local private title: string = '';
  private hotAnimationArray: Array<VideoCard> = [];

  aboutToAppear(): void {
    this.hotAnimationArray = DataGenerator.getHotAnimationData(this.getUIContext());
  }

  build() {
    NavDestination() {
      List({ space: 18 }) {
        ForEach(this.hotAnimationArray, (item: VideoCard) => {
          ListItem() {
            CommonOneColumn({
              videoCard: item
            })
          }
          .margin({
            bottom: $r('app.float.12vp')
          });
        }, (item: VideoCard) => JSON.stringify(item));
      }
      .width(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .padding({
        right: '4%',
        left: '4%'
      })
    }
    .title(Title(this.title))
    .onReady((cxt: NavDestinationContext) => {
      this.title = cxt.pathInfo.param as string
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}