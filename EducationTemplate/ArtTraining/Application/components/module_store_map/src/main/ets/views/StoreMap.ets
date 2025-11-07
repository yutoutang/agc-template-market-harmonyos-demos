import { map, MapComponent } from '@kit.MapKit';
import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, WindowUtil } from 'module_ui_base';
import { StoreMapInfo } from '../commons/Types';
import { StoreMapVM } from '../viewmodels/StoreMapVM';

@ComponentV2
export struct StoreMap {
  @Param
  mapWidth: Length = '100%';
  @Param
  mapHeight: Length = 200;
  @Param
  showInfoWindow: boolean = true;
  @Param
  storeInfo: StoreMapInfo | null = null;
  @Param
  showUserLocation: boolean = false;
  // 自定义信息窗BuilderParam
  @BuilderParam customInfoWindow: ($$: map.MarkerDelegate) => void = this.customInfoWindowBuilder;
  @Local
  curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  vm: StoreMapVM = new StoreMapVM();

  @Computed
  get infoWindowPadding(){
    if(this.curBreakpoint.value === BreakpointTypeEnum.MD){
      return '16%';
    }
    return '32%';
  }

  aboutToAppear() {
    WindowUtil.initWindowUtil(this.getUIContext());
    BreakpointSystem.register(this.getUIContext())
    if (this.storeInfo) {
      this.vm.initController(this.storeInfo, this.showUserLocation);
    }
  }

  build() {
    Stack() {
      MapComponent({
        mapOptions: this.vm.mapOptions,
        mapCallback: this.vm.callback,
        // 自定义信息窗
        customInfoWindow: this.customInfoWindow.bind(this),
      })
        .width($r('app.string.size_percent_full'))
        .height($r('app.string.size_percent_full'));
    }
    .width(this.mapWidth)
    .height(this.mapHeight);
  }

  // 自定义信息窗Builder
  @Builder
  customInfoWindowBuilder($$: map.MarkerDelegate) {
    if ($$.marker && this.showInfoWindow) {
      Column() {
        Stack() {
          Image($r('app.media.ic_popover_bg'))
            .objectFit(ImageFit.Contain);

          Flex() {
            Column() {
              Text($$.marker.getTitle())
                .fontSize($r('app.string.font_size_12'))
                .margin({
                  bottom: $r('app.string.space_s'),
                });
              Text($$.marker.getSnippet())
                .fontSize($r('app.string.font_size_12'))
                .fontColor($r('app.color.font_color_level2'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }
            .alignItems(HorizontalAlign.Start);

            Divider()
              .vertical(true)
              .margin($r('app.string.space_s'));

            Column() {
              Image($r('app.media.ic_guide'))
                .width(18)
                .margin({ bottom: $r('app.string.space_xs') });
              Text('导航')
                .fontSize($r('app.string.font_size_12'))
                .fontColor($r('app.color.font_color_link'))
                .maxLines(1);
            }
            .width(40)
            .padding({ right: $r('app.string.space_s') })
            .onClick(() => {
              this.vm.handleClickGuide();
            });
          }
          .padding(12)
          .margin({ left: $r('app.string.space_s') });
        }
        .width(240)
      }
      .width('100%')
      .padding({ left: this.infoWindowPadding })
      .alignItems(HorizontalAlign.Center)
      .height(75);
    }
  }
}