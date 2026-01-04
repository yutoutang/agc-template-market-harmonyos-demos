import { geoLocationManager } from '@kit.LocationKit';
import { map, mapCommon } from '@kit.MapKit';
import { LineServiceApi, SearchServiceApi } from 'lib_api';
import { Busline, LineModel, LocationUtils, RandomUtils, StopModel, StringUtils, TransferLine } from 'lib_common';
import {
  BusSubwayMap,
  CurrentBusstop,
  LineDetailBusstop,
  LineDetailModel,
  StopDetailModel,
  SubwayLineInfo,
  TransferDetailLine
} from 'module_station_line_detail';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class StopLineModelConvertUtil {
  /**
   * 线路详情模型转换
   * @param lineDetailModel 线路详情模型
   * @param lineModel 线路模型
   */
  public static async genLineDetailModel(lineModel: LineModel, currentStop: CurrentBusstop | null) {
    const lineDetailModel: LineDetailModel = new LineDetailModel();
    StopLineModelConvertUtil.convertToLineDetailModel(lineDetailModel, lineModel);
    // 切换路线
    lineDetailModel.switchDirec = async () => {
      if (lineDetailModel.direc) {
        const lineModel = await SearchServiceApi.searchBuslineById(lineDetailModel.direc)
        if (lineModel) {
          StopLineModelConvertUtil.convertToLineDetailModel(lineDetailModel, lineModel);
          if (currentStop) {
            StopLineModelConvertUtil.getBusCarState(lineDetailModel, currentStop);
            lineDetailModel.currentStop = currentStop
            // 计算最近公交离始发站多少站
            lineDetailModel.busstops!.forEach((busstops, index) => {
              const id = busstops.id
              if (id === lineDetailModel.currentStop!.id!) {
                lineDetailModel.currentStop!.stopOffsetIndex = index
              }
            })
          } else {
            await StopLineModelConvertUtil.calRecentStop(lineDetailModel)
          }
        }
      }
    };
    if (currentStop) {
      StopLineModelConvertUtil.getBusCarState(lineDetailModel, currentStop);
      lineDetailModel.currentStop = currentStop
      // 计算最近公交离始发站多少站
      lineDetailModel.busstops!.forEach((busstops, index) => {
        const id = busstops.id
        if (id === lineDetailModel.currentStop!.id!) {
          lineDetailModel.currentStop!.stopOffsetIndex = index
        }
      })
    } else {
      await StopLineModelConvertUtil.calRecentStop(lineDetailModel)
    }
    // 路线拥堵
    if (lineModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
      lineDetailModel.busstops?.forEach(busstop => {
        busstop.congestion = String(RandomUtils.getRandomIndex(3))
      })
    }
    return lineDetailModel;
  }

  /**
   * 公交线路详情模型转换
   * @param lineDetailModel 线路详情模型
   * @param lineModel 线路模型
   */
  public static async genLineDetailModelByBusline(busline: Busline, currentStop: CurrentBusstop | null) {
    const lineDetailModel: LineDetailModel = new LineDetailModel();
    StopLineModelConvertUtil.convertToLineDetailModelByBusline(lineDetailModel, busline);
    // 切换路线
    lineDetailModel.switchDirec = async () => {
      if (lineDetailModel.direc) {
        const lineModel = await SearchServiceApi.searchBuslineById(lineDetailModel.direc)
        if (lineModel) {
          StopLineModelConvertUtil.convertToLineDetailModel(lineDetailModel, lineModel);
          if (currentStop) {
            StopLineModelConvertUtil.getBusCarState(lineDetailModel, currentStop);
            lineDetailModel.currentStop = currentStop
            // 计算最近公交离始发站多少站
            lineDetailModel.busstops!.forEach((busstops, index) => {
              const id = busstops.id
              if (id === lineDetailModel.currentStop!.id!) {
                lineDetailModel.currentStop!.stopOffsetIndex = index
              }
            })
          } else {
            await StopLineModelConvertUtil.calRecentStop(lineDetailModel)
          }
        }
      }
    };
    if (currentStop) {
      StopLineModelConvertUtil.getBusCarState(lineDetailModel, currentStop);
      lineDetailModel.currentStop = currentStop
      // 计算最近公交离始发站多少站
      lineDetailModel.busstops!.forEach((busstops, index) => {
        const id = busstops.id
        if (id === lineDetailModel.currentStop!.id!) {
          lineDetailModel.currentStop!.stopOffsetIndex = index
        }
      })
    } else {
      await StopLineModelConvertUtil.calRecentStop(lineDetailModel)
    }
    // 路线拥堵
    if (busline.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
      lineDetailModel.busstops?.forEach(busstop => {
        busstop.congestion = String(RandomUtils.getRandomIndex(3))
      })
    }
    return lineDetailModel;
  }

  public static genStoplineToLineDetailModel(busline: Busline, currentStop: CurrentBusstop) {
    const lineDetailModel: LineDetailModel = new LineDetailModel();
    lineDetailModel.busSubwayType = busline.busSubwayType;
    lineDetailModel.id = busline.id;
    lineDetailModel.name = busline.name;
    lineDetailModel.startStop = busline.startStop;
    lineDetailModel.endStop = busline.endStop;
    lineDetailModel.startTime = busline.startTime;
    lineDetailModel.endTime = busline.endTime;
    lineDetailModel.direc = busline.direc;
    lineDetailModel.basicPrice = busline.basicPrice;
    lineDetailModel.totalPrice = busline.totalPrice;
    lineDetailModel.interval = busline.interval;
    lineDetailModel.busstops = [];
    busline.busstops?.forEach(busstop => {
      const lineDetailBusstop: LineDetailBusstop = new LineDetailBusstop();
      lineDetailBusstop.name = busstop.name;
      lineDetailBusstop.location = busstop.location;
      lineDetailModel.busstops?.push(lineDetailBusstop);
    });
    // 切换路线
    lineDetailModel.switchDirec = async () => {
      if (lineDetailModel.direc) {
        const lineModel = await SearchServiceApi.searchBuslineById(lineDetailModel.direc)
        if (lineModel) {
          StopLineModelConvertUtil.convertToLineDetailModel(lineDetailModel, lineModel);
          if (currentStop) {
            StopLineModelConvertUtil.getBusCarState(lineDetailModel, currentStop);
            lineDetailModel.currentStop = currentStop
          }
        }
      }
    };
    if (currentStop) {
      StopLineModelConvertUtil.getBusCarState(lineDetailModel, currentStop);
      lineDetailModel.currentStop = currentStop
    }

    // 计算最近公交离始发站多少站
    lineDetailModel.busstops!.forEach((busstops, index) => {
      const name = busstops.name
      if (name === StringUtils.trimInBracket(lineDetailModel.currentStop!.name!)) {
        lineDetailModel.currentStop!.stopOffsetIndex = index
      }
    })
    // 路线拥堵
    if (busline.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
      lineDetailModel.busstops?.forEach(busstop => {
        busstop.congestion = String(RandomUtils.getRandomIndex(3))
      })
    }
    return lineDetailModel;
  }

  /**
   * 最近公交
   * @param lineDetailModel 线路模型
   */
  public static async calRecentStop(lineDetailModel: LineDetailModel) {
    const busstops = lineDetailModel.busstops!
    let location: geoLocationManager.Location
    try {
      location = await geoLocationManager.getCurrentLocation()
    } catch (error) {
      hilog.error(0x0000, 'StopLineModelConvertUtil', `loadSameNameStops failed: ${JSON.stringify(error)}`);
      return
    }
    if (location) {
      let shortestDistance: number
      let recentStop: CurrentBusstop = new CurrentBusstop()
      busstops?.forEach(busstop => {
        const busLocation = busstop.location
        const busLocations = busLocation?.split(',')!
        let busPosition: mapCommon.LatLng = {
          longitude: Number(busLocations[0]),
          latitude: Number(busLocations[1])
        }
        const distance = map.calculateDistance(location, busPosition)
        if (shortestDistance) {
          if (shortestDistance > distance) {
            shortestDistance = distance
            recentStop.id = busstop.id
            recentStop.name = busstop.name
            recentStop.location = busstop.location
          }
        } else {
          shortestDistance = distance
          recentStop.id = busstop.id
          recentStop.name = busstop.name
          recentStop.location = busstop.location
        }
      })
      // 最近车辆
      StopLineModelConvertUtil.getBusCarState(lineDetailModel, recentStop);
      lineDetailModel.currentStop = recentStop
      // 计算最近公交离始发站多少站
      lineDetailModel.busstops!.forEach((busstops, index) => {
        const id = busstops.id
        if (id === lineDetailModel.currentStop!.id) {
          lineDetailModel.currentStop!.stopOffsetIndex = index
        }
      })
    }
  }

  public static convertToLineDetailModel(lineDetailModel: LineDetailModel, lineModel: LineModel) {
    lineDetailModel.busSubwayType = lineModel.busSubwayType;
    lineDetailModel.id = lineModel.id;
    lineDetailModel.name = lineModel.name;
    lineDetailModel.polyline = lineModel.polyline;
    lineDetailModel.startStop = lineModel.startStop;
    lineDetailModel.endStop = lineModel.endStop;
    lineDetailModel.startTime = lineModel.startTime;
    lineDetailModel.endTime = lineModel.endTime;
    lineDetailModel.direc = lineModel.direc;
    lineDetailModel.basicPrice = lineModel.basicPrice;
    lineDetailModel.totalPrice = lineModel.totalPrice;
    lineDetailModel.interval = lineModel.interval;
    lineDetailModel.uicolor = lineModel.uicolor;
    lineDetailModel.busstops = [];
    lineModel.busstops?.forEach(busstop => {
      const lineDetailBusstop: LineDetailBusstop = new LineDetailBusstop();
      lineDetailBusstop.id = busstop.id;
      lineDetailBusstop.name = busstop.name;
      lineDetailBusstop.location = busstop.location;
      const transferLines: TransferDetailLine[] = [];
      busstop.transferLines?.forEach((transferLine: TransferLine) => {
        const transferDetailLine: TransferDetailLine = new TransferDetailLine();
        transferDetailLine.name = transferLine.name
        transferDetailLine.color = transferLine.color
        transferLines.push(transferDetailLine)
      })
      lineDetailBusstop.transferLines = busstop.transferLines;
      lineDetailModel.busstops?.push(lineDetailBusstop);
    });
  }

  public static convertToLineDetailModelByBusline(lineDetailModel: LineDetailModel, busline: Busline) {
    lineDetailModel.busSubwayType = busline.busSubwayType;
    lineDetailModel.id = busline.id;
    lineDetailModel.name = busline.name;
    lineDetailModel.polyline = busline.polyline;
    lineDetailModel.startStop = busline.startStop;
    lineDetailModel.endStop = busline.endStop;
    lineDetailModel.startTime = busline.startTime;
    lineDetailModel.endTime = busline.endTime;
    lineDetailModel.direc = busline.direc;
    lineDetailModel.basicPrice = busline.basicPrice;
    lineDetailModel.totalPrice = busline.totalPrice;
    lineDetailModel.interval = busline.interval;
    lineDetailModel.uicolor = busline.color;
    lineDetailModel.busstops = [];
    busline.busstops?.forEach(busstop => {
      const lineDetailBusstop: LineDetailBusstop = new LineDetailBusstop();
      lineDetailBusstop.id = busstop.id;
      lineDetailBusstop.name = busstop.name;
      lineDetailBusstop.location = busstop.location;
      const transferLines: TransferDetailLine[] = [];
      busstop.transferLines?.forEach((transferLine: TransferLine) => {
        const transferDetailLine: TransferDetailLine = new TransferDetailLine();
        transferDetailLine.name = transferLine.name
        transferDetailLine.color = transferLine.color
        transferLines.push(transferDetailLine)
      })
      lineDetailBusstop.transferLines = busstop.transferLines;
      lineDetailModel.busstops?.push(lineDetailBusstop);
    });
  }

  /**
   * 将StopModel转换为StopDetailModel（包含同名站台处理）
   * @param stopModel 站点模型
   * @returns StopDetailModel 站点详情模型
   */
  public static async genStopDetailModel(stopModel: StopModel): Promise<StopDetailModel> {
    const stopDetailModel: StopDetailModel = new StopDetailModel();

    // 基础信息转换
    stopDetailModel.siteId = stopModel.id;
    stopDetailModel.name = stopModel.name;

    // 坐标信息转换
    if (stopModel.location) {
      const locationParts = stopModel.location.split(',');
      if (locationParts.length >= 2) {
        stopDetailModel.longitude = parseFloat(locationParts[0]);
        stopDetailModel.latitude = parseFloat(locationParts[1]);
      }
    }

    // 站点类型设置
    if (stopModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
      stopDetailModel.stopType = 'subway_station';
    } else {
      stopDetailModel.stopType = 'bus_stop';
    }

    // 初始化线路信息
    stopDetailModel.busLines = [];
    stopDetailModel.subwayLines = [];
    // 处理站点经过的线路（去重处理）
    if (stopModel.buslines && stopModel.buslines.length > 0) {
      for (const busline of stopModel.buslines) {
        if (stopModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
          // 判断有没有当前线路
          let subwayLine = new SubwayLineInfo();
          stopDetailModel.subwayLines.forEach(item => {
            if (item.lineName === busline.name) {
              subwayLine = item;
              return
            }
          })
          if (subwayLine.lineName) {
            const currentStop: CurrentBusstop = new CurrentBusstop()
            currentStop.id = stopModel.id
            currentStop.name = stopModel.name
            currentStop.location = stopModel.location
            // 方向1：开往终点站（主要方向）
            const lineDetailModel: LineDetailModel =
              await StopLineModelConvertUtil.genLineDetailModelByBusline(busline, currentStop)

            subwayLine.directions?.push(lineDetailModel);
          } else {
            // 地铁线路
            subwayLine.lineName = busline.name;
            subwayLine.lineNumber = busline.name; // 使用名称作为编号
            subwayLine.lineColor = busline.color ? busline.color : '#f3db00'; // 设置默认颜色
            const currentStop: CurrentBusstop = new CurrentBusstop()
            currentStop.id = stopModel.id
            currentStop.name = stopModel.name
            currentStop.location = stopModel.location
            // 方向1：开往终点站（主要方向）
            const lineDetailModel: LineDetailModel =
              await StopLineModelConvertUtil.genLineDetailModelByBusline(busline, currentStop)
            subwayLine.directions?.push(lineDetailModel);
            stopDetailModel.subwayLines.push(subwayLine);
          }
        } else {
          // 公交线路
          const currentStop: CurrentBusstop = new CurrentBusstop()
          currentStop.id = stopModel.id
          currentStop.name = stopModel.name
          currentStop.location = stopModel.location
          const lineDetailModel: LineDetailModel =
            await StopLineModelConvertUtil.genLineDetailModelByBusline(busline, currentStop)
          stopDetailModel.busLines.push(lineDetailModel);
        }
      }
    }

    // 距离
    const location: mapCommon.LatLng = await LocationUtils.getGCJ02CurrentLocation()
    let distance = 0
    if (location) {
      distance =
        await SearchServiceApi.distanceSearch(location.longitude + ',' + location.latitude, stopModel.location!)
    }
    stopDetailModel.distance = Number(distance)

    // 设置默认值
    stopDetailModel.isFavorited = false;

    return stopDetailModel;
  }

  public static getBusCarState(lineDetailModel: LineDetailModel, recentStop: CurrentBusstop) {
    if (lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
      recentStop.comingBusList = LineServiceApi.getComingBusList();
    } else {
      recentStop.comingSubwayCarList = LineServiceApi.getComingSubwayCarList();
    }
  }

  /**
   * 加载同名站台信息（只有公交站才需要同名站台功能）
   * @param stopDetailModel 站点详情模型
   */
  private static async loadSameNameStops(stopDetailModel: StopDetailModel) {
    if (!stopDetailModel.siteId) {
      stopDetailModel.sameNameCount = 1;
      return;
    }

    // 只有公交站才需要同名站台功能，地铁站不需要
    if (stopDetailModel.stopType === 'bus_stop') {
      try {
        // 调用API获取同名站台信息
        const sameNameStopModel = await SearchServiceApi.searchSameNameBusstop(stopDetailModel.siteId);

        if (sameNameStopModel && sameNameStopModel.sameNameStopList.length > 0) {
          // 计算同名站台数量（主站台 + 其他同名站台）
          stopDetailModel.sameNameCount = sameNameStopModel.sameNameStopList.length + 1;

          // 注意：这里不直接处理同名站台的详细数据
          // 因为StopDetailPage会重新调用loadSameNameStops方法
          // 我们只需要设置sameNameCount即可
        } else {
          stopDetailModel.sameNameCount = 1;
        }
      } catch (error) {
        stopDetailModel.sameNameCount = 1;
      }
    } else {
      // 地铁站直接设置同名站台数量为1，不调用API
      stopDetailModel.sameNameCount = 1;
    }
  }
}