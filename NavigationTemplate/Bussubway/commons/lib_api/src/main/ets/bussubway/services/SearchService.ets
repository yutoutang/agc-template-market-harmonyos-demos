import { PersistenceV2 } from '@kit.ArkUI';
import { HashMap } from '@kit.ArkTS';
import {
  Busline,
  Busstop,
  City,
  CityToCitycodeMap,
  LineModel,
  SameNameStop,
  SameNameStopLine,
  SameNameStopModel,
  StopLineBase,
  StopModel,
  StringUtils,
  TransferLine,
  TransitModel,
  TransitRoute,
  TransitRouteCost,
  TransitRoutePolyline,
  TransitRouteTransit,
  TransitRouteTransitSegment,
  TransitRouteTransitSegmentBus,
  TransitRouteTransitSegmentBusBusline,
  TransitRouteTransitSegmentBusBuslineArrivalStop,
  TransitRouteTransitSegmentBusBuslineDepartureStop,
  TransitRouteTransitSegmentBusBuslineViaStop,
  TransitRouteTransitSegmentTaxi,
  TransitRouteTransitSegmentWork,
  TransitRouteTransitSegmentWorkStep
} from 'lib_common';
import {
  BuslineIdSearchReq,
  BuslineSearchReq,
  BusstopSearchReq,
  BusSubwayAroundReq,
  DistanceSearchReq,
  StopIdSearchReq,
  TransitSearchReq,
  WorkSearchReq
} from '../params/request/BusstopReq';
import { BusHttpApi } from '../https/apis/Bus';
import { BusstopResponse, BusstopSearchResponse } from '../params/response/BusstopResponse';
import { BusSubwayMap } from '../constants/Enums';
import { BuslineResponse, BuslineSearchResponse } from '../params/response/BuslineResponse';
import { BusSubwayAroundResponse } from '../params/response/BusSubwayAroundResponse';
import { TransitResponse } from '../params/response/TransitResponse';
import { DistanceResponse } from '../params/response/DistanceResponse';
import { WalkingResponse } from '../params/response/WalkingResponse';

export class SearchService {
  public async search(keywords: string): Promise<StopLineBase[]> {
    // 搜索结果
    const searchResults: StopLineBase[] = []
    // 公交站点查询
    const busstopSearchResults = await this.searchBusstop(keywords);
    // 公交线路查询
    const buslineSearchResults = await this.searchBusline(keywords);

    searchResults.push(...busstopSearchResults, ...buslineSearchResults)
    return searchResults
  }

  /**
   * 公交线路搜索
   * @param keywords 关键字
   * @param searchResults 搜索结果
   */
  public async searchBusline(keywords: string): Promise<StopLineBase[]> {
    const buslineSearchReq: BuslineSearchReq = {
      keywords: keywords,
      city: CityToCitycodeMap.CITYNAME_ADCODE_RECORD[PersistenceV2.connect(City, () => new City())!.cityName!],
      offset: 50,
      page: 1,
      extensions: 'all'
    };
    const searchResults: StopLineBase[] = [];
    const busLineSearchResponse: BuslineSearchResponse = await BusHttpApi.busLineSearch(buslineSearchReq);

    if (busLineSearchResponse.status !== '1' || busLineSearchResponse.infocode !== '10000') {
      return searchResults;
    }

    const buslines = busLineSearchResponse.buslines;
    if (!buslines || buslines.length === 0) {
      return searchResults;
    }

    const currentCityCode =
      CityToCitycodeMap.CITYNAME_ADCODE_RECORD[PersistenceV2.connect(City, () => new City())!.cityName!];
    let searchNum = 0;

    for (let buslineResponse of buslines) {
      if (buslineResponse.citycode !== currentCityCode || searchNum >= 5) {
        continue;
      }

      searchNum++;
      const type: string = buslineResponse.type;
      const lineModel = new LineModel();

      switch (type) {
        case '普通公交':
          lineModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_BUS;
          break;
        case '地铁':
          lineModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY;
          break;
        default:
          continue;
      }

      this.fillLineModelData(lineModel, buslineResponse);

      // 线路站点
      let stopModels: StopModel[] = [];
      if (lineModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
        let stopIds = buslineResponse.busstops.map(stop => stop.id).join('|');
        stopModels = await this.listSubwayTransferBusstopByIds(stopIds);
      }

      await this.processBusStops(lineModel, buslineResponse, stopModels);
      searchResults.push(lineModel);
    }

    return searchResults;
  }

  private fillLineModelData(lineModel: LineModel, buslineResponse: BuslineResponse): void {
    lineModel.id = buslineResponse.id;
    lineModel.name = StringUtils.trimInBracket(buslineResponse.name);
    lineModel.startStop = buslineResponse.start_stop;
    lineModel.endStop = buslineResponse.end_stop;
    lineModel.startTime = buslineResponse.start_time as string;
    lineModel.endTime = buslineResponse.end_time as string;
    lineModel.direc = buslineResponse.direc;
    lineModel.basicPrice = buslineResponse.basic_price;
    lineModel.totalPrice = buslineResponse.total_price;
    lineModel.interval = buslineResponse.interval;
    lineModel.polyline = buslineResponse.polyline;

    if (buslineResponse.uicolor && buslineResponse.uicolor.length > 0) {
      lineModel.uicolor = '#' + buslineResponse.uicolor;
    }

    lineModel.busstops = [];
  }

  private async processBusStops(lineModel: LineModel, buslineResponse: BuslineResponse,
    stopModels: StopModel[]): Promise<void> {
    for (let index = 0; index < buslineResponse.busstops.length; index++) {
      const buslineStopResponse = buslineResponse.busstops[index];
      const busstop: Busstop = new Busstop();

      busstop.id = buslineStopResponse.id;
      busstop.name = buslineStopResponse.name;
      busstop.location = buslineStopResponse.location;

      // 可换乘地铁路线
      if (lineModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
        const transferLines: TransferLine[] = [];
        const stopModelBuslines = stopModels[index].buslines || [];

        const uniqueBuslines = stopModelBuslines.filter(busline =>
        busline.name !== lineModel.name &&
          !transferLines.some(tl => tl.name === busline.name)
        );

        uniqueBuslines.forEach(busline => {
          const transferLine = new TransferLine();
          transferLine.name = busline.name!;
          transferLine.color = busline.color;
          transferLines.push(transferLine);
        });

        busstop.transferLines = transferLines;
      }

      lineModel.busstops?.push(busstop);
    }
  }

  /**
   * 公交线路id搜索
   * @param id 公交站id
   * @param searchResults 搜索结果
   */
  public async searchBuslineById(id: string): Promise<LineModel> {
    const buslineIdSearchReq: BuslineIdSearchReq = {
      id: id,
      extensions: 'all'
    };
    const busLineSearchResponse: BuslineSearchResponse = await BusHttpApi.busLineIdSearch(buslineIdSearchReq)
    const lineModel = new LineModel();
    if (busLineSearchResponse.status === '1' && busLineSearchResponse.infocode === '10000') {
      const buslines = busLineSearchResponse.buslines;
      if (buslines && buslines.length > 0) {
        const buslineResponse: BuslineResponse = buslines[0]
        const type: string = buslineResponse.type;
        if (type === '普通公交') {
          lineModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_BUS;
        } else if (type === '地铁') {
          lineModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY;
        } else {
          return lineModel;
        }
        lineModel.id = buslineResponse.id;
        lineModel.name = StringUtils.trimInBracket(buslineResponse.name)
        lineModel.polyline = buslineResponse.polyline
        lineModel.startStop = buslineResponse.start_stop;
        lineModel.endStop = buslineResponse.end_stop;
        lineModel.startTime = buslineResponse.start_time as string
        lineModel.endTime = buslineResponse.end_time as string;
        lineModel.direc = buslineResponse.direc
        if (buslineResponse.uicolor && buslineResponse.uicolor.length > 0) {
          lineModel.uicolor = '#' + buslineResponse.uicolor
        }
        lineModel.basicPrice = buslineResponse.basic_price;
        lineModel.totalPrice = buslineResponse.total_price;
        lineModel.interval = buslineResponse.interval;
        lineModel.busstops = [];
        // 线路站点
        let stopModels: StopModel[] = [];
        if (lineModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
          let stopIds = ''
          for (let buslineStopResponse of buslineResponse.busstops) {
            stopIds += buslineStopResponse.id + '|'
          }
          stopModels = await this.listSubwayTransferBusstopByIds(stopIds)
        }
        for (let index = 0; index < buslineResponse.busstops.length; index++) {
          const busstop: Busstop = new Busstop();
          const buslineStopResponse = buslineResponse.busstops[index]
          busstop.id = buslineStopResponse.id;
          busstop.name = buslineStopResponse.name;
          busstop.location = buslineStopResponse.location;
          // 可换乘地铁路线
          if (lineModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
            const transferLines: TransferLine[] = [];
            stopModels[index].buslines?.forEach((busline) => {
              const buslineName = busline.name!
              // 当前线路不添加
              if (buslineName !== lineModel.name) {
                // 已添加线路不添加
                let isHave: boolean = false;
                transferLines.forEach((transferLine) => {
                  if (transferLine.name === buslineName) {
                    isHave = true
                    return
                  }
                })
                if (!isHave) {
                  const transferLine = new TransferLine();
                  transferLine.name = buslineName;
                  transferLine.color = busline.color
                  transferLines.push(transferLine)
                }
              }
            })
            busstop.transferLines = transferLines;
          }
          lineModel.busstops?.push(busstop);
        }
      }
    }
    return lineModel
  }

  /**
   * 公交线路id搜索
   * @param id 公交站id
   * @param searchResults 搜索结果
   */
  public async searchLineModelByIds(ids: string): Promise<LineModel[]> {
    const buslineIdSearchReq: BuslineIdSearchReq = {
      id: ids,
      extensions: 'all'
    };
    const lineModels: LineModel[] = [];
    const busLineSearchResponse: BuslineSearchResponse = await BusHttpApi.busLineIdSearch(buslineIdSearchReq)
    let direcs = ''
    if (busLineSearchResponse.status === '1' && busLineSearchResponse.infocode === '10000') {
      const buslines = busLineSearchResponse.buslines;
      if (buslines && buslines.length > 0) {
        buslines.forEach(buslineResponse => {
          const lineModel = new LineModel();
          const type: string = buslineResponse.type;
          if (type === '普通公交') {
            lineModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_BUS;
          } else if (type === '地铁') {
            lineModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY;
          } else {
            return
          }
          lineModel.id = buslineResponse.id;
          lineModel.name = StringUtils.trimInBracket(buslineResponse.name)
          lineModel.polyline = buslineResponse.polyline
          lineModel.startStop = buslineResponse.start_stop;
          lineModel.endStop = buslineResponse.end_stop;
          lineModel.startTime = buslineResponse.start_time as string
          lineModel.endTime = buslineResponse.end_time as string;
          lineModel.direc = buslineResponse.direc
          if (buslineResponse.uicolor && buslineResponse.uicolor.length > 0) {
            lineModel.uicolor = '#' + buslineResponse.uicolor
          }
          lineModel.basicPrice = buslineResponse.basic_price;
          lineModel.totalPrice = buslineResponse.total_price;
          lineModel.interval = buslineResponse.interval;
          lineModels.push(lineModel)
        })
      }
    }
    return lineModels
  }

  /**
   * 公交线路id批量搜索
   * @param id 公交站id
   * @param searchResults 搜索结果
   */
  public async searchLineModelMapByIds(id: string): Promise<HashMap<string, LineModel>> {
    const buslineIdSearchReq: BuslineIdSearchReq = {
      id: id,
      extensions: 'all'
    };
    const busLineSearchResponse: BuslineSearchResponse = await BusHttpApi.busLineIdSearch(buslineIdSearchReq)
    const lineModelMap: HashMap<string, LineModel> = new HashMap<string, LineModel>();
    if (busLineSearchResponse.status === '1' && busLineSearchResponse.infocode === '10000') {
      const buslines = busLineSearchResponse.buslines;
      if (buslines && buslines.length > 0) {
        buslines.forEach((buslineResponse: BuslineResponse) => {
          const lineModel = new LineModel();
          const type: string = buslineResponse.type;
          if (type === '地铁') {
            lineModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY;
          } else {
            lineModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_BUS;
          }
          lineModel.id = buslineResponse.id;
          lineModel.name = StringUtils.trimInBracket(buslineResponse.name)
          lineModel.startStop = buslineResponse.start_stop;
          lineModel.endStop = buslineResponse.end_stop;
          if (buslineResponse.uicolor && buslineResponse.uicolor.length > 0) {
            lineModel.uicolor = '#' + buslineResponse.uicolor
          }
          lineModel.basicPrice = buslineResponse.basic_price;
          lineModel.totalPrice = buslineResponse.total_price;
          lineModelMap.set(buslineResponse.id, lineModel)
        })
      }
    }
    return lineModelMap
  }

  /**
   * 查询中转站线路主要是查询颜色
   * @param id 公交站id
   * @param searchResults 搜索结果
   */
  public async listSubwayTransferBuslineByIds(ids: string): Promise<LineModel[]> {
    const buslineIdSearchReq: BuslineIdSearchReq = {
      id: ids,
      extensions: 'all'
    };
    const busLineSearchResponse: BuslineSearchResponse = await BusHttpApi.busLineIdSearch(buslineIdSearchReq)
    const lineModels: LineModel[] = [];
    if (busLineSearchResponse.status === '1' && busLineSearchResponse.infocode === '10000') {
      const buslines = busLineSearchResponse.buslines;
      if (buslines && buslines.length > 0) {
        buslines.forEach((buslineResponse: BuslineResponse) => {
          const lineModel = new LineModel();
          lineModel.id = buslineResponse.id;
          lineModel.name = StringUtils.trimInBracket(buslineResponse.name);
          if (buslineResponse.uicolor && buslineResponse.uicolor.length > 0) {
            lineModel.uicolor = '#' + buslineResponse.uicolor
          }
          lineModels.push(lineModel)
        })

      }
    }
    return lineModels
  }

  /**
   * 公交线路id搜索
   * @param id 公交站id
   * @param searchResults 搜索结果
   */
  public async searchBusstopById(id: string): Promise<StopModel> {
    const stopIdSearchReq: StopIdSearchReq = {
      id: id,
    };
    const busstopSearchResponse: BusstopSearchResponse = await BusHttpApi.stopIdSearch(stopIdSearchReq);
    const stopModel: StopModel = new StopModel();

    if (busstopSearchResponse.status !== '1' || busstopSearchResponse.infocode !== '10000') {
      return stopModel;
    }

    const busstops = busstopSearchResponse.busstops;
    if (!busstops || busstops.length === 0) {
      return stopModel;
    }

    const busstopResponse: BusstopResponse = busstops[0];
    stopModel.id = busstopResponse.id;

    if (busstopResponse.name.endsWith('(地铁站)')) {
      stopModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY;
    } else {
      stopModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_BUS;
    }

    stopModel.name = busstopResponse.name;
    stopModel.location = busstopResponse.location;
    stopModel.buslines = [];

    // 查询所有线路-性能优化
    let buslineIds: string = '';
    for (const buslineResp of busstopResponse.buslines) {
      buslineIds += buslineResp.id + '|';
    }

    const buslineIdSearchReq: BuslineIdSearchReq = {
      id: buslineIds,
      extensions: 'all'
    };

    const busLineSearchResponse: BuslineSearchResponse = await BusHttpApi.busLineIdSearch(buslineIdSearchReq);

    let stopModelMap: HashMap<string, StopModel> = new HashMap();
    if (stopModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
      let stopIds = '';
      if (busLineSearchResponse.status === '1' && busLineSearchResponse.infocode === '10000') {
        for (const buslineResponse of busLineSearchResponse.buslines) {
          // 线路站点
          for (let buslineStopResponse of buslineResponse.busstops) {
            if (!stopIds.includes(buslineStopResponse.id)) {
              stopIds += buslineStopResponse.id + '|';
            }
          }
        }
      }
      stopModelMap = await this.listSubwayTransferBusstopMapByIds(stopIds);
    }

    if (busLineSearchResponse.status !== '1' || busLineSearchResponse.infocode !== '10000') {
      return stopModel;
    }

    await this.processBusLinesForStop(busLineSearchResponse.buslines, stopModel, stopModelMap);
    return stopModel;
  }

  private async processBusLinesForStop(
    buslines: BuslineResponse[],
    stopModel: StopModel,
    stopModelMap: HashMap<string, StopModel>
  ): Promise<void> {
    for (const buslineResponse of buslines) {
      const busline: Busline = new Busline();
      const type: string = buslineResponse.type;

      switch (type) {
        case '普通公交':
          busline.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_BUS;
          break;
        case '地铁':
          busline.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY;
          break;
        default:
          continue;
      }

      busline.id = buslineResponse.id;
      busline.name = StringUtils.trimInBracket(buslineResponse.name);
      busline.startStop = buslineResponse.start_stop;
      busline.endStop = buslineResponse.end_stop;
      busline.startTime = buslineResponse.start_time as string;
      busline.endTime = buslineResponse.end_time as string;
      busline.polyline = buslineResponse.polyline;
      busline.direc = buslineResponse.direc;
      busline.basicPrice = buslineResponse.basic_price;
      busline.totalPrice = buslineResponse.total_price;
      busline.interval = buslineResponse.interval;

      if (buslineResponse.uicolor && buslineResponse.uicolor.length > 0) {
        busline.color = '#' + buslineResponse.uicolor;
      }

      busline.busstops = [];

      // 线路站点
      for (let index = 0; index < buslineResponse.busstops.length; index++) {
        const busstop: Busstop = new Busstop();
        const buslineStopResponse = buslineResponse.busstops[index];
        busstop.id = buslineStopResponse.id;
        busstop.name = buslineStopResponse.name;
        busstop.location = buslineStopResponse.location;

        // 可换乘地铁路线
        if (busline.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
          const transferLines: TransferLine[] = [];
          const stopModelBuslines = stopModelMap.get(busstop.id)?.buslines || [];

          for (const stopModelBusline of stopModelBuslines) {
            const buslineName = stopModelBusline.name!;

            // 当前线路不添加
            if (buslineName === busline.name) {
              continue;
            }

            // 已添加线路不添加
            let isHave: boolean = false;
            for (const transferLine of transferLines) {
              if (transferLine.name === buslineName) {
                isHave = true;
                break;
              }
            }

            if (!isHave) {
              const transferLine = new TransferLine();
              transferLine.name = buslineName;
              transferLine.color = stopModelBusline.color;
              transferLines.push(transferLine);
            }
          }

          busstop.transferLines = transferLines;
        }

        busline.busstops?.push(busstop);
      }

      stopModel.buslines?.push(busline);
    }
  }

  /**
   * 查询地铁中转站线路
   * @param id 公交站id
   * @param searchResults 搜索结果
   */
  public async listSubwayTransferBusstopByIds(ids: string): Promise<StopModel[]> {
    const stopIdSearchReq: StopIdSearchReq = {
      id: ids,
    };
    const busstopSearchResponse: BusstopSearchResponse = await BusHttpApi.stopIdSearch(stopIdSearchReq);
    const stopModels: StopModel[] = [];
    if (busstopSearchResponse.status === '1' && busstopSearchResponse.infocode === '10000') {
      const busstops = busstopSearchResponse.busstops;
      if (busstops && busstops.length > 0) {
        // 查询所有路线颜色，提升性能
        let buslineids: string = ''
        for (const busstopResponse of busstops) {
          for (const buslineResp of busstopResponse.buslines) {
            buslineids += buslineResp.id + '|'
          }
        }
        const lineModels: LineModel[] = await this.listSubwayTransferBuslineByIds(buslineids)
        const lineColorMap: HashMap<string, string> = new HashMap<string, string>()
        lineModels.forEach((lineModel: LineModel) => {
          lineColorMap.set(lineModel.id, lineModel.uicolor);
        })
        for (const busstopResponse of busstops) {
          const stopModel: StopModel = new StopModel()
          stopModel.id = busstopResponse.id
          stopModel.name = busstopResponse.name
          stopModel.location = busstopResponse.location
          stopModel.buslines = []
          for (let index = 0; index < busstopResponse.buslines.length; index++) {
            const buslineResp = busstopResponse.buslines[index]
            const busline: Busline = new Busline()
            busline.id = buslineResp.id;
            busline.name = StringUtils.trimInBracket(buslineResp.name)
            busline.color = lineColorMap.get(buslineResp.id)
            if (busline.name !== '') {
              stopModel.buslines.push(busline)
            }
          }
          stopModels.push(stopModel)
        }


      }
    }
    return stopModels
  }

  /**
   * 查询地铁中转站线路
   * @param id 公交站id
   * @param searchResults 搜索结果
   */
  public async listSubwayTransferBusstopMapByIds(ids: string): Promise<HashMap<string, StopModel>> {
    const stopIdSearchReq: StopIdSearchReq = {
      id: ids,
    };
    const busstopSearchResponse: BusstopSearchResponse = await BusHttpApi.stopIdSearch(stopIdSearchReq);
    const stopModelMap: HashMap<string, StopModel> = new HashMap<string, StopModel>();
    if (busstopSearchResponse.status === '1' && busstopSearchResponse.infocode === '10000') {
      const busstops = busstopSearchResponse.busstops;
      if (busstops && busstops.length > 0) {
        // 查询所有路线颜色，提升性能
        let buslineids: string = ''
        for (const busstopResponse of busstops) {
          for (const buslineResp of busstopResponse.buslines) {
            buslineids += buslineResp.id + '|'
          }
        }
        const lineModels: LineModel[] = await this.listSubwayTransferBuslineByIds(buslineids)
        const lineColorMap: HashMap<string, string> = new HashMap<string, string>()
        lineModels.forEach((lineModel: LineModel) => {
          lineColorMap.set(lineModel.id, lineModel.uicolor);
        })
        for (const busstopResponse of busstops) {
          const stopModel: StopModel = new StopModel()
          stopModel.id = busstopResponse.id
          stopModel.name = busstopResponse.name
          stopModel.location = busstopResponse.location
          stopModel.buslines = []
          for (let index = 0; index < busstopResponse.buslines.length; index++) {
            const buslineResp = busstopResponse.buslines[index]
            const busline: Busline = new Busline()
            busline.id = buslineResp.id;
            busline.name = StringUtils.trimInBracket(buslineResp.name)
            busline.color = lineColorMap.get(buslineResp.id)
            if (busline.name !== '') {
              stopModel.buslines.push(busline)
            }
          }
          stopModelMap.set(stopModel.id, stopModel)
        }


      }
    }
    return stopModelMap
  }

  /**
   * 公交站搜索
   * @param keywords 关键字
   * @param searchResults 搜索结果
   */
  public async searchBusstop(keywords: string, searchMaxNum: number = 5) {
    const busstopSearchReq: BusstopSearchReq = {
      keywords: keywords,
      city: CityToCitycodeMap.CITYNAME_ADCODE_RECORD[PersistenceV2.connect(City, () => new City())!.cityName!],
      offset: 50,
      page: 1
    };
    const searchResults: StopLineBase[] = [];
    const busStopSearchResponse: BusstopSearchResponse = await BusHttpApi.busStopSearch(busstopSearchReq);
    if (busStopSearchResponse.status === '1' && busStopSearchResponse.infocode === '10000') {
      const busstops = busStopSearchResponse.busstops;
      if (busstops && busstops.length > 0) {
        let searchNum = 0
        busstops.forEach((busstopResponse) => {
          // 去除站口信息、最大搜索5条有用信息
          if (busstopResponse.citycode !==
          CityToCitycodeMap.CITYNAME_ADCODE_RECORD[PersistenceV2.connect(City, () => new City())!.cityName!] ||
            !busstopResponse.buslines || busstopResponse.buslines.length === 0 || searchNum >= searchMaxNum) {
            return
          }
          searchNum++
          const name: string = busstopResponse.name;
          const stopModel = new StopModel();
          if (name.includes('(地铁站)')) {
            stopModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY;
          } else {
            stopModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_BUS;
          }
          stopModel.id = busstopResponse.id;
          stopModel.name = name;
          stopModel.location = busstopResponse.location;
          stopModel.buslines = [];
          // 站点线路
          for (const busstopLineResponse of busstopResponse.buslines) {
            if (busstopLineResponse.start_stop && busstopLineResponse.start_stop.length === 0 ||
              busstopLineResponse.end_stop && busstopLineResponse.end_stop.length === 0) {
              continue
            }
            const busline: Busline = new Busline()
            busline.id = busstopLineResponse.id;
            busline.name = StringUtils.trimInBracket(busstopLineResponse.name)
            busline.location = busstopLineResponse.location;
            busline.startStop = busstopLineResponse.start_stop;
            busline.endStop = busstopLineResponse.end_stop;
            stopModel.buslines?.push(busline);
          }
          searchResults.push(stopModel);
        });
      }
    }
    return searchResults
  }

  /**
   * 根据Id搜索同名站台以及站台线路
   * @param keywords 关键字
   * @param searchResults 搜索结果
   */
  public async searchSameNameBusstop(id: string): Promise<SameNameStopModel> {
    const stopIdSearchReq: StopIdSearchReq = {
      id: id,
    };
    const busstopSearchResponse: BusstopSearchResponse = await BusHttpApi.stopIdSearch(stopIdSearchReq);
    const sameNameStopModel: SameNameStopModel = new SameNameStopModel()
    if (busstopSearchResponse.status === '1' && busstopSearchResponse.infocode === '10000') {
      const busstops = busstopSearchResponse.busstops;
      if (busstops && busstops.length > 0) {
        const busstopResponse: BusstopResponse = busstops[0]
        sameNameStopModel.id = busstopResponse.id
        sameNameStopModel.name = StringUtils.trimInBracket(busstopResponse.name)
        sameNameStopModel.location = busstopResponse.location
        busstopResponse.buslines.forEach(busline => {
          let sameNameStop: SameNameStop = new SameNameStop()
          sameNameStopModel.sameNameStopList.forEach((stop: SameNameStop) => {
            if (stop.location === busline.location) {
              sameNameStop = stop
              return
            }
          })
          // 已经存在同名站台，增加线路
          if (sameNameStop.location) {
            const sameNameStopLine: SameNameStopLine = new SameNameStopLine()
            sameNameStopLine.id = busline.id
            sameNameStopLine.start_stop = busline.start_stop
            sameNameStopLine.end_stop = busline.end_stop
            sameNameStopLine.name = StringUtils.trimInBracket(busline.name)
            sameNameStop.sameNameStopLineList.push(sameNameStopLine)
          } else {
            sameNameStop.location = busline.location
            const sameNameStopLine: SameNameStopLine = new SameNameStopLine()
            sameNameStopLine.id = busline.id
            sameNameStopLine.start_stop = busline.start_stop
            sameNameStopLine.end_stop = busline.end_stop
            sameNameStopLine.name = StringUtils.trimInBracket(busline.name)
            sameNameStop.sameNameStopLineList.push(sameNameStopLine)
            sameNameStopModel.sameNameStopList.push(sameNameStop)
          }
        })
      }
    }
    return sameNameStopModel
  }

  /**
   * 公交站点附近搜索
   * @param id 中心点金纬度
   * @param searchResults 搜索结果
   */
  public async aroundSearch(location: string): Promise<StopLineBase[]> {
    const busSubwayAroundReq: BusSubwayAroundReq = {
      types: '150700|150500',
      location: location,
      radius: 1000,
      page_size: 50,
      page_num: 0
    };
    let busSubwayAroundResponse: BusSubwayAroundResponse
    const aroundStopList: StopLineBase[] = []
    do {
      busSubwayAroundReq.page_num++
      busSubwayAroundResponse = await BusHttpApi.busSubwayAroundSearch(busSubwayAroundReq)
      if (busSubwayAroundResponse.status === '1' && busSubwayAroundResponse.infocode === '10000') {
        if (busSubwayAroundResponse.count > 0) {
          busSubwayAroundResponse.pois.forEach(poi => {
            // 公交站点
            if (poi.typecode === '150700') {
              const stopModel: StopModel = new StopModel()
              stopModel.id = poi.id
              stopModel.name = poi.name
              stopModel.location = poi.location
              stopModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_BUS
              aroundStopList.push(stopModel)
            } else if (poi.typecode === '150500') {
              const stopModel: StopModel = new StopModel()
              stopModel.id = poi.id
              stopModel.name = poi.name
              stopModel.location = poi.location
              stopModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY
              aroundStopList.push(stopModel)
            }
          })
        }
      }
    } while (busSubwayAroundResponse.status === '1' && busSubwayAroundResponse.infocode === '10000' &&
      busSubwayAroundResponse.count > 0)

    return aroundStopList
  }

  /**
   * 公交站点附近搜索
   * @param id 中心点金纬度
   * @param searchResults 搜索结果
   */
  public async aroundSearchByPage(location: string, pageNum: number): Promise<StopLineBase[]> {
    const busSubwayAroundReq: BusSubwayAroundReq = {
      types: '150700|150500',
      location: location,
      radius: 1000,
      page_size: 20,
      page_num: pageNum
    };
    let busSubwayAroundResponse: BusSubwayAroundResponse
    const aroundStopList: StopLineBase[] = []
    let count = 0
    busSubwayAroundResponse = await BusHttpApi.busSubwayAroundSearch(busSubwayAroundReq)
    if (busSubwayAroundResponse.status === '1' && busSubwayAroundResponse.infocode === '10000') {
      if (busSubwayAroundResponse.count > 0) {
        busSubwayAroundResponse.pois.forEach(poi => {
          if (count < 10) {
            // 公交站点
            if (poi.typecode === '150700') {
              count++
              const stopModel: StopModel = new StopModel()
              stopModel.id = poi.id
              stopModel.name = poi.name
              stopModel.location = poi.location
              stopModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_BUS
              aroundStopList.push(stopModel)
            } else if (poi.typecode === '150500') {
              count++
              const stopModel: StopModel = new StopModel()
              stopModel.id = poi.id
              stopModel.name = poi.name
              stopModel.location = poi.location
              stopModel.busSubwayType = BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY
              aroundStopList.push(stopModel)
            }
          } else {
            return
          }

        })
      }
    }

    return aroundStopList
  }

  /**
   * 路径规划
   * @param id 中心点金纬度
   * @param searchResults 搜索结果
   */
  public async transitSearch(origin: string, destination: string, city1: string, city2: string,
    strategy: number): Promise<TransitModel> {
    const transitSearchReq: TransitSearchReq = {
      origin: origin,
      destination: destination,
      city1: city1,
      city2: city2,
      strategy: strategy
    };
    let transitResponse: TransitResponse = await BusHttpApi.transitSearch(transitSearchReq)
    const transitModel: TransitModel = new TransitModel()
    if (transitResponse.status === '1' && transitResponse.infocode === '10000') {

      // 批量查询线路详情
      let buslineIds: string = ''
      transitResponse.route.transits.forEach(transitResponse => {
        transitResponse.segments.forEach(segmentResponse => {
          // bus
          if (segmentResponse.bus) {
            segmentResponse.bus.buslines.forEach(buslineResponse => {
              buslineIds += buslineResponse.id + '|'
            })
          }
        })
      })
      // 线路详情
      const lineModelMap: HashMap<string, LineModel> = await this.searchLineModelMapByIds(buslineIds)

      const transitRoute: TransitRoute = new TransitRoute()
      transitRoute.origin = transitResponse.route.origin
      transitRoute.destination = transitResponse.route.destination
      const transits: TransitRouteTransit[] = []
      transitResponse.route.transits.forEach(transitResponse => {
        const transit: TransitRouteTransit = new TransitRouteTransit()
        transit.distance = transitResponse.distance
        const transitRouteCost: TransitRouteCost = new TransitRouteCost()
        transitRouteCost.duration = transitResponse.cost?.duration!
        transitRouteCost.transitFee = transitResponse.cost?.transit_fee
        transit.cost = transitRouteCost
        const segments: TransitRouteTransitSegment[] = []
        transitResponse.segments.forEach(segmentResponse => {
          const segment: TransitRouteTransitSegment = new TransitRouteTransitSegment()
          // walking
          if (segmentResponse.walking) {
            const walking: TransitRouteTransitSegmentWork = new TransitRouteTransitSegmentWork()
            walking.origin = segmentResponse.walking.origin
            walking.destination = segmentResponse.walking.destination
            walking.distance = segmentResponse.walking.distance
            const transitRouteCost: TransitRouteCost = new TransitRouteCost()
            transitRouteCost.duration = segmentResponse.walking.cost.duration!
            walking.cost = transitRouteCost
            const steps: TransitRouteTransitSegmentWorkStep[] = []
            segmentResponse.walking.steps.forEach(stepResponse => {
              const step: TransitRouteTransitSegmentWorkStep = new TransitRouteTransitSegmentWorkStep()
              step.instruction = stepResponse.instruction
              step.distance = stepResponse.distance
              step.road = stepResponse.road
              const polyline: TransitRoutePolyline = new TransitRoutePolyline()
              polyline.polyline = stepResponse.polyline.polyline
              step.polyline = polyline
              steps.push(step)
            });
            walking.steps = steps
            segment.walking = walking
          }
          // bus
          if (segmentResponse.bus) {
            const bus: TransitRouteTransitSegmentBus = new TransitRouteTransitSegmentBus()
            const buslines: TransitRouteTransitSegmentBusBusline[] = []
            segmentResponse.bus.buslines.forEach(buslineResponse => {
              const busline: TransitRouteTransitSegmentBusBusline = new TransitRouteTransitSegmentBusBusline()
              const departureStop: TransitRouteTransitSegmentBusBuslineDepartureStop =
                new TransitRouteTransitSegmentBusBuslineDepartureStop()
              departureStop.name = buslineResponse.departure_stop.name
              departureStop.id = buslineResponse.departure_stop.id
              departureStop.location = buslineResponse.departure_stop.location
              departureStop.entrance = buslineResponse.departure_stop.entrance
              busline.departureStop = departureStop
              const arrivalStop: TransitRouteTransitSegmentBusBuslineArrivalStop =
                new TransitRouteTransitSegmentBusBuslineArrivalStop()
              arrivalStop.name = buslineResponse.arrival_stop.name
              arrivalStop.id = buslineResponse.arrival_stop.id
              arrivalStop.location = buslineResponse.arrival_stop.location
              arrivalStop.entrance = buslineResponse.arrival_stop.entrance
              busline.arrivalStop = arrivalStop
              busline.name = buslineResponse.name
              busline.id = buslineResponse.id
              busline.type = buslineResponse.type
              busline.distance = buslineResponse.distance
              const transitRouteCost: TransitRouteCost = new TransitRouteCost()
              transitRouteCost.duration = buslineResponse.cost.duration
              busline.cost = transitRouteCost
              const polyline: TransitRoutePolyline = new TransitRoutePolyline()
              polyline.polyline = buslineResponse.polyline.polyline
              busline.polyline = polyline
              // via_stops
              const viaStops: TransitRouteTransitSegmentBusBuslineViaStop[] = [];
              buslineResponse.via_stops.forEach(viaStopResponse => {
                const viaStop: TransitRouteTransitSegmentBusBuslineViaStop =
                  new TransitRouteTransitSegmentBusBuslineViaStop()
                viaStop.name = viaStopResponse.name
                viaStop.id = viaStopResponse.id
                viaStop.location = viaStopResponse.location
                viaStops.push(viaStop)
              })
              busline.viaStops = viaStops
              // 线路详情
              busline.endStop = lineModelMap.get(busline.id).endStop
              busline.uicolor = lineModelMap.get(busline.id).uicolor
              busline.basicPrice = lineModelMap.get(busline.id).basicPrice
              busline.totalPrice = lineModelMap.get(busline.id).totalPrice
              buslines.push(busline)
            });
            bus.buslines = buslines
            segment.bus = bus
          }
          // taxi
          if (segmentResponse.taxi) {
            const taxi: TransitRouteTransitSegmentTaxi = new TransitRouteTransitSegmentTaxi()
            taxi.distance = segmentResponse.taxi.distance
            taxi.startpoint = segmentResponse.taxi.startpoint
            taxi.endpoint = segmentResponse.taxi.endpoint
            const polyline: TransitRoutePolyline = new TransitRoutePolyline()
            polyline.polyline = segmentResponse.taxi.polyline.polyline
            taxi.polyline = polyline
            segment.taxi = taxi
          }
          segments.push(segment)
        })
        transit.segments = segments
        transits.push(transit)
      });
      transitRoute.transits = transits
      transitModel.route = transitRoute
    }
    if (transitModel.route?.transits?.length === 0 && (strategy === 5 || strategy === 7)) {
      const workSearchReq: WorkSearchReq = {
        origin: origin,
        destination: destination,
      };
      let workingResponse: WalkingResponse = await BusHttpApi.workingSearch(workSearchReq)
      if (workingResponse.status === '1' && workingResponse.infocode === '10000') {
        const transitRoute: TransitRoute = new TransitRoute()
        transitRoute.origin = workingResponse.route.origin
        transitRoute.destination = workingResponse.route.destination
        const transits: TransitRouteTransit[] = []
        workingResponse.route.paths.forEach(pathResponse => {
          const transit: TransitRouteTransit = new TransitRouteTransit()
          transit.distance = pathResponse.distance
          const cost: TransitRouteCost = new TransitRouteCost()
          cost.duration = pathResponse.cost?.duration
          transit.cost = cost
          const segments: TransitRouteTransitSegment[] = []
          const segment: TransitRouteTransitSegment = new TransitRouteTransitSegment()
          const walking = new TransitRouteTransitSegmentWork()
          const steps: TransitRouteTransitSegmentWorkStep[] = []
          pathResponse.steps.forEach(stepResponse => {
            walking.origin = workingResponse.route.origin
            walking.destination = workingResponse.route.destination
            walking.distance = Number(pathResponse.distance)
            walking.cost = cost
            const step = new TransitRouteTransitSegmentWorkStep()
            step.instruction = stepResponse.instruction
            step.distance = stepResponse.step_distance
            step.road = stepResponse.road_name
            const transitRoutePolyline: TransitRoutePolyline = new TransitRoutePolyline()
            transitRoutePolyline.polyline = stepResponse.polyline
            step.polyline = transitRoutePolyline
            steps.push(step)
          })
          walking.steps = steps
          segment.walking = walking
          segments.push(segment)
          transit.segments = segments
          transits.push(transit)
        });
        transitRoute.transits = transits
        transitModel.route = transitRoute
      }
    }
    return transitModel

  }

  /**
   * 步行路径规划
   * @param id 中心点金纬度
   * @param searchResults 搜索结果
   */
  public async workSearch(origin: string, destination: string): Promise<TransitModel> {
    const workSearchReq: WorkSearchReq = {
      origin: origin,
      destination: destination,
    };
    let workingResponse: WalkingResponse = await BusHttpApi.workingSearch(workSearchReq)
    const transitModel: TransitModel = new TransitModel()
    if (workingResponse.status === '1' && workingResponse.infocode === '10000') {

    }

    return transitModel

  }

  /**
   * 公交站点附近搜索
   * @param id 中心点金纬度
   * @param searchResults 搜索结果
   */
  public async distanceSearch(origins: string, destination: string): Promise<number> {
    const distanceSearchReq: DistanceSearchReq = {
      origins: origins,
      destination: destination
    };
    let distanceResponse: DistanceResponse
    distanceResponse = await BusHttpApi.distanceSearch(distanceSearchReq)
    if (distanceResponse.status === '1' && distanceResponse.infocode === '10000') {
      if (distanceResponse.results && distanceResponse.results.length > 0) {
        return distanceResponse.results[0].distance
      }
    }

    return 0
  }
}

const instance = new SearchService();

export { instance as SearchServiceApi };