import {
  CommonConstants,
  GlobalContext,
  LogUtil,
  NoMoreTab,
  TimeControl,
  Title,
} from '@ohos_agcit/children_education_utils';
import { ArrayList } from '@kit.ArkTS';
import { History, VideoCardDetail, VideoDetail } from '@ohos_agcit/children_education_datasource';

@Builder
export function ViewHistoryBuilder() {
  ViewHistory();
}

@ComponentV2
export struct ViewHistory {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local historyList: Array<History> = [];

  build() {
    NavDestination() {
      List() {
        ForEach(this.historyList, (item: History) => {
          ListItem() {
            ViewHistoryItem({
              history: item,
            });
          }.onClick(() => {
            if (TimeControl.timeControl(this.getUIContext())) {
              return;
            }
            let videoDetail: VideoDetail = {
              videoCard: item.videoCard,
              videoCardDetailList: item.videoCardList,
            };
            GlobalContext.getContext().setObject(CommonConstants.GLOBAL_VIDEO_LIST, videoDetail);
            let pathInfo: NavPathInfo;
            if (item.videoCard.videoType === 0) {
              pathInfo = new NavPathInfo(CommonConstants.VIDEO_PLAY_PAGE, item.lastWatch);
            } else {
              pathInfo = new NavPathInfo(CommonConstants.AUDIO_PLAY_PAGE, item.lastWatch);
            }
            this.appPathStack.pushDestination(pathInfo, true);
          });
        }, (item: History) => JSON.stringify(item));

        if (this.historyList.length >= 20) {
          ListItem() {
            NoMoreTab($r('app.string.twenty_record'));
          };
        }
      }
      .scrollBar(BarState.Off)
      .margin({
        top: '6%',
        left: '3%',
        right: '3%',
      });
    }
    .title(Title('观看历史'))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
    .onShown(() => {
      let list: ArrayList<History> =
        GlobalContext.getContext().getObject(CommonConstants.HISTORY_LIST) as ArrayList<History>
      try {
        this.historyList = list.convertToArray().reverse()
      } catch (error) {
        LogUtil.error(`convertToArray fail, code: ${error.code}, message: ${error.message}`)
      }
    });
  }
}

@ComponentV2
struct ViewHistoryItem {
  @Param @Once @Require history: History;
  @Local videoCardDetail: VideoCardDetail = {
    id: CommonConstants.EMPTY_STRING,
    cardId: CommonConstants.EMPTY_STRING,
    title: CommonConstants.EMPTY_STRING,
    imageUrl: CommonConstants.EMPTY_STRING,
    videoNumber: 0,
    iconUrl: CommonConstants.EMPTY_STRING,
    videoUrl: CommonConstants.EMPTY_STRING,
    isVip: false,
  };

  aboutToAppear(): void {
    this.videoCardDetail = this.history.lastWatch as VideoCardDetail;
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image(this.history.videoCard.imageUrl)
            .width('35%')
            .aspectRatio(1.78)
            .borderRadius(8);
          Image($r('app.media.icon_vip'))
            .width('11%');
        };

        Column({ space: 10 }) {
          Text(this.history.videoCard.title)
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text('已更新: ' + this.history.videoCard.updateCount + '/' + this.history.videoCard.totalCount)
            .fontWeight(FontWeight.Regular)
            .fontSize(12)
            .fontColor(Color.Gray);
          Text(this.history.videoCard.videoType === 0 ? '上次观看: ' + this.videoCardDetail.title
            : '上次收听: ' + this.videoCardDetail.title)
            .fontWeight(FontWeight.Regular)
            .fontSize(12)
            .fontColor(Color.Gray)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .width('62%')
        .alignItems(HorizontalAlign.Start)
        .margin({
          left: '3%',
        });
      }
      .width(CommonConstants.FULL_PERCENT);

      Divider()
        .width('65%')
        .margin({
          top: '4%',
          bottom: '4%',
        })
        .alignSelf(ItemAlign.End);
    }
    .width(CommonConstants.FULL_PERCENT);
  }
}