import { navi } from '@kit.MapKit';
import { TransitRouteTransit } from './TransitDetailModel';

@ObservedV2
export class SaveOneClass {
  // 一条单独的路径
  @Trace routers?: TransitRouteTransit;
  // 总共有多少站
  @Trace total?: number;
  // 到哪儿上车
  @Trace address?: string;
  // id
  @Trace id?: string;
  // 步行距离
  @Trace walkDistance?: number;
  // 起点
  @Trace startAddress?: string;
  @Trace startLa?: number;
  @Trace startLo?: number;
  // 终点
  @Trace endAddress?: string;
  @Trace endLa?: number;
  @Trace endLo?: number;
}