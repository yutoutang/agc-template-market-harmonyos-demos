import { MonthItemModel } from '../model/SportModel';

export class TrajectoryConstants {
  static readonly FULL_PERCENT: string = '100%';
  static readonly SPACE_12: number = 12;
  static readonly PADDING_PAGE: number = 16;
  static readonly PADDING_XS: number = 4;
  static readonly PADDING_XL: number = 16;
  static readonly RADIUS_16: number = 16;
  static readonly PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;
}

export enum RouterMap {
  MY_ROUTE_PAGE = 'MyRoutePage',
  OTHERS_ROUTE_PAGE = 'OthersRoutePage',
  TRACK_MAP_PAGE = 'TrackMapPage',
  Route_Map_PAGE = 'MyRouteMap'
}

export interface ISettingItem {
  label: string;
  routerName: RouterMap;
}

export const WAY_SORT_LIST: ISettingItem[] = [
  {
    label: '我的路线',
    routerName: RouterMap.MY_ROUTE_PAGE,
  },
  {
    label: '路线集合',
    routerName: RouterMap.OTHERS_ROUTE_PAGE,
  }
];

export const SELECT_DISTANCE_DEFAULT = '距离最近'

export const SELECT_DISTANCE_L_1 = '<1 KM'

export const SELECT_DISTANCE_L_5 = '<5 KM'

export const SELECT_DISTANCE_L_10 = '<10 KM'

export const SELECT_DISTANCE_GE_10 = '>=10 KM'

export const SELECT_DISTANCE_OPTIONS: SelectOption[] = [
  {
    value: SELECT_DISTANCE_DEFAULT,
  },
  {
    value: SELECT_DISTANCE_L_1,
  },
  {
    value: SELECT_DISTANCE_L_5,
  },
  {
    value: SELECT_DISTANCE_L_10,
  },
  {
    value: SELECT_DISTANCE_GE_10,
  }
]

export const SELECT_LENGTH_DEFAULT = '所有长度'

export const SELECT_LENGTH_L_3 = '<3 KM'

export const SELECT_LENGTH_L_5 = '3-5 KM'

export const SELECT_LENGTH_GE5_LE10 = '5-10 KM'

export const SELECT_LENGTH_G_10 = '>10 KM'

export const SELECT_LENGTH_OPTIONS: SelectOption[] = [
  {
    value: SELECT_LENGTH_DEFAULT,
  },
  {
    value: SELECT_LENGTH_L_3,
  },
  {
    value: SELECT_LENGTH_L_5,
  },
  {
    value: SELECT_LENGTH_GE5_LE10,
  },
  {
    value: SELECT_LENGTH_G_10,
  }
]

export const saveRouteData: MonthItemModel[] = []