import { User, VideoCardDetail, VideoDetail, VipRecord } from '@ohos_agcit/children_education_datasource';
import {
  CommonConstants,
  GlobalContext,
  IconAndCount,
  QuickLoginUtil,
  TimeControl,
  Title,
} from '@ohos_agcit/children_education_utils';

@Builder
export function AudioDetailBuilder() {
  AudioDetailListView();
}


@ComponentV2
export struct AudioDetailListView {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.USER_INFO) user: User = new User();
  @Consumer(CommonConstants.VIP_RECORD) vipRecord: VipRecord = new VipRecord();
  @Local audioDetail: VideoDetail = {
    videoCard: {
      id: CommonConstants.EMPTY_STRING,
      title: CommonConstants.EMPTY_STRING,
      describe: CommonConstants.EMPTY_STRING,
      tags: [],
      videoType: 1,
      updateCount: 0,
      totalCount: 0,
      imageUrl: CommonConstants.EMPTY_STRING,
      isVip: false,
    },
    videoCardDetailList: [],
  };

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Column() {
              RelativeContainer() {
                Image(this.audioDetail.videoCard.imageUrl)
                  .borderRadius(8)
                  .id(CommonConstants.IMAGE);
                IconAndCount(CommonConstants.IMAGE,
                  this.audioDetail.videoCard.isVip,
                  this.audioDetail.videoCard.updateCount,
                  this.audioDetail.videoCard.totalCount
                  , '25%', '50%', '60%');
              }
              .width(104)
              .height(104)
            }
            .margin({ left: 12 })

            Blank().width(12)

            Column() {
              Text(this.audioDetail.videoCard.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium);
              Blank().height(4)
              Text(this.audioDetail.videoCard.describe)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor('#ff949191')
                .fontSize(12);
            }
            .margin({ right: 12 })
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(130)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(12)
          .shadow(ShadowStyle.OUTER_DEFAULT_SM);

          List({ space: 10 }) {
            ForEach(this.audioDetail.videoCardDetailList, (item: VideoCardDetail, index: number) => {
              AudioListItem({
                audioItem: item,
                index: index,
              })
                .onClick(() => {
                  // 是否登录
                  if (item.isVip && this.user.isLogin === false) {
                    QuickLoginUtil.getQuickLoginAnonymousPhone(this.getUIContext(), this.appPathStack)
                    return
                  }

                  // 是否开通VIP
                  if (item.isVip && !this.vipRecord.isVip) {
                    let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.VIP_PAGE_VIEW, item);
                    this.appPathStack.pushDestination(pathInfo, true);
                    return;
                  }
                  if (TimeControl.timeControl(this.getUIContext())) {
                    return;
                  }
                  GlobalContext.getContext().setObject(CommonConstants.GLOBAL_VIDEO_LIST, this.audioDetail);
                  let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.AUDIO_PLAY_PAGE, item);
                  this.appPathStack.pushDestination(pathInfo, true);

                });
            }, (item: VideoCardDetail) => JSON.stringify(item));
          }
          .alignListItem(ListItemAlign.Start)
          .margin({
            top: '10%',
          });
        }
        .margin({
          left: '4%',
          right: '4%',
        });
      }
      .scrollBar(BarState.Off);
    }
    .onReady((cxt: NavDestinationContext) => {
      this.audioDetail = cxt.pathInfo.param as VideoDetail;
    })
    .title(Title(this.audioDetail.videoCard.title))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}

@ComponentV2
export struct AudioListItem {
  @Param @Once @Require audioItem: VideoCardDetail;
  @Param @Once @Require index: number;

  build() {
    Column() {
      if (this.index !== 0) {
        Divider()
          .width('85%')
          .padding({
            bottom: 10,
          });
      }

      Row() {
        Column() {
          Text(this.index + 1 + CommonConstants.EMPTY_STRING)
            .fontColor(Color.Gray);
        }
        .width('10%');

        Column({ space: 5 }) {
          Row() {
            Image(this.audioItem.isVip ? $r('app.media.icon_vip') : $r('app.media.icon_free'))
              .width('10%');
            Text(this.audioItem.title)
              .fontWeight(FontWeight.Regular)
              .fontColor(Color.Black)
              .fontSize(12)
              .padding({
                left: '2%',
              });
          };

          Row() {
            Image($r('app.media.icon_block'))
              .width('5%');
            Text('03:34')
              .fontColor(Color.Gray)
              .fontSize(10)
              .padding({
                left: '2%',
              });
          };
        }
        .alignItems(HorizontalAlign.Start)
        .width('90%');
      };
    };
  }
}