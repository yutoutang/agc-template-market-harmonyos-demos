import { RecipeBriefInfo, RecipeCategory } from '../types/Index';

@ComponentV2
export struct LinkCategory {
  @Param recipeCategoryList: RecipeCategory[] = []
  @Param currentIndex: number = 0
  @Param selectedItems: Set<string> = new Set()
  titleItemScroller: Scroller = new Scroller();
  scroller: Scroller = new Scroller();
  @Event onRecipeClick: (recipeDetail: RecipeBriefInfo, categoryName: string) => void = () => {
  }
  @Event changeCurrentIndex: (currentIndex: number) => void = () => {
  }
  @Local isClickLeft: boolean = false

  // 下标索引处理
  currentIndexChangeAction(index: number, isClassify: boolean): void {
    if (this.currentIndex !== index) {
      if (this.isClickLeft && isClassify) {
        this.changeCurrentIndex(index);
        this.scroller.scrollToIndex(index);
      } else if (!this.isClickLeft && !isClassify) {
        this.changeCurrentIndex(index);
      }
      if (isClassify) {
        this.scroller.scrollToIndex(index);
      } else {
        this.titleItemScroller.scrollToIndex(index);
      }
    }
  }

  // 分类列表
  @Builder
  leftListBuilder(typeName: string, index: number) {
    Row() {
      Text(typeName)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#99000000')
        .textAlign(TextAlign.Center)

    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.currentIndex === index ? '#FFFFFF' : '#00000000')
    .width('100%')
    .height(50)
    .padding({
      left: 12,
      right: 4,
      top: 12,
      bottom: 12,
    })
    .constraintSize({ maxWidth: '100%' })
    .onClick(() => {
      this.isClickLeft = true
      setTimeout(() => {
        this.isClickLeft = false
      }, 1500)
      this.currentIndexChangeAction(index, true);
    })
  }

  // 右列表分类标题
  @Builder
  listTitleBuilder(title: string) {
    Row() {
      Text(title).fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
    }.width('100%').margin({ bottom: 12 })
  }

  build() {
    Column() {
      // 列表页
      Row() {
        List({ scroller: this.titleItemScroller }) {
          ForEach(this.recipeCategoryList, (item: RecipeCategory, index: number) => {
            ListItem() {
              this.leftListBuilder(item.name, index)
            }
          }, (item: RecipeCategory, index: number) => item.name + index)
        }
        .width(92)
        .height('100%')
        .backgroundColor('#F1F3F5')
        .listDirection(Axis.Vertical) // 排列方向
        .scrollBar(BarState.Off)
        .contentEndOffset(12)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

        List({ space: 16, scroller: this.scroller }) {
          ForEach(this.recipeCategoryList, (item: RecipeCategory) => {
            ListItemGroup({
              header: this.listTitleBuilder(item.name),
              space: 12,
            }) {
              ListItem() {
                Grid() {
                  ForEach(item.recipeList, (listItem: RecipeBriefInfo) => {
                    GridItem() {
                      Column() {
                        Text(listItem.title)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.selectedItems.has(`${item.name}_${listItem.title}`) ? 'rgba(86, 74, 247, 1)' :
                            'rgba(0, 0, 0, 0.60)')
                          .textAlign(TextAlign.Center)
                          .constraintSize({ maxWidth: 76 })
                          .maxLines(2)
                          .margin({ top: 4 })
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                      .width('100%')
                      .height(38)
                      .backgroundColor(this.selectedItems.has(`${item.name}_${listItem.title}`) ?
                        'rgba(86, 74, 247, 0.1)' :
                        'rgba(0, 0, 0, 0.06)')
                      .borderRadius(8)
                      .justifyContent(FlexAlign.Center)
                    }.onClick(() => {
                      this.onRecipeClick(listItem, item.name)
                    })

                  }, (listItem: RecipeBriefInfo) => `${item.id}${listItem.id}`)
                }
                .rowsGap(12)
                .columnsGap(8)
                .columnsTemplate('1fr 1fr')
              }

            }
          }, (item: RecipeCategory) => item.id.toString())
        }
        .layoutWeight(1)
        .height('100%')
        .margin({ left: 8, right: 16 })
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.None)
        .contentStartOffset(12)
        .contentEndOffset(12)
        .onScrollIndex((start: number) => this.currentIndexChangeAction(start, false))
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }.layoutWeight(1)

    }
    .width('100%')
    .layoutWeight(1)
    .constraintSize({ maxHeight: '100%' })
  }
}
