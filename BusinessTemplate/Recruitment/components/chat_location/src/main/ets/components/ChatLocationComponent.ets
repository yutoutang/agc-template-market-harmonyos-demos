import { mapCommon, map, navi } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { ChatBreakpoint } from 'chat_base';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ChatLocationComponent {
  @Param @Require latitude: number;
  @Param @Require longitude: number;
  @Param @Require address: string;
  @Param @Require addressDetail: string;
  @Param @Require onReturnClick?: () => void
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local distance: string | undefined;
  @Local mapOption?: mapCommon.MapOptions
  @Local mapController?: map.MapComponentController

  async aboutToAppear(): Promise<void> {
    this.mapOption = {
      position: {
        target: {
          latitude: this.latitude,
          longitude: this.longitude
        },
        zoom: 16
      },
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomControlsEnabled: false,
      compassControlsEnabled: false
    }

    let currentLocation: geoLocationManager.Location = {
      latitude: 31.8698571539735,
      longitude: 118.82523154589367,
      altitude: 0,
      accuracy: 0,
      speed: 0,
      timeStamp: 0,
      direction: 0,
      timeSinceBoot: 0
    }

  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {


        Column() {
          Text(this.address)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .lineHeight($r('app.float.vp_22'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.addressDetail)
            .fontSize($r('sys.float.Body_S'))
            .fontColor(Color.Black)
            .lineHeight($r('app.float.vp_18'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.distance)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('#7E7E7E')
            .lineHeight($r('app.float.vp_18'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .visibility(this.distance ? Visibility.Visible : Visibility.None)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .height(78 + this.chatBreakpoint.bottomValue)
        .padding({
          left: this.chatBreakpoint.pagePadding,
          right: this.chatBreakpoint.pagePadding,
          top: 20,
          bottom: 20 + this.chatBreakpoint.bottomValue
        })
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')

      Row().width('100%').height(94 + this.chatBreakpoint.topValue)
        .linearGradient({
          angle: 0,
          colors: [['#00000000', 0.0], ['#33000000', 1.0]]
        })

      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .margin({ left: this.chatBreakpoint.pagePadding, top: this.chatBreakpoint.topValue })
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.onReturnClick) {
          this.onReturnClick?.()
        }
      })
    }
    .width('100%')
    .height('100%')

  }

  async getWalkingRoutes(currentLocation: geoLocationManager.Location) {
    try {
      let params: navi.RouteParams = {
        origins: [
          {
            'latitude': currentLocation.latitude,
            'longitude': currentLocation.longitude
          }
        ],
        destination: {
          'latitude': this.latitude,
          'longitude': this.longitude
        },
        language: 'zh_CN'
      };
      const result = await navi.getWalkingRoutes(params);
      if (result) {
        let route = result.routes[0];
        let step = route.steps[0];
        this.distance = `距离你${step.distanceDescription} ｜ 步行${step.durationDescription}`;
      }
    } catch (error) {
    }
  }
}
