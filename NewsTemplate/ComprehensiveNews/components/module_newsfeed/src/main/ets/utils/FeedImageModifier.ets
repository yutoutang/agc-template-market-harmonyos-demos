import { FeedCardInfoModel } from '../model/RecommendModel'
import { calculateDimensions } from './Index'

export class FeedImageModifier implements AttributeModifier<ImageAttribute | ColumnAttribute> {
  curFeedCardInfo: FeedCardInfoModel = new FeedCardInfoModel()
  imageWidth: number = 0
  imageHeight: number = 0

  constructor(curFeedCardInfo: FeedCardInfoModel) {
    this.curFeedCardInfo = curFeedCardInfo
  }

  applyNormalAttribute(instance: ImageAttribute | ColumnAttribute): void {
    if (this.curFeedCardInfo.postImgList?.length === 1) {
      this.calculateSize()
      instance.width(this.imageWidth)
      instance.height(this.imageHeight)
    } else {
      instance.aspectRatio(1)
    }
  }

  calculateSize() {
    this.imageWidth = calculateDimensions(this.curFeedCardInfo.postImgList?.[0].surfaceUrl ?
    this.curFeedCardInfo.postImgList?.[0].surfaceUrl :
    this.curFeedCardInfo.postImgList?.[0].picVideoUrl).width
    this.imageHeight = calculateDimensions(this.curFeedCardInfo.postImgList?.[0].surfaceUrl ?
    this.curFeedCardInfo.postImgList?.[0].surfaceUrl :
    this.curFeedCardInfo.postImgList?.[0].picVideoUrl).height
  }
}