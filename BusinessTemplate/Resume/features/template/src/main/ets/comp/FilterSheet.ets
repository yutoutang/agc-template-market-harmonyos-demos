/**
 * 筛选面板组件
 * 用于模板页面的半模态筛选弹窗,支持按行业、职位、风格等条件筛选模板
 */

import { promptAction } from '@kit.ArkUI'

interface FilterTemplateInfo {
  id: number;
  title: string;
  isGroupTitle?: boolean;
}

interface TemplateCategory {
  id: number;
  name: string;
  templateList: FilterTemplateInfo[];
}

// 半模态筛选弹窗内容组件
@ComponentV2
export struct FilterSheetContent {
  @Param onConfirm: (selectedItems: string[]) => void = () => {
  }
  @Param onReset: () => void = () => {
  }
  @Param onDismiss: () => void = () => {
  }
  @Param onSelectionChange: (count: number) => void = () => {
  }
  @Local currentIndex: number = 0
  @Local selectedItems: Set<string> = new Set()

  aboutToAppear() {
    const savedItems = AppStorage.get<string[]>('filterSelectedItems')
    if (savedItems && savedItems.length > 0) {
      this.selectedItems = new Set(savedItems)
    }
  }

  private createItem(id: number, title: string, isGroupTitle: boolean = false): FilterTemplateInfo {
    return {
      id,
      title,
      isGroupTitle
    }
  }

  @Local templateCategoryList: TemplateCategory[] = [
    {
      id: 1001,
      name: '行业类型',
      templateList: [
        this.createItem(1, '互联网/AI', true),
        this.createItem(2, '互联网'),
        this.createItem(3, '电子商务'),
        this.createItem(4, '计算机软件'),
        this.createItem(5, '生活服务(O2O)'),
        this.createItem(6, '企业服务'),
        this.createItem(7, '医疗健康'),
        this.createItem(8, '电子/通信/半导体', true),
        this.createItem(9, '半导体/芯片'),
        this.createItem(10, '电子/硬件开发'),
        this.createItem(11, '通信/网络设备'),
        this.createItem(12, '计算机硬件'),
        this.createItem(13, '运营商/增值服务'),
        this.createItem(14, '服务业', true),
        this.createItem(15, '餐饮'),
        this.createItem(16, '电子/美容'),
        this.createItem(17, '酒店/民宿'),
        this.createItem(18, '休闲/娱乐'),
      ],
    },
    {
      id: 1002,
      name: '岗位',
      templateList: [
        this.createItem(1, '人力资源', true),
        this.createItem(2, '人力资源专员/助理'),
        this.createItem(3, '人力资源经理/主管'),
        this.createItem(4, '人力资源总监'),
        this.createItem(5, '招聘'),
        this.createItem(6, 'HRBP'),
        this.createItem(7, '培训'),
        this.createItem(8, '员工关系'),
        this.createItem(9, '组织发展'),
        this.createItem(10, '企业文化'),
        this.createItem(11, '猎头顾问'),
        this.createItem(12, '行政', true),
        this.createItem(13, '行政专员/助理'),
        this.createItem(14, '行政经理/主管'),
        this.createItem(15, '行政总监'),
        this.createItem(16, '前台'),
        this.createItem(17, '后勤'),
        this.createItem(18, '经理助理'),
      ],
    },
    {
      id: 1003,
      name: '风格',
      templateList: [
        this.createItem(1, '极简风', true),
        this.createItem(2, '简约'),
        this.createItem(3, '大气'),
        this.createItem(4, '留白'),
        this.createItem(5, '文艺'),
        this.createItem(6, '商务'),
        this.createItem(7, '扁平化', true),
        this.createItem(8, '单调'),
        this.createItem(9, '色块'),
        this.createItem(10, '色彩搭配'),
        this.createItem(11, '造型'),
        this.createItem(12, '手绘', true),
        this.createItem(13, '原创'),
        this.createItem(14, '个性'),
        this.createItem(15, '效果'),
        this.createItem(16, '张力'),
      ],
    },
  ];

  build() {
    Column() {
      Row() {
        Column() {
          List() {
            ForEach(this.templateCategoryList, (category: TemplateCategory, index: number) => {
              ListItem() {
                Text(category.name)
                  .fontSize(14)
                  .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular)
                  .fontColor(this.currentIndex === index ? $r('sys.color.black') : 'rgba(0, 0, 0, 0.60)')
                  .width('100%')
                  .height(48)
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.currentIndex === index ? $r('sys.color.comp_background_list_card') :
                    'transparent')
              }
              .onClick(() => {
                this.currentIndex = index
              })
            }, (category: TemplateCategory, index: number) => `category-${index}`)
          }
          .width('100%')
          .height('100%')
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          .scrollBar(BarState.Off)
        }
        .width(100)
        .height('100%')
        .backgroundColor('#F5F5F5')

        Scroll() {
          Column() {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween, alignContent: FlexAlign.Start }) {
              ForEach(this.templateCategoryList[this.currentIndex].templateList,
                (listItem: FilterTemplateInfo, index: number) => {
                  if (listItem.isGroupTitle) {
                    Text(listItem.title)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('sys.color.black'))
                      .width('100%')
                      .margin({ top: index === 0 ? 0 : 16, bottom: 8 })
                  } else {
                    Column() {
                      Text(listItem.title)
                        .fontSize(14)
                        .fontWeight(400)
                        .fontColor(
                          this.selectedItems.has(`${this.templateCategoryList[this.currentIndex].name}_${listItem.title}`)
                            ? '#0A59F7'
                            : '#99000000')
                        .textAlign(TextAlign.Center)
                        .width('100%')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width('48%')
                    .height(38)
                    .backgroundColor(
                      this.selectedItems.has(`${this.templateCategoryList[this.currentIndex].name}_${listItem.title}`)
                        ? '#1a0a59f7'
                        : '#f0f0f0')
                    .borderRadius(8)
                    .justifyContent(FlexAlign.Center)
                    .margin({ bottom: 8 })
                    .onClick(() => {
                      const key = `${this.templateCategoryList[this.currentIndex].name}_${listItem.title}`
                      if (this.selectedItems.has(key)) {
                        this.selectedItems.delete(key)
                      } else {
                        this.selectedItems.add(key)
                      }
                      this.selectedItems = new Set(this.selectedItems)
                      this.onSelectionChange(this.selectedItems.size)
                    })
                  }
                }, (listItem: FilterTemplateInfo, index: number) => `${this.currentIndex}-${index}-${listItem.title}`)
            }
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .height('100%')
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .align(Alignment.TopStart)
        .backgroundColor($r('sys.color.comp_background_list_card'))
      }
      .layoutWeight(1)
      .width('100%')

      Row() {
        Row() {
          Text('重置')
            .fontSize(14)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#e5e7e9')
        .borderRadius('50%')
        .onClick(() => {
          this.selectedItems.clear()
          this.selectedItems = new Set()
          AppStorage.setOrCreate('filterSelectedItems', [])
          AppStorage.setOrCreate('filterAppliedTimestamp', Date.now())
          this.onSelectionChange(0)
          this.onReset()
          promptAction.showToast({
            message: '已重置筛选',
            duration: 1000
          })
        })

        Row() {
          Text('确定')
            .fontSize(14)
            .fontColor($r('sys.color.comp_background_list_card'))
        }
        .layoutWeight(3)
        .height(40)
        .margin({ left: 10 })
        .backgroundColor('#0a59f7')
        .borderRadius('50%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          const selectedCount = this.selectedItems.size
          const selectedArray = Array.from(this.selectedItems)
          AppStorage.setOrCreate('filterSelectedItems', selectedArray)
          AppStorage.setOrCreate('filterAppliedTimestamp', Date.now())
          this.onConfirm(selectedArray)
          this.onDismiss()
          if (selectedCount > 0) {
            promptAction.showToast({
              message: `已应用 ${selectedCount} 个筛选条件`,
              duration: 1000
            })
          }
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
      .margin({ top: 12 })
    }
    .width('100%')
    .constraintSize({ maxHeight: '70%' })
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}
