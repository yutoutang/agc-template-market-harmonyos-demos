import { AppStorageV2 } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { LineCommonConstants } from '../common/LineCommonConstants'
import { LineWindowModel } from '../models/LineWindowModel'
import { SubwayCityAdcode } from '../common/SubwayCityAdcode'
import { SubwayViewModel } from '../viewmodels/SubwayViewModel'
import { SubwayStopInfo, SubwayStopline } from '../models/SubwayStopModel'
import { SubwayStopLineCard } from '../components/SubwayStopLineCard'

@ComponentV2
export struct SubwayView {
  @Param @Require cityName: string
  @Param @Require lnglat: string
  @Local subwayVM: SubwayViewModel = new SubwayViewModel()
  @Event searchSubwayStopline: (id: string[]) => Promise<SubwayStopline[]>
  @Event searchSubwayStopDistance: (lnglat: string) => Promise<number>
  @Event routeStopline: (subwayStopInfo: SubwayStopInfo, id: string) => void
  @Event onStationClick?: (stationInfo: SubwayStopInfo) => void
  private windowModel: LineWindowModel = AppStorageV2.connect(LineWindowModel, () => new LineWindowModel())!;
  private webController: webview.WebviewController = new webview.WebviewController();

  async aboutToAppear(): Promise<void> {
    webview.WebviewController.setWebDebuggingAccess(true)
    this.subwayVM.searchSubwayStopline = this.searchSubwayStopline
    this.subwayVM.searchSubwayStopDistance = this.searchSubwayStopDistance
  }

  @Builder
  stopSheetBuilder() {
    Column() {
      Row() {
        Row() {
          Text(this.subwayVM.subwayStopInfo.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .lineHeight(19)
          Image($r('app.media.walk'))
            .width(16)
            .height(16)
            .margin({ left: 12 })
          Text(this.subwayVM.subwayStopInfo.distance)
        }

        Image($r('app.media.stop_route'))
          .width(12)
          .height(24)
      }
      .margin({ top: 25 })
      .width(LineCommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        if (this.onStationClick) {
          this.onStationClick(this.subwayVM.subwayStopInfo);
          this.subwayVM.isShowStopSheet = false
        }
      })

      ForEach(this.subwayVM.subwayStoplines, (subwayStopline: SubwayStopline) => {
        SubwayStopLineCard({
          subwayStopline: subwayStopline,
          subwayStopInfo: this.subwayVM.subwayStopInfo,
          webController: this.webController,
          routeStopline: this.routeStopline,
          closeStopSheet: () => {
            this.subwayVM.isShowStopSheet = false
          }
        }).margin({ top: 16 })
      }, (v: SubwayStopline) => v.name)

    }
    .padding({ left: 16, right: 16, bottom: this.windowModel.windowBottomPadding })

  }

  build() {
    Column() {
      Web({
        src: $rawfile('index.html?adcode=' + SubwayCityAdcode.CITYNAME_ADCODE_RECORD[this.cityName] + '&lnglat=' +
        this.lnglat),
        controller: this.webController
      })
        .javaScriptProxy({
          object: this.subwayVM,
          name: 'subwayView',
          methodList: ['showStopSheet'],
          controller: this.webController,
        })
        .bindSheet(this.subwayVM.isShowStopSheet!!, this.stopSheetBuilder(), {
          height: SheetSize.FIT_CONTENT,
          dragBar: true,
          showClose: false,
          preferType: SheetType.CENTER
        })
        .geolocationAccess(false)
        .fileAccess(false)

    }
    .width(LineCommonConstants.FULL_PERCENT)
    .height(LineCommonConstants.FULL_PERCENT)
    .padding({
      top: this.windowModel.windowTopPadding,
      bottom: this.windowModel.windowBottomPadding
    })
    .backgroundColor($r('app.color.index_background'))
  }
}