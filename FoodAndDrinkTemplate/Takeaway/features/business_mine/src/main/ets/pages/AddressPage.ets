import { CommonDivider } from 'lib_native_components';
import { ParamAddressPage, TypeAddressPage } from '../common/TypeAddressConstant';
import { TipsDialog } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { IAddrInfo } from 'lib_takeaway_api/src/main/ets/database/IAddrType';
import { AddressPageVM } from '../viewmodels/AddressPageVM';
import { AddressUtils } from 'lib_takeaway_api';
import { CommonConstants, Logger, RouterMap } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';

const TAG = '[AddressPage]';

@Builder
export function AddressPageBuilder() {
  AddressPage();
}

@ComponentV2
export struct AddressPage {
  vm: AddressPageVM = AddressPageVM.instance
  dialogControllerDelete: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      content: '是否删除当前地址?',
      primaryButton: {
        value: '取消',
        action: () => {
          Logger.info(TAG, 'Callback when the first button is clicked')
        },
      },
      secondaryButton: {
        value: '删除',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.deleteAddr()
          this.dialogControllerDelete.close()
        }
      },
    }),
  })

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的地址',
        })
        Scroll() {
          Column() {
            Row() {
              Image($r('app.media.ic_add'))
                .width(24)
                .height(24)
                .margin({ right: 8 })
              Text('添加地址')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .height(56)
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .backgroundColor($r('sys.color.white'))
            .margin({ bottom: 12 })
            .onClick(() => {
              const param: ParamAddressPage = {
                type: TypeAddressPage.NEW,
              };
              this.vm.stack.pushPath({
                name: RouterMap.EDIT_ADDRESS_PAGE,
                param,
                onPop: (info: PopInfo) => {
                  if (info.result) {
                    this.vm.queryList();
                  }
                },
              });
            })

            ForEach(this.vm.list, (address: IAddrInfo) => {
              Column() {
                Column() {
                  Row() {
                    Text(address.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ right: 12 })
                    Text(AddressUtils.encryptPhoneNo(address.cellphone))
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width('100%')
                  .margin({ bottom: 4 })

                  Row() {
                    Text(address.province + address.city + address.area + address.detailAddress)
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width('100%')

                  CommonDivider()
                }
                .onClick(() => {
                  const addressInfoData: IAddrInfo = {
                    id: address.id,
                    name: address.name,
                    cellphone: address.cellphone,
                    province: address.province,
                    city: address.city,
                    area: address.area,
                    detailAddress: address.detailAddress,
                    isDefault: address.isDefault
                  }
                  let addressInfo: emitter.EventData = {
                    data: addressInfoData
                  };
                  emitter.emit('address', addressInfo);
                  this.vm.stack.pop()
                })

                Row() {
                  Row() {
                    Toggle({ type: ToggleType.Switch, isOn: address.isDefault })
                      .margin({ right: 12 })
                      .onChange((value) => {
                        address.isDefault = value
                        this.vm.update(address)
                        if (value) {
                          this.vm.list.forEach((item) => {
                            if (item.id !== address.id) {
                              item.isDefault = false
                              this.vm.update(item)
                            }
                          })
                        }
                      })
                    Text('默认地址')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                  }

                  Row() {
                    Button('编辑')
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                      .width(72)
                      .controlSize(ControlSize.SMALL)
                      .backgroundColor($r('sys.color.comp_background_tertiary'))
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ right: 8 })
                      .onClick(() => {
                        const param: ParamAddressPage = {
                          type: TypeAddressPage.EDIT,
                          param: address,
                        };
                        this.vm.stack.pushPath({
                          name: RouterMap.EDIT_ADDRESS_PAGE,
                          param: param,
                          onPop: (info: PopInfo) => {
                            if (info.result) {
                              this.vm.queryList();
                            }
                          },
                        });
                      })
                    Button('删除')
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                      .width(72)
                      .controlSize(ControlSize.SMALL)
                      .backgroundColor($r('sys.color.comp_background_tertiary'))
                      .fontColor($r('sys.color.font_primary'))
                      .onClick(() => {
                        this.vm.selectedAddress = address
                        this.dialogControllerDelete.open()
                      })
                  }
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .backgroundColor(Color.White)
              .padding(12)
              .borderRadius(16)
              .margin({ bottom: 12 })
            }, (item: IAddrInfo[]) => JSON.stringify(item))
          }
          .padding({
            top: 12,
            left: 12,
            right: 12,
            bottom: 13
          })
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .borderRadius(16)
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)

    }
    .padding({ bottom: this.vm.windowModel.windowBottomPadding })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context) => {
      this.vm.setStack(context.pathStack);
    })
    .onShown(() => {
      this.vm.init()
    })
  }
}