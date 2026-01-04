import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { RouterMap, RouterUtils, TransitRouteTransitSegment } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { LineBusCard, LineMetroCard } from 'lib_native_components';
import {
  CollectionServiceApi,
  LineCollectionInnerModel,
  LineCollectionModel,
  LineDetailModel, StationCollectionModel, StopDetailModel, SubwayLineInfo } from 'module_station_line_detail';
import { SaveAllClass, SaveClass, SaveOneClass } from 'module_map_detail';
import { StationBusCard } from '../components/StationBusCard';
import { StationMetroCard } from '../components/StationMetroCard';

interface MergedStationData {
  tag: string;
  stations: StopDetailModel[];
}

@Builder
export function CollectPageBuilder() {
  CollectPage()
}

@ComponentV2
struct CollectPage {
  stack: NavPathStack = RouterUtils.getStack();
  @Local currentIndex: number = 0;
  @Local saveAllClass?: SaveAllClass = AppStorageV2.connect(SaveAllClass);
  saveClass?: SaveOneClass = AppStorageV2.connect(SaveOneClass, () => new SaveOneClass())!;
  @Local sumWork: number = 0
  @Local sumHome: number = 0
  @Local nestedHome: string[][] = [];
  @Local nestedWork: string[][] = [];
  @Local sumOther: number = 0
  private lineCollectionModel: LineCollectionModel =
    AppStorageV2.connect(LineCollectionModel, () => CollectionServiceApi.getLineCollectionList())!;
  private stationCollectionModel: StationCollectionModel =
    AppStorageV2.connect(StationCollectionModel,
      (): StationCollectionModel => new StationCollectionModel())!;

  @Builder
  LineBuilder() {
    Column() {
      Scroll() {
        Column() {
          // 动态显示收藏的线路，按标签分组
          ForEach(this.lineCollectionModel.lineCollectionInnerModels, (item: LineCollectionInnerModel) => {
            Column() {
              // 显示标签标题
              Row() {
                if (item.tag === '家') {
                  Image($r('app.media.home'))
                    .height(25)
                    .width(25)
                } else if (item.tag === '公司') {
                  Image($r('app.media.work'))
                    .height(25)
                    .width(25)
                } else {
                  Image($r('app.media.collection_other'))
                    .height(25)
                    .width(25)
                }
                Text(item.tag || '其他').margin({ left: 5 })
              }.width('100%').margin({ bottom: 15 })

              // 显示该标签下的线路
              ForEach(item.lineDetailList, (lineItem: LineDetailModel) => {
                if (lineItem.busSubwayType === '0') {
                  // 公交线路
                  LineBusCard({
                    title: lineItem.name,
                    stopCount: lineItem.currentStop?.comingBusList[0].stations,
                    stopTime: lineItem.currentStop?.comingBusList[0].time,
                    stationText: lineItem.startStop,
                    headingText: lineItem.endStop,
                    onCardClick: () => {
                      this.navigateToLineDetail(lineItem)
                    },
                  })
                } else {
                  // 地铁线路
                  LineMetroCard({
                    etaText: lineItem.interval + '分钟',
                    firstTime: lineItem.startTime,
                    title: lineItem.name,
                    stationText: lineItem.startStop,
                    lastTime: lineItem.endTime,
                    uicolor: lineItem.uicolor,
                    headingText: lineItem.endStop,
                    onCardClick: () => {
                      this.navigateToLineDetail(lineItem)
                    },
                  })
                }
              }, (v: LineDetailModel) => v.id)
            }
          }, (v: LineCollectionInnerModel) => v.tag)

          // 如果没有收藏数据，显示提示信息
          if (this.lineCollectionModel.lineCollectionInnerModels.length === 0) {
            Column() {
              Text('暂无收藏线路')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 40, bottom: 20 })
              Text('去线路详情页收藏常用线路吧')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
        }
        .margin({
          right: 12,
          top: 12,
          left: 12,
          bottom: 120
        })
      }.scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

    }.height('100%').width('100%').margin({ top: 20 })
  }

  // 获取到达时间
  getTimeArrive(arrivalTime?: number, isSelectOne?: boolean): string {
    let text: string = ''
    if (arrivalTime) {
      let targetTime = new Date(arrivalTime * 1000);
      const currentTime: Date = new Date();
      // 计算剩余毫秒数（取绝对值确保正值）
      const remainingMs: number = Math.abs(targetTime.getTime() - currentTime.getTime());
      // 计算小时和分钟
      const hours: number = Math.floor(remainingMs / (1000 * 60 * 60));
      const minutes: number = Math.floor((remainingMs % (1000 * 60 * 60)) / (1000 * 60));
      if (hours !== 0) {
        if (isSelectOne) {
          text = hours + '小时' + minutes + '分钟'
        } else {
          text = hours + ' 小时 ' + minutes + ' 分钟'
        }
      } else {
        if (isSelectOne) {
          text = minutes + '分钟'
        } else {
          text = minutes + ' 分钟'
        }
      }
    }
    return text
  }

  @Builder
  TransferBuilder() {
    Column() {
      Scroll() {
        Column() {
          if (this.saveAllClass?.saveAllClass.length === 0) {
            Column() {
              Text('暂无收藏方案')
                .margin({ top: 40, bottom: 20 })
                .fontColor('#999999')
                .fontSize(16)
              Text('去站路线规划页面收藏路线吧')
                .fontColor('#999999')
                .fontSize(14)
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
          } else {
            if (this.saveAllClass?.saveAllClass) {
              ForEach(this.saveAllClass.saveAllClass, (item: SaveClass, index: number) => {
                if (item.tag === '家' && item.savePlanClass.length > 0) {
                  // 回家标题
                  Row() {
                    Image($r('app.media.home'))
                      .height(25)
                      .width(25)
                    Text('回家').margin({ left: 5 })
                  }.width('100%').margin({ bottom: 15, top: 10 })

                  this.ShowPlan(item)

                } else if (item.tag === '公司' && item.savePlanClass.length > 0) {
                  // 公司标题
                  Row() {
                    Image($r('app.media.work'))
                      .height(25)
                      .width(25)
                    Text('公司').margin({ left: 5 })
                  }.width('100%').margin({ bottom: 15 })

                  this.ShowPlan(item)
                } else if (item.savePlanClass.length > 0) {
                  // 其他
                  Row() {
                    Image($r('app.media.collection_other'))
                      .height(25)
                      .width(25)
                    Text(item.tag).margin({ left: 5 })
                  }.width('100%').margin({ bottom: 15, top: 10 })

                  this.ShowPlan(item)
                }
              }, (v: SaveClass) => v.tag)
            }
          }
        }.margin({
          right: 12,
          left: 12,
          top: 15,
          bottom: 120
        })
      }.scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

    }.width('100%').height('100%').margin({ top: 20 })

  }

  @Builder
  ShowPlan(item: SaveClass) {
    ForEach(item.savePlanClass, (item: SaveOneClass, indexs: number) => {
      if (item.routers) {

        Column() {
          Row() {
            Text(this.getTime(Number(item.routers.cost?.duration)))
              .fontWeight(500)
              .fontSize(17)
            Image($r('app.media.ic_walk'))
              .margin({ left: 10 })
              .width(10)
            if (item.walkDistance) {
              if (item.walkDistance / 1000 > 1) {
                Text((Math.round(item.walkDistance / 1000 * 100) /
                  100).toFixed(1) + '公里')
                  .fontSize(14)
                  .margin({ left: 2 })
              } else {
                Text(item.walkDistance + '米')
                  .fontSize(14)
                  .margin({ left: 2 })
              }
            }
          }
          .margin({ top: 10, left: 12, bottom: 10 })

          // 第二行
          Flex({ wrap: FlexWrap.Wrap, space: { cross: LengthMetrics.px(20) } }) {
            if (item.routers.segments) {
              ForEach(item.routers.segments,
                (itemSegment: TransitRouteTransitSegment, index2: number) => {
                  if (itemSegment) {
                    if (itemSegment && item.routers?.segments) {
                      if (itemSegment.walking) {

                        Row() {
                          // 步行的情况
                          Image($r('app.media.is_walk'))
                            .width(15)
                            .margin({ right: 2 })
                          Text(this.getTime(Number(itemSegment.walking.cost?.duration)))
                            .fontSize(14)
                            .margin({ right: 5 })
                        }
                        .alignItems(VerticalAlign.Center)
                        .borderRadius(8)
                        .justifyContent(FlexAlign.Center)
                        .backgroundColor('#fff3f3f3')
                        .height(20)

                        if (index2 !== item.routers.segments.length - 1 || item.routers.segments.length === 1 ||
                          (itemSegment.bus && itemSegment.walking)) {
                          Image($r('app.media.ic_zhong_jian'))
                            .width(20)
                        }
                      }
                    }
                    if (itemSegment.bus && itemSegment.bus.buslines) {
                      if (itemSegment.bus.buslines[0].type === '普通公交线路' &&
                      itemSegment.bus.buslines[0].name) {
                        Column() {
                          Text(itemSegment.bus.buslines[0].name?.substring(0,
                            itemSegment.bus.buslines[0].name?.indexOf('(')))
                            .fontColor('#02A500')
                            .margin({ left: 3, right: 3 })
                            .fontSize(14)
                        }
                        .height(20)
                        //.width(50)
                        .borderWidth(1)
                        .justifyContent(FlexAlign.Center)
                        .backgroundColor('#E0FBEC')
                        .alignItems(HorizontalAlign.Center)
                        .borderRadius(8)
                        .borderColor('#02A500')

                        if (item.routers && item.routers.segments) {
                          if (index2 !== item.routers.segments.length - 1) {
                            Image($r('app.media.ic_zhong_jian'))
                              .width(20)
                          }
                        }

                      }
                      if (itemSegment.bus.buslines[0].type === '地铁线路' &&
                      itemSegment.bus.buslines[0].name) {
                        Column() {
                          Text(itemSegment.bus.buslines[0].name?.substring(0,
                            itemSegment.bus.buslines[0].name?.indexOf('(')))
                            .fontColor(Color.Black)
                            .margin({ left: 5, right: 5 })
                            .fontSize(14)
                        }
                        .backgroundColor(itemSegment.bus.buslines[0].uicolor)
                        .height(20)
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                        .borderRadius(8)

                        if (item.routers && item.routers.segments) {
                          if (index2 !== item.routers.segments.length - 1) {
                            Image($r('app.media.ic_zhong_jian'))
                              .width(20)
                          }
                        }
                      }
                    }

                  }
                }, (v: TransitRouteTransitSegment) => v.walking?.cost?.duration)
            }
          }
          .margin({
            right: 12,
            left: 12,
            bottom: 10
          })
          .width('100%')
          .padding({ right: 12 })

          if (item.routers?.cost?.transitFee && item.routers.cost.transitFee !== undefined) {
            Row() {
              Text(`共${item.total}站 · ${item.address} 上车 . 票价${item.routers.cost?.transitFee}元`)
                .fontColor('#000000')
                .fontSize(14)
                .width('95%')
            }
            .margin({ left: 12, bottom: 10 })
          }
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(10)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .onClick(() => {
          if (this.saveClass) {
            this.saveClass.id = item.id
            this.saveClass.total = item.total
            this.saveClass.routers = item.routers
            this.saveClass.address = item.address
            this.saveClass.walkDistance = item.walkDistance
            this.saveClass.startAddress = item.startAddress
            this.saveClass.endAddress = item.endAddress
            this.saveClass.startLa = item.startLa
            this.saveClass.startLo = item.startLo
            this.saveClass.endLa = item.endLa
            this.saveClass.endLo = item.endLo
          }
          RouterUtils.pushPathByName(RouterMap.INDEX_PAGE, true)
        })
        .margin({ bottom: 10 })
      }
    }, (v: SaveOneClass) => v.id)
  }

  @Builder
  StationBuilder() {
    Column() {
      Scroll() {
        Column() {
          // 显示收藏的站点，按标签分组（使用合并后的数据）
          ForEach(this.getMergedStationData(), (item: MergedStationData) => {
            if (item.stations && item.stations.length > 0) {
              // 标签标题
              Row() {
                if (item.tag === '家') {
                  Image($r('app.media.home'))
                    .height(25)
                    .width(25)
                } else if (item.tag === '公司') {
                  Image($r('app.media.work'))
                    .height(25)
                    .width(25)
                } else {
                  Image($r('app.media.collection_other'))
                    .height(25)
                    .width(25)
                }
                Text(item.tag || '其他').margin({ left: 5 })
              }.width('100%').margin({ bottom: 15 })

              // 显示该标签下的站点（合并后的数据）
              ForEach(item.stations, (stopItem: StopDetailModel) => {
                if (stopItem.stopType === 'subway_station') {
                  // 地铁站点卡片
                  StationMetroCard({
                    metroTitle: stopItem.name || '地铁站',
                    subwayLines: stopItem.subwayLines,
                    walkingText: stopItem.distance && stopItem.distance < 1000 ? stopItem.distance + '米' :
                      Number(((stopItem.distance!) / 1000).toFixed(1)) + '公里',
                    lastTime: stopItem.subwayLines?.[0]?.directions?.[0]?.endTime || '23:00',
                    firstTime: stopItem.subwayLines?.[0]?.directions?.[0]?.startTime || '06:00',
                    onStationClick: (): void => this.navigateToStopDetail(stopItem),
                    routeLineDetailPage: (lineDetailModel: LineDetailModel) => {
                      this.navigateToLineDetail(lineDetailModel)
                    }
                  })
                } else {
                  // 公交站点卡片
                  StationBusCard({
                    buslines: stopItem.busLines,
                    metroTitle: stopItem.name || '公交站',
                    walkingText: stopItem.distance && stopItem.distance < 1000 ? stopItem.distance + '米' :
                      Number(((stopItem.distance!) / 1000).toFixed(1)) + '公里',
                    statusSubTime: '',
                    statusPrefix: '',
                    onStationClick: (): void => this.navigateToStopDetail(stopItem),
                    routeLineDetailPage: (lineDetailModel: LineDetailModel) => {
                      this.navigateToLineDetail(lineDetailModel)
                    }
                  })
                }
              }, (v: StopDetailModel) => v.siteId)
            }
          }, (v: MergedStationData) => v.tag)

          // 如果没有收藏数据，显示提示信息
          if (this.getMergedStationData().length === 0) {
            Column() {
              Text('暂无收藏站点')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 40, bottom: 20 })
              Text('去站点详情页收藏常用站点吧')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
        }
        .margin({
          top: 12,
          right: 12,
          left: 12,
          bottom: 120
        })
      }.scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

    }.width('100%').height('100%').margin({ top: 20 })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '收藏',
        })
        Tabs({ index: this.currentIndex }) {
          TabContent() {
            this.LineBuilder()
          }.tabBar(SubTabBarStyle.of('线路')).width('100%').height('100%')

          TabContent() {
            this.TransferBuilder()
          }.tabBar(SubTabBarStyle.of('换乘方案')).width('100%').height('100%')

          TabContent() {
            Column() {
              this.StationBuilder()
            }
          }.tabBar(SubTabBarStyle.of('站点')).width('100%').height('100%')
        }
      }.width('100%').height('100%').backgroundColor('#f5f5f5')
    }.hideTitleBar(true)
  }

  // 跳转到线路详情页
  private navigateToLineDetail(lineDetailModel: LineDetailModel) {
    RouterUtils.pushPathByName(RouterMap.LINE_DETAIL_PAGE, lineDetailModel)
  }

  // 跳转到站点详情页
  private navigateToStopDetail(stopDetailModel: StopDetailModel) {
    // 现在收藏页面显示的是合并后的数据，直接跳转即可
    RouterUtils.pushPathByName(RouterMap.STOPDETAIL_PAGE, stopDetailModel)
  }

  // 获取合并后的站点数据（像首页一样合并同名站台）
  private getMergedStationData(): MergedStationData[] {
    const mergedData: MergedStationData[] = [];

    this.stationCollectionModel.stationCollectionInnerModels.forEach(innerModel => {
      if (innerModel.stopDetailList && innerModel.stopDetailList.length > 0) {
        // 按站点名称分组，合并同名站台
        const stationGroups = new Map<string, StopDetailModel[]>();

        innerModel.stopDetailList.forEach(stop => {
          const baseName = this.getBaseStationName(stop.name || '');
          if (!stationGroups.has(baseName)) {
            stationGroups.set(baseName, []);
          }
          stationGroups.get(baseName)!.push(stop);
        });

        // 为每个站点组创建合并后的数据
        const mergedStations: StopDetailModel[] = [];
        stationGroups.forEach((stops, baseName) => {
          if (stops.length > 0) {
            // 使用第一个站台作为基础（主站台）
            const mergedStop = new StopDetailModel();
            const mainStop = stops[0];

            // 复制主站台的基本信息
            mergedStop.siteId = mainStop.siteId;
            mergedStop.latitude = mainStop.latitude;
            mergedStop.name = mainStop.name;
            mergedStop.longitude = mainStop.longitude;
            mergedStop.stopType = mainStop.stopType;
            mergedStop.isFavorited = mainStop.isFavorited;
            mergedStop.address = mainStop.address;
            mergedStop.distance = mainStop.distance;
            mergedStop.sameNameCount = stops.length; // 设置同名站台数量

            // 合并所有同名站台的线路信息
            const allBusLines: LineDetailModel[] = [];
            const allSubwayLines: SubwayLineInfo[] = [];
            const processedSubwayLines = new Set<string>();
            const processedBusLines = new Set<string>();

            stops.forEach(stop => {
              // 合并公交线路
              if (stop.busLines) {
                stop.busLines.forEach(busLine => {
                  const lineKey = `${busLine.name || ''}_${busLine.endStop || ''}`;
                  if (!processedBusLines.has(lineKey)) {
                    processedBusLines.add(lineKey);
                    allBusLines.push(busLine);
                  }
                });
              }

              // 合并地铁线路
              if (stop.subwayLines) {
                stop.subwayLines.forEach(subwayLine => {
                  const lineKey = subwayLine.lineName || '';
                  if (!processedSubwayLines.has(lineKey)) {
                    processedSubwayLines.add(lineKey);
                    allSubwayLines.push(subwayLine);
                  }
                });
              }
            });

            mergedStop.busLines = allBusLines;
            mergedStop.subwayLines = allSubwayLines;

            mergedStations.push(mergedStop);
          }
        });

        if (mergedStations.length > 0) {
          mergedData.push({
            tag: innerModel.tag || '其他',
            stations: mergedStations
          });
        }
      }
    });

    return mergedData;
  }

  // 获取站点基础名称（去掉括号部分）
  private getBaseStationName(stationName: string): string {
    // 去掉括号及其内容，如"竹山路(东)" -> "竹山路"
    const match = stationName.match(/^([^(]+)/);
    return match ? match[1].trim() : stationName;
  }

  getTime(time: number): string {
    let text: string = ''
    // 计算小时、分钟和剩余秒数
    const hours: number = Math.floor(time / 3600);
    const minutes: number = Math.floor((time % 3600) / 60);
    if (hours > 0) {
      text = hours + '小时'
    }
    text = text + minutes + '分钟'
    return text
  }
}