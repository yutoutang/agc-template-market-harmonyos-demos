import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants, RouterMap, RouterUtils, SettingModel } from 'lib_common'
import { VideoPipViewModel } from 'lib_av_details';
import { PiPWindowModel } from 'module_swipeplayer';
import { BaseImage } from 'lib_widget';
import { VideoNewsData } from '../models/VideoModel'


const TAG = '[LivestreamCard]';

@ComponentV2
export struct LivestreamCard {
  @Param @Require cardData: VideoNewsData
  @Param showLiveTag: boolean = false;
  @Param imgBorderRadius: number = 8;
  @Param titleFontSize: number = 14;
  @Local prefixText: string = ''
  settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  @Local videoPipViewModel: VideoPipViewModel = new VideoPipViewModel()

  aboutToAppear(): void {
    if (this.showLiveTag) {
      this.prefixText = '【正在直播】'
    }
  }

  async pushToDetailPage() {
    await this.videoPipViewModel.isRestPipController(this.cardData.id)
    let param: Record<string, boolean | VideoNewsData> = {
      'detailData': this.cardData,
      'isLivestream': this.showLiveTag,
    }
    RouterUtils.pushPathByName(RouterMap.LIVESTREAM_DETAIL_PAGE, param)
  }

  build() {
    Column({ space: CommonConstants.SPACE_S }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        BaseImage({
          url: this.cardData.coverUrl,
          imgRadius: this.imgBorderRadius,
          downloadWithoutWlan: this.settingInfo.network.downloadWithoutWlan,
        })
          .width(CommonConstants.FULL_PERCENT)
          .aspectRatio(16 / 9)

        if (this.showLiveTag) {
          Row({ space: 2 }) {
            Image($r('app.media.ic_live'))
              .width(12)
              .height(12)
            Text('直播中')
              .fontSize(10)
              .fontColor(Color.White)
              .lineHeight(13)
          }
          .padding({
            left: 8,
            top: 3,
            right: 8,
            bottom: 3,
          })
          .borderRadius({
            topLeft: 2,
            bottomLeft: 14,
            topRight: 14,
            bottomRight: 2,
          })
          .backgroundColor($r('sys.color.warning'))
          .offset({ top: 2, right: 2 })
        }
      }

      Row() {
        Text(this.prefixText + this.cardData.title)
          .fontSize(this.titleFontSize)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(500)
          .lineHeight(21)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .height(42)
      .alignItems(VerticalAlign.Top)
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.pushToDetailPage()
    })
  }
}