import { LocationPageVM } from './LocationPageVM';
import { map, MapComponent } from '@kit.MapKit';
import { Logger, RouterModule } from 'commonlib';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function locationPageBuilder() {
  LocationPage();
}

const TAG: string = '[LocationPage]'

@ComponentV2
export struct LocationPage {
  vm: LocationPageVM = LocationPageVM.instance;
  // 自定义信息窗BuilderParam
  @BuilderParam customInfoWindow: ($$: map.MarkerDelegate) => void = this.customInfoWindowBuilder;
  @Local
  avoidTop: Length = 0

  setFullScreen(status: boolean) {
    window.getLastWindow(this.getUIContext().getHostContext())
      .then((win) => {
        if (status) {
          const top = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT).topRect.height
          this.avoidTop = this.getUIContext().px2vp(top) + 12;
        }
        win.setWindowLayoutFullScreen(status)
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, 'set full screen failed. error:' + JSON.stringify(err))
      })
  }

  build() {
    NavDestination() {
      Stack({
        alignContent: Alignment.BottomEnd,
      }) {
        MapComponent({
          mapOptions: this.vm.mapOptions,
          mapCallback: this.vm.callback,
          customInfoWindow: this.customInfoWindow,
        })
          .width('100%')
          .height('100%')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        this.guideButtonBuilder();
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .title('酒店位置')
    .padding({ top: this.avoidTop })
    .onReady(() => {
      if (!this.vm.mapController) {
        this.vm.initController();
      }
      this.setFullScreen(true)
    })
    .onShown(async () => {
      if (this.vm.mapController !== undefined) {
        this.vm.mapController.show();
      }
    })
    .onBackPressed(() => {
      RouterModule.pop();
      this.setFullScreen(false)
      return true;
    })
    .onHidden(() => {
      // 将地图切换到后台
      try {
        if (this.vm.mapController !== undefined) {
          this.vm.mapController.hide();
        }
      } catch (err) {
        Logger.error(TAG, 'hide map failed. error:' + JSON.stringify(err))
      }
    });
  }

  @Builder
  guideButtonBuilder() {
    Row() {
      Image($r('app.media.ic_guide'))
        .width(24)
        .margin({
          right: $r('app.string.margin_s'),
        });
      Text('导航')
        .fontSize($r('app.string.font_size_16'));
    }
    .justifyContent(FlexAlign.Center)
    .padding($r('app.string.padding_m'))
    .margin({ right: $r('app.string.margin_l'), bottom: $r('app.string.margin_xl') })
    .borderRadius($r('app.string.border_radius_capsule'))
    .backgroundColor($r('app.color.background_color_white'))
    .onClick(() => {
      this.vm.handleClickGuide();
    });
  }

  @Builder
  customInfoWindowBuilder($$: map.MarkerDelegate) {
    Row() {
      if ($$.marker) {
        Text($$.marker.getTitle())
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.font_color_level1_invert'));
      }
    }
    .padding($r('app.string.padding_s'))
    .margin({ right: $r('app.string.margin_m'), bottom: $r('app.string.margin_s') })
    .backgroundColor($r('app.color.theme_color'))
    .borderRadius($r('app.string.border_radius_capsule'));
  }
}