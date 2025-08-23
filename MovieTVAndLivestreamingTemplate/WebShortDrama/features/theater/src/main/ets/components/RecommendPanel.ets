import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { LengthMetrics } from '@kit.ArkUI'
import { DramaRecommendInfo } from './DramaRecommendInfo'
import { WindowManager } from '@agctemplate/utils'
import { onDramaClick } from './BannerPanel'

@ComponentV2
export struct RecommendPanel {

  @Param @Require recommendList: Array<DramaCoverVM>
  @Param @Require gutter: number
  @Param inPage: string = ''

  build() {
    Row() {
        Row() {
          Flex({
            wrap: FlexWrap.Wrap,
            space: { cross: LengthMetrics.vp(16), main: LengthMetrics.vp(this.gutter) },
            justifyContent: FlexAlign.Start
          }) {
            ForEach(this.recommendList, (recommend: DramaCoverVM) => {
              DramaRecommendInfo({ drama: recommend, inPage: this.inPage, onItemClick: (options: DramaCoverVM) => {
                if (onDramaClick) {
                  onDramaClick(options, () => {
                    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                  })
                }
              }})
            }, (recommend: DramaCoverVM, index: number) => recommend.dramaId + index)
          }
        }
        .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}