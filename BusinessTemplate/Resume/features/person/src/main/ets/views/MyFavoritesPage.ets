import { PreferenceUtil, RouterMap, getMedia, BreakpointModel } from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { TemplateModel, TemplateDetailPageBuilder } from 'template'
import { ManageBottomBar } from '../comp/ManageBottomBar'
import { DeleteDialogController, DeleteDialogParams } from '../comp/DeleteDialogController'
import { promptAction, AppStorageV2 } from '@kit.ArkUI'
import { FilterTags } from 'resume'

@Builder
export function FavoritesPageBuilder() {
  FavoritesPage()
}

@ComponentV2
export struct FavoritesPage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local isManaging: boolean = false
  @Local selectedIds: Array<string> = []
  @Local favoriteList: Array<FavoriteItem> = []
  @Local forceUpdate: number = 0
  @Local favoriteUpdateTimestamp: number = 0
  private store: PreferenceUtil = PreferenceUtil.getInstance(undefined, 'favorite_store')
  private checkTimer: number = -1

  aboutToAppear(): void {
    this.loadData()
    this.startCheckTimer()
  }

  aboutToDisappear(): void {
    this.stopCheckTimer()
  }

  private startCheckTimer() {
    // 每500ms检查一次AppStorage中的时间戳变化
    this.checkTimer = setInterval(() => {
      this.checkFavoriteUpdate()
    }, 500)
  }

  private stopCheckTimer() {
    if (this.checkTimer !== -1) {
      clearInterval(this.checkTimer)
      this.checkTimer = -1
    }
  }

  private checkFavoriteUpdate() {
    // 检查AppStorage中的更新时间戳
    const timestamp = AppStorage.get<number>('favoriteUpdateTimestamp') || 0
    if (timestamp > this.favoriteUpdateTimestamp) {
      this.favoriteUpdateTimestamp = timestamp
      this.loadData()
    }
  }

  private loadData() {
    // 强制重新获取store实例，清除缓存
    // 注意:由于PreferenceUtil使用单例模式，需要确保获取最新数据
    const store = PreferenceUtil.getInstance(undefined, 'favorite_store')
    const raw = store.get('my_favorites_list', '[]') as string
    try {
      const newList = JSON.parse(raw as string) as Array<FavoriteItem>
      // 使用新数组引用，确保触发响应式更新
      this.favoriteList = [...newList]
      this.forceUpdate++
    } catch (e) {
      this.favoriteList = []
    }
  }

  private toggleManage() {
    this.isManaging = !this.isManaging
    if (!this.isManaging) {
      this.selectedIds = []
    }
  }

  private toggleSelect(id: string) {
    const i = this.selectedIds.indexOf(id)
    if (i !== -1) {
      this.selectedIds.splice(i, 1)
    } else {
      this.selectedIds.push(id)
    }
  }

  private selectAll(): void {
    // 如果当前已经是全选状态，则取消全选；否则全选
    if (this.selectedIds.length === this.favoriteList.length) {
      this.selectedIds = []
    } else {
      this.selectedIds = this.favoriteList.map(it => it.id)
    }
  }

  private confirmDelete() {
    if (this.selectedIds.length === 0) {
      promptAction.showToast({ message: '请先选择要删除的收藏' })
      return
    }
    const params: DeleteDialogParams = {
      title: '确认删除?',
      onConfirm: () => {
        this.deleteSelected()
      },
      onCancel: () => {}
    }
    DeleteDialogController.openDialog(this.getUIContext(), params)
  }

  private deleteSelected() {
    const newList = this.favoriteList.filter(it => this.selectedIds.indexOf(it.id) === -1)
    this.favoriteList = newList
    this.store.put('my_favorites_list', JSON.stringify(this.favoriteList))
    this.selectedIds = []
    this.isManaging = false
  }

  private getTemplateCoverMedia(name: string): Resource {
    if (name.includes('大气')) {
      return getMedia('app.media.ic_templateExampleTwo')
    }
    if (name.includes('简约')) {
      return getMedia('app.media.ic_templateExampleOne')
    }
    return getMedia('app.media.ic_templateExampleOne')
  }

  // 根据断点获取列数
  private getColumns(): number {
    const breakpoint = this.breakPointModel.currentBreakpoint
    // 中屏及以上使用4列，小屏使用2列
    return (breakpoint === 'md' || breakpoint === 'lg' || breakpoint === 'xl') ? 4 : 2
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
    return 240
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: true,
    })
  }

  @Builder
  render() {
    Column() {
      // 顶部导航栏
      Row() {
        Row() {
          Image($r('app.media.chevron_backward'))
            .width(24)
            .height(24)
            .onClick(() => {
              phoneRouterControl.popPage()
            })
        }
        .width(40)
        .height(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .padding(8)
        .borderRadius(40)

        Text('我的收藏')
          .fontSize(20)
          .fontWeight(700)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: 8 })

        Blank()

        Text(this.isManaging ? '取消管理' : '管理')
          .fontSize(16)
          .fontColor('#0A59F7')
          .onClick(() => {
            this.toggleManage()
          })
      }
      .width('100%')
      .height(56)

      // 内容区域
      Column() {
        if (this.favoriteList.length === 0) {
          Column() {
            Text('暂无收藏')
              .fontSize(18)
              .fontColor($r('sys.color.font_secondary'))
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .height('100%')
        } else {
          Scroll() {
            GridRow({ columns: this.getColumns(), gutter: 16 }) {
              ForEach(this.favoriteList, (item: FavoriteItem) => {
                GridCol() {
                  Column() {
                    Stack({ alignContent: Alignment.TopEnd }) {
                      // 模板预览图
                      Image(this.getTemplateCoverMedia(item.name))
                        .width('100%')
                        .height(this.getCardHeight())
                        .objectFit(ImageFit.Fill)
                        .borderRadius(8)

                      // 管理模式下的选中标记
                      if (this.isManaging) {
                        Image(this.selectedIds.indexOf(item.id) !== -1 ?
                        $r('app.media.ic_selected') : $r('app.media.ic_notSelected'))
                          .width(24)
                          .height(24)
                          .margin({ top: 8, right: 8 })
                          .onClick(() => {
                            this.toggleSelect(item.id)
                          })
                      }
                    }
                    .width('100%')

                    // 模板名称
                    Text(item.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 8 })
                  }
                  .width('100%')
                  .onClick(() => {
                    if (this.isManaging) {
                      this.toggleSelect(item.id)
                      return
                    }
                    const vm = TemplateModel.instance
                    vm.selectedTemplate = {
                      name: item.name,
                      coverColor: item.coverColor,
                      filterTags: item.filterTags
                    }
                    phoneRouterControl.jumpPage({
                      pageName: RouterMap.TEMPLATE_DETAIL_PAGE,
                      builder: wrapBuilder(TemplateDetailPageBuilder)
                    })
                  })
                }
                .margin({ bottom: 16 })
              }, (item: FavoriteItem) => `${item.id}_${item.name}_${this.forceUpdate}`)
            }
            .width('100%')
            .padding({
              bottom: (this.isManaging ? 64 : 0)
            })
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
      }
      .width('100%')
      .layoutWeight(1)

      // 管理模式底部栏
      if (this.isManaging) {
        ManageBottomBar({
          selectedCount: this.selectedIds.length,
          totalCount: this.favoriteList.length,
          onSelectAll: () => {
            this.selectAll()
          },
          onDelete: () => {
            this.confirmDelete()
          }
        })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

interface FavoriteItem {
  id: string
  name: string
  coverColor: string
  updatedAt: number
  filterTags?: FilterTags
}
