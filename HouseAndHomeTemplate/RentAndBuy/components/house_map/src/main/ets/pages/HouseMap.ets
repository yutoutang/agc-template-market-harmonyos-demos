import { MapComponent } from '@kit.MapKit';
import { common } from '@kit.AbilityKit';
import { BaseResponse, EventEmitName, IBasicHouse, MapUtil, TitleBar } from 'module_base';
import { HouseMapVM } from '../viewmodel/HouseMapVM';

@Builder
export function HouseMapBuilder() {
  HouseMap();
}

@ComponentV2
export struct HouseMap {
  vm: HouseMapVM = HouseMapVM.instance;
  mu: MapUtil = MapUtil.instance;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        MapComponent({
          mapOptions: this.mu.mapOptions,
          mapCallback: this.mu.callback,
        }).height('100%');
        TitleBar({ title: '地图找房', stack: this.vm.stack });
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.vm.stack = context.pathStack;
      this.vm.fetchHousePromise = context.pathInfo.param as Promise<BaseResponse<IBasicHouse[]>>[];
      this.vm.initMap(this.getUIContext());
      this.vm.drawMap();
    }).onWillDisappear(() => {
      (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit(EventEmitName.CLEAR_MAKER_STATUS);
    });
  }
}