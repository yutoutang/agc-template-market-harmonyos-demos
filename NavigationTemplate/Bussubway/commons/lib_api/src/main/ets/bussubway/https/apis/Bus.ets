import { ConfigMap, RequestUrlMap } from '../../constants/Enums';
import {
  BuslineIdSearchReq,
  BuslineSearchReq,
  BusstopSearchReq,
  BusSubwayAroundReq,
  DistanceSearchReq,
  StopIdSearchReq,
  TransitSearchReq,
  WorkSearchReq
} from '../../params/request/BusstopReq';
import { BuslineSearchResponse } from '../../params/response/BuslineResponse';
import { BusstopSearchResponse } from '../../params/response/BusstopResponse';
import { BusSubwayAroundResponse } from '../../params/response/BusSubwayAroundResponse';
import { DistanceResponse } from '../../params/response/DistanceResponse';
import { TransitResponse } from '../../params/response/TransitResponse';
import { WalkingResponse } from '../../params/response/WalkingResponse';
import { httpRequest } from '../Request';

/**
 * 高德公交服务
 */
class BusHttpApi {
  /**
   *  公交站关键字查询
   */
  public async busStopSearch(req: BusstopSearchReq): Promise<BusstopSearchResponse> {
    req.key = ConfigMap.BUS_STOP_KEY
    return httpRequest.get(RequestUrlMap.BUS_STOP_NAME_URL, { params: req });
  }

  /**
   *  公交线路关键字查询
   */
  public async busLineSearch(req: BuslineSearchReq): Promise<BuslineSearchResponse> {
    req.key = ConfigMap.BUS_STOP_KEY
    const buslineSearchResponse: BuslineSearchResponse =
      await httpRequest.get(RequestUrlMap.BUS_LINE_NAME_URL, { params: req });
    if (buslineSearchResponse.status === '1' && buslineSearchResponse.infocode === '10000') {
      const buslines = buslineSearchResponse.buslines;
      if (buslines && buslines.length > 0) {
        buslines.forEach((buslineResponse) => {
          // 处理时间，高德时间默认格式0600
          if (!buslineResponse.start_time || buslineResponse.start_time.length === 0) {
            buslineResponse.start_time = '06:00'
          } else {
            const startTime: string = buslineResponse.start_time as string
            buslineResponse.start_time = startTime.substring(0, 2) + ':' + startTime.substring(2)
          }
          if (!buslineResponse.end_time || buslineResponse.end_time.length === 0) {
            buslineResponse.end_time = '19:00'
          } else {
            const endTime: string = buslineResponse.end_time as string
            buslineResponse.end_time = endTime.substring(0, 2) + ':' + endTime.substring(2)
          }
          // mock发车间隔
          buslineResponse.interval = '10'
        });
      }
    }
    return buslineSearchResponse;
  }

  /**
   *  公交线路id查询
   */
  public async busLineIdSearch(req: BuslineIdSearchReq): Promise<BuslineSearchResponse> {
    req.key = ConfigMap.BUS_STOP_KEY
    const buslineSearchResponse: BuslineSearchResponse =
      await httpRequest.get(RequestUrlMap.BUS_LINE_ID_URL, { params: req });
    if (buslineSearchResponse.status === '1' && buslineSearchResponse.infocode === '10000') {
      const buslines = buslineSearchResponse.buslines;
      if (buslines && buslines.length > 0) {
        buslines.forEach((buslineResponse) => {
          // 处理时间，高德时间默认格式0600
          if (!buslineResponse.start_time || buslineResponse.start_time.length === 0) {
            buslineResponse.start_time = '06:00'
          } else {
            const startTime: string = buslineResponse.start_time as string
            buslineResponse.start_time = startTime.substring(0, 2) + ':' + startTime.substring(2)
          }
          if (!buslineResponse.end_time || buslineResponse.end_time.length === 0) {
            buslineResponse.end_time = '19:00'
          } else {
            const endTime: string = buslineResponse.end_time as string
            buslineResponse.end_time = endTime.substring(0, 2) + ':' + endTime.substring(2)
          }
          // mock发车间隔
          buslineResponse.interval = '5'
        });
      }
    }
    return buslineSearchResponse;
  }

  /**
   * 公交地铁周边搜索
   * @param req
   * @returns
   */
  public async busSubwayAroundSearch(req: BusSubwayAroundReq): Promise<BusSubwayAroundResponse> {
    req.key = ConfigMap.BUS_STOP_KEY
    const aroundResponse: BusSubwayAroundResponse =
      await httpRequest.get(RequestUrlMap.BUS_SUBWAY_AROUND_URL, { params: req });
    return aroundResponse;
  }

  /**
   *  公交站 ID 查询
   */
  public async stopIdSearch(req: StopIdSearchReq): Promise<BusstopSearchResponse> {
    req.key = ConfigMap.BUS_STOP_KEY
    const busstopSearchResponse: BusstopSearchResponse =
      await httpRequest.get(RequestUrlMap.BUS_STOP_ID_URL, { params: req });
    return busstopSearchResponse;
  }

  /**
   * 公交路线规划
   * @param req
   * @returns
   */
  public async transitSearch(req: TransitSearchReq): Promise<TransitResponse> {
    req.key = ConfigMap.BUS_STOP_KEY
    req.show_fields = 'polyline,cost'
    const transitResponse: TransitResponse =
      await httpRequest.get(RequestUrlMap.BUS_SUBWAY_TRANSIT_URL, { params: req });
    return transitResponse;
  }

  /**
   * 公交路线规划
   * @param req
   * @returns
   */
  public async workingSearch(req: WorkSearchReq): Promise<WalkingResponse> {
    req.key = ConfigMap.BUS_STOP_KEY
    req.show_fields = 'polyline,cost'
    const walkingResponse: WalkingResponse =
      await httpRequest.get(RequestUrlMap.WALKING_URL, { params: req });
    return walkingResponse;
  }

  /**
   * 公交路线规划
   * @param req
   * @returns
   */
  public async distanceSearch(req: DistanceSearchReq): Promise<DistanceResponse> {
    req.key = ConfigMap.BUS_STOP_KEY
    req.type = 3
    const distanceResponse: DistanceResponse =
      await httpRequest.get(RequestUrlMap.BUS_SUBWAY_DISTANCE_URL, { params: req });

    return distanceResponse;
  }
}

const instance = new BusHttpApi();

export { instance as BusHttpApi };