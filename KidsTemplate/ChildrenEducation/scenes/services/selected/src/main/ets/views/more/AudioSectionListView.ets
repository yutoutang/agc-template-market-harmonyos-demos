import { DataGenerator, VideoCard, VideoDetail } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, IconAndCount, Title } from '@ohos_agcit/children_education_utils';

@Builder
export function AudioSectionListBuilder() {
  AudioSectionListView();
}


@ComponentV2
export struct AudioSectionListView {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  private audioList: Array<VideoCard> = [];

  aboutToAppear(): void {
    this.audioList = DataGenerator.getAudioListData(this.getUIContext());
  }

  build() {
    NavDestination() {
      List({ space: 12 }) {
        ForEach(this.audioList, (item: VideoCard) => {
          ListItem() {
            AudioSectionListItem({
              imageUrl: item.imageUrl,
              isVip: item.isVip,
              updateCount: item.updateCount,
              totalCount: item.totalCount,
              title: item.title,
              describe: item.describe,
            })
              .onClick(() => {
                let detail: VideoDetail = DataGenerator.getAudioDetail(this.getUIContext());
                detail.videoCard = item;
                this.appPathStack.pushPathByName('AudioDetailListView', detail);
              });
          };
        }, (item: VideoCard) => JSON.stringify(item));
      }
      .scrollBar(BarState.Off)
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        top: 8,
        right: 16,
        left: 16
      })
    }
    .title(Title('音频故事专区'))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}

@ComponentV2
struct AudioSectionListItem {
  @Param @Require imageUrl: string;
  @Param @Require isVip: boolean;
  @Param @Require updateCount: number;
  @Param @Require totalCount: number;
  @Param @Require title: string;
  @Param @Require describe: string;

  build() {
    Row() {
      Column() {
        RelativeContainer() {
          Image(this.imageUrl)
            .borderRadius(8)
            .id(CommonConstants.IMAGE);
          IconAndCount(CommonConstants.IMAGE, this.isVip, this.updateCount, this.totalCount, '30%', '45%', '50%');
        }
        .width(104)
        .height(104)
      }

      Blank().width(12)

      Column() {
        Text(this.title)
          .fontWeight(FontWeight.Medium)
          .fontSize(16);

        Blank().height(4)

        Text(this.describe)
          .fontSize(12)
          .fontColor('#ff817e7e')
          .textAlign(TextAlign.Start)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(3)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    };
  }
}
