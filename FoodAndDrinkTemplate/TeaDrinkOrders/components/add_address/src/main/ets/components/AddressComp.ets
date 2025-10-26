import { ADDRESS_TAG_MAP, AddressTagEnum } from '../constants/Index'
import { AddressInfo } from '../models/Index'

@ComponentV2
export struct AddressComp {
  @Param @Require address: AddressInfo

  build() {
    Column() {
      Row() {
        if (this.address.tag) {
          Text(ADDRESS_TAG_MAP[this.address.tag])
            .fontSize(10)
            .fontColor(this.getTagFontColor(this.address.tag))
            .borderRadius(4)
            .padding({
              top: 2,
              bottom: 2,
              left: 8,
              right: 8,
            })
            .backgroundColor(this.getTagBgColor(this.address.tag))
            .margin({ right: 4 })
        }

        Text(`${this.address.addressPre}${this.address.addressNum}`)
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }

      Row() {
        Text(this.address.name).fontSize(12).fontColor($r('sys.color.font_secondary'))
        Text(this.address.tel)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ left: 12 })
      }.margin({ top: 9 })
    }.alignItems(HorizontalAlign.Start)
  }

  getTagFontColor(tag: number) {
    if (tag === AddressTagEnum.DEFAULT) {
      return '#486602'
    } else {
      return '#FFC62F'
    }
  }

  getTagBgColor(tag: number) {
    if (tag === AddressTagEnum.DEFAULT) {
      return '#6686AD2B'
    } else {
      return '#33FFC62F'
    }
  }
}