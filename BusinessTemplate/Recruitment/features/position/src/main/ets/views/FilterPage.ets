import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { BarVM, CommonHeader } from 'common';
import { LinkCategory, RecipeBriefInfo, RecipeCategory } from 'link_category';
import { OHPage, phoneRouterControl } from 'oh_router';
import { SalaryPickerDialog } from 'job_intention'

export interface FilterData {
  selectedItems: string[];
  timestamp: number;
}

// 持久化存储筛选条件
@ObservedV2
class FilterStorage {
  @Trace selectedItems: string[] = [];
}

@Builder
export function FilterPageBuilder() {
  FilterPage()
}


@ComponentV2
struct FilterPage {
  @Local currentIndex: number = 1
  @Local selectedItems: Set<string> = new Set()
  @Local filterStorage: FilterStorage = AppStorageV2.connect(FilterStorage, () => new FilterStorage())!;
  @Local showSalaryPicker: boolean = false
  @Local defineSalary: string = ''
  @Local currentSalary: string = '10K-12K'
  @Local recipeCategoryList: RecipeCategory[] = [
    {
      id: 1001,
      name: '薪资区间',
      recipeList: [
        { id: 1, title: '全部' } as RecipeBriefInfo,
        { id: 2, title: '3K以下' } as RecipeBriefInfo,
        { id: 3, title: '3-5K' } as RecipeBriefInfo,
        { id: 4, title: '5-7K' } as RecipeBriefInfo,
        { id: 5, title: '7-9K' } as RecipeBriefInfo,
        { id: 6, title: '9-12K' } as RecipeBriefInfo,
        { id: 7, title: '12K以上' } as RecipeBriefInfo,
        { id: 8, title: '自定义薪资' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1002,
      name: '行业类型',
      recipeList: [
        { id: 1, title: '全部' } as RecipeBriefInfo,
        { id: 2, title: '电子商务' } as RecipeBriefInfo,
        { id: 3, title: '互联网' } as RecipeBriefInfo,
        { id: 4, title: '计算机软件' } as RecipeBriefInfo,
        { id: 5, title: '人工智能' } as RecipeBriefInfo,
        { id: 6, title: '企业服务' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1003,
      name: '公司性质',
      recipeList: [
        { id: 1, title: '国企' } as RecipeBriefInfo,
        { id: 2, title: '私企' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1004,
      name: '公司规模',
      recipeList: [
        { id: 1, title: '全部' } as RecipeBriefInfo,
        { id: 2, title: '0-20人' } as RecipeBriefInfo,
        { id: 3, title: '20-99人' } as RecipeBriefInfo,
        { id: 4, title: '100-499人' } as RecipeBriefInfo,
        { id: 5, title: '500-9999人' } as RecipeBriefInfo,
        { id: 6, title: '10000以上' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1005,
      name: '职位类型',
      recipeList: [
        { id: 1, title: '全部' } as RecipeBriefInfo,
        { id: 2, title: 'C/C++' } as RecipeBriefInfo,
        { id: 3, title: 'Java工程师' } as RecipeBriefInfo,
        { id: 4, title: 'C＃' } as RecipeBriefInfo,
        { id: 5, title: '前端开发工程师' } as RecipeBriefInfo,
        { id: 6, title: '测试工程师' } as RecipeBriefInfo,
        { id: 7, title: '产品经理' } as RecipeBriefInfo,
        { id: 8, title: '运维工程师' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1006,
      name: '学历',
      recipeList: [
        { id: 1, title: '全部' } as RecipeBriefInfo,
        { id: 2, title: '初中以下' } as RecipeBriefInfo,
        { id: 3, title: '高中' } as RecipeBriefInfo,
        { id: 4, title: '中专/中技' } as RecipeBriefInfo,
        { id: 5, title: '大专' } as RecipeBriefInfo,
        { id: 6, title: '本科' } as RecipeBriefInfo,
        { id: 7, title: '硕士' } as RecipeBriefInfo,
      ],
    },
  ];

  aboutToAppear(): void {
    // 从持久化存储中恢复筛选条件
    if (this.filterStorage.selectedItems && this.filterStorage.selectedItems.length > 0) {
      this.selectedItems = new Set(this.filterStorage.selectedItems);
      const tempArray = Array.from(this.selectedItems);
      tempArray.forEach((item, index) => {
        if (item.includes('自定义薪资D')) {
          const salaryArr = item.split('D');
          const newItem = salaryArr;

          tempArray[index] = newItem[0]; // 直接修改临时数组
          this.currentSalary = salaryArr[1];
        }
      });

      // 重新赋值 Set（若需要保持 Set 特性）
      this.selectedItems = new Set(tempArray);
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.FilterBuilder()
      },
    })
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
        currentSalary: this.currentSalary,
        onConfirm: (salary: string) => {
          if (salary) {
            const match = salary.match(/(\d+)K?-(\d+)K/)!
            this.defineSalary += 'D' + match[1] + 'K-' + match[2] + 'K' //薪资区间_自定义薪资D10k-12k  薪资区间_5-7K
            this.currentSalary = match[1] + 'K-' + match[2] + 'K'
            this.selectedItems.add(this.defineSalary)
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
  FilterBuilder() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '筛选',
          backgroundColorParam: '#fff',
          onReturnClick: () => {
            phoneRouterControl.popPage();
          },
        }).padding({ left: 16 })
        RelativeContainer() {
          LinkCategory({
            recipeCategoryList: this.recipeCategoryList,
            currentIndex: this.currentIndex,
            selectedItems: this.selectedItems,
            onRecipeClick: (listItem, categoryName) => {
              // 筛选项点击事件 - 支持多选
              const key = `${categoryName}_${listItem.title}`
              const isAllOption = listItem.title === '全部' || categoryName === '薪资区间' || categoryName === '公司性质'

              if (this.selectedItems.has(key)) {
                // 已选中，取消选中
                if (listItem.title === '自定义薪资') {
                  this.defineSalary = key
                  this.showSalaryPicker = true
                } else {
                  this.selectedItems.delete(key)
                }
              } else {
                // 未选中，添加选中
                if (isAllOption) {
                  // 如果点击的是"全部"，清除该分类下的其他所有选项
                  const keysToDelete: string[] = []
                  this.selectedItems.forEach((selectedKey) => {
                    if (selectedKey.startsWith(`${categoryName}_`) && selectedKey !== key) {
                      keysToDelete.push(selectedKey)
                    }
                  })
                  keysToDelete.forEach(k => this.selectedItems.delete(k))
                } else {
                  // 如果点击的是其他选项，取消该分类下的"全部"选项
                  const allKey = `${categoryName}_全部`
                  if (this.selectedItems.has(allKey)) {
                    this.selectedItems.delete(allKey)
                  }
                }
                //薪资区间_自定义薪资D10k-12k
                if (listItem.title === '自定义薪资') {
                  this.defineSalary = key
                  this.showSalaryPicker = true

                } else {
                  this.defineSalary = ''
                }
                this.selectedItems.add(key)
              }

              // 触发UI更新并保存到持久化存储
              this.selectedItems = new Set(this.selectedItems)
              this.filterStorage.selectedItems = Array.from(this.selectedItems)
            },
            changeCurrentIndex: (index: number) => {
              // 点击分类标签切换index事件
              this.currentIndex = index
            },
          })
        }
        .layoutWeight(1)
        .width('100%')

        Row() {
          Text('重置')
            .fontSize(14)
            .fontColor('#666666')
            .onClick(() => {
              // 清空所有选中项并清除持久化存储
              this.selectedItems.clear()
              this.selectedItems = new Set()
              this.filterStorage.selectedItems = []
              promptAction.showToast({
                message: '已重置',
                duration: 1000
              })
            })

          Row() {
            Text('确定')
              .fontSize(14)
              .fontColor('#FFFFFFFF')
          }
          .width(256)
          .height(40)
          .backgroundColor('rgba(86, 74, 247, 1)')
          .borderRadius('50%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            // 返回首页并传递筛选条件
            const tempArray = Array.from(this.selectedItems);
            tempArray.forEach((item, index) => {
              if (item === '薪资区间_自定义薪资') {
                tempArray.splice(index, 1)
              }
            });
            this.selectedItems = new Set(tempArray)
            const selectedCount = this.selectedItems.size

            // 保存到持久化存储
            this.filterStorage.selectedItems = Array.from(this.selectedItems)

            // 将选中项转换为可传递的对象
            const filterData: FilterData = {
              selectedItems: Array.from(this.selectedItems),
              timestamp: Date.now()
            }

            phoneRouterControl.popPage({
              popData: filterData
            })

            promptAction.showToast({
              message: `已应用 ${selectedCount} 个筛选条件`,
              duration: 1000
            })
          })
        }
        .width('100%')
        .height(76)
        .justifyContent(FlexAlign.SpaceEvenly)
        .backgroundColor('#FFFFFF')

        if (this.showSalaryPicker) {
          this.salaryPickerOverlay()
        }
      }
      .width('100%')
      .padding({
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
    }
    .height('100%')
    .width('100%')
  }
}
