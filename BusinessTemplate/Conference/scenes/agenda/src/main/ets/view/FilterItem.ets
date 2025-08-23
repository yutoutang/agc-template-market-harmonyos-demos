import { DictListItem } from '../viewModel/DistListModel'

@Component
export struct FilterItem {
  @Consume('pageStack') pageStack: NavPathStack
  @ObjectLink item: DictListItem
  callback?: (item: DictListItem) => void

  build() {
    Column() {
      Text(this.item.name).fontSize(14).lineHeight(20)
        .fontColor(this.item.isSelect ? '#fff' : '#191919')
    }
    .backgroundColor(this.item.isSelect ? '#cc0a59f7' : '#0d000000')
    .borderRadius(20)
    .padding({
      top: 3,
      left: 16,
      right: 16,
      bottom: 6
    })
    .margin({
      bottom: 11,
      right: 8
    })
    .onClick(() => {
      if (this.callback) {
        this.callback(this.item)
      } else {
        this.item.isSelect = !this.item.isSelect
      }
    })
  }
}