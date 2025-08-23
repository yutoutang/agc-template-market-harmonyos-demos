import { TagItem } from '../viewModel/TagModel'

@Component
export struct TagChildItem {
  @ObjectLink item: TagItem

  aboutToAppear(): void {

  }

  build() {
    Row() {
      Image(this.item.selectIcon).width(14)
        .margin({
          right: 5
        })
        .visibility(this.item.isSelect ? Visibility.Visible : Visibility.None)
      Image(this.item.coverImageRealPath).width(14)
        .margin({
          right: 5
        }).visibility(this.item.isSelect ? Visibility.None : Visibility.Visible)
      Text(this.item.title?.toString())
        .fontSize(14)
        .fontColor(this.item.isSelect ? Color.White : '#191919')
        .lineHeight(20)
    }
    .padding({
      top: 9,
      right: 12,
      bottom: 9,
      left: 12,
    })
    .margin({
      bottom: 12,
      right: 12,
    })
    .border({
      width: 1,
      color: this.item.isSelect ? '#cc0a59f7' : '#E6E6E6',
    })
    .backgroundColor(this.item.isSelect ? '#cc0a59f7' : Color.White)
    .borderRadius(20)
    .onClick(() => {
      this.item.isSelect = !this.item.isSelect
    })
  }
}