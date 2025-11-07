export interface StoreInfo {
  shopName: string;
  latitude: number;
  longitude: number;
  address: string;
  phoneNumber: string;
  email: string;
  logoUrl: string;
  bannerImg: string;
  desc: string;
  businessTime: string;
}

export interface CourseInfoResp {
  courseId: number;
  type: number;
  name: string;
  summary: string;
  detail: string;
  mainDiagram: string;
  price: number;
  expireType: number;
  startTime: string;
  endTime: string;
  orderTime: string;
  classHour: number;
  status: number;
  currentHour: number;
  timetable: CourseTimetable;
}

export interface CourseTimetable {
  weekdays: number[];
  startTime: string;
  endTime: string;
}

export interface StoreConfig {
  banners?: string[];
  storeInfo?: StoreInfo;
  courseList?: CourseInfoResp[];
}