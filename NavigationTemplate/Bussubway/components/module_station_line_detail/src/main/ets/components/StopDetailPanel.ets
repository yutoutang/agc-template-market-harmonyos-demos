import { AppStorageV2, PromptAction } from '@kit.ArkUI'
import { BusLineInfo, StopDetailModel, SubwayLineInfo } from '../models/StopDetailModel'
import { StopCommonConstants } from '../common/StopCommonConstants'
import { BusLineItem } from './BusLineItem'
import { SubwayLineItem } from './SubwayLineItem'
import { MapChooseType, StopType } from '../common/Enums'
import { SameStopDetail, SameStopDetailModel } from '../models/SameStopDetailModel'
import { StationCollectionInnerModel, StationCollectionModel } from '../models/StationCollectionModel'
import { StopNavigation } from '../models/StopNavigation'
import { StopEventDispatcher } from '../utils/EventDispatcher'
import { LineDetailModel } from '../line/models/LineDetailModel'
import { BusSubwaySetting } from '../line/models/BusSubwaySetting'
import { StopDetailViewModel } from '../line/viewmodels/StopDetailViewModel'

@ComponentV2
export struct StopDetailPanel {
  @Param @Require stopDetailModel: StopDetailModel
  // 还有多少站台需要提醒
  @Param arrivalReminderStations: number = 0
  @Param sameStopDetailModel: SameStopDetailModel = new SameStopDetailModel()
  @Consumer() isFavoriteSheetVisible: boolean = false
  @Event onNavigate: (stopNavigation: StopNavigation) => void
  @Event routeLineDetailPage: (lineDetailModel: LineDetailModel) => void
  @Event onFavoriteClick?: () => void // 收藏按钮点击事件（需要收藏时触发，用于登录校验）
  // 同名主站台
  @Local sameMainStop: SameStopDetail = new SameStopDetail()
  @Param setting: BusSubwaySetting = new BusSubwaySetting();
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  private stationCollectionModel: StationCollectionModel =
    AppStorageV2.connect(StationCollectionModel,
      (): StationCollectionModel => new StationCollectionModel())!;
  private stopDetailViewModel: StopDetailViewModel =
    AppStorageV2.connect(StopDetailViewModel, () => new StopDetailViewModel())!;

  @Monitor('sameStopDetailModel.mainStopId')
  onSameStopDetailsChange(): void {
    this.sameStopDetailModel.sameStopDetails.forEach((sameStopDetail: SameStopDetail) => {
      if (sameStopDetail.id === this.sameStopDetailModel.mainStopId) {
        this.sameMainStop = sameStopDetail
      }
    })
  }

  aboutToAppear(): void {
    this.sameStopDetailModel.sameStopDetails.forEach((sameStopDetail: SameStopDetail) => {
      if (sameStopDetail.id === this.sameStopDetailModel.mainStopId) {
        this.sameMainStop = sameStopDetail
      }
    })
  }

  build() {
    Column() {
      // 拖拽指示器
      this.dragIndicator()

      // 站点信息头部
      this.stationHeader()

      // 操作按钮
      this.actionButtons()

      // 公交线路列表
      this.busLinesList()
    }
    .width(StopCommonConstants.FULL_PERCENT)
    .height(StopCommonConstants.DETAIL_PANEL_HEIGHT)
    .backgroundColor('#f9fbfc')
    .borderRadius({
      topLeft: StopCommonConstants.BORDER_RADIUS,
      topRight: StopCommonConstants.BORDER_RADIUS
    })
    .padding({
      left: StopCommonConstants.PADDING_PAGE,
      right: StopCommonConstants.PADDING_PAGE,
      top: StopCommonConstants.SPACE_S,
      bottom: StopCommonConstants.PADDING_PAGE
    })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  dragIndicator() {
    Row() {
      // 拖拽指示条
    }
    .width(48)
    .height(4)
    .backgroundColor('#cacacc')
    .borderRadius(2)
    .alignSelf(ItemAlign.Center)
  }

  @Builder
  stationHeader() {
    Column() {
      Row() {
        Text(this.stopDetailModel.name || '站点名称')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')


        Row() {
          Image($r('app.media.walk'))
            .width(18)
            .aspectRatio(1)
            .margin({ right: 4, left: 10 })

          Text(this.convertWalkDistance(this.stopDetailModel.distance ?? 0))
            .fontSize(16)
        }
      }
      .margin({ top: 15 })
      .width(StopCommonConstants.FULL_PERCENT)

      // 只有公交站点才显示同名站台信息（以实际同名列表为准）
      if (this.stopDetailModel.stopType !== StopType.SUBWAY_STATION && this.getSameCount() > 1) {
        Text(`${this.getSameCount()}个同名站台`)
          .fontSize(14)
          .fontColor('#777777')
          .margin({ top: 4 })
      }
    }
    .width(StopCommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
  }

  @Builder
  actionButtons() {
    Scroll() {
      Row() {
        // 收藏按钮（所有站点都有）
        this.favoriteButton()

        // 根据站点类型显示不同的按钮
        if (this.stopDetailModel.stopType === StopType.SUBWAY_STATION) {
          // 地铁站点
          this.actionButton(
            $r('app.media.switch_line'),
            '到这里去',
            () => {
              this.onNavigate({
                chooseType: MapChooseType.TARGET,
                stopDetail: this.stopDetailModel
              } as StopNavigation)
            }
          )

          this.actionButton(
            $r('app.media.switch_line2'),
            '从这出发',
            () => {
              this.onNavigate({
                chooseType: MapChooseType.ORIGIN,
                stopDetail: this.stopDetailModel
              } as StopNavigation)
            }
          )
        } else {
          // 公交站点
          this.actionButton(
            $r('app.media.switch_bus'),
            '切换站台',
            () => {
              this.onSwitchStation()
            }
          )

          this.actionButton(
            $r('app.media.switch_line'),
            '到这里去',
            () => {
              this.onNavigate({
                chooseType: MapChooseType.TARGET,
                stopDetail: this.stopDetailModel
              } as StopNavigation)
            }
          )

          this.actionButton(
            $r('app.media.switch_line2'),
            '从这出发',
            () => {
              this.onNavigate({
                chooseType: MapChooseType.ORIGIN,
                stopDetail: this.stopDetailModel
              } as StopNavigation)
            }
          )
        }
      }
      .justifyContent(FlexAlign.Start)
      .padding({ right: StopCommonConstants.PADDING_PAGE })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width(StopCommonConstants.FULL_PERCENT)
    .height(StopCommonConstants.BUTTON_HEIGHT)
    .margin({ bottom: 16 })
  }

  @Builder
  favoriteButton() {
    Row() {
      Image(this.stopDetailViewModel.isFavorited ? $r('app.media.collect_true') : $r('app.media.collect'))
        .width(14)
        .height(14)
        .margin({ right: 4 })

      Text(this.stopDetailViewModel.isFavorited ? '取消收藏' : '收藏')
        .fontSize(13)
        .fontColor('#000000')
    }
    .width(105)
    .height(StopCommonConstants.BUTTON_HEIGHT)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#efeff2')
    .borderRadius(15)
    .margin({ right: 15 })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (this.stopDetailModel.isFavorited) {
        // 取消收藏也需要登录校验
        StopEventDispatcher.dispatchToInterceptLogin((isLogin: boolean) => {
          if (isLogin || isLogin === undefined) {
            for (let i = this.stationCollectionModel.stationCollectionInnerModels.length - 1; i >= 0; i--) {
              const stationCollectionInnerModel: StationCollectionInnerModel =
                this.stationCollectionModel.stationCollectionInnerModels[i]
              for (let j = stationCollectionInnerModel.stopDetailList.length - 1; j >= 0; j--) {
                const stopDetailModel: StopDetailModel = stationCollectionInnerModel.stopDetailList[j]
                if (stopDetailModel.siteId === this.stopDetailModel.siteId) {
                  stationCollectionInnerModel.stopDetailList.splice(j, 1)
                  this.stopDetailModel.isFavorited = false
                  this.promptAction.showToast({ message: '取消收藏成功' })
                  this.stopDetailViewModel.isFavorited = this.stopDetailModel.isFavorited
                  // 跳出双层循环
                  i = -1
                  break
                }
              }
            }
          }
        })
      } else {
        // 收藏需要登录校验
        StopEventDispatcher.dispatchToInterceptLogin((isLogin: boolean) => {
          if (isLogin || isLogin === undefined) {
            if (this.onFavoriteClick) {
              this.onFavoriteClick()
            }
          }
        })
      }
    })
  }

  @Builder
  actionButton(icon: Resource, text: string, onClick: () => void) {
    Row() {
      Image(icon)
        .width(14)
        .height(14)
        .margin({ right: 4 })

      Text(text)
        .fontSize(13)
        .fontColor('#000000')
    }
    .width(105)
    .height(StopCommonConstants.BUTTON_HEIGHT)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#efeff2')
    .borderRadius(15)
    .margin({ right: 15 })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      onClick()
    })
  }

  @Builder
  busLinesList() {
    List() {
      // 根据站点类型显示不同的线路信息
      if (this.stopDetailModel.stopType === StopType.SUBWAY_STATION) {
        // 地铁线路
        if (this.stopDetailModel.subwayLines && this.stopDetailModel.subwayLines.length > 0) {
          ForEach(this.stopDetailModel.subwayLines, (subwayLine: SubwayLineInfo, index: number) => {
            ListItem() {
              SubwayLineItem({
                subwayLine: subwayLine,
                routeLineDetailPage: this.routeLineDetailPage
              })
                .margin({
                  bottom: index < this.stopDetailModel.subwayLines!.length - 1 ?
                    StopCommonConstants.SPACE_M :
                    0
                })
            }
          }, (v: SubwayLineInfo) => v.lineName)
        } else {
          ListItem() {
            Text('暂无地铁线路信息')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: StopCommonConstants.SPACE_L })
              .width(StopCommonConstants.FULL_PERCENT)
              .textAlign(TextAlign.Center)
          }
        }
      } else {
        // 公交线路（过滤掉目的地为空的线路）
        if (this.sameMainStop.lineDetailModels &&
          this.sameMainStop.lineDetailModels.length > 0) {
          if (this.sameMainStop.lineDetailModels.filter((line: LineDetailModel) => Boolean(line.endStop &&
            String(line.endStop).length > 0))
            .length > 0) {
            ForEach(this.sameMainStop.lineDetailModels.filter((line: LineDetailModel) => Boolean(line.endStop &&
              String(line.endStop).length > 0)), (busLine: LineDetailModel, index: number) => {
              ListItem() {
                BusLineItem({
                  busLine: busLine,
                  arrivalReminderStations: this.arrivalReminderStations,
                  setting: this.setting,
                  routeLineDetailPage: this.routeLineDetailPage
                })
                  .margin({
                    bottom: index <
                      this.stopDetailModel.busLines!.filter((line: BusLineInfo) => Boolean(line.destination &&
                        String(line.destination).length > 0)).length - 1 ? StopCommonConstants.SPACE_M : 0
                  })
              }
            }, (v: LineDetailModel) => v.id)
          } else {
            ListItem() {
              Text('暂无公交线路信息')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: StopCommonConstants.SPACE_L })
                .width(StopCommonConstants.FULL_PERCENT)
                .textAlign(TextAlign.Center)
            }
          }
        } else {
          ListItem() {
            Text('暂无公交线路信息')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: StopCommonConstants.SPACE_L })
              .width(StopCommonConstants.FULL_PERCENT)
              .textAlign(TextAlign.Center)
          }
        }
      }
    }
    .width(StopCommonConstants.FULL_PERCENT)
    .height(StopCommonConstants.LINES_LIST_HEIGHT)
    .backgroundColor('#f9fbfc')
    .padding({ top: StopCommonConstants.SPACE_S })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  private onSwitchStation() {
    const sameStopDetails: SameStopDetail[] = this.sameStopDetailModel.sameStopDetails
    for (let index = 0; index < sameStopDetails.length; index++) {
      const sameStopDetail: SameStopDetail = sameStopDetails[index]
      if (sameStopDetail.id === this.sameStopDetailModel.mainStopId) {
        // 下一个主站点索引
        let nextMainIndex: number = index + 1
        if (index === sameStopDetails.length - 1) {
          nextMainIndex = 0
        }
        this.sameStopDetailModel.mainStopId = sameStopDetails[nextMainIndex].id
        this.sameMainStop = sameStopDetail
        break
      }

    }
  }

  private getSameCount(): number {
    return this.sameStopDetailModel?.sameStopDetails?.length ?? 0
  }

  private convertWalkDistance(distance: number) {
    if (distance < 1000) {
      return distance + '米'
    } else {
      return Number((distance / 1000).toFixed(1)) + '公里'
    }
  }
}
