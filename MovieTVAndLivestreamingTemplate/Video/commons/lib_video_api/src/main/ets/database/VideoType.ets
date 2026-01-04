/**
 * 视频Model
 */
export interface BaseVideo {
  // 视频id
  videoId: string
  // 内容类型
  contentType: ContentType
  // 视频分类:
  videoType: '科幻' | '战争' | '年代' | '爱情' | '喜剧'
  // 分类：
  category: '热播' | '热搜' | '必看榜' | '亲子互动' | '小朋友爱看'
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
  // 内容状态：未上映 / 未首播，已上映 / 已首播，下架
  status: '未上映' | '已上映' | '下架'
  // 数据创建时间（默认当前时间）
  createTime: string
  //数据更新时间（每次修改自动更新）
  updateTime: string
  // 评论总数
  commentCount: number
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
  // 播放量
  playCount: number
  // tab栏分类
  tabType: TabType
  // 当前集数
  currentEpisode: number
  // 当前进度（0-100）
  currentProgress: number
}


export enum TabType {
  /**
   * 精选推荐
   */
  Recommend = 'recommend',
  /**
   * 电影
   */
  Movie = 'movie',
  /**
   * 电视剧
   */
  TvMovie = 'tv_movie',
  /**
   * 少儿
   */
  Children = 'children',
  // 全部
  ALL = ''
}

export enum ContentType {
  /**
   * 电影
   */
  Movie = 'movie',
  /**
   * 电视剧
   */
  TvMovie = 'tv_movie'
}

export enum RoleType {
  /**
   * 导演
   */
  Director = 'director',

  /**
   * 主演
   */
  Starring = 'starring',

  /**
   * 演员
   */
  Actor = 'actor',

}

/**
 * 演员数据库字段
 */
export interface BaseActor {
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

