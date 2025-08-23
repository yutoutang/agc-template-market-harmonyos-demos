import { http } from '../utils/api';
import { MyConfig } from '../constants/MyConfig'
import { VideoItem } from '../viewModel/VideoModel';
import { ApiResponse } from '../utils/api'
import { ArticleInterface } from '../viewModel/ArticleModel';

// 定义接口
export interface IArticle {
  title: string;
  summary: string;
  order: number;
  coverImageRealPath: string
}

// 精彩视频
export function getVideoList(): Promise<ApiResponse<VideoItem[]>> {
  return http.get<VideoItem[]>(`/videoList.json`)
}

// 门票权益文章
export function getTicketRoleArticleList(): Promise<ApiResponse<IArticle[]>> {
  return http.get<IArticle[]>(`/roleArticleList.json`)
}

// 合作伙伴
export function getPartnerList() {
  return http.get<ArticleInterface[]>(`/partnerList.json`)
}

// 合作伙伴
export function getAdList() {
  return http.get<ArticleInterface[]>(`/advertiseList.json`)
}

// 常见问题
export function getQaArticleList() {
  return http.get<IArticle[]>(`/qaArticle.json`)
}