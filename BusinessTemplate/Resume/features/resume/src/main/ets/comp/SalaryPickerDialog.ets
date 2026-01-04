/**
 * 期望薪资选择弹窗
 * 双列选择器，左侧选择最低薪资，右侧选择最高薪
 */

import { ComponentContent } from '@kit.ArkUI'

export interface SalaryPickerParams {
  currentSalary: string // 当前薪资，格式如"10-12K"
  onConfirm: (salary: string) => void
  onCancel: () => void
}

class SalaryPickerData {
  currentSalary: string = ''
  onConfirm: (salary: string) => void = () => {
  }
  onCancel: () => void = () => {
  }

  constructor(params: SalaryPickerParams) {
    this.currentSalary = params.currentSalary
    this.onConfirm = params.onConfirm
    this.onCancel = params.onCancel
  }
}

export class SalaryPickerDialogController {
  private static ctx: UIContext
  private static contentNode: ComponentContent<SalaryPickerData> | null = null

  static openDialog(uiContext: UIContext, params: SalaryPickerParams) {
    SalaryPickerDialogController.ctx = uiContext
    const data = new SalaryPickerData(params)
    SalaryPickerDialogController.contentNode =
      new ComponentContent(uiContext, wrapBuilder(salaryPickerDialogBuilder), data)
    uiContext.getPromptAction().openCustomDialog(SalaryPickerDialogController.contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false
    })
  }

  static closeDialog() {
    if (SalaryPickerDialogController.contentNode && SalaryPickerDialogController.ctx) {
      SalaryPickerDialogController.ctx.getPromptAction().closeCustomDialog(SalaryPickerDialogController.contentNode)
      SalaryPickerDialogController.contentNode = null
    }
  }
}

@Builder
function salaryPickerDialogBuilder(data: SalaryPickerData) {
  SalaryPickerDialog({ data: data })
}

@ComponentV2
export struct SalaryPickerDialog {
  @Require @Param data: SalaryPickerData
  @Local minSalaryIndex: number = 9 // 默认10K的索引（加上前置2个空项）
  @Local maxSalaryIndex: number = 11 // 默认12K的索引（加上前置2个空项）
  // 薪资选项（单位:K
  // 前后各添加两个空项，使得所有选项都能滚动到中项
  private salaryOptions: number[] = [0, 0, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    22, 24, 26, 28, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100, 0, 0]
  private minScroller: Scroller = new Scroller()
  private maxScroller: Scroller = new Scroller()
  private itemHeight: number = 40
  private isInitialized: boolean = false // 标记是否已初始化，防止onScrollIndex干扰

  aboutToAppear(): void {
    // 解析当前薪资，支持 "5K-6K" 或 "5-6K" 格式
    if (this.data.currentSalary && this.data.currentSalary.trim()) {
      // 匹配 "5K-6K" 或 "5-6K" 格式
      const match = this.data.currentSalary.match(/(\d+)K?-(\d+)K/)
      if (match) {
        const minSalary = parseInt(match[1])
        const maxSalary = parseInt(match[2])

        // 查找薪资在数组中的索引
        let minIndex = -1
        let maxIndex = -1
        for (let i = 0; i < this.salaryOptions.length; i++) {
          if (this.salaryOptions[i] === minSalary && minIndex === -1) {
            minIndex = i
          }
          if (this.salaryOptions[i] === maxSalary && maxIndex === -1) {
            maxIndex = i
          }
        }
        // 如果找到了有效的薪资值，使用它们；否则使用默认值10K-12K
        if (minIndex !== -1 && maxIndex !== -1) {
          this.minSalaryIndex = minIndex
          this.maxSalaryIndex = maxIndex
        } else {
          // 默认10K-12K（索引9和11，因为前面有2个0）
          this.minSalaryIndex = 9
          this.maxSalaryIndex = 11
        }
      } else {
        // 格式不匹配，使用默认值
        this.minSalaryIndex = 9
        this.maxSalaryIndex = 11
      }
    } else {
      // 没有当前薪资，使用默认值10K-12K
      this.minSalaryIndex = 9
      this.maxSalaryIndex = 11
    }

    // 立即设置初始滚动位置（无动画，直接定位）
    setTimeout(() => {
      // smooth: false 表示无动画，直接跳转
      this.minScroller.scrollToIndex(this.minSalaryIndex, false, ScrollAlign.CENTER)
      this.maxScroller.scrollToIndex(this.maxSalaryIndex, false, ScrollAlign.CENTER)
      // 标记初始化完成，允许onScrollIndex更新索引
      this.isInitialized = true
    }, 50)
  }

  build() {
    Stack() {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.data.onCancel()
          SalaryPickerDialogController.closeDialog()
        })

      // 弹窗内容
      Column() {
        // 标题
        Text('期望薪资')
          .textAlign(TextAlign.Start)
          .fontSize(20)
          .fontWeight(FontWeight.Normal)
          .fontColor($r('sys.color.black'))
          .margin({ left: 24, top: 16, bottom: 8 })
          .width('100%')

        // 双列选择框
        Row() {
          // 最低薪资
          Stack() {
            List({ space: 0, scroller: this.minScroller }) {
              ForEach(this.salaryOptions, (salary: number, index: number) => {
                ListItem() {
                  Text(salary === 0 ? '' : `${salary}K`)
                    .fontSize(index === this.minSalaryIndex ? 18 : 14)
                    .fontWeight(index === this.minSalaryIndex ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(index === this.minSalaryIndex ? '#0A59F7' : '#999999')
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .height(this.itemHeight)
                }
              }, (salary: number, index: number) => `min-${index}-${salary}`)
            }
            .height(200)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            .onScrollIndex((start: number) => {
              // 只有初始化完成后才响应滚动事件
              if (!this.isInitialized) {
                return
              }
              // 滚动时实时更新选中索引（中间项 = start + 2）
              const newIndex = Math.max(0, Math.min(start + 2, this.salaryOptions.length - 1))
              // 跳过空项
              if (this.salaryOptions[newIndex] !== 0) {
                const newMinValue = this.salaryOptions[newIndex]
                const currentMaxValue = this.salaryOptions[this.maxSalaryIndex]

                // 如果新值不超过最高值，允许更新
                if (newMinValue <= currentMaxValue) {
                  this.minSalaryIndex = newIndex
                } else {
                  // 如果超过了，强制滚动回当前最高值的位置
                  this.minScroller.scrollToIndex(this.maxSalaryIndex, true, ScrollAlign.CENTER)
                }
              }
            })
            .onScrollStop(() => {
              // 滚动停止后，自动对齐到中间项
              this.minScroller.scrollToIndex(this.minSalaryIndex, true, ScrollAlign.CENTER)
            })

            // 中间选中
            Column()
              .width('100%')
              .height(this.itemHeight)
              .border({ width: { top: 1, bottom: 1 }, color: '#E5E5E5' })
              .position({ y: 80 })
          }
          .layoutWeight(1)

          // 分隔符
          Text('——')
            .fontSize(16)
            .fontColor('#CCCCCC')
            .margin({ left: 12, right: 12 })

          // 最高薪资
          Stack() {
            List({ space: 0, scroller: this.maxScroller }) {
              ForEach(this.salaryOptions, (salary: number, index: number) => {
                ListItem() {
                  Text(salary === 0 ? '' : `${salary}K`)
                    .fontSize(index === this.maxSalaryIndex ? 18 : 14)
                    .fontWeight(index === this.maxSalaryIndex ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(index === this.maxSalaryIndex ? '#0A59F7' : '#999999')
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .height(this.itemHeight)
                }
              }, (salary: number, index: number) => `max-${index}-${salary}`)
            }
            .height(200)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            .onScrollIndex((start: number) => {
              // 只有初始化完成后才响应滚动事件
              if (!this.isInitialized) {
                return
              }
              // 滚动时实时更新选中索引（中间项 = start + 2）
              const newIndex = Math.max(0, Math.min(start + 2, this.salaryOptions.length - 1))

              if (this.salaryOptions[newIndex] !== 0) {
                const newMaxValue = this.salaryOptions[newIndex]
                const currentMinValue = this.salaryOptions[this.minSalaryIndex]

                // 如果新值不低于最低值，允许更新
                if (newMaxValue >= currentMinValue) {
                  this.maxSalaryIndex = newIndex
                } else {
                  // 如果低于了，强制滚动回当前最低值的位置
                  this.maxScroller.scrollToIndex(this.minSalaryIndex, true, ScrollAlign.CENTER)
                }
              }
            })
            .onScrollStop(() => {
              // 滚动停止后，自动对齐到中间项
              this.maxScroller.scrollToIndex(this.maxSalaryIndex, true, ScrollAlign.CENTER)
            })

            // 中间选中
            Column()
              .width('100%')
              .height(this.itemHeight)
              .border({ width: { top: 1, bottom: 1 }, color: '#E5E5E5' })
              .position({ y: 80 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 40, right: 40 })
        .margin({ top: 8, bottom: 8 })

        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.comp_divider'))
          .margin({ top: 8, bottom: 0 })

        // 按钮
        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor($r('sys.color.black'))
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              this.data.onCancel()
              SalaryPickerDialogController.closeDialog()
            })

          Divider()
            .vertical(true)
            .height(44)
            .strokeWidth('1px')
            .color($r('sys.color.comp_divider'))

          Text('确定')
            .fontSize(16)
            .fontColor('#0A59F7')
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              const minSalary = this.salaryOptions[this.minSalaryIndex]
              const maxSalary = this.salaryOptions[this.maxSalaryIndex]
              const salary = `${minSalary}K-${maxSalary}K`
              this.data.onConfirm(salary)
              SalaryPickerDialogController.closeDialog()
            })
        }
        .width('100%')
        .height(44)
      }
      .width('85%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(32)
    }
  }
}
