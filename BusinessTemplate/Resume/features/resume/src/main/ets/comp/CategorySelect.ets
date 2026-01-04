/**
 * 职位选择组件
 * 用于求职意向和公司经历页面的职位选择
 */

import { CommonHeader } from 'common'
import { phoneRouterControl } from 'oh_router'

export interface CategorySelectConfig {
  title: string
  categories: string[]
  subItems: Record<string, string[]>
  searchPlaceholder?: string
  showCustomInput?: boolean
  customInputTitle?: string
  customInputPlaceholder?: string
  freeOption?: string
  groupedDisplay?: boolean
  groupMapping?: Record<string, string[]>
}

export interface CategorySelectParams {
  selected?: string
  config: CategorySelectConfig
  onConfirm: (value: string) => void
}

interface HighlightPart {
  text: string
  isHighlight: boolean
}

@Builder
export function CategorySelectPageBuilder(_param: Object) {
  CategorySelectPage()
}

@ComponentV2
export struct CategorySelectPage {
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local params: CategorySelectParams = {
    selected: '',
    config: {
      title: '',
      categories: [],
      subItems: {}
    },
    onConfirm: () => {
    }
  }
  @Local localSelected: string = ''
  @Local searchText: string = ''
  @Local selectedCategoryIndex: number = 0
  @Local customInput: string = ''
  @Local allItems: string[] = []
  private scroller: Scroller = new Scroller()
  private categoryScroller: Scroller = new Scroller() // 一级分类列表的滚动控制器

  aboutToAppear(): void {
  }

  initSelection() {
    const selected = this.params.selected
    this.localSelected = selected || ''
    if (!selected) {
      return
    }

    // 找到对应的分类并展开
    for (let i = 0; i < this.params.config.categories.length; i++) {
      const category = this.params.config.categories[i]
      const items = this.params.config.subItems[category]
      if (items && items.includes(selected)) {
        this.selectedCategoryIndex = i
        // 自动滚动到选中的分类项（延迟执行以确保UI已渲染）
        setTimeout(() => {
          this.categoryScroller.scrollToIndex(i, true, ScrollAlign.CENTER)
        }, 100)
        break
      }
    }
  }

  initAllItems() {
    const items: string[] = []
    // 遍历subItems的所有值，收集所有可选项
    Object.keys(this.params.config.subItems).forEach((key: string) => {
      const subList = this.params.config.subItems[key]
      if (subList && Array.isArray(subList)) {
        items.push(...subList)
      }
    })
    this.allItems = items
  }

  confirmAndPop(value: string) {
    if (this.params && typeof this.params.onConfirm === 'function') {
      this.params.onConfirm(value)
    }
    phoneRouterControl.popPage()
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.routerModule = context.pathStack
      if (context.pathInfo.param) {
        this.params = context.pathInfo.param as CategorySelectParams
        this.initSelection()
        this.initAllItems()
      }
    })
  }

  @Builder
  render() {
    Column() {
      CommonHeader({
        title: this.params.config.title,
        backgroundColorParam: $r('sys.color.comp_background_list_card'),
        onReturnClick: () => {
          phoneRouterControl.popPage()
        }
      })
        .padding({ left: 16, right: 16 })

      // Search Bar
      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(20)
          .fontColor([$r('sys.color.font_secondary')])
          .margin({ left: 16 })

        TextInput({
          placeholder: this.params.config.searchPlaceholder || '请搜索意向职位',
          text: this.searchText
        })
          .onChange((value: string) => {
            this.searchText = value
          })
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .placeholderColor($r('sys.color.font_secondary'))
      }
      .width('92%')
      .height(40)
      .backgroundColor('#F5F5F5')
      .borderRadius(20)
      .margin({ top: 8, bottom: 8 })
      .padding({ right: 16 })

      Stack() {
        // Main Content
        Row() {
          List({ scroller: this.categoryScroller }) {
            ForEach(this.params.config.categories, (item: string, index: number) => {
              ListItem() {
                Text(item)
                  .fontSize(14)
                  .fontColor(this.selectedCategoryIndex === index ? '#0A59F7' : '#666666')
                  .width('100%')
                  .padding({ left: 16, top: 16, bottom: 16 })
                  .backgroundColor(this.selectedCategoryIndex === index ? $r('sys.color.comp_background_list_card') :
                    '#F5F5F5')
                  .onClick(() => {
                    this.selectedCategoryIndex = index
                  })
              }
            }, (item: string, index: number) => `category-${index}-${item}`)
          }
          .width('30%')
          .height('100%')
          .backgroundColor('#F5F5F5')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

          if (this.isCustomCategory()) {
            this.customCategoryContent()
          } else if (this.params.config.groupedDisplay) {
            this.groupedContent()
          } else {
            this.simpleListContent()
          }
        }
        .width('100%')
        .height('100%')
        .alignItems(VerticalAlign.Top)
        .visibility(this.searchText ? Visibility.None : Visibility.Visible)

        // Search Results
        if (this.searchText) {
          this.searchResults()
        }
      }
      .width('100%')
      .layoutWeight(1)

      // 底部保存按钮（仅在自定义分类时显示）
      if (this.isCustomCategory() && !this.searchText) {
        Button('保存')
          .width('90%')
          .height(44)
          .backgroundColor('#0A59F7')
          .borderRadius(22)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.comp_background_list_card'))
          .enabled(this.customInput.trim().length > 0)
          .margin({
            top: 8,
            bottom: 16,
            left: '5%',
            right: '5%'
          })
          .onClick(() => {
            if (this.customInput.trim()) {
              this.confirmAndPop(this.customInput.trim())
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  isCustomCategory(): boolean {
    return (this.params.config.showCustomInput === true) &&
      this.params.config.categories[this.selectedCategoryIndex] ===
      this.params.config.categories[this.params.config.categories.length - 1]
  }

  @Builder
  customCategoryContent() {
    Column() {
      if (this.params.config.customInputTitle) {
        Text(this.params.config.customInputTitle)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .margin({ bottom: 16 })
      }

      TextInput({
        placeholder: this.params.config.customInputPlaceholder || '请输入职位名称',
        text: this.customInput,
      })
        .onChange((value: string) => {
          this.customInput = value
        })
        .maxLength(12)
        .height(40)
        .width('100%')
        .backgroundColor('#F5F7FA')
        .borderRadius(4)
        .margin({ bottom: 8 })
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .placeholderColor($r('sys.color.font_secondary'))

      if (this.params.config.freeOption) {
        Text(this.params.config.freeOption)
          .fontSize(14)
          .fontColor(this.localSelected === this.params.config.freeOption ? '#0A59F7' : '#666666')
          .width('100%')
          .borderRadius(4)
          .padding({ left: 16, top: 16, bottom: 16 })
          .backgroundColor(this.localSelected === this.params.config.freeOption ? '#E6F0FF' : '#F5F5F5')
          .onClick(() => {
            this.confirmAndPop(this.params.config.freeOption!)
          })
      }

      if (this.customInput.length >= 12) {
        Text('限制12字')
          .fontSize(14)
          .lineHeight(16)
          .fontWeight(400)
          .width('100%')
          .fontColor($r('sys.color.warning'))
          .textAlign(TextAlign.Start)
          .margin({ top: 12 })
      }
    }
    .layoutWeight(1)
    .height('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  @Builder
  groupedContent() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          ForEach(this.getSubItems(), (groupName: string, groupIndex: number) => {
            Column() {
              // 分组标题
              Text(groupName)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%')
                .padding({ top: groupIndex === 0 ? 0 : 16, bottom: 12 })

              // 职位网格布局（每行2个）
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                ForEach(this.filterSubItems(groupName), (item: string, itemIndex: number) => {
                  Text(item)
                    .fontSize(14)
                    .fontColor(this.localSelected === item ? '#0A59F7' : '#666666')
                    .width('48%')
                    .padding({ top: 12, bottom: 12 })
                    .borderRadius(8)
                    .textAlign(TextAlign.Center)
                    .backgroundColor(this.localSelected === item ? '#E6F0FF' : '#F5F5F5')
                    .borderRadius(4)
                    .margin({ bottom: 12 })
                    .onClick(() => {
                      this.confirmAndPop(item)
                    })
                }, (item: string, itemIndex: number) => `subitem-${groupName}-${itemIndex}-${item}`)
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }, (groupName: string, groupIndex: number) => `group-${groupIndex}-${groupName}`)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollable(ScrollDirection.Vertical)
      .align(Alignment.TopStart)
      .id(`scroll_${this.selectedCategoryIndex}`)
    }
    .layoutWeight(1)
    .height('100%')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  simpleListContent() {
    List() {
      ForEach(this.getSubItems(), (groupName: string, groupIndex: number) => {
        ListItemGroup({ header: this.groupHeader(groupName) }) {
          ForEach(this.filterSubItems(groupName), (item: string, itemIndex: number) => {
            ListItem() {
              Text(item)
                .fontSize(14)
                .fontColor(this.localSelected === item ? '#0A59F7' : '#333333')
                .width('100%')
                .padding({ top: 12, bottom: 12 })
                .textAlign(TextAlign.Center)
                .backgroundColor(this.localSelected === item ? '#E6F0FF' : '#F5F7FA')
                .borderRadius(4)
                .margin({ bottom: 8 })
                .onClick(() => {
                  this.confirmAndPop(item)
                })
            }
          }, (item: string, itemIndex: number) => `simple-item-${groupName}-${itemIndex}-${item}`)
        }
      }, (groupName: string, groupIndex: number) => `simple-group-${groupIndex}-${groupName}`)
    }
    .layoutWeight(1)
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  getFilteredItems(): string[] {
    return this.allItems.filter(p => p.toLowerCase().includes(this.searchText.toLowerCase()))
  }

  @Builder
  searchResults() {
    if (this.getFilteredItems().length === 0) {
      // 无搜索结果展示
      Column() {
        Image($r('app.media.ic_notFound'))
          .width(120)
          .height(120)
          .margin({ left: 16, top: 120 })
        Text('暂无相关内容')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    } else {
      // 搜索列表展示
      List() {
        ForEach(this.getFilteredItems(),
          (item: string, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  this.buildHighlightText(item, this.searchText)
                }
                .width('100%')
                .padding({ top: 16, bottom: 16 })

                Divider().color($r('sys.color.comp_divider'))
              }
              .width('100%')
              .backgroundColor(Color.White)
              .onClick(() => {
                this.confirmAndPop(item)
              })
            }
          }, (item: string, index: number) => `search-${index}-${item}`)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }

  // 高亮显示搜索关键词
  @Builder
  buildHighlightText(text: string, keyword: string) {
    if (!keyword || keyword.trim() === '') {
      Text(text)
        .fontSize(16)
        .fontColor('#333333')
    } else {
      Row() {
        ForEach(this.getHighlightParts(text, keyword), (part: HighlightPart) => {
          Text(part.text)
            .fontSize(16)
            .fontColor(part.isHighlight ? '#0A59F7' : '#333333')
        }, (part: HighlightPart, idx: number) => `${idx}-${part.text}`)
      }
    }
  }

  // 获取高亮分段
  getHighlightParts(text: string, keyword: string): Array<HighlightPart> {
    const lowerText = text.toLowerCase()
    const lowerKeyword = keyword.toLowerCase()
    const index = lowerText.indexOf(lowerKeyword)
    const result: Array<HighlightPart> = []

    if (index >= 0) {
      if (index > 0) {
        const part1: HighlightPart = { text: text.substring(0, index), isHighlight: false }
        result.push(part1)
      }
      const part2: HighlightPart = { text: text.substring(index, index + keyword.length), isHighlight: true }
      result.push(part2)
      if (index + keyword.length < text.length) {
        const part3: HighlightPart = { text: text.substring(index + keyword.length), isHighlight: false }
        result.push(part3)
      }
    } else {
      const part: HighlightPart = { text: text, isHighlight: false }
      result.push(part)
    }

    return result
  }

  @Builder
  groupHeader(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#333333')
      .width('100%')
      .padding({ top: 16, bottom: 12 })
      .backgroundColor(Color.White)
  }

  getSubItems(): string[] {
    const currentCategory = this.params.config.categories[this.selectedCategoryIndex]
    if (this.params.config.groupMapping && this.params.config.groupMapping[currentCategory]) {
      return this.params.config.groupMapping[currentCategory]
    }
    return [currentCategory]
  }

  filterSubItems(group: string): string[] {
    return this.params.config.subItems[group] || []
  }
}
