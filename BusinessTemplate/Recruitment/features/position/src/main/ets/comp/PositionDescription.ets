@ComponentV2
export struct PositionDescription {
  // 基础参数
  @Param title: string = '职位描述'
  @Param tags?: string[] = ['移动端/APP设计', '互联网', '前端技术开发', '广告视觉创意设计走查']
  @Param responsibilitiesTitle: string = '岗位职责：'
  @Param description: string = ''
  // 展开/收起控制
  @Local private isExpanded: boolean = false
  @Local private needExpand: boolean = false // 是否需要展开按钮
  private textHeight: number = 0 // 文本实际高度
  private maxHeight: number = 0 // 10行的最大高度
  // 样式参数
  @Param titleColor?: ResourceColor = '#333333'
  @Param tagTextColor?: ResourceColor = '#666666'
  @Param tagBgColor?: ResourceColor = '#F5F5F5'
  @Param descriptionTitleColor?: ResourceColor = '#333333'
  @Param descriptionTextColor?: ResourceColor = '#666666'
  @Param expandTextColor?: ResourceColor = '#5B6FFF'

  build() {
    Column() {
      Column() {

      }
      .width('100%')
      .height('1px')
      .backgroundColor('#EFEFEF')
      .margin({
        bottom: 16
      })

      // 标题
      Text(this.title)
        .fontSize(18)
        .fontColor(this.titleColor)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      // 标签区域
      if (this.tags && this.tags.length > 0) {
        this.buildTagsSection()
      }

      // 职责描述
      Text(this.responsibilitiesTitle)
        .fontSize(14)
        .fontColor(this.descriptionTitleColor)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16 })
        .width('100%')

      Text(this.getJobDescription())
        .fontSize(14)
        .fontColor(this.descriptionTextColor)
        .lineHeight(24)
        .margin({ top: 4})
        .maxLines(this.isExpanded ? 999 : 10)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .onAreaChange((oldValue: Area, newValue: Area) => {
          // 计算10行的高度：lineHeight(24) * maxLines(10)
          this.maxHeight = 24 * 10
          this.textHeight = Number(newValue.height)
          // 如果文本实际高度大于10行高度，显示展开按钮
          this.needExpand = this.textHeight >= this.maxHeight
        })

      // 展开/收起按钮（仅在需要时显示）
      if (this.needExpand) {
        Row() {
          Text(this.isExpanded ? '收起' : '查看全部')
            .fontSize(14)
            .fontColor(this.expandTextColor)
            .margin({ top: 8 })
            .onClick(() => {
              this.isExpanded = !this.isExpanded
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }

      Column() {

      }
      .width('100%')
      .height('1px')
      .backgroundColor('#EFEFEF')
      .alignItems(HorizontalAlign.Start)
      .margin({
        top: 16
      })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16
    })
    .backgroundColor('#ffffff')

  }

  @Builder
  private buildTagsSection() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.tags!, (tag: string, index: number) => {
        Text(tag)
          .fontSize(12)
          .fontColor(this.tagTextColor)
          .padding({
            left: 12,
            right: 12,
            top: 6,
            bottom: 6
          })
          .backgroundColor(this.tagBgColor)
          .borderRadius(4)
          .margin({
            right: 8,
            top: 12
          })
      }, (item: string, index: number) => `${JSON.stringify(item)}_${index}}`)
    }
    .width('100%')
  }

  getJobDescription(): string {
    return '1. 学历与专业\n' +
      '通常要求本科及以上学历，计算机科学、软件工程、电子信息等相关专业。\n' +
      '2. 专业知识与技能\n' +
      '测试理论：扎实的软件测试基础，熟悉软件测试流程、方法和理论（如黑盒、白盒测试）。\n' +
      '自动化测试：有自动化测试经验者优先，熟悉Selenium、Appium等主流自动化测试框架和工具。\n' +
      '性能测试（可选）：了解性能测试基本原理，有使用JMeter、LoadRunner等工具经验者优先。\n' +
      '编程语言：掌握至少一门编程语言，如Java、Python或C++。\n' +
      '3. 经验与能力\n' +
      '具备（请按需填写，如：1-3年）及以上软件测试工作经验。';
  }
}

