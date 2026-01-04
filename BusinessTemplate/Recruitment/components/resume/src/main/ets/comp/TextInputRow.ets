/**
 * 文本输入行组件
 * 用于公司名称、项目名称、学校名称等单行文本输入
 * 点击后打开 CenterEditDialog
 */
import { InfoRow } from './InfoRow'

export interface TextInputRowParams {
  title: string // 标题，如"公司名称"、"项目名称"、"学校名称"
  value: string // 当前值
  placeholder: string // 占位符，如"请填写公司名称"
  onClickRow: () => void // 点击行的回调
}

@ComponentV2
export struct TextInputRow {
  @Param @Require title: string = ''
  @Param @Require value: string = ''
  @Param @Require placeholder: string = ''
  @Param @Require onClickRow: () => void = () => {
  }
  @Param isDraftPosition: boolean = false

  build() {
    InfoRow({
      title: this.title,
      value: this.value || this.placeholder,
      isSecondary: !this.value,
      onClickRow: this.onClickRow,
      isDraftPosition: this.isDraftPosition
    })
  }
}
