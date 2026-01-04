import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, Logger, UserInfoModel, WindowModel } from 'lib_common';
import { AddressUtils, AddrMgtApi } from 'lib_takeaway_api';
import { IAddrInfo } from 'lib_takeaway_api/src/main/ets/database/IAddrType';

@Builder
export function builderSelectAddress(selected: number, confirmAddrInfo: (address: IAddrInfo) => void) {
  SelectAddress({
    selected: selected,
    confirmAddrInfo: confirmAddrInfo
  })
}

@ComponentV2
export struct SelectAddress {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local userInfoModel: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  // 选中地址id
  @Param @Require selected: number
  // 选中地址
  @Local selectedIAddrInfo: IAddrInfo | undefined = AddrMgtApi.defaultAddress();
  @Local addrInfoList: IAddrInfo[] = []
  @Event
  confirmAddrInfo: (address: IAddrInfo) => void = () => {
    // do nothing.
  }

  async aboutToAppear(): Promise<void> {
    this.addrInfoList = await AddrMgtApi.getAddressList();
    this.selectedIAddrInfo = this.addrInfoList.find(item => item.id === this.selected);
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          ForEach(this.addrInfoList, (address: IAddrInfo) => {
            Column({ space: CommonConstants.SPACE_L }) {
              Row() {
                Column() {
                  Row() {
                    Text(address.name)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ right: 12 })
                    Text(AddressUtils.encryptPhoneNo(address.cellphone))
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width('100%')
                  .margin({ bottom: 4 })

                  Row() {
                    Text(address.province + address.city + address.area + address.detailAddress)
                      .fontSize(14)
                      .fontWeight(FontWeight.Normal)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width('100%')
                }.width('90%')

                Checkbox({ name: 'channelCheckBox', group: 'checkboxGroup' })
                  .select(this.selected === address.id)
                  .shape(CheckBoxShape.CIRCLE)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.selectedIAddrInfo = address;
                      Logger.info('selectedIAddrInfo', JSON.stringify(this.selectedIAddrInfo))
                      this.confirmAddrInfo(this.selectedIAddrInfo)
                    }
                  });
              }
              .justifyContent(FlexAlign.Start)
              .backgroundColor($r('sys.color.white'))
              .borderRadius(16)
              .padding({
                left: CommonConstants.PADDING_L,
                right: CommonConstants.PADDING_L,
                top: CommonConstants.PADDING_L,
                bottom: CommonConstants.PADDING_L
              })
              .margin({ bottom: CommonConstants.PADDING_S })
            }
          }, (item: IAddrInfo, index: number) => index + '__' + item.id)
        }

      }
      .layoutWeight(1)
      .width(CommonConstants.FULL_PERCENT)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_S,
      right: CommonConstants.PADDING_S,
      bottom: this.windowModel.windowBottomPadding,
      top: 10
    })
  }
}

