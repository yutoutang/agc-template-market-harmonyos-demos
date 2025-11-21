// PreferencesManager.ets（数据存储）
import preferences from '@ohos.data.preferences';
import { DateUtils } from '../util/DateUtil';
import { CheckInDetailRecord, CheckInHistoryDataItem, CheckInHistoryDetailDataItem } from '../types/Types';


export class DataManager {
  private static CHECK_IN_KEY: string = 'checkin';
  private static IS_QUICK_CHECK_IN_KEY: string = 'isQuickCheckIn';
  private static DEFAULT_TIME: string = '--:--:--';
  private static DEFAULT_LOCATION: string = '--------';
  private static DEFAULT_LATITUDE: number = 0;
  private static DEFAULT_LONGITUDE: number = 0;
  private static CHECK_IN_HISTORY_QUEUE: CheckInHistoryDataItem[] = [];

  static init() {
  }

  static queryCheckInHistories(): CheckInHistoryDataItem[] {
    return DataManager.getCheckInDetails().slice().reverse();
  }

  static getTodayCheckInDetail(): CheckInHistoryDetailDataItem[] {
    let checkInDetails: CheckInHistoryDataItem[] = DataManager.getCheckInDetails();
    const latestCheckInRecord = checkInDetails[checkInDetails.length - 1];
    if (latestCheckInRecord !== undefined && DateUtils.isToday(latestCheckInRecord.day)) {
      return latestCheckInRecord.details;
    }

    return [{
      time: DataManager.DEFAULT_TIME,
      location: DataManager.DEFAULT_LOCATION,
      latitude: DataManager.DEFAULT_LATITUDE,
      longitude: DataManager.DEFAULT_LONGITUDE
    },
      {
        time: DataManager.DEFAULT_TIME,
        location: DataManager.DEFAULT_LOCATION,
        latitude: DataManager.DEFAULT_LATITUDE,
        longitude: DataManager.DEFAULT_LONGITUDE
      }];
  }

  static addCheckInDetail(value: CheckInDetailRecord) {
    let checkInDetails: CheckInHistoryDataItem[] = DataManager.getCheckInDetails();
    const latestCheckInRecord = checkInDetails[checkInDetails.length - 1];;
    const detailItem: CheckInHistoryDetailDataItem = {
      time: value.time,
      location: value.location,
      latitude: value.latitude,
      longitude: value.longitude
    };
    if (latestCheckInRecord !== undefined && latestCheckInRecord.day === value.day) {
      if (latestCheckInRecord.details[1].time === DataManager.DEFAULT_TIME) {
        latestCheckInRecord.details[1] = detailItem
      } else {
        latestCheckInRecord.details.push(detailItem)
      }
    } else {
      const dataItem: CheckInHistoryDataItem = {
        day: value.day,
        dayOfWeek: value.dayOfWeek,
        details: [detailItem, {
          time: DataManager.DEFAULT_TIME,
          location: DataManager.DEFAULT_LOCATION,
          latitude: DataManager.DEFAULT_LATITUDE,
          longitude: DataManager.DEFAULT_LONGITUDE
        }]
      }
      checkInDetails.shift();
      checkInDetails.push(dataItem)
    }
    DataManager.getPreferences().putSync(DataManager.CHECK_IN_KEY, JSON.stringify(checkInDetails));
    DataManager.getPreferences().flush();
  }

  static saveIsQuickCheckIn(value: boolean) {
    DataManager.getPreferences().putSync(DataManager.IS_QUICK_CHECK_IN_KEY, value);
    DataManager.getPreferences().flush();
  }

  static isQuickCheckIn() {
    let isQuickCheckIn = DataManager.getPreferences().getSync(DataManager.IS_QUICK_CHECK_IN_KEY, '');
    if (isQuickCheckIn === '') {
      return false;
    }

    return isQuickCheckIn as boolean;
  }

  private static getCheckInDetails(): CheckInHistoryDataItem[] {
    let checkInDetails = DataManager.getPreferences().getSync(DataManager.CHECK_IN_KEY, '');
    if (checkInDetails === '') {
      return DataManager.CHECK_IN_HISTORY_QUEUE;
    }

    return JSON.parse(checkInDetails as string);
  }

  static getPreferences() {
    return preferences.getPreferencesSync(getContext(), { 'name': 'checkin-detail' })
  }
}