import { common } from '@kit.AbilityKit';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  CommonConstants,
  LinearColumnModifier,
  RouterMap,
  RouterUtils,
  SettingModel,
  UserInfoModel
} from 'lib_common';
import { HomeHeaderBar } from '../components/HomeHeaderBar';
import { NewsSwiper } from '../components/NewsSwiper';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { LineBusCard, LineMetroCard } from 'lib_native_components';
import { StationBusCard } from '../components/StationBusCard';
import { StationMetroCard } from '../components/StationMetroCard';
import { SystemSceneUtils } from 'module_city_select';
import {
  CollectionServiceApi,
  LineCollectionInnerModel,
  LineCollectionModel,
  LineDetailModel,
  StopDetailModel
} from 'module_station_line_detail';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  @Local homeViewModel: HomeViewModel = new HomeViewModel();
  @Local modifier: LinearColumnModifier = new LinearColumnModifier($r('app.color.home_linear'));
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  private uiContext: UIContext = this.getUIContext()
  private context: Context = this.getUIContext().getHostContext()!
  private lineCollectionModel: LineCollectionModel =
    AppStorageV2.connect(LineCollectionModel, () => CollectionServiceApi.getLineCollectionList())!;

  aboutToAppear(): void {
    SystemSceneUtils.applyLocationPermission().then((granted: boolean) => {
      this.settingInfo.locationHasPermission = granted
      this.settingInfo.locationShowPrompt = !granted
      if (granted) {
        this.loadHomeData()
      }
    })
  }

  @Monitor('settingInfo.locationHasPermission')
  onLocationPermissionChanged() {
    // 边沿触发：从未授权变为授权后首次加载
    if (this.settingInfo.locationHasPermission) {
      this.loadHomeData()
    }
  }

  // 生命周期：组件销毁时清除定时器
  aboutToDisappear() {
    this.homeViewModel.clearInterval()
  }

  @Builder
  HomeNotCollectBuilder() {
    Column() {

    }
  }

  @Builder
  LineBuilder() {
    Column() {
      if (!this.userInfoModel.isLogin) {
        this.HomeNotCollectBuilder()
      } else {
        // 动态显示收藏的线路，按标签分组
        ForEach(this.lineCollectionModel.lineCollectionInnerModels, (item: LineCollectionInnerModel) => {
          Column() {
            // 显示标签标题
            Row() {
              if (item.tag === '家') {
                Image($r('app.media.home'))
                  .width(25)
                  .height(25)
              } else if (item.tag === '公司') {
                Image($r('app.media.work'))
                  .width(25)
                  .height(25)
              } else {
                Image($r('app.media.collection_other'))
                  .width(25)
                  .height(25)
              }
              Text(item.tag || '其他').margin({ left: 8 })
            }.width('100%').margin({ bottom: 20 })

            // 显示该标签下的线路
            ForEach(item.lineDetailList, (lineItem: LineDetailModel) => {
              if (lineItem.busSubwayType === '0') {
                // 公交线路
                LineBusCard({
                  title: lineItem.name,
                  stopCount: lineItem.currentStop?.comingBusList[0].stations ?
                    lineItem.currentStop?.comingBusList[0].stations : 0,
                  stopTime: lineItem.currentStop?.comingBusList[0].time ? lineItem.currentStop?.comingBusList[0].time :
                    0,
                  stationText: lineItem.startStop,
                  headingText: lineItem.endStop,
                  onCardClick: () => {
                    this.navigateToLineDetail(lineItem)
                  },
                })
              } else {
                // 地铁线路
                LineMetroCard({
                  title: lineItem.name,
                  etaText: lineItem.interval + '分钟',
                  stationText: lineItem.startStop,
                  firstTime: lineItem.startTime,
                  lastTime: lineItem.endTime,
                  headingText: lineItem.endStop,
                  uicolor: lineItem.uicolor,
                  onCardClick: () => {
                    this.navigateToLineDetail(lineItem)
                  },
                })
              }
            })
          }
        }, (v: LineCollectionInnerModel) => v.tag)
      }
    }
  }

  @Builder
  StationBuilder() {
    Column() {
      if (this.homeViewModel.isLoadingNearby) {
        // 显示加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .aspectRatio(1)
            .color($r('sys.color.icon_secondary'))
            .margin({ bottom: 16 })

          Text('正在获取附近站点...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.homeViewModel.nearbyStops.length > 0) {
        // 显示真实的附近站点数据
        ForEach(this.homeViewModel.nearbyStops, (stop: StopDetailModel) => {
          // 根据站点类型显示不同的卡片
          if (stop.stopType === 'subway_station') {
            // 地铁站点卡片
            StationMetroCard({
              metroTitle: stop.name,
              walkingText: this.convertWalkDistance(stop.distance ?? 0),
              subwayLines: stop.subwayLines,
              onStationClick: (): void => {
                this.navigateToStopDetail(stop);
              },
              onLineClick: async (busline: LineDetailModel): Promise<void> => {
                RouterUtils.pushPathByName(RouterMap.LINE_DETAIL_PAGE, busline)
              },
            })
          } else {
            // 公交站点卡片
            StationBusCard({
              metroTitle: stop.name || '公交站',
              buslines: stop.busLines,
              // walkingText: this.homeViewModel.calculateDistance(stop.location || ''),
              walkingText: this.convertWalkDistance(stop.distance ?? 0),
              onStationClick: (): void => {
                this.navigateToStopDetail(stop);
              },
              onLineClick: (busline: LineDetailModel): void => {
                RouterUtils.pushPathByName(RouterMap.LINE_DETAIL_PAGE, busline)
              },
            })
          }
        }, (v: StopDetailModel) => v.siteId)
      } else {
        // 显示无数据状态
        Column() {
          Text('暂无附近站点')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })

          Text('请检查定位权限或网络连接')
            .fontSize(14)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      }
    }
  }

  @Builder
  LocationPermissionPrompt() {
    Column() {
      Image($r('app.media.location_not'))
        .width(120)
        .aspectRatio(1)
      Text('无法获取当前位置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16 })

      Text('请开启精确定位权限，以获取附近站点与路线信息')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 8 })

      Text('开启定位')
        .width(120)
        .height(40)
        .backgroundColor('#e5e7e9')
        .fontColor('#0A59F7')
        .margin({ top: 24 })
        .textAlign(TextAlign.Center)
        .borderRadius(30)
        .onClick(() => {
          this.requestLocationPermissionAgain()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    NavDestination() {
      if (this.settingInfo.locationShowPrompt) {
        this.LocationPermissionPrompt()
      } else {
        Column() {
          HomeHeaderBar()
          NewsSwiper()
          Scroll() {
            Column() {
              Row() {
                Text('收藏线路').fontSize(18).fontWeight(FontWeight.Medium)
                Text(`已收藏${this.getTotalCollectionCount()}条`).fontColor('#99000000').fontSize(14)
              }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 22 })

              this.LineBuilder()

              Row() {
                Text('附近站点').fontSize(18).fontWeight(FontWeight.Medium)
              }.width('100%').margin({ top: 10, bottom: 10 })

              this.StationBuilder()
            }.margin({ top: 22, bottom: 240 })

          }.scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .backgroundColor('#F2F2F2')
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
        })
      }
    }
    .hideTitleBar(true)
  }

  private loadHomeData() {
    this.homeViewModel.sendPushNotice(getContext(this) as common.UIAbilityContext)
    this.homeViewModel.getCurrentCity(this.uiContext)
    // 加载附近站点
    this.homeViewModel.loadNearbyStops(this.context)
    // 加载公交地铁站点线路数据
    this.homeViewModel.loadStopLineData()
  }

  private async requestLocationPermissionAgain() {
    const granted: boolean = await SystemSceneUtils.applyLocationPermission()
    this.settingInfo.locationHasPermission = granted
    this.settingInfo.locationShowPrompt = !granted
    if (granted) {
      this.loadHomeData()
    }
  }

  private convertWalkDistance(distance: number) {
    if (distance < 1000) {
      return distance + '米'
    } else {
      return Number((distance / 1000).toFixed(1)) + '公里'
    }
  }

  // 计算收藏线路总数
  private getTotalCollectionCount(): number {
    // 未登录时直接返回0
    if (!this.userInfoModel.isLogin) {
      return 0
    }
    let totalCount = 0
    this.lineCollectionModel.lineCollectionInnerModels.forEach(innerModel => {
      totalCount += innerModel.lineDetailList.length
    })
    return totalCount
  }

  // 跳转到线路详情页
  private navigateToLineDetail(lineDetailModel: LineDetailModel) {
    RouterUtils.pushPathByName(RouterMap.LINE_DETAIL_PAGE, lineDetailModel)
  }

  // 跳转到站点详情页
  private navigateToStopDetail(stop: StopDetailModel) {
    RouterUtils.pushPathByName(RouterMap.STOPDETAIL_PAGE, stop);
  }
}