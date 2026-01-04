/**
 * 期望薪资选择弹窗
 * 双列选择器，左侧选择最低薪资，右侧选择最高薪
 */

export interface SalaryPickerParams {
  currentSalary: string // 当前薪资，格式如"10-12K"
  onConfirm: (salary: string) => void
  onCancel: () => void
}

@ComponentV2
export struct SalaryPickerDialog {
  @Param @Require currentSalary: string = ''
  @Param @Require onConfirm: (salary: string) => void = () => {
  }
  @Param @Require onCancel: () => void = () => {
  }
  @Local minSalaryIndex: number = 9 // 默认10K的索引（加上前置2个空项）
  @Local maxSalaryIndex: number = 11 // 默认12K的索引（加上前置2个空项）
  private maxScroller: Scroller = new Scroller()
  private itemHeight: number = 56
  // 薪资选项（单位：K
  // 前后各添加两个空项，使得所有选项都能滚动到中项
  private salaryOptions: number[] = [0, 0, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    22, 24, 26, 28, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100, 0, 0]
  private minScroller: Scroller = new Scroller()
  private visibleItemCount: number = 5 // 可见项数量（奇数，中间项为选中项）
  private isInitialized: boolean = false // 标记是否已初始化，防止onScrollIndex干扰

  aboutToAppear(): void {

    // 解析当前薪资，支持 "5K-6K" 或 "5-6K" 格式
    if (this.currentSalary && this.currentSalary.trim()) {
      // 匹配 "5K-6K" 或 "5-6K" 格式
      const match = this.currentSalary.match(/(\d+)K?-(\d+)K/)
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

  @Builder
  buildTitle() {
    Text('期望薪资')
      .fontSize(20)
      .fontWeight(700)
      .fontColor('#000000')
      .padding({ left: 20 })
      .margin({ top: 14 })
      .width('100%')
  }

  @Builder
  buildMinSalaryPicker() {
    Stack() {
      List({ space: 0, scroller: this.minScroller }) {
        ForEach(this.salaryOptions, (salary: number, index: number) => {
          ListItem() {
            Text(salary === 0 ? '' : `${salary}K`)
              .fontSize(index === this.minSalaryIndex ? 20 :
                (index === this.minSalaryIndex - 1 || index === this.minSalaryIndex + 1) ? 16 : 14)
              .fontWeight(index === this.minSalaryIndex ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(index === this.minSalaryIndex ? '#0A59F7' : '#000000')
              .textAlign(TextAlign.Center)
              .width('100%')
              .height(index === this.minSalaryIndex ? this.itemHeight : 40)
          }
          .opacity((index === this.minSalaryIndex - 2 || index === this.minSalaryIndex + 2) ? 0.4 : 1)
          .selectable(false)
        }, (data: Number, index: number) => `${JSON.stringify(data)}_${index}}`)
      }
      .height(200)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .friction(0.6)
      .onScrollIndex((start: number) => {
        if (!this.isInitialized) {
          return
        }
        const newIndex = Math.max(0, Math.min(start + 2, this.salaryOptions.length - 1))
        if (this.salaryOptions[newIndex] !== 0) {
          const newMinValue = this.salaryOptions[newIndex]
          const currentMaxValue = this.salaryOptions[this.maxSalaryIndex]

          if (newMinValue <= currentMaxValue) {
            this.minSalaryIndex = newIndex
          } else {
            this.minScroller.scrollToIndex(this.maxSalaryIndex, true, ScrollAlign.CENTER)
          }
        }
      })
      .onScrollStop(() => {
        this.minScroller.scrollToIndex(this.minSalaryIndex, true, ScrollAlign.CENTER)
      })

      Column()
        .border({ width: { top: 1, bottom: 1 }, color: '#E5E5E5' })
        .width('100%')
        .height(this.itemHeight)
        .border({ width: { top: 0.5, bottom: 0.5 }, color: 'rgba(0,0,0,0.2)' })
        .position({ y: 70 })
        .hitTestBehavior(HitTestMode.Transparent)
    }
    .layoutWeight(1)
  }

  @Builder
  buildMaxSalaryPicker() {
    Stack() {
      List({ space: 0, scroller: this.maxScroller }) {
        ForEach(this.salaryOptions, (salary: number, index: number) => {
          ListItem() {
            Text(salary === 0 ? '' : `${salary}K`)
              .fontSize(index === this.maxSalaryIndex ? 20 :
                (index === this.maxSalaryIndex - 1 || index === this.maxSalaryIndex + 1) ? 16 : 14)
              .fontWeight(index === this.maxSalaryIndex ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(index === this.maxSalaryIndex ? '#0A59F7' : '#000000')
              .textAlign(TextAlign.Center)
              .fontSize(index === this.maxSalaryIndex ? 18 : 14)
              .width('100%')
              .height(index === this.maxSalaryIndex ? this.itemHeight : 40)
          }
          .opacity((index === this.maxSalaryIndex - 2 || index === this.maxSalaryIndex + 2) ? 0.4 : 41)
          .selectable(false)
        }, (item: number, idx: number) => JSON.stringify(item) + idx)
      }
      .height(200)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
      .friction(0.6)
      .onScrollIndex((start: number) => {
        if (!this.isInitialized) {
          return
        }
        const newIndex = Math.max(0, Math.min(start + 2, this.salaryOptions.length - 1))

        if (this.salaryOptions[newIndex] !== 0) {
          const newMaxValue = this.salaryOptions[newIndex]
          const currentMinValue = this.salaryOptions[this.minSalaryIndex]

          if (newMaxValue >= currentMinValue) {
            this.maxSalaryIndex = newIndex
          } else {
            this.maxScroller.scrollToIndex(this.minSalaryIndex, true, ScrollAlign.CENTER)
          }
        }
      })
      .onScrollStop(() => {
        this.maxScroller.scrollToIndex(this.maxSalaryIndex, true, ScrollAlign.CENTER)
      })

      Column()
        .width('100%')
        .height(this.itemHeight)
        .border({ width: { top: 0.5, bottom: 0.5 }, color: 'rgba(0,0,0,0.2)' })
        .position({ y: 70 })
        .hitTestBehavior(HitTestMode.Transparent)
    }
    .layoutWeight(1)
  }

  @Builder
  buildSalaryPickers() {
    Row() {
      this.buildMinSalaryPicker()
      this.buildMaxSalaryPicker()
    }
    .width('100%')
    .padding({ left: 40, right: 40 })
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  buildActionButtons() {
    Row() {
      Text('取消')
        .fontSize(16)
        .fontColor('#000000')
        .layoutWeight(1)
        .height(44)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.onCancel()
        })

      Divider()
        .vertical(true)
        .height(44)
        .color('#E5E5E5')
        .strokeWidth('1px')

      Text('确定')
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .fontColor('#0A59F7')
        .height(44)
        .onClick(() => {
          const minSalary = this.salaryOptions[this.minSalaryIndex]
          const maxSalary = this.salaryOptions[this.maxSalaryIndex]
          const salary = `${minSalary}K-${maxSalary}K`
          this.onConfirm(salary)
        })
    }
    .width('100%')
    .height(44)
  }

  build() {
    Column() {
      this.buildTitle()
      this.buildSalaryPickers()
      Divider()
        .strokeWidth('1px')
        .margin({ top: 16, bottom: 0 })
      this.buildActionButtons()
    }
    .width('calc(100% - 32vp)')
    .backgroundColor('#FFFFFF')
    .borderRadius(32)
  }
}
