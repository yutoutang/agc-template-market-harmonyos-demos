import { UIContext, KeyboardAvoidMode } from '@kit.ArkUI';
import { TitleBar } from '../components/TitleBar';
import { CareerObjectiveModel } from '../viewmodel/CareerObjectiveModel'
import { WorkExperienceModel } from '../viewmodel/WorkExperienceModel'

export interface IndustrySelectParams {
  selected: string[]
  onConfirm: (values: string[]) => void
  source?: string // 标识来源页面:'work' 或 'career'
}

@Builder
export function IndustrySelectPageBuilder(_param: Object) {
  IndustrySelectPage()
}

@ComponentV2
export struct IndustrySelectPage {
  @Local navPathStack: NavPathStack = new NavPathStack();
  private uiContext: UIContext = this.getUIContext();
  private cacheKeyboardAvoidMode: KeyboardAvoidMode = KeyboardAvoidMode.OFFSET;
  private params: IndustrySelectParams = {
    selected: [], onConfirm: () => {
    }
  }
  @Local expandedGroups: string[] = [] // 默认不展开任何分组
  @Local selectedItems: string[] = []
  private industries: Record<string, string[]> = {
    '互联网/AI': ['软件开发', '人工智能', '互联网服务'],
    '电子/通信/半导体': ['电子', '通信', '半导体'],
    '消费品/批发/零售': ['消费品', '零售'],
    '房地产/建筑': ['房地产', '建筑'],
    '教育培训': ['培训/辅导机构', '职业培训', '学前教育', '学校/学历教育', '学术/科研'],
    '广告/传媒/文化/体育': ['广告', '传媒'],
    '制造业': ['制造'],
    '专业服务': ['咨询', '法律'],
    '制药/医疗': ['制药', '医疗']
  }
  private groupKeys: string[] = [
    '互联网/AI', '电子/通信/半导体', '消费品/批发/零售', '房地产/建筑',
    '教育培训', '广告/传媒/文化/体育', '制造业', '专业服务', '制药/医疗'
  ]

  initSelection() {
    if (this.params.selected && this.params.selected.length > 0) {
      this.selectedItems = [...this.params.selected]
      // 根据已选中的项目，自动展开对应的分组
      const groupsToExpand = new Set<string>()
      this.selectedItems.forEach(item => {
        for (const group of this.groupKeys) {
          if (this.industries[group] && this.industries[group].includes(item)) {
            groupsToExpand.add(group)
            break
          }
        }
      })
      // 只有当有选中项时才设置展开分组
      this.expandedGroups = Array.from(groupsToExpand)
    } else {
      // 没有选中项时，不展开任何分组
      this.expandedGroups = []
    }
  }

  aboutToAppear(): void {
    // 如果路由参数失败，从Model中读取当前的industry
    setTimeout(() => {
      if (this.selectedItems.length === 0) {
        const lastEditPage = AppStorage.get<string>('lastEditPage')
        let currentIndustry = ''

        if (lastEditPage === 'career') {
          currentIndustry = CareerObjectiveModel.instance.draft.industry
        } else {
          currentIndustry = WorkExperienceModel.instance.draft.industry
        }

        if (currentIndustry) {
          this.params.selected = currentIndustry.split(',').filter(s => s.trim())
          this.initSelection()
        }
      }
    }, 100)
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          title: '所属行业',
          onBack: () => this.navPathStack.pop('back')
        })

        List() {
          ForEach(this.groupKeys, (group: string) => {
            ListItemGroup({ header: this.groupHeader(group) }) {
              if (this.expandedGroups.includes(group)) {
                ListItem() {
                  Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                    ForEach(this.industries[group], (item: string) => {
                      Text(item)
                        .fontSize(14)
                        .fontColor(this.selectedItems.includes(item) ? '#0A59F7' : '#333333')
                        .backgroundColor(this.selectedItems.includes(item) ? '#E6F0FF' : '#F5F5F5')
                        .padding({
                          left: 12,
                          right: 12,
                          top: 8,
                          bottom: 8
                        })
                        .borderRadius(4)
                        .margin({ right: 12, bottom: 12 })
                        .onClick(() => {
                          this.toggleSelection(item)
                        })
                    }, (item: string, idx: number) => JSON.stringify(item) + idx)
                  }
                  .padding({
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8
                  })
                }
              }
            }
          }, (item: string, idx: number) => JSON.stringify(item) + idx)
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

        // Bottom Bar
        Row() {
          Column() {
            Row() {
              Text(`已选${this.selectedItems.length}个`)
                .fontSize(16)
                .fontColor('#333333')
                .width(80)
                .textAlign(TextAlign.Start)
            }

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.selectedItems, (item: string) => {
                Text(item)
                  .fontSize(12)
                  .fontColor('#0A59F7')
                  .backgroundColor('#E6F0FF')
                  .padding({
                    left: 8,
                    right: 8,
                    top: 4,
                    bottom: 4
                  })
                  .borderRadius(4)
                  .margin({ right: 8, bottom: 4 })
              }, (item: string, idx: number) => JSON.stringify(item) + idx)
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('确定')
            .height(36)
            .backgroundColor('#0A59F7')
            .borderRadius(18)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_on_primary'))
            .padding({ left: 16, right: 16 })
            .margin({ left: 12 })
            .onClick(() => {
              this.confirmAndPop(this.selectedItems)
            })
        }
        .width('100%')
        .constraintSize({ minHeight: 56 })
        .padding({
          top: 8
        })
        .backgroundColor(Color.White)
        .border({ width: { top: 1 }, color: '#F0F0F0' })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({
        top: 32,
        bottom: 32,
        left: 16,
        right: 16
      })
      .backgroundColor(Color.White)
    }
    .hideTitleBar(true)
    .onShown(() => this.uiContext.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE))
    .onWillDisappear(() => this.uiContext.setKeyboardAvoidMode(this.cacheKeyboardAvoidMode))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack
      if (context.pathInfo.param) {
        this.params = context.pathInfo.param as IndustrySelectParams
        this.initSelection()
      }
    })
    .onBackPressed(() => {
      this.navPathStack.pop('back')
      return true
    })
  }

  @Builder
  groupHeader(title: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)

      SymbolGlyph(this.expandedGroups.includes(title) ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
        .fontSize(20)
        .fontColor([$r('sys.color.font_secondary')])
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
    .onClick(() => {
      this.toggleGroup(title)
    })
  }

  toggleGroup(group: string) {
    const index = this.expandedGroups.indexOf(group)
    if (index !== -1) {
      this.expandedGroups.splice(index, 1)
    } else {
      this.expandedGroups.push(group)
    }
  }

  toggleSelection(item: string) {
    const index = this.selectedItems.indexOf(item)
    if (index !== -1) {
      this.selectedItems.splice(index, 1)
    } else {
      if (this.selectedItems.length >= 3) {
        return
      }
      this.selectedItems.push(item)
    }
  }

  confirmAndPop(values: string[]) {
    try {
      // 尝试调用回调
      if (this.params && typeof this.params.onConfirm === 'function') {
        this.params.onConfirm(values)
      }

      // 无论回调是否成功，都强制更新对应的单例Model（双重保障）
      const industryStr = values.join(',')

      // 智能判断:检查哪个Model正在编辑
      // 注意:添加模式时editingIndex是-1，所以需要检查draft是否有内容或使用其他标识
      const careerHasDraft = CareerObjectiveModel.instance.draft.position !== '' ||
        CareerObjectiveModel.instance.draft.city !== '' ||
        CareerObjectiveModel.instance.draft.salary !== ''
      const workHasDraft = WorkExperienceModel.instance.draft.company !== '' ||
        WorkExperienceModel.instance.draft.position !== ''
      // 优先根据draft内容判断
      if (careerHasDraft && !workHasDraft) {
        CareerObjectiveModel.instance.setDraftIndustry(industryStr)
      } else if (workHasDraft && !careerHasDraft) {
        WorkExperienceModel.instance.setDraftIndustry(industryStr)
      } else if (CareerObjectiveModel.instance.editingIndex !== -1) {
        CareerObjectiveModel.instance.setDraftIndustry(industryStr)
      } else if (WorkExperienceModel.instance.editingIndex !== -1) {
        WorkExperienceModel.instance.setDraftIndustry(industryStr)
      } else {
        // 最后兜底：使用AppStorage标记
        const lastEditPage = AppStorage.get<string>('lastEditPage')
        if (lastEditPage === 'career') {
          CareerObjectiveModel.instance.setDraftIndustry(industryStr)
        } else {
          WorkExperienceModel.instance.setDraftIndustry(industryStr)
        }
      }
    } catch (e) {
    }

    this.navPathStack.pop('back')
  }
}
