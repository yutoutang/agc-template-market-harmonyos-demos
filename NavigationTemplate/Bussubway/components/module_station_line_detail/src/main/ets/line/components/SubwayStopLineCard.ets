import { webview } from '@kit.ArkWeb'
import { SubwayStopInfo, SubwayStopline, SubwayStoplineDetail } from '../models/SubwayStopModel'

// 站点地铁卡片
@ComponentV2
export struct SubwayStopLineCard {
  @Param @Require subwayStopline: SubwayStopline
  @Param @Require subwayStopInfo: SubwayStopInfo
  @Event routeStopline: (subwayStopInfo: SubwayStopInfo, id: string) => void
  @Event closeStopSheet: Function
  @Param @Require webController: webview.WebviewController

  build() {
    Column() {

      Row() {
        Text(this.subwayStopline.name)
          .fontColor(Color.Black)
          .backgroundColor(this.subwayStopline.uicolor)
          .padding({
            left: 4,
            right: 4,
          })
          .fontSize(16)
          .lineHeight(19)
          .borderRadius(4)
          .height(22)
      }.width('100%').margin({ bottom: 15 })

      ForEach(this.subwayStopline.lineDetails, (lineDetail: SubwayStoplineDetail, index) => {
        Row() {
          Row() {
            Text('开往').margin({ right: 8 }).fontColor('#b2b2b2')
            Text(lineDetail.startStop).fontColor('#b2b2b2')
          }

          Text(lineDetail.startTime && lineDetail.endTime ?
            `首 ${lineDetail.startTime} ${'|'} 末 ${lineDetail.endTime}` : '')
            .fontColor('#b2b2b2')
        }
        .width('100%')
        .margin({ bottom: 10 })
        .justifyContent(FlexAlign.SpaceBetween)
        .border(index !== this.subwayStopline.lineDetails.length - 1 ? { width: { bottom: 1 }, color: '#f2f2f2' } : {})
        .padding({ bottom: 10 })
        .onClick(() => {
          this.routeStopline(this.subwayStopInfo, lineDetail.id!)
          this.closeStopSheet()
          // 调用前端页面有参函数。
          this.webController.runJavaScript('clearCurrentMarker()');
        })
      }, (v: SubwayStoplineDetail) => v.id)

    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .padding({
      top: 12,
      left: 12,
      right: 12
    })
  }
}