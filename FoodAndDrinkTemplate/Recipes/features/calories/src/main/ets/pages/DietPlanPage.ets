import { buildTitleBar, CommonConstants, RouterMap, RouterModule } from 'commonlib';
import { LengthMetrics } from '@kit.ArkUI';
import { DietPlanPageVM } from '../viewModels/DietPlanPageVM';
import { FoodCalories, FoodCategory, MyMenuItem } from '../types/Index';

@Builder
export function DietPlanPageBuilder() {
  DietPlanPage()
}

@ComponentV2
struct DietPlanPage {
  @Local vm: DietPlanPageVM = new DietPlanPageVM();

  aboutToAppear(): void {
    this.vm.init()
  }

  @Computed
  get foodCategoryFilterList() {
    if (!this.vm.searchText) {
      return this.vm.foodCategories
    } else {
      return this.vm.foodCategories.map(item => new FoodCategory(item.id, item.name,
        item.foodList.filter(food => food.name.includes(this.vm.searchText))))
    }
  }

  // 分类列表
  @Builder
  leftListBuilder(typeName: string, index: number) {
    Row() {
      Column()
        .width(4)
        .height(28)
        .borderRadius({ topRight: 4, bottomRight: 4 })
        .backgroundColor(this.vm.currentIndex === index ? '#FD4238' : '#00000000')
      Text(typeName)
        .fontSize(12)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
        .width(68)
        .margin({
          left: 12,
          right: 8,
          top: 12,
          bottom: 12,
        })
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.vm.currentIndex === index ? $r('sys.color.background_primary') : '#00000000')
    .width('100%')
    .height(40)
    .constraintSize({ maxWidth: '100%' })
    .onClick(() => {
      this.vm.currentIndexChangeAction(index, true);
    })
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Row({ space: 12 }) {
          Select(this.vm.menuList)
            .selected(this.vm.selectIndex)
            .value(this.vm.selectText)
            .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .fontColor($r('sys.color.font_primary'))
            .width(124)
            .optionWidth(224)
            .optionHeight(296)
            .menuItemContentModifier(new MyMenuItem())
            .onSelect((index: number, text?: string | undefined) => {
              console.info('Select:' + index)
              this.vm.selectIndex = index;
              if (text) {
                this.vm.selectText = text;
              }
            })

          Row() {
            Search({ value: $$this.vm.searchText, placeholder: '请输入食物名称' })
              .textFont({ size: $r('sys.float.Body_L') })
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .maxLength(20)
              .enabled(false)
              .hitTestBehavior(HitTestMode.Transparent)
          }.layoutWeight(1)
          .onClick(() => {
            RouterModule.push(RouterMap.SEARCH_FOOD_PAGE, { 'id': this.vm.selectIndex } as Record<string, number>,
              (popInfo: PopInfo) => {
                if (popInfo.result) {
                  RouterModule.pop(popInfo.result)
                }
              })
          })
        }.width('100%').padding({ left: 16, right: 16 })

        Divider()
        // 列表页
        Row({ space: 8 }) {
          List({ scroller: this.vm.titleItemScroller }) {
            ForEach(this.foodCategoryFilterList, (item: FoodCategory, index: number) => {
              ListItem() {
                this.leftListBuilder(item.name, index)
              }
            }, (item: FoodCategory, index: number) => item.name + index)
          }
          .width(92)
          .height('100%')
          .backgroundColor('#F1F3F5')
          .listDirection(Axis.Vertical) // 排列方向
          .scrollBar(BarState.Off)

          List({ scroller: this.vm.scroller }) {
            ForEach(this.foodCategoryFilterList, (item: FoodCategory) => {
              ListItemGroup() {
                ForEach(item.foodList, (listItem: FoodCalories) => {
                  ListItem() {
                    Column() {
                      Row() {
                        Column() {
                          Text(listItem.name)
                            .fontSize(14)
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r('sys.color.font_primary'))
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                          Text(`${listItem.calories}千卡/${listItem.weight}克`)
                            .fontSize(12)
                            .fontColor($r('sys.color.font_secondary'))
                            .margin({ top: 2 })
                        }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                        Checkbox({ name: `${listItem.id}`, group: `foodGroup` })
                          .select(this.vm.selectFoods.some(food => food.id === listItem.id))
                          .height(20)
                          .width(20)
                          .selectedColor('#64BB5C')
                          .shape(CheckBoxShape.CIRCLE)
                          .onClick(() => {
                            this.vm.changeFood(listItem)
                          })
                      }
                      .justifyContent(FlexAlign.SpaceBetween)
                      .width(CommonConstants.FULL_WIDTH)
                      .padding({ top: 12, bottom: 4, left: 4 })

                      Divider().strokeWidth(1).margin({ bottom: 12 })
                    }
                  }.onClick(() => {
                  })
                }, (listItem: FoodCalories) => `${item.id}${listItem.id}`)
              }
            }, (item: FoodCategory) => JSON.stringify(item))
            ListItem() {
              Column() {
                Text('添加食物').fontSize(12).fontColor('#E84026').onClick(() => {
                  this.vm.showAddFoodSheet = true
                })
              }.width('100%')
            }
          }
          .layoutWeight(1)
          .height('100%')
          .margin({ left: 8, right: 16 })
          .scrollBar(BarState.Off)
          .sticky(StickyStyle.None)
          .contentEndOffset(12)
          .onScrollIndex((start: number) => this.vm.currentIndexChangeAction(start, false))
          .bindSheet($$this.vm.showAddFoodSheet, this.addFoodSheet(), {
            height: 400,
            blurStyle: BlurStyle.Thick,
            preferType: SheetType.CENTER,
            showClose: false,
          });
        }.layoutWeight(1)

        Row({ space: 16 }) {
          if (this.vm.selectFoods.length) {
            Badge({
              count: this.vm.selectFoods.length,
              style: { fontSize: 10, badgeSize: 16 },
            }) {
              Image($r('app.media.ic_dish')).width(40).height(40)
            }
          } else {
            Image($r('app.media.ic_dish_off')).width(40).height(40)
          }

          Button('确定')
            .backgroundColor(this.vm.selectFoods.length ? '#E84026' : '#1A000000')
            .layoutWeight(1)
            .onClick(() => {
              this.vm.addDietPlan()
            })
        }.padding({ left: 24, right: 24 })
      }
    }
    .title(buildTitleBar('饮食计划'), { paddingStart: LengthMetrics.vp(16) })
  }

  @Builder
  addFoodSheet() {
    Column() {
      Column() {
        Row().width(48).height(4).backgroundColor($r('sys.color.icon_fourth')).borderRadius(2)
        Row() {
          Select(this.vm.menuList)
            .selected(this.vm.selectIndex)
            .value(this.vm.selectText)
            .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .fontColor($r('sys.color.font_primary'))
            .space(16)
            .width(124)
            .optionWidth(224)
            .optionHeight(296)
            .menuItemContentModifier(new MyMenuItem())
            .onSelect((index: number, text?: string | undefined) => {
              console.info('Select:' + index)
              this.vm.selectIndex = index;
              if (text) {
                this.vm.selectText = text;
              }
            })
          Image($r('app.media.ic_close')).width(40).onClick(() => {
            this.vm.showAddFoodSheet = false
          })
        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
      }

      Column() {
        Text('自定义添加食物').fontSize(18).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
        Column({ space: 12 }) {
          TextInput({ text: $$this.vm.inputName, placeholder: '输入食品名称' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
            .borderRadius(12)
            .maxLength(20)
            .maxLength(10)
          TextInput({ text: $$this.vm.inputWeight, placeholder: '输入食品重量（克 /毫升）' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
            .type(InputType.Number)
            .borderRadius(12)
            .maxLength(10)
            .maxLength(10)
          TextInput({ text: $$this.vm.inputCalories, placeholder: '输入食品热量（千卡）' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
            .type(InputType.Number)
            .borderRadius(12)
            .maxLength(10)
            .maxLength(10)
        }
        .alignItems(HorizontalAlign.Start)
        .backgroundColor($r('sys.color.background_primary'))
        .margin({ top: 16 })
        .padding(12)
        .borderRadius(16)
      }.margin({ top: 24 })

      Row({ space: 16 }) {
        Button('取消')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor('#e6e8e9')
          .layoutWeight(1)
          .onClick(() => {
            this.vm.showAddFoodSheet = false
          })
        Button('确定')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#E84026')
          .layoutWeight(1)
          .onClick(() => {
            this.vm.confirmBtn()
          })
      }.margin({ top: 24 })
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(400)
    .padding({ left: 16, right: 16, top: 8 })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topLeft: 32, topRight: 32 })
    .constraintSize({ maxWidth: CommonConstants.FULL_WIDTH })
  }
}
