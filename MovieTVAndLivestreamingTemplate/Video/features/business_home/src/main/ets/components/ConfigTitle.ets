import { CommonConstants, RouterMap, RouterUtils } from 'lib_common'
import { MorePageParams } from '../model/TabInfoModel'

@ComponentV2
export struct ConfigTitle {
  @Param @Require text: string
  @Param currentIndex: number = 0

  build() {
    Row() {
      Text(this.text)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .lineHeight(25)
        .fontColor('#E6000000')
      Row({ space: 5 }) {
        Text('更多').fontSize(14).lineHeight(16).fontColor('#99000000')
        Image($r('app.media.ic_right')).width($r('app.float.arrow_right_w'))
      }
      .onClick(() => {
        const params: MorePageParams = {
          title: this.text,
          currentIndex: this.currentIndex
        }
        RouterUtils.pushPathByName(RouterMap.MORE_PAGE, params);
      })
    }.width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 22, bottom: 10 })
  }
}