import { ContentType, RoleType, TabType } from '../../database/VideoType'
import { CommentResponse } from './CommentResponse'

export interface VideoResponse {
  // 视频id
  videoId: string
  // 内容类型
  contentType: ContentType
  // 视频分类: “科幻”“动作”“剧情”“犯罪”“喜剧”“动画”
  videoType: string
  // 标题
  title: string
  // 副标题
  subTitle: string
  // 剧情简介
  synopsis: string
  // 发行国家“中国大陆”“美国”“日韩”
  country: string
  // 语言“汉语普通话”“英语”“日语”
  language: string
  // 上映 / 首播日期（电影 = 上映日，电视剧 = 首播日）
  releaseDate: string
  // 评分（如豆瓣 / IMDB 评分，范围 0-10，保留 1 位小数）
  rating: number
  // 评分来源（如 “豆瓣”“IMDB”“猫眼”）
  ratingSource: '豆瓣' | '猫眼'
  // 封面
  coverUrl: string
  // 视频源
  videoUrl: ResourceStr[]
  // 每集时长
  urlDuration?: number[]
  // 内容状态：1 = 未上映 / 未首播，2 = 已上映 / 已首播，3 = 下架
  status: '未上映' | '已上映' | '下架'
  // 数据创建时间（默认当前时间）
  createTime: string
  // 数据更新时间（每次修改自动更新）
  updateTime: string
  // 收藏数量
  markCount: number
  // 点赞数量
  likeCount: number
  // 分享数量
  shareCount: number
  // 是否被点赞
  isLiked: boolean
  // 是否被收藏
  isMarked: boolean
  // tab栏分类
  tabType: TabType
  // 评论
  commentList: CommentResponse[]
  // 评论总数
  commentCount: number
  // 播放量
  playCount: number
  // 当前集数
  currentEpisode: number
  // 当前进度（0-100）
  currentProgress: number,

}

/**
 * 演员数据库字段
 */
export interface ActorResponse {
  // 演员id
  id: number
  // 视频id
  videoId: number
  // 头像
  avatar: string
  // 演员姓名
  actorName: number
  // 角色类型
  roleType: RoleType
}

