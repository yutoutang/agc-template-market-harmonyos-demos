/**
 * 行业类型选择组件
 * 用于工作经历、求职意向页面的行业类型选择
 */

import { CommonHeader } from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { WorkExperienceModel } from '../viewsmodel/WorkExperienceModel'
import { CareerObjectiveModel } from '../viewsmodel/CareerObjectiveModel'
import { promptAction } from '@kit.ArkUI'

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
  @Local routerModule: NavPathStack = new NavPathStack()
  private params: IndustrySelectParams = {
    selected: [], onConfirm: () => {
    }
  }
  @Local expandedGroups: string[] = [] // 默认不展开任何分组
  @Local selectedItems: string[] = []
  private industries: Record<string, string[]> = {
    // 科技类
    '互联网/AI/大数据': ['软件开发', '人工智能', '大数据', '云计算', '互联网服务', '电商'],
    '电子/通信/半导体': ['电子元器件', '通信工程', '半导体/芯片', '集成电路'],
    // 工业制造类
    '制造业': ['装备制造', '轻工制造', '机械制造', '汽车制造', '家电制造'],
    '汽车/交通/物流': ['汽车研发/生产', '交通运输', '物流仓储', '供应链管理'],
    // 地产建筑类
    '房地产/建筑': ['房地产开发', '建筑工程', '物业', '装修装饰'],
    // 消费服务类
    '消费品/批发/零售': ['快消品', '日用百货', '批发贸易', '线下零售'],
    '餐饮/住宿/文旅': ['餐饮服务', '酒店住宿', '文旅景区', '民宿'],
    // 教育科研类
    '教育培训': ['K12辅导', '职业培训', '学前教育', '学历教育（学校）', '成人教育'],
    '科研/学术': ['高校科研', '科研机构', '实验室/检测'], // 拆分学术/科研为独立分类
    // 文化传媒类
    '广告/传媒/文化/体育': ['广告策划', '媒体运营', '文化创意', '体育赛事', '影视制作'],
    // 专业服务类
    '专业服务': ['管理咨询', '法律咨询', '会计审计', '人力资源', '财税服务', '知识产权'],
    // 医疗健康类
    '制药/医疗': ['制药研发/生产', '医院/诊所', '医疗器械', '健康管理'],
    '金融/银行/证券/保险': ['银行', '证券', '基金', '保险', '期货', '理财风控'],
    '能源/化工/环保': ['石油化工', '新能源', '电力/电网', '环保工程'],
    '政府/公共事业': ['政务服务', '公共管理', '市政工程', '公益组织'],
    '其他行业': ['农林牧渔', '航空航天', '奢侈品', '珠宝首饰']
  }
  private groupKeys: string[] = [
    '互联网/AI/大数据',
    '电子/通信/半导体',
    '制造业',
    '汽车/交通/物流',
    '房地产/建筑',
    '消费品/批发/零售',
    '餐饮/住宿/文旅',
    '教育培训',
    '科研/学术',
    '广告/传媒/文化/体育',
    '专业服务',
    '制药/医疗',
    '金融/银行/证券/保险',
    '能源/化工/环保',
    '政府/公共事业',
    '其他行业'
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
    OHPage({
      childBuilder: () => {
        this.pageNav()
      },
      useSafePadding: true,
      pageBackgroundColor: $r('sys.color.comp_background_list_card')
    })
  }

  @Builder
  pageNav() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.routerModule = context.pathStack
      if (context.pathInfo.param) {
        this.params = context.pathInfo.param as IndustrySelectParams
        this.initSelection()
      }
    })
  }

  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '所属行业',
        backgroundColorParam: $r('sys.color.comp_background_list_card'),
        onReturnClick: () => {
          phoneRouterControl.popPage()
        }
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
                  }, (item: string) => `${group}-${item}`)
                }
                .padding({
                  top: 8,
                  bottom: 8
                })
              }
            }
          }
        }, (group: string) => group)
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
            }, (item: string) => `selected-${item}`)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button('确定')
          .height(36)
          .backgroundColor('#0A59F7')
          .borderRadius(18)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.comp_background_list_card'))
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
    .backgroundColor(Color.White)
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
        promptAction.showToast({
          message: `最多选择3个行业类别`,
          duration: 1000
        })
        return
      }
      this.selectedItems.push(item)
    }
  }

  confirmAndPop(values: string[]) {
    try {
      // 1. 优先调用回调
      if (this.params && typeof this.params.onConfirm === 'function') {
        this.params.onConfirm(values)
      }
      
      // 2. 强制更新对应的单例Model (作为双重保障)
      const industryStr = values.join(',')
      
      // 直接根据来源页面标记判断，不再根据草稿内容猜测
      const lastEditPage = AppStorage.get<string>('lastEditPage')
      if (lastEditPage === 'career') {
        CareerObjectiveModel.instance.setDraftIndustry(industryStr)
      } else {
        // 默认为工作经历 (包括 'work' 或未设置的情况)
        WorkExperienceModel.instance.setDraftIndustry(industryStr)
      }
    } catch (e) {
    }
    phoneRouterControl.popPage()
  }
}
