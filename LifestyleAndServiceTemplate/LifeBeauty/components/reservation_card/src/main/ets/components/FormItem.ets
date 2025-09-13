import { FormItemModel } from '../common/Type'

@ComponentV2
export struct FormItem {
  @Param info: FormItemModel = new FormItemModel();
  @Param enableOperate: boolean = false;

  build() {
    Row() {
      Text(this.info.label)
        .fontSize(14)
        .fontColor(this.enableOperate ? '#333333' : '#878787')
        .width(100)
      Text(this.info.content)
        .fontSize(14)
        .fontColor(this.enableOperate ? '#333333' : '#878787')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}