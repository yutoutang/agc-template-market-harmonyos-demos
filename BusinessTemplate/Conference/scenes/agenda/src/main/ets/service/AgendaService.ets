import { http, MyConfig, ApiResponse } from 'commons';
import { AgendaListItemModel } from '../viewModel/AgendaModel';
import { AgendaDetailModel, liveItem } from '../viewModel/AgendaDetailModel';


export interface ISeminarResponse<T> {
  result?: number;
  content: T;
  desc?: string;
}

export interface ReserveParams {
  token: string
}

export interface FavoriteParams {
  token: string,
  favoriteId: string,
}

export interface AddCalcParam {
  token: string,
  tenantId: string,
  seminarId: string,
  instanceId: string,
  subSeminarId: string
  hideToast?: boolean
}


export function getSubSeminarList(): Promise<ApiResponse<AgendaListItemModel[]>> {
  return http.get<AgendaListItemModel[]>(`/subSeminar/list.json`)
}

// 分会场详情
export function getSubSeminarDetail(subSeminarId: string): Promise<ApiResponse<AgendaDetailModel>> {
  return http.get<AgendaDetailModel>(`/${subSeminarId}/subSeminarDetail.json`)
}

// 获取我的议程收藏列表
export function getReserveList(params: ReserveParams): Promise<ApiResponse<string[]>> {
  return http.post<string[]>(`/my-favorites`, params, {
    baseURL: MyConfig.PROJECTURL
  })
}

// 收藏
export function addReserve(params: FavoriteParams): Promise<ApiResponse<ISeminarResponse<object>>> {
  return http.post<ISeminarResponse<object>>(`/favorite`, params, {
    baseURL: MyConfig.PROJECTURL
  })
}

// 取消收藏
export function deleteReserve(params: FavoriteParams): Promise<ApiResponse<ISeminarResponse<object>>> {
  return http.post<ISeminarResponse<object>>(`/cancel-favorite`, params, {
    baseURL: MyConfig.PROJECTURL
  })
}

// 添加日历
export function addCalendar(params: AddCalcParam): Promise<ApiResponse<ISeminarResponse<object>>> {
  return http.post<ISeminarResponse<object>>(`/front/cbg/agenda/calendar/save`, params, {
    baseURL: MyConfig.PROJECTURL
  })
}


export interface IArticle {
  title: string;
  order: number;
  isRecommend: number;
}

interface IArticleItem {
  items: IArticle[];
}

interface IArticleResponse<T> {
  result?: number;
  content: T;
  desc?: string;
}

// 获取热门搜索
export function getHotSearch(): Promise<ApiResponse<IArticle[]>> {
  return http.get<IArticle[]>(`/hot_search.json`)
}

interface LiveParams {
  seminarId: string
}

// 获取直播状态
export function getAgendaLiveStatus(): Promise<ApiResponse<liveItem[]>> {
  let params: LiveParams = {
    seminarId:''
  }
  return http.post<liveItem[]>(`/live/status`, params, {
    baseURL: MyConfig.PROJECTURL
  })
}
