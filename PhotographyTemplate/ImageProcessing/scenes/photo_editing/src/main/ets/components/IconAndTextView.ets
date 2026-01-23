import { ImageShowModel } from '../model/PageParams';

@ComponentV2
export struct IconAndTextView {
  @Param @Require barItem: ImageShowModel

  build() {
    Column({space:4}) {
      Image(this.barItem.imageSource)
        .width(48)
        .height(48)
        .borderRadius(8)
        .shadow({
          radius:this.getUIContext().vp2px(8),
          offsetY:this.getUIContext().vp2px(4),
          color:'rgba(0, 0, 0, 0.1)'
        })

      Text(this.barItem.text)
        .fontFamily('鸿蒙黑体')
        .fontWeight(FontWeight.Regular)
        .fontSize(14)
        .fontColor($r('sys.color.black'))
    }
  }
}