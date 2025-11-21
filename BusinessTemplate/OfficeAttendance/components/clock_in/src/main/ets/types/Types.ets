export interface CheckInHistoryDataItem {
  day: string;
  dayOfWeek: number;
  details: CheckInHistoryDetailDataItem[]
}

export interface CheckInHistoryDetailDataItem {
  time: string;
  location: string;
  latitude: number;
  longitude: number;
}

export interface CheckInDetailRecord {
  day: string;
  dayOfWeek: number;
  time: string;
  location: string;
  latitude: number ;
  longitude: number ;
}

export interface BaseResponse<T = ESObject> {
  code: number;

  msg?: string;

  data: T;
}