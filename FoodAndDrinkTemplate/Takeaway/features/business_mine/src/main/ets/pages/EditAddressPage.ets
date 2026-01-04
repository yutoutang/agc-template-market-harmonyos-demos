import { CommonConstants, RouterMap } from 'lib_common';
import { CommonDivider } from 'lib_native_components';
import { AddressUtils } from 'lib_takeaway_api';
import { NavHeaderBar } from 'lib_widget';
import { ParamAddressPage } from '../common/TypeAddressConstant';
import { CommonCascade } from '../components/CommonCascade';
import { EditAddressPageVM } from '../viewmodels/EditAddressPageVM';

@Builder
export function EditAddressPageBuilder() {
  EditAddressPage();
}

@ComponentV2
export struct EditAddressPage {
  @Local vm: EditAddressPageVM = new EditAddressPageVM();

  build() {
    NavDestination() {
      NavHeaderBar({
        title: this.vm.isNew() ? '添加地址' : '修改地址',
      })
      Column() {

        Column() {
          Scroll() {
            Column() {
              Row() {
                Row() {
                  Image($r('app.media.ic_link'))
                    .width(24)
                    .height(24)
                    .margin({ right: 8 })
                  Text('获取关联账号地址')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                }

                Image($r('app.media.ic_arrow_right'))
                  .width(12)
                  .height(24)
              }
              .width('100%')
              .height(56)
              .padding({ left: 12, right: 12 })
              .justifyContent(FlexAlign.SpaceBetween)
              .borderRadius(16)
              .backgroundColor(Color.White)
              .margin({ bottom: 12 })
              .onClick(async () => {
                const address = await AddressUtils.chooseAddress()
                if (address) {
                  this.vm.name = address.name
                  this.vm.cellphone = address.cellphone
                  this.vm.province = address.province
                  this.vm.city = address.city
                  this.vm.area = address.area
                  this.vm.detailAddress = address.detailAddress
                }
              })

              Column() {
                Row() {
                  Flex() {
                    Text('姓名')
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width(60)

                  TextInput({ text: $$this.vm.name, placeholder: '名字' })
                    .backgroundColor(Color.Transparent)
                    .layoutWeight(1)
                    .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
                    .placeholderColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.Body_M'))
                }

                CommonDivider()
                Row() {
                  Row() {
                    Text('手机号码')
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width(60)

                  TextInput({ text: $$this.vm.cellphone, placeholder: '手机号' })
                    .backgroundColor(Color.Transparent)
                    .layoutWeight(1)
                    .maxLength(11)
                    .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
                    .placeholderColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.Body_M'))
                }

                CommonDivider()
                Row() {
                  Row() {
                    Text('地区')
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width(60)

                  CommonCascade({
                    province: this.vm.province,
                    city: this.vm.city,
                    area: this.vm.area,
                    onChange: (data) => {
                      this.vm.province = data[0] ?? ''
                      this.vm.city = data[1] ?? ''
                      this.vm.area = data[2] ?? ''
                    }
                  })
                }

                CommonDivider()
                Row() {
                  Row() {
                    Text('详细地址')
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width(60)

                  TextInput({ text: $$this.vm.detailAddress, placeholder: '详细的街道门牌、楼栋、居民号等信息' })
                    .backgroundColor(Color.Transparent)
                    .layoutWeight(1)
                    .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
                    .placeholderColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.Body_M'))
                }
              }
              .width('100%')
              .padding(12)
              .borderRadius(16)
              .backgroundColor(Color.White)
              .margin({ bottom: 12 })

              Row() {
                Text('设置为默认地址')
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))

                Toggle({ type: ToggleType.Switch, isOn: this.vm.isDefault })
                  .onChange((value) => {
                    this.vm.isDefault = value
                  })
              }
              .width('100%')
              .height(44)
              .padding({ left: 12, right: 12 })
              .justifyContent(FlexAlign.SpaceBetween)
              .borderRadius(16)
              .backgroundColor(Color.White)
              .margin({ bottom: 12 })
            }
          }
          .scrollBar(BarState.Off)
        }
        .height('80%')

        Row() {
          Button('保存')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .width('100%')
            .backgroundColor($r('app.color.app_theme'))
            .onClick(() => {
              this.vm.onSubmit().then(() => {
                this.vm.stack.pop('ok');
              });
            })
        }
        .width('100%')
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        left: 16,
        right: 16,
      });
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context) => {
      this.vm.stack = context.pathStack;
      const params: ParamAddressPage[] =
        this.vm.stack.getParamByName(RouterMap.EDIT_ADDRESS_PAGE) as ParamAddressPage[];
      if (params.length && params[params.length - 1]) {
        const param = params[params.length - 1];
        if (param.param) {
          this.vm.address = param.param
          this.vm.type = param.type
          this.vm.name = param.param.name
          this.vm.cellphone = param.param.cellphone
          this.vm.province = param.param.province
          this.vm.city = param.param.city
          this.vm.area = param.param.area
          this.vm.detailAddress = param.param.detailAddress
          this.vm.isDefault = param.param.isDefault
        }
      }
    })
  }
}

