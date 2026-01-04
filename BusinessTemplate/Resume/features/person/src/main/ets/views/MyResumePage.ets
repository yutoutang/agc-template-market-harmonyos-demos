import { getMedia, BreakpointModel } from 'common'
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router'
import { PreferenceUtil } from 'common'
import { TimeUtil } from 'common'
import { TemplateCard, TemplateModel } from 'template'
import { promptAction, AppStorageV2 } from '@kit.ArkUI'
import { MyResumeDetailPageBuilder } from './MyResumeDetailPage'
import { ResumeSnapshotUtil, ResumeItem, FilterTags } from 'resume'
import { ManageBottomBar } from '../comp/ManageBottomBar'
import { DeleteDialogController, DeleteDialogParams } from '../comp/DeleteDialogController'
import { ResumeNameEditDialogController, ResumeNameEditParams } from '../comp/ResumeNameEditDialog'
import { MyResumeRouterParams } from '../viewmodel/MyResumeDetailModel'


@Builder
export function MyResumePageBuilder() {
  MyResumePage()
}

@ComponentV2
export struct MyResumePage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local isManaging: boolean = false
  @Local selectedIds: Array<string> = []
  @Local resumeList: Array<ResumeItem> = []
  @Local editingId: string = ''
  private store: PreferenceUtil = PreferenceUtil.getInstance(undefined, 'resume_store')

  aboutToAppear(): void {
    this.loadData()
  }

  private loadData() {
    const raw = this.store.get('my_resume_list', '[]') as string
    try {
      const list = JSON.parse(raw as string) as Array<ResumeItem>
      // 按更新时间倒序排列（最新的在前面）
      this.resumeList = list.sort((a, b) => b.updatedAt - a.updatedAt)
    } catch (_) {
      this.resumeList = []
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
    if (this.selectedIds.length === this.resumeList.length) {
      this.selectedIds = []
    } else {
      this.selectedIds = this.resumeList.map((it: ResumeItem): string => it.id)
    }
  }

  private confirmDelete() {
    if (this.selectedIds.length === 0) {
      promptAction.showToast({ message: '请先选择要删除的简历' })
      return
    }
    const params: DeleteDialogParams = {
      title: '确认删除?',
      onConfirm: () => {
        this.deleteSelected()
      },
      onCancel: () => {
      }
    }
    DeleteDialogController.openDialog(this.getUIContext(), params)
  }

  private deleteSelected() {
    // 删除选中的简历
    const newList = this.resumeList.filter(it => this.selectedIds.indexOf(it.id) === -1)
    this.resumeList = newList
    this.store.put('my_resume_list', JSON.stringify(this.resumeList))
    this.selectedIds = []
    this.isManaging = false
  }

  private startEdit(item: ResumeItem) {
    this.editingId = item.id
    const params: ResumeNameEditParams = {
      currentName: item.name,
      onConfirm: (name: string) => {
        this.saveEdit(name)
      },
      onCancel: () => {
        this.editingId = ''
      }
    }
    ResumeNameEditDialogController.openDialog(this.getUIContext(), params)
  }

  private saveEdit(name: string) {
    const index = this.resumeList.findIndex(it => it.id === this.editingId)
    if (index !== -1) {
      // 创建新数组触发UI刷新
      const updatedList: Array<ResumeItem> = []
      for (let i = 0; i < this.resumeList.length; i++) {
        if (i === index) {
          // 创建新对象并更新属性
          const updatedItem: ResumeItem = {
            id: this.resumeList[i].id,
            name: name,
            coverColor: this.resumeList[i].coverColor,
            templateStyle: this.resumeList[i].templateStyle,
            filterTags: this.resumeList[i].filterTags,
            updatedAt: Date.now(),
            applied: this.resumeList[i].applied,
            snapshot: this.resumeList[i].snapshot,
            previewImage: this.resumeList[i].previewImage
          }
          updatedList.push(updatedItem)
        } else {
          updatedList.push(this.resumeList[i])
        }
      }
      // 重新排序并更新列表
      this.resumeList = updatedList.sort((a: ResumeItem, b: ResumeItem): number => b.updatedAt - a.updatedAt)
      this.store.put('my_resume_list', JSON.stringify(this.resumeList))
    }
    this.editingId = ''
  }

  private getTemplateCoverMedia(filterTags?: FilterTags): Resource {
    // 根据完整的 filterTags 生成唯一标识
    const industry = filterTags?.industry || ''
    const position = filterTags?.position || ''
    const style = filterTags?.style || ''

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

  // 判断是否为折叠屏
  private isFoldAbleScreen(): boolean {
    const breakpoint = this.breakPointModel.currentBreakpoint
    return breakpoint === 'md' || breakpoint === 'lg' || breakpoint === 'xl'
  }

  // 保存简历（调用工具类）
  saveResume(templateName: string, coverColor: string, templateStyle: string, filterTags?: FilterTags): void {
    const success: boolean = ResumeSnapshotUtil.saveResume(templateName, coverColor, templateStyle, filterTags)
    if (success) {
      // 重新加载列表
      this.loadData()
    }
  }

  private viewTemplate(item: ResumeItem) {
    const vm = TemplateModel.instance

    // 从 templateCards 中找到匹配的模板
    let matchedTemplate: TemplateCard | null = null

    // 如果有 filterTags，尝试精确匹配
    if (item.filterTags) {
      for (const card of vm.templateCards) {
        if (card.filterTags?.industry === item.filterTags.industry &&
          card.filterTags?.position === item.filterTags.position &&
          card.filterTags?.style === item.filterTags.style) {
          matchedTemplate = card
          break
        }
      }
    }

    // 如果没有精确匹配，使用第一个模板作为基础
    if (!matchedTemplate && vm.templateCards.length > 0) {
      matchedTemplate = vm.templateCards[0]
    }

    // 设置选中的模板
    vm.selectedTemplate = matchedTemplate
    vm.setApplied(item.applied === true)

    // 使用 AppStorage 传递参数（包括简历ID）
    AppStorage.setOrCreate('currentResumeName', item.name)
    AppStorage.setOrCreate('currentResumeId', item.id)
    phoneRouterControl.jumpPage({
      pageName: 'MyResumeDetailPage',
      builder: wrapBuilder(MyResumeDetailPageBuilder),
      param: { type: item.filterTags?.style } as MyResumeRouterParams
    })
  }

  // 简历卡片构建器
  @Builder
  resumeCardBuilder(item: ResumeItem) {
    Row() {
      if (this.isManaging) {
        Column() {
          Image(this.selectedIds.indexOf(item.id) !== -1 ? $r('app.media.ic_selected') :
          $r('app.media.ic_notSelected'))
            .width(20)
            .height(20)
            .onClick(() => {
              this.toggleSelect(item.id)
            })
        }
        .width(28)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // 左侧模板图片（优先使用保存的预览图）
      if (item.previewImage) {
        Column() {
          Image('data:image/jpeg;base64,' + item.previewImage)
            .width(75)
            .objectFit(ImageFit.Fill)
        }
        .width(75)
        .height('100%')
        .clip(true)
        .margin({ left: 8, top: 8, bottom: 8 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      } else {
        Image(this.getTemplateCoverMedia(item.filterTags))
          .width(75)
          .height('100%')
          .margin({ left: 8, top: 8, bottom: 8 })
          .borderRadius(8)
          .objectFit(ImageFit.Fill)
          .backgroundColor(item.coverColor)
      }

      // 右侧内容
      Column() {
        // 简历名称和编辑按钮
        Row() {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: '90%' })
          Image($r('app.media.ic_edit'))
            .width(20)
            .height(20)
            .margin({ left: 8 })
            .flexShrink(0)
            .onClick(() => {
              this.startEdit(item)
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)

        Blank()
        // 更新时间
        Text('更新时间:' + TimeUtil.formatDate(item.updatedAt, 'yyyy-MM-dd HH:mm:ss'))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 8 })

        // 查看按钮
        Row() {
          Button({ type: ButtonType.Capsule }) {
            Text('查看').fontSize(14).fontColor('#0A59F7')
          }
          .height(37)
          .width(95)
          .backgroundColor('#E6EEFE')
          .borderRadius(8)
          .onClick(() => {
            this.viewTemplate(item)
          })
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .margin({ left: 8 })
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(128)
    .padding(4)
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .borderRadius(8)
  }

  @Builder
  render() {
    Column() {
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

        Text('我的简历')
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

      Column() {
        if (this.resumeList.length === 0) {
          Column() {
            Text('暂无保存简历')
              .fontSize(18)
              .fontColor($r('sys.color.font_secondary'))
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .height('100%')
        } else {
          Scroll() {
            if (this.isFoldAbleScreen()) {
              // 折叠屏:网格布局，每行2个
              GridRow({ columns: 2, gutter: 16 }) {
                ForEach(this.resumeList, (item: ResumeItem) => {
                  GridCol() {
                    this.resumeCardBuilder(item)
                  }
                  .margin({ bottom: 16 })
                }, (item: ResumeItem) => `${item.id}_${item.name}_${item.updatedAt}`)
              }
              .width('100%')
              .padding({
                bottom: (this.isManaging ? 64 : 0)
              })
            } else {
              // 小屏:列表布局
              Column({ space: 8 }) {
                ForEach(this.resumeList, (item: ResumeItem) => {
                  this.resumeCardBuilder(item)
                }, (item: ResumeItem) => `${item.id}_${item.name}_${item.updatedAt}`)
              }
              .width('100%')
              .padding({
                bottom: (this.isManaging ? 64 : 0)
              })
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
      }
      .width('100%')
      .layoutWeight(1)

      if (this.isManaging) {
        ManageBottomBar({
          selectedCount: this.selectedIds.length,
          totalCount: this.resumeList.length,
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

  build() {
    OHPage({
      pageConfig: new OHPageConfig({
        onPageShow: () => {
          // 从详情页返回时重新加载数据
          this.loadData()
        }
      }),
      childBuilder: () => {
        this.render()
      },
      useSafePadding: true
    })
  }
}
