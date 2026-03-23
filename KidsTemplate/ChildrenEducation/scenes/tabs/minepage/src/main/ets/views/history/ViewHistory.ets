import {
  AvoidArea,
  BreakpointType,
  CommonConstants,
  GlobalContext,
  GlobalInfoModel,
  LogUtil,
  TimeControl,
  Title
} from '@ohos_agcit/children_education_utils';
import { ArrayList } from '@kit.ArkTS';
import { History, VideoCardDetail, VideoCollection } from '@ohos_agcit/children_education_datasource';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function ViewHistoryBuilder() {
  ViewHistory();
}

@ComponentV2
export struct ViewHistory {
  @Local historyList: Array<History> = [];
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    NavDestination() {
      Column() {
        Grid() {
          ForEach(this.historyList, (item: History) => {
            GridItem() {
              ViewHistoryItem({
                history: item,
              });
            }
            .onClick(() => {
              if (TimeControl.timeControl(this.getUIContext())) {
                return;
              }
              let videoDetail: VideoCollection = {
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
              this.globalInfo.navStack.pushDestination(pathInfo, true);
            });
          }, (item: History) => JSON.stringify(item));
        }
        .scrollBar(BarState.Off)
        .columnsGap(new BreakpointType<number>({
          sm: 8,
          md: 12,
          lg: 16,
        }).getValue(this.globalInfo.currentBreakpoint))
        .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
          sm: 1,
          md: 2,
          lg: 3,
        }).getValue(this.globalInfo.currentBreakpoint)))
      }
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
    .title(Title('观看历史'))
    .padding({
      top: this.getUIContext().px2vp(this.avoidArea.topRectHeight),
    })
    .onBackPressed(() => {
      this.globalInfo.navStack.pop();
      return true;
    })
    .onShown(() => {
      let list: History[] =
        GlobalContext.getContext().getObject(CommonConstants.HISTORY_LIST) as History[];
      try {
        this.historyList = list.reverse()
      } catch (error) {
        LogUtil.error(`convertToArray fail, code: ${error.code}, message: ${error.message}`)
      }
    });
  }
}

@ComponentV2
struct ViewHistoryItem {
  stackWidth: number = 96
  @Local dividerWidth: number = 0
  @Local rowWidth: number = 0
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
            .height(56)
            .width(this.stackWidth)
            .borderRadius(10)
            .aspectRatio(16 / 9)
          Image($r('app.media.icon_vip'))
            .width(32)
            .height(16)
        }

        Column() {
          Text(this.history.videoCard.title)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(19)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text('已更新: ' + this.history.videoCard.updateCount + '/' + this.history.videoCard.totalCount)
            .fontSize(12)
            .lineHeight(16)
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .margin({ top: 2 })
          Text(this.history.videoCard.videoType === 0 ? '上次观看: ' + this.videoCardDetail.title
            : '上次收听: ' + this.videoCardDetail.title)
            .fontWeight(FontWeight.Regular)
            .fontSize(12)
            .lineHeight(16)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .maxLines(1)
            .margin({ top: 2 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        .height(56)
        .margin({ left: 12 })
      }
      .height(56)
      .width(CommonConstants.FULL_PERCENT)
      .margin({ top: 12, bottom: 11 })
      .onAreaChange((_, area) => {
        this.rowWidth = Number(area.width)
        this.calcDividerWidth()
      })

      Row() {
        Divider().width(this.dividerWidth).strokeWidth('1px')
      }
      .justifyContent(FlexAlign.End)
      .height(1)
      .width(CommonConstants.FULL_PERCENT)
    }
    .justifyContent(FlexAlign.Center)
    .height(80)
    .width(CommonConstants.FULL_PERCENT);
  }

  private calcDividerWidth() {
    if (this.rowWidth <= 0 || this.stackWidth <= 0) {
      return
    }

    const margin = 12
    const width = this.rowWidth - this.stackWidth - margin

    if (Math.abs(width - this.dividerWidth) > 1) {
      this.dividerWidth = width
    }
  }
}