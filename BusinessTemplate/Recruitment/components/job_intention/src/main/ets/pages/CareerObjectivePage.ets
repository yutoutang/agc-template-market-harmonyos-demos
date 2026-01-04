import { UIContext, KeyboardAvoidMode } from '@kit.ArkUI';
import { UnsavedChangesDialog, UnsavedChangesDialogController } from '../components/UnsavedChangesDialog'
import { promptAction } from '@kit.ArkUI'
import { WorkExperienceModel } from '../viewmodel/WorkExperienceModel'
import { SalaryPickerDialog } from '../components/SalaryPickerDialog'
import { CITY_LIST_SAMPLE, CitySelect, HOT_CITY_LIST_SAMPLE, CitySelectController, City } from 'city_select'
import { CareerObjectiveModel } from '../viewmodel/CareerObjectiveModel'
import { InfoRow } from '../components/InfoRow'
import { CategorySelectConfig, CategorySelectParams } from './CategorySelectPage';
import { PageName } from '../common/CustomTypes';
import { IndustrySelectParams } from './IndustrySelectPage';
import { TitleBar } from '../components/TitleBar';
import { CitySelectParams } from './CitySelectPage';
import { CommonSingleDialogController, DegreeSelectDialogParams } from '../components/CommonSinglePickers';

@Builder
export function CareerObjectivePageBuilder() {
  CareerObjectivePage()
}


@ComponentV2
export struct CareerObjectivePage {
  @Local navPathStack: NavPathStack = new NavPathStack();
  private uiContext: UIContext = this.getUIContext();
  private cacheKeyboardAvoidMode: KeyboardAvoidMode = KeyboardAvoidMode.OFFSET;
  @Local vm: CareerObjectiveModel = CareerObjectiveModel.instance
  @Local showSalaryPicker: boolean = false // 是否显示薪资选择器
  @Local refreshKey: number = 0 // 用于强制刷新UI
  @Local showExitDialog: boolean = false
  @Local initialDraft: string = ''
  citySelectController: CitySelectController = new CitySelectController()

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

  onPageShow(): void {
    this.handlePageShow()
    // 页面显示时刷新数据
    this.refreshKey++
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

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          TitleBar({
            title: this.vm.editingIndex === -1 ? '添加求职意向' : '编辑求职意向',
            onBack: () => {
              this.handleBack()
            }
          })

          Column({ space: 0 }) {
            // 强制刷新标记
            Text(`${this.refreshKey}`).width(0).height(0).opacity(0)

            InfoRow({
              title: '工作性质',
              titleFontSize: 16,
              titleFontColor: 'rgba(0,0,0,0.6)',
              valueBuilder: () => {
                this.jobTypeButtons()
              },
              onClickRow: () => {
              }
            })
            Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

            // 意向职位
            InfoRow({
              title: '意向职位',
              isDraftPosition: true,
              titleFontColor: 'rgba(0,0,0,0.6)',
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
              isDraftPosition: true,
              titleFontColor: 'rgba(0,0,0,0.6)',
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
              isDraftPosition: true,
              titleFontColor: 'rgba(0,0,0,0.6)',
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
              isDraftPosition: true,
              titleFontColor: 'rgba(0,0,0,0.6)',
              value: this.vm.draft.salary || '请选择期望薪资',
              isSecondary: !this.vm.draft.salary,
              onClickRow: () => {
                this.showSalaryPicker = true
              }
            })
            Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

            // 求职状态
            InfoRow({
              title: '求职状态',
              isDraftPosition: true,
              titleFontColor: 'rgba(0,0,0,0.6)',
              value: this.vm.draft.jobStatus || '请选择求职状态',
              isSecondary: !this.vm.draft.jobStatus,
              onClickRow: () => {
                this.openDraftDialog()
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
            // 编辑模式：显示删除和保存按钮
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
                .fontColor($r('sys.color.font_on_primary'))
                .layoutWeight(2)
                .onClick(() => {
                  this.vm.saveDraft()
                  this.navPathStack.pop('back')
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 16 })
          } else {
            // 新增模式：只显示保存按钮
            Button('保存')
              .width('100%')
              .height(48)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor('#0A59F7')
              .borderRadius(24)
              .margin({ left: 16, right: 16, bottom: 16 })
              .onClick(() => {
                this.vm.saveDraft()
                this.navPathStack.pop('back')
              })
          }
        }.padding({ left: 16, right: 16 }).height('100%')

        // 薪资选择器弹窗
        if (this.showSalaryPicker) {
          this.salaryPickerOverlay()
        }


        // 未保存更改确认弹窗
        UnsavedChangesDialog({
          visible: this.showExitDialog,
          onConfirm: () => {
            this.showExitDialog = false
            this.navPathStack.pop('back')
          },
          onCancel: () => {
            this.showExitDialog = false
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        top: 32,
        bottom: 32
      })
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
    .onShown(() => this.uiContext.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE))
    .onWillDisappear(() => this.uiContext.setKeyboardAvoidMode(this.cacheKeyboardAvoidMode))
    .onReady((ctx: NavDestinationContext) => this.navPathStack = ctx.pathStack)
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

  // 处理返回
  handleBack(): void {
    if (this.hasUnsavedChanges()) {
      UnsavedChangesDialogController.openDialog(this.getUIContext(), {
        onConfirm: () => {
          this.navPathStack.pop('back')
        },
        onCancel: () => {
        }
      })
    } else {
      this.navPathStack.pop('back')
    }
  }

  // 打开城市选择
  openCitySelect(): void {

    const params: CitySelectParams = {
      selected: '',
      source: 'career',
      onConfirm: (city: string) => {
        this.vm.setDraftCity(city)
      }
    }
    this.navPathStack.pushPathByName(PageName.CitySelect, params)
  }

  // 打开职位选择
  openPositionSelect = () => {
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
      freeOption: '自由职业',
      textMax: 12
    }

    const params: CategorySelectParams = {
      selected: this.vm.draft.position,
      config: config,
      onConfirm: (value: string) => {
        this.vm.setDraftPosition(value)
        // 不要立即popPage，让CategorySelect自己处理
      }
    }

    this.navPathStack.pushPathByName(PageName.CategorySelect, params)
  }
  // 打开行业选择
  openIndustrySelect = () => {
    const params: IndustrySelectParams = {
      selected: this.vm.draft.industry ? this.vm.draft.industry.split(',')
        .filter(s => s.trim()) : [],
      source: 'career',
      onConfirm: (industries: string[]) => {
        this.vm.setDraftIndustry(industries.join(','))
      }
    }

    this.navPathStack.pushPathByName(PageName.IndustrySelect, params)
  }

  //求职状态
  openDraftDialog() {
    let range: string[] = ['离职-正在找工作', '在职-考虑机会', '在职-暂不考虑'];
    const params: DegreeSelectDialogParams = {
      selected: this.vm.draft.jobStatus || '本科',
      title: '求职状态',
      range,
      onConfirm: (val: string) => {
        this.vm.setDraftJobStatus(val)
      },
      onCancel: () => {
      }
    }
    CommonSingleDialogController.openDialog(this.getUIContext(), params)

  }

  // 薪资选择器覆盖层
  @Builder
  salaryPickerOverlay() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showSalaryPicker = false
        })

      // 弹窗内容（居中显示）
      SalaryPickerDialog({
        currentSalary: this.vm.draft.salary,
        onConfirm: (salary: string) => {
          if (salary) {
            this.vm.setDraftSalary(salary)
          }
          this.showSalaryPicker = false
        },
        onCancel: () => {
          this.showSalaryPicker = false
        }
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder
  jobTypeButtons() {
    Row({ space: 12 }) {
      ForEach(['全职', '兼职'], (item: string) => {
        Column() {
          Text(item)
            .fontSize(14)
            .fontColor(this.vm.draft.jobType === item ? '#FFFFFF' : '#1E242C')
        }
        .width(60)
        .height(32)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.vm.draft.jobType === item ? '#0A59F7' : 'rgba(0,0,0,0.06)')
        .borderRadius('50%')
        .onClick(() => {
          this.vm.setDraftJobType(item)
        })
      }, (item: string, index: number) => `${JSON.stringify(item)}_${index}}`)
    }
  }

  // 删除求职意向
  deleteCareerObjective(): void {
    try {
      promptAction.showDialog({
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
          this.navPathStack.pop('back')
        }
      })
    } catch (error) {
    }
  }
}
