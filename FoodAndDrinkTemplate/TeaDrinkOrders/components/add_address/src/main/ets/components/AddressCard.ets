import { AddressInfo } from '../models/Index'
import { AddressComp } from './AddressComp'

@ComponentV2
export struct AddressCard {
  @Param @Require address: AddressInfo
  @Param selectId: number = 0
  @Param showSelect: boolean = false
  @Param disable: boolean = false
  @Param showEdit: boolean = true
  @Event selectAddress: (address: AddressInfo) => void = () => {
  }
  @Event modifyAddress: (address: AddressInfo) => void = () => {
  }

  build() {
    Row() {
      Row() {
        Radio({ value: this.address.id.toString(), group: 'addressGroup' })
          .checked(this.selectId === this.address.id)
          .radioStyle({
            checkedBackgroundColor: '#486602',
          })
          .height(20)
          .width(20)
          .enabled(!this.disable)
          .visibility(this.selectId >= 0 ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.selectAddress(this.address)
          })
        AddressComp({ address: this.address }).layoutWeight(1)
      }.layoutWeight(1)

      Image($r('app.media.ic_modify'))
        .width(32)
        .margin({ left: 8 })
        .enabled(!this.disable)
        .visibility(this.showEdit ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.modifyAddress(this.address)
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12,
    })
  }
}