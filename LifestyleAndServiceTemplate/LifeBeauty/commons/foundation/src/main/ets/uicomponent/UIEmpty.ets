import { CommonConstants } from '../constants/CommonConstants'

@ComponentV2
export struct UIEmpty {
  @Param emptyDesc: ResourceStr = '暂无内容';
  @Param emptyIcon: ResourceStr = $r('app.media.ic_empty');
  @Param imgSize: SizeOptions = { width: 56, height: 47 }
  @Param fg: number = 14;

  build() {
    Column({ space: 10 }) {
      Image(this.emptyIcon).size(this.imgSize)
      Text(this.emptyDesc).fontColor($r('app.color.common_grey')).fontSize(this.fg)
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}