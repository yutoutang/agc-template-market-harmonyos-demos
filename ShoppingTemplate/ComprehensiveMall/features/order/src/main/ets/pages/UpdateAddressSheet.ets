import { routerStack } from 'lib_foundation'
import { ContainerColumn, NavTitleBar } from 'lib_widget'
import { AddressManage } from 'module_address_manage'
import { AddressInfo } from 'lib_network'
import { OrderButtonStyleMap } from '../common/Enums'
import { MyButtonModifier } from '../common/Types'
import { buildAddressInfo } from '../components/AddressInfoCard'
import { OrderUtil } from '../utils/OrderUtil'

export interface UpdateAddressSheetOptions {
  originalAddress?: AddressInfo
  orderNo: string
  handleSubmitSuccess: () => void
}

@Builder
export function buildUpdateAddressSheet() {
  UpdateAddressSheet()
}

@ComponentV2
export struct UpdateAddressSheet {
  @Local
  orderNo: string = ''
  @Local
  originalAddress?: AddressInfo = undefined
  @Local
  newAddress?: AddressInfo = undefined
  @Event
  handleSubmitSuccess: () => void

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          NavTitleBar({
            title: '修改地址',
            showBackBtn: true,
          })
          Column({ space: 12 }) {
            Text('原地址')
              .fontSize($r('app.float.font_size_18'))
              .fontColor($r('app.color.font_color_level1'))
            ContainerColumn(){
              buildAddressInfo(this.originalAddress)
            }
            Row() {
              Text('新地址')
                .fontSize($r('app.float.font_size_18'))
                .fontColor($r('app.color.font_color_level1'))
              AddressManage({
                navPathStack: routerStack,
                isSelectMode: true,
                onSelect: (data) => {
                  this.newAddress = {
                    name: data.name,
                    cellphone: data.phone,
                    address: data.province + data.city + data.district + data.street + data.detail,
                  }
                },
              }) {
                Button('选择地址')
                  .attributeModifier(new MyButtonModifier(OrderButtonStyleMap.OUTLINE, ControlSize.SMALL))
              }
            }
            .width($r('app.string.size_percent_full'))
            .justifyContent(FlexAlign.SpaceBetween)

            if (this.newAddress) {
              ContainerColumn(){
                buildAddressInfo(this.newAddress)
              }
            }

            Blank()
            Button('提交修改')
              .attributeModifier(new MyButtonModifier(OrderButtonStyleMap.FULFILL))
              .enabled(Boolean(this.newAddress))
              .width($r('app.string.size_percent_full'))
              .onClick(() => {
                OrderUtil.handleUpdateAddress({
                  orderNo: this.orderNo,
                  callback: () => {
                    this.handleSubmitSuccess?.()
                  },
                  data: this.newAddress,
                })
              })
          }
          .padding($r('app.float.space_l'))
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width($r('app.string.size_percent_full'))
        .height($r('app.string.size_percent_75'))
        .backgroundColor($r('app.color.background_color_grey'))
        .borderRadius({
          topLeft: $r('app.float.border_radius_xl'),
          topRight: $r('app.float.border_radius_xl'),
        })
        .padding({top:$r('app.float.space_m')})
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

      }
      .height($r('app.string.size_percent_full'))
      .width($r('app.string.size_percent_full'))
      .backgroundColor($r('sys.color.mask_fourth'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)

    .align(Alignment.Bottom)
    .onReady((context) => {
      const param = context.pathInfo.param as UpdateAddressSheetOptions | undefined
      if (param) {
        this.orderNo = param.orderNo
        this.originalAddress = param.originalAddress
        this.handleSubmitSuccess = param.handleSubmitSuccess
      }
    })
  }
}