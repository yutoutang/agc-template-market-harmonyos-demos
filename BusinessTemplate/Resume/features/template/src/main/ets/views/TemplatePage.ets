/**
 * 模板列表页面
 * 展示所有可用的简历模板,支持筛选、搜索和查看模板详情
 */

import { RouterMap, getMedia, BreakpointModel, BarVM } from 'common';
import { phoneRouterControl } from 'oh_router';
import { SearchPageBuilder } from './SearchPage';
import { TemplateDetailPageBuilder } from './TemplateDetailPage';
import { TemplateModel } from '../viewsmodel/TemplateModel';
import { TemplateCard } from '../viewsmodel/TemplateModel';
import { FilterSheetContent } from '../comp/FilterSheet';
import { AppStorageV2 } from '@kit.ArkUI';
import { SearchController } from '../viewsmodel/SearchModel';

@Builder
export function TemplatePageBuilder() {
  TemplatePage()
}

@ComponentV2
export struct TemplatePage {
  templateModelVM: TemplateModel = TemplateModel.instance;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local buttonState: boolean = false
  @Local isFilterSheetVisible: boolean = false
  @Local filterPanelTop: number = 0
  @Local filterPanelHeight: number = 0
  @Local filterCount: number = 0 // 筛选条件数量

  private getTemplateCoverMedia(item: TemplateCard): Resource {
    // 根据完整的 filterTags 生成唯一标识
    const industry = item?.filterTags?.industry || ''
    const position = item?.filterTags?.position || ''
    const style = item?.filterTags?.style || ''

    // 生成唯一标识：行业-岗位-风格
    const templateKey = `${industry}-${position}-${style}`

    // 根据唯一标识精确匹配模板图片
    if (templateKey === '互联网-人力资源专员/助理-简约') {
      return getMedia('app.media.ic_templateExampleOne')
    }
    if (templateKey === '电子商务-行政专员/助理-大气') {
      return getMedia('app.media.ic_templateExampleTwo')
    }

    // 默认返回第一个模板
    return getMedia('app.media.ic_templateExampleOne')
  }

  // 根据断点获取列数
  private getColumnsTemplate(): string {
    const breakpoint = this.breakPointModel.currentBreakpoint
    // 中屏及以上使用4列，小屏使用2列
    return (breakpoint === 'md' || breakpoint === 'lg' || breakpoint === 'xl') ? '1fr 1fr 1fr 1fr' : '1fr 1fr'
  }

  // 根据断点获取卡片高度
  private getCardHeight(): number {
    const breakpoint = this.breakPointModel.currentBreakpoint
    if (breakpoint === 'lg' || breakpoint === 'xl') {
      return 280
    } else if (breakpoint === 'md') {
      // 折叠屏4列布局，适当增加高度保持宽高比
      return 240
    }
    return 250
  }

  aboutToAppear() {
    // 初始化筛选数量
    const savedItems = AppStorage.get<string[]>('filterSelectedItems')
    this.filterCount = savedItems?.length || 0
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Column() {
            Column() {
              Row() {
                Blank().width(this.breakPointModel.pagePadding)
                Row() {
                  Stack() {
                    Row() {
                    }
                    .height(40)
                    .width('100%')
                    .backgroundColor('#FFF4F4F6')
                    .borderRadius(20)

                    Row() {
                      Image($r('app.media.ic_search'))
                        .zIndex(1)
                        .width(24)
                        .height(24)
                        .margin({ left: 16 })

                      Text('请输入搜索内容')
                        .fontColor($r('sys.color.font_tertiary'))
                        .textAlign(TextAlign.Center)
                        .margin({ left: 8 })
                    }
                  }
                  .align(Alignment.Start)
                }
                .width('100%')
                .layoutWeight(1)

                Blank().width(this.breakPointModel.pagePadding)
              }
              .margin({ top: 8 })
            }
            .width('100%')
            .onClick(() => {
              // 清除之前的搜索关键词
              SearchController.instance.searchCondition = '';
              SearchController.instance.isShowResult = false;
              // 恢复到筛选状态:如果有筛选条件则显示筛选结果，否则显示全部
              const savedItems = AppStorage.get<string[]>('filterSelectedItems')
              if (savedItems && savedItems.length > 0) {
                // 有筛选条件，重新应用筛选
                this.templateModelVM.applyFilterByTags(savedItems)
              } else {
                // 无筛选条件，显示全部模板
                this.templateModelVM.applyFilter('')
              }
              phoneRouterControl.jumpPage({
                pageName: RouterMap.SEARCH_PAGE,
                builder: wrapBuilder(SearchPageBuilder)
              });
            })

            Row() {
              Blank().width(this.breakPointModel.pagePadding)
              Row() {
                Text('推荐')
                  .fontSize(18)
                  .fontWeight(700)
                  .fontColor('#E5000000')
                  .lineHeight(21)
                Button({ type: ButtonType.Normal, stateEffect: true }) {
                  Text(this.filterCount > 0 ? `筛选·${this.filterCount}` : '筛选')
                    .fontSize(12)
                    .lineHeight(14)
                    .fontWeight(400)
                    .fontColor(this.filterCount > 0 ? '#0A59F7 ' : '#99000000')
                }
                .backgroundColor(this.filterCount > 0 ? '#F5F9FF' : '#F5F5F5')
                .borderRadius(4)
                .width(this.filterCount > 9 ? 70 : 62)
                .height(28)
                .padding({ left: 12, right: 12 })
                .onClick(() => {
                  this.isFilterSheetVisible = !this.isFilterSheetVisible
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .layoutWeight(1)

              Blank().width(this.breakPointModel.pagePadding)
            }
            .height(49)
            .id('filterTriggerRow')
            .onAreaChange((_oldValue: Area, newValue: Area) => {
              const position = newValue.position as Position
              const height = newValue.height as number
              this.filterPanelTop = (position.y as number) + height
            })

            Column() {
              if (this.templateModelVM.filteredTemplateCards.length === 0) {
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
                WaterFlow({ layoutMode: WaterFlowLayoutMode.SLIDING_WINDOW }) {
                  ForEach(this.templateModelVM.filteredTemplateCards, (item: TemplateCard) => {
                    FlowItem() {
                      Column() {
                        Image(this.getTemplateCoverMedia(item))
                          .height(this.getCardHeight())
                          .objectFit(ImageFit.Fill)
                          .borderRadius(8)
                          .border({ width: 1, color: '#E5E7E9' })
                          .backgroundColor(item.coverColor)

                        Text(item.name)
                          .fontSize(14)
                          .fontWeight(400)
                          .lineHeight(16)
                          .margin({ top: 8 })
                          .textAlign(TextAlign.Center)
                          .fontColor($r('sys.color.mask_secondary'))
                      }
                      .id(item.name)
                      .onClick(() => {
                        this.templateModelVM.selectedTemplate = item
                        phoneRouterControl.jumpPage({
                          pageName: RouterMap.TEMPLATE_DETAIL_PAGE,
                          builder: wrapBuilder(TemplateDetailPageBuilder)
                        })
                      })
                    }
                    .margin({ top: 8 })
                  }, (item: TemplateCard) => item.name)
                }
                .width('100%')
                .height('100%')
                .layoutWeight(1)
                .columnsTemplate(this.getColumnsTemplate())
                .rowsGap(16)
                .columnsGap(8)
                .padding({
                  left: this.breakPointModel.pagePadding,
                  right: this.breakPointModel.pagePadding,
                  bottom: 96
                })
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
              }
            }
            .backgroundColor('#FFF1F3F5')
          }
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .width('100%')
          .height('100%')

          if (this.isFilterSheetVisible) {
            Column() {
              Column() {
                FilterSheetContent({
                  onConfirm: (selectedItems: string[]) => {
                    this.templateModelVM.applyFilterByTags(selectedItems)
                    this.filterCount = selectedItems.length
                    this.isFilterSheetVisible = false
                  },
                  onReset: () => {
                    this.templateModelVM.applyFilterByTags([])
                    this.filterCount = 0
                  },
                  onDismiss: () => {
                    this.isFilterSheetVisible = false
                  },
                  onSelectionChange: (count: number) => {
                    this.filterCount = count
                  }
                })
              }
              .width('100%')

              Column()
                .width('100%')
                .layoutWeight(1)
                .backgroundColor('rgba(0, 0, 0, 0.5)')
                .onClick(() => {
                  this.isFilterSheetVisible = false
                })
            }
            .width('100%')
            .position({ x: 0, y: this.filterPanelTop })
            .constraintSize({ minHeight: 0, maxHeight: `calc(100% - ${this.filterPanelTop}px)` })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .alignContent(Alignment.TopStart)
      }
      .width('100%')
      .height('100%')
    }
    .onBackPressed(() => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.SEARCH_PAGE,
        builder: wrapBuilder(SearchPageBuilder)
      })
      return true
    })
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}
