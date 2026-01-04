/**
 * 选择行组件
 * 用于职位名称、担任角色等需要跳转到选择页面的场景
 */
import { InfoRow } from './InfoRow'

export interface SelectRowParams {
  title: string // 标题，如"职位名称"、"担任角色"
  value: string // 当前选中的值
  placeholder: string // 占位符，如"请选择职位名称"
  onClickRow: () => void // 点击行的回调
}

@ComponentV2
export struct SelectRow {
  @Param @Require title: string = ''
  @Param @Require value: string = ''
  @Param @Require placeholder: string = ''
  @Param @Require onClickRow: () => void = () => {}
  @Param isDraftPosition: boolean = false
  build() {
    InfoRow({
      title: this.title,
      value: this.value || this.placeholder,
      isSecondary: !this.value,
      onClickRow: this.onClickRow,
      isDraftPosition:this.isDraftPosition
    })
  }
}
