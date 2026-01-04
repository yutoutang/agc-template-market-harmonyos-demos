@ObservedV2
export class MediaItemModel {
  @Trace videoId: string = ''
  @Trace type: string = ''
  @Trace title: string = ''
  @Trace coverUrl: string = ''
  @Trace videoUrl: ResourceStr[] = []
  @Trace createTime: string = ''
  @Trace isLike: boolean = false
  @Trace likeCount: number = 0
  @Trace isMark: boolean = false
  @Trace commentCount: number = 0

  constructor(mediaItem?: MediaItem) {
    if (mediaItem) {
      this.videoId = mediaItem.videoId
      this.type = mediaItem.type
      this.title = mediaItem.title
      this.coverUrl = mediaItem.coverUrl
      this.videoUrl = mediaItem.videoUrl
      this.createTime = mediaItem.createTime
      this.isLike = mediaItem.isLike
      this.likeCount = mediaItem.likeCount
      this.isMark = mediaItem.isMark
      this.commentCount = mediaItem.commentCount
    }
  }
}

interface MediaItem {
  videoId: string
  type: string
  title: string
  coverUrl: string
  videoUrl: ResourceStr[]
  createTime: string
  isLike: boolean
  likeCount: number
  isMark: boolean
  commentCount: number
}

