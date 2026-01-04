import { ContentType, TabType } from '../database/VideoType'
import { CommentResponse } from '../params/response/CommentResponse'
import { VideoResponse } from '../params/response/VideoResponse'

@ObservedV2
export class VideoModel {
  @Trace videoId: string
  @Trace contentType: ContentType
  @Trace videoType: string
  @Trace title: string
  @Trace subTitle: string
  @Trace synopsis: string
  @Trace country: string
  @Trace language: string
  @Trace releaseDate: string
  @Trace rating: number
  @Trace ratingSource: '豆瓣' | '猫眼'
  @Trace coverUrl: string
  @Trace videoUrl: ResourceStr[]
  @Trace status: '未上映' | '已上映' | '下架'
  @Trace createTime: string
  @Trace updateTime: string
  @Trace commentCount: number
  @Trace markCount: number
  @Trace likeCount: number
  @Trace shareCount: number
  @Trace isLiked: boolean
  @Trace isMarked: boolean
  @Trace tabType: TabType
  @Trace playCount: number
  @Trace commentList: CommentResponse[]
  @Trace currentEpisode: number
  @Trace currentProgress: number

  constructor(v: VideoResponse) {
    this.videoId = v.videoId
    this.contentType = v.contentType
    this.videoType = v.videoType
    this.title = v.title
    this.subTitle = v.subTitle
    this.synopsis = v.synopsis
    this.country = v.country
    this.language = v.language
    this.releaseDate = v.releaseDate
    this.rating = v.rating
    this.ratingSource = v.ratingSource
    this.coverUrl = v.coverUrl
    this.videoUrl = v.videoUrl
    this.status = v.status
    this.createTime = v.createTime
    this.updateTime = v.updateTime
    this.commentCount = v.commentCount
    this.markCount = v.markCount
    this.likeCount = v.likeCount
    this.shareCount = v.shareCount
    this.isLiked = v.isLiked
    this.isMarked = v.isMarked
    this.tabType = v.tabType
    this.playCount = v.playCount
    this.commentList = v.commentList
    this.currentEpisode = v.currentEpisode
    this.currentProgress = v.currentProgress
  }
}