import { BannerPanel } from '../components/BannerPanel'
import { RecommendPanel } from '../components/RecommendPanel'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'

@ComponentV2
export struct NewDrama {
  @Param @Require bannerList: Array<DramaCoverVM>
  @Param @Require recommendList: Array<DramaCoverVM>
  @Param @Require gutter: number

  build() {
    Column() {
      Text('必追新剧')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(700)
        .fontColor('#e6000000')
        .textAlign(TextAlign.Start)
      BannerPanel({ bannerList: this.bannerList, inPage: 'new' })

      Text('今日上新')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(700)
        .fontColor('#e6000000')
        .textAlign(TextAlign.Start)
      RecommendPanel({ recommendList: this.recommendList, gutter: this.gutter, inPage: 'new' })
    }
  }
}