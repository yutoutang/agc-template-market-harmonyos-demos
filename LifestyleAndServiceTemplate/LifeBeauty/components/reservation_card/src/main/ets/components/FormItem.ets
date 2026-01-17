import { FormItemModel } from '../common/Type'

@ComponentV2
export struct FormItem {
  @Param info: FormItemModel = new FormItemModel();
  @Param enableOperate: boolean = false;

  build() {
    Row() {
      Text(this.info.label)
        .fontSize(12)
        .fontColor(this.enableOperate ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
        .width(60)
      Text(this.info.content)
        .fontSize(12)
        .fontColor(this.enableOperate ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}