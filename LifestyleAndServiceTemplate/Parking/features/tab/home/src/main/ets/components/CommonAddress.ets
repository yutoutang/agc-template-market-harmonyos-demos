import {
  AddressModel,
  AddressType,
  AddressUtil,
  AppStorageMap,
  CommonConstants,
  EmitterConstants,
  RouterMap,
  RouterModule,
} from 'common';
import { HomePageVM } from '../viewmodels/HomePageVM';
import { emitter } from '@kit.BasicServicesKit';
import { AssociateUtil } from 'network';
import { MapController } from 'module_parking_map';

@ComponentV2
export struct CommonAddress {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('常去地址')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
        Row() {
          Text('设置').fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.font_secondary'))
          Image($r('app.media.ic_arrow')).width(12)
        }
        .onClick(() => {
          AssociateUtil.checkBindPhone(() => {
            RouterModule.push({ url: RouterMap.COMMON_ADDRESS });
          });
        })
      }
      .width(CommonConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        ForEach(this.vm.commonAddresses.list.slice(0, 3), (item: AddressModel) => {
          this.commonItem(item)
        }, (item: AddressModel, index) => JSON.stringify(item) + '_' + index)
        this.commonItem({
          siteId: '',
          name: '',
          addr: '',
          location: { latitude: 39.9, longitude: 116.4 },
          type: AddressType.CUSTOM,
        })
      }
      .width(CommonConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: $r('app.string.padding_12'), right: $r('app.string.padding_12') })
    }
    .padding($r('app.string.padding_12'))
    .borderRadius($r('app.string.border_radius_16'))
    .backgroundColor($r('app.color.system_color_background_white'))
    .width('calc(100% - 32vp)')
  }

  @Builder
  commonItem(address: AddressModel) {
    Column({ space: 8 }) {
      Image($r(AddressUtil.CONFIG_LIST[Number(address.type)].iconOuter)).width(32)
      Text(AddressUtil.CONFIG_LIST[Number(address.type)].textOuter)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_primary'))
    }
    .onClick(() => {
      AssociateUtil.checkBindPhone(() => {
        if (address.siteId) {
          emitter.emit(EmitterConstants.TO_FIND);
          AppStorage.setOrCreate(AppStorageMap.SELECTED_ADDRESS,address.name);
          MapController.move(address.location);
        } else {
          RouterModule.push({ url: RouterMap.COMMON_ADDRESS });
        }
      });
    })
  }
}