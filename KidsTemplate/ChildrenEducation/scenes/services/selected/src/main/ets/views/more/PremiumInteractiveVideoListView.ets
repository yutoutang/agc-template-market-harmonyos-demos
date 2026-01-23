import { DataGenerator, VideoCard, VideoDetail } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, TagLabelCard, Title } from '@ohos_agcit/children_education_utils';
import { VideoCover } from '../../components/VideoCover';

@Builder
export function PremiumInteractiveVideoListBuilder() {
  PremiumInteractiveVideoListView();
}


@ComponentV2
export struct PremiumInteractiveVideoListView {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  private videoArray: Array<VideoCard> = [];

  aboutToAppear(): void {
    this.videoArray = DataGenerator.getPremiumInteractiveVideoData(this.getUIContext());
  }

  build() {
    NavDestination() {
      List({ space: 16 }) {
        ForEach(this.videoArray, (item: VideoCard) => {
          ListItem() {
            Row() {
              PremiumInteractiveVideoListItem({
                videoCard: item,
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
          .align(Alignment.Center)
        }, (item: VideoCard) => JSON.stringify(item));
      }
      .width(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .padding({
        right: 16,
        left: 16
      })
    }
    .title(Title($r('app.string.interactive_section')))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}


@ComponentV2
struct PremiumInteractiveVideoListItem {
  @Param @Once @Require videoCard: VideoCard;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    Column({ space: 10 }) {
      VideoCover({
        imageUrl: this.videoCard.imageUrl,
        isVip: this.videoCard.isVip,
        updateCount: this.videoCard.updateCount,
        totalCount: this.videoCard.totalCount,
        imageWidth: 328,
        imageHeight: 186
      })
        .onClick(() => {
          let detail: VideoDetail = DataGenerator.getVideoDetail(this.getUIContext());
          detail.videoCard = this.videoCard;
          this.appPathStack.pushPathByName('VideoDetailListView', detail);
        });

      Column() {
        Text(this.videoCard.title)
          .height(21)
          .lineHeight(21)
          .width('100%')
        
        Blank().height(2)

        Row() {
          ForEach(this.videoCard.tags, (item: string) => {
            TagLabelCard(item);
          }, (item: string) => item);
        }
      }
      .alignItems(HorizontalAlign.Start)
      .height(41)
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(328)
    .height(235)
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}
