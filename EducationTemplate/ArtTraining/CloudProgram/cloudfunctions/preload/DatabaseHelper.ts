import { cloud, CloudDBCollection, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { CloudCourseInfo } from './models/CloudCourseInfo';
import { CourseInfoResp, StoreConfig } from './types/ResponseTypes';
import { ListResp } from './models/ListResp';
import { BANNERS, STORE_INFO } from './constants';

const ZONE_NAME = 'ArtTraining';
const TAG = '[preload]';

export class DatabaseHelper {
  logger;
  courseList: CloudDBCollection<CloudCourseInfo>;

  constructor(logger) {
    this.logger = logger;
    this.courseList = cloud.database({ zoneName: ZONE_NAME }).collection(CloudCourseInfo);
  }

  public async getStoreConfig(): Promise<StoreConfig | undefined> {
    const LOGGER_TAG = TAG + '[get-store-config]';
    try {
      const initList = await this.courseList.query();
      const listResp = await this._createCourseInfoRespList(initList);
      const result: StoreConfig = {
        banners: BANNERS,
        storeInfo: STORE_INFO,
        courseList: listResp.courseList ?? [],
      };
      return result;
    } catch (err) {
      this.logger.error(LOGGER_TAG + `error: ${err}`);
      return;
    }
  }

  private async _createCourseInfoRespList(query: CloudDBZoneQuery<CloudCourseInfo>): Promise<ListResp<CourseInfoResp>> {
    const LOGGER_TAG = TAG + 'create activity resp list';
    const listResp: ListResp<CourseInfoResp> = new ListResp<CourseInfoResp>(0, 0, []);
    try {
      const userData = await query.get();
      const totalCount: number = await query.countQuery('courseId');
      if (!userData.length) {
        return listResp;
      }
      userData.forEach((item: CloudCourseInfo) => {
        const activityResp: CourseInfoResp = this._createCourseInfoRespItem(item);
        listResp.courseList.push(activityResp);
      });
      listResp.totalCount = totalCount;
      listResp.returnCount = totalCount;
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
      throw new Error(err);
    }
  }

  private _createCourseInfoRespItem(item: CloudCourseInfo): CourseInfoResp {
    const res: CourseInfoResp = {
      courseId: item.getCourseId(),
      type: item.getType(),
      name: item.getName(),
      summary: item.getSummary(),
      detail: item.getDetail(),
      mainDiagram: item.getMainDiagram(),
      price: item.getPrice(),
      expireType: item.getExpireType(),
      startTime: item.getStartTime(),
      endTime: item.getEndTime(),
      orderTime: item.getOrderTime(),
      classHour: item.getClassHour(),
      status: item.getStatus(),
      currentHour: item.getCurrentHour(),
      timetable: JSON.parse(item.getTimetable() ?? '{}'),
    };
    return res;
  }
}
