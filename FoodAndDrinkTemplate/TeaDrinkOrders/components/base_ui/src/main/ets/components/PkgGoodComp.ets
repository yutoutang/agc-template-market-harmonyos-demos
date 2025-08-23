import { Constants } from '../constants/Index'
import { PackageSpec } from '../models/Index'

@ComponentV2
export struct PkgGoodComp {
  @Param @Require pkgGoods: Array<PackageSpec>

  build() {
    List() {
      ForEach(this.pkgGoods, (item: PackageSpec) => {
        ListItem() {
          Row() {
            Row() {
              Image(`${Constants.CLOUD_STORAGE_URL}${item.specLogo}`).width(60).height(60)
              Column() {
                Text(item.specName)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                Text(item.specVal)
                  .fontSize($r('sys.float.Caption_M'))
                  .fontColor($r('sys.color.font_secondary'))
                  .margin({ top: 4 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1)
            }.layoutWeight(1)

            Row() {
              Text(`x${item.specNum}`).fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.font_secondary'))
            }.alignItems(VerticalAlign.Bottom).justifyContent(FlexAlign.End).height(60)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween)
        }
      }, (item: PackageSpec) => JSON.stringify(item))
    }
    .width('100%')
    .padding({
      left: 8,
      right: 8,
      top: 12,
      bottom: 12,
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius(12)
  }
}