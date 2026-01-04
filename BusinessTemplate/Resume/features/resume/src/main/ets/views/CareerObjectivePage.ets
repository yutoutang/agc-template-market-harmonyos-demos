/**
 * 求职意向页面
 * 用于编辑简历的求职意向信息,包括期望职位、期望行业、期望城市、期望薪资等
 */

import { CommonHeader, RouterMap, BreakpointModel, GlobalContext } from 'common'
import { OHPage, phoneRouterControl, OHPageConfig } from 'oh_router'
import { CareerObjectiveModel } from '../viewsmodel/CareerObjectiveModel'
import { WorkExperienceModel } from '../viewsmodel/WorkExperienceModel'
import { CategorySelectPageBuilder, CategorySelectParams, CategorySelectConfig } from '../comp/CategorySelect'
import { IndustrySelectPageBuilder, IndustrySelectParams } from '../comp/IndustrySelect'
import { SalaryPickerDialogController, SalaryPickerParams } from '../comp/SalaryPickerDialog'
import { InfoRow } from '../comp/InfoRow'
import { UnsavedChangesDialogController } from '../comp/UnsavedChangesDialog'
import { AppStorageV2 } from '@kit.ArkUI'
import { CitySelectPageBuilder } from '../comp/CitySelectPage'

@Builder
export function CareerObjectivePageBuilder() {
  CareerObjectivePage()
}


@ComponentV2
export struct CareerObjectivePage {
  @Local vm: CareerObjectiveModel = CareerObjectiveModel.instance
  @Local refreshKey: number = 0 // 用于强制刷新UI
  @Local initialDraft: string = ''
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    // 如果editingIndex是-1，说明没有调用startEdit，自动初始化为添加模式
    if (this.vm.editingIndex === -1) {
      this.vm.startEdit(-1)
    }

    // 设置AppStorage标记，标识当前是求职意向页面
    AppStorage.setOrCreate('lastEditPage', 'career')
    // 保存初始状态用于检测是否有修改
    this.initialDraft = JSON.stringify(this.vm.draft)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: false,
      pageConfig: new OHPageConfig({
        onBackPress: () => {
          this.handleBack()
          return true
        },
        onPageShow: () => {
          this.handlePageShow()
        }
      })
    })
  }

  handlePageShow(): void {
    // 页面显示时刷新数据
    this.refreshKey++
    const city = AppStorage.get<string>('resume_city_select_result')
    if (city) {
      this.vm.setDraftCity(city)
      AppStorage.setOrCreate('resume_city_select_result', undefined)
    }
  }

  @Builder
  render() {
    NavDestination() {
      Stack() {
        Column() {
          CommonHeader({
            title: this.vm.editingIndex === -1 ? '添加求职意向' : '编辑求职意向',
            onReturnClick: () => {
              this.handleBack()
            },
          })

          Column({ space: 0 }) {
            // 强制刷新标记
            Text(`${this.refreshKey}`).width(0).height(0).opacity(0)

            // 意向职位
            InfoRow({
              title: '意向职位',
              value: this.vm.draft.position || '请选择意向职位',
              isSecondary: !this.vm.draft.position,
              onClickRow: () => {
                this.openPositionSelect()
              }
            })
            Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

            // 工作城市
            InfoRow({
              title: '工作城市',
              value: this.vm.draft.city || '请选择工作城市',
              isSecondary: !this.vm.draft.city,
              onClickRow: () => {
                this.openCitySelect()
              }
            })
            Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

            // 行业类型
            InfoRow({
              title: '行业类型',
              value: this.vm.draft.industry || '请选择行业类型',
              isSecondary: !this.vm.draft.industry,
              onClickRow: () => {
                this.openIndustrySelect()
              }
            })
            Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

            // 期望薪资
            InfoRow({
              title: '期望薪资',
              value: this.vm.draft.salary || '请选择期望薪资',
              isSecondary: !this.vm.draft.salary,
              onClickRow: () => {
                const params: SalaryPickerParams = {
                  currentSalary: this.vm.draft.salary,
                  onConfirm: (salary: string) => {
                    if (salary) {
                      this.vm.setDraftSalary(salary)
                    }
                  },
                  onCancel: () => {}
                }
                SalaryPickerDialogController.openDialog(GlobalContext.getUIContext(), params)
              }
            })
            Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          }
          .width('100%')
          .borderRadius(8)
          .margin({ top: 12 })

          Blank()

          // 按钮区域
          if (this.vm.editingIndex !== -1) {
            // 编辑模式:显示删除和保存按钮
            Row() {
              Button('删除')
                .height(44)
                .backgroundColor('#E5E7E9')
                .borderRadius(22)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_tertiary'))
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.deleteCareerObjective()
                })

              Button('保存')
                .height(44)
                .backgroundColor('#0A59F7')
                .borderRadius(22)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.comp_background_list_card'))
                .layoutWeight(2)
                .onClick(() => {
                  this.saveCareerObjective()
                })
            }
            .width('100%')
            .padding({ bottom: 16 })
          } else {
            // 新增模式:只显示保存按钮
            Button('保存')
              .width('100%')
              .height(48)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.comp_background_list_card'))
              .backgroundColor('#0A59F7')
              .borderRadius(24)
              .margin({ bottom: 16 })
              .onClick(() => {
                this.saveCareerObjective()
              })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.background_secondary'))
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.handleBack()
      return true
    })
  }

  // 检查是否有未保存的修改
  hasUnsavedChanges(): boolean {
    const currentDraft = JSON.stringify(this.vm.draft)
    return currentDraft !== this.initialDraft
  }

  // 检查是否至少填写了一项数据
  hasAnyData(): boolean {
    const draft = this.vm.draft
    return !!(draft.position || draft.city || draft.industry || draft.salary)
  }

  // 保存求职意向（带验证）
  saveCareerObjective(): void {
    if (!this.hasAnyData()) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '请先填写信息',
        duration: 2000
      })
      return
    }
    this.vm.saveDraft()
    AppStorage.setOrCreate('resumeDataUpdated', Date.now())
    phoneRouterControl.popPage()
  }

  // 处理返回
  handleBack(): void {
    if (this.hasUnsavedChanges()) {
      UnsavedChangesDialogController.openDialog(GlobalContext.getUIContext(), {
        onConfirm: () => {
          phoneRouterControl.popPage()
        },
        onCancel: () => {}
      })
    } else {
      phoneRouterControl.popPage()
    }
  }

  // 打开城市选择
  openCitySelect(): void {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.RESUME_CITY_SELECT_PAGE,
      builder: wrapBuilder(CitySelectPageBuilder)
    })
  }

  // 打开职位选择
  openPositionSelect(): void {
    const config: CategorySelectConfig = {
      title: '意向职位',
      categories: WorkExperienceModel.instance.getPositionCategories(),
      subItems: WorkExperienceModel.instance.getPositionSubItems(),
      searchPlaceholder: '请搜索意向职位',
      groupedDisplay: true,
      groupMapping: WorkExperienceModel.instance.getPositionGroupMapping(),
      showCustomInput: true,
      customInputTitle: '自定义职位',
      customInputPlaceholder: '请输入职位名称',
      freeOption: '自由职业'
    }

    const params: CategorySelectParams = {
      selected: this.vm.draft.position,
      config: config,
      onConfirm: (value: string) => {
        this.vm.setDraftPosition(value)
        // 不要立即popPage，让CategorySelect自己处理
      }
    }

    phoneRouterControl.jumpPage({
      pageName: RouterMap.RESUME_POSITION_SELECT_PAGE,
      builder: wrapBuilder(CategorySelectPageBuilder),
      param: params
    })
  }

  // 打开行业选择
  openIndustrySelect(): void {
    const params: IndustrySelectParams = {
      selected: this.vm.draft.industry ? this.vm.draft.industry.split(',')
        .filter(s => s.trim()) : [],
      source: 'career',
      onConfirm: (industries: string[]) => {
        this.vm.setDraftIndustry(industries.join(','))
      }
    }

    phoneRouterControl.jumpPage({
      pageName: RouterMap.RESUME_INDUSTRY_SELECT_PAGE,
      builder: wrapBuilder(IndustrySelectPageBuilder),
      param: params
    })
  }

  // 删除求职意向
  deleteCareerObjective(): void {
    GlobalContext.getUIContext().getPromptAction().showDialog({
      title: '提示',
      message: '确定要删除该求职意向吗？',
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '删除', color: '#FF0000' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        // 删除当前编辑的求职意向
        this.vm.deleteItem(this.vm.editingIndex)
        AppStorage.setOrCreate('resumeDataUpdated', Date.now())
        phoneRouterControl.popPage()
      }
    })
  }
}
