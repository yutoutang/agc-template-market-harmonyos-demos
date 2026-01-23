import { DataGenerator, VideoDetail } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, IconLoc, TagLabelCard } from '@ohos_agcit/children_education_utils';

@ComponentV2
export struct SingStory {
  @Param @Once @Require singStory: Array<VideoDetail>;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local textWidth: number = 0;

  build() {
    List() {
      ForEach(this.singStory, (item: VideoDetail, index: number) => {
        ListItem() {
          Column() {
            Row() {
              RelativeContainer() {
                Image(item.videoCard.imageUrl)
                  .width(96)
                  .borderRadius(10)
                  .id(CommonConstants.IMAGE);
                IconLoc(CommonConstants.IMAGE, item.videoCard.isVip, '35%');
              }
              .height(54)
              .width(96)

              Blank().width(12)

              Column() {
                Row() {
                  Text(item.videoCard.title)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(2)
                    .fontWeight(FontWeight.Bold)
                    .fontSize(14)
                    .lineHeight(19)
                }

                Blank()

                Row() {
                  ForEach(item.videoCard.tags, (tag: string) => {
                    TagLabelCard(tag);
                  }, (item: string) => item);
                }
                .alignSelf(ItemAlign.Start)
              }
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.SpaceBetween)
              .height(56)
              .layoutWeight(1)
            };

            Blank().height(16)

            Divider()
              .width('70%')
              .alignSelf(ItemAlign.End);

            if (index !== this.singStory.length - 1) {
              Blank().height(16)
            }
          }
        }
        .onClick(() => {
          item.videoCardDetailList = DataGenerator.getVideoDetail(this.getUIContext()).videoCardDetailList;
          this.appPathStack.pushPathByName('VideoDetailListView', item);
        });
      }, (item: VideoDetail) => JSON.stringify(item));
    }
    .margin({ top: 16 })
    .padding({
      left: 16,
      right: 16,
    })
  }
}