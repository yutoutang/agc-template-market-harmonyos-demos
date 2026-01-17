import { RecipeBriefInfo, RecipeCategory } from '../types/Index';
import { BreakpointModel, BreakpointType } from 'base_ui';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct LinkCategory {
  @Param recipeCategoryList: RecipeCategory[] = []
  @Param currentIndex: number = 0
  @Param gridCount: number = 3
  titleItemScroller: Scroller = new Scroller();
  scroller: Scroller = new Scroller();
  @Event onRecipeClick: (recipeDetail: RecipeBriefInfo) => void = () => {
  }
  @Event changeCurrentIndex: (currentIndex: number) => void = () => {
  }
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 3,
    md: 4,
    lg: 4,
    xl: 4,
  });

  // 下标索引处理
  currentIndexChangeAction(index: number, isClassify: boolean): void {
    if (this.currentIndex !== index) {
      this.changeCurrentIndex(index);
      if (isClassify) {
        this.scroller.scrollToIndex(index);
      } else {
        this.titleItemScroller.scrollToIndex(index);
      }
    }
  }

  @Computed
  get listLanes() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  // 分类列表
  @Builder
  leftListBuilder(typeName: string, index: number) {
    Row() {
      Text(typeName)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)

    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.currentIndex === index ? '#FF0000' : '#00000000')
    .width('100%')
    .height(40)
    .padding({
      left: 12,
      right: 4,
      top: 12,
      bottom: 12,
    })
    .margin({ right: 4 })
    .constraintSize({ maxWidth: '100%' })
    .borderRadius({ topRight: 12, bottomRight: 12 })
    .onClick(() => {
      this.currentIndexChangeAction(index, true);
    })
  }

  // 右列表分类标题
  @Builder
  listTitleBuilder(title: string) {
    Row() {
      Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
    }.width('100%').margin({ bottom: 12 })
  }

  build() {
    Column() {
      // 列表页
      Row() {
        List({ space: 8, scroller: this.titleItemScroller }) {
          ForEach(this.recipeCategoryList, (item: RecipeCategory, index: number) => {
            ListItem() {
              this.leftListBuilder(item.name, index)
            }
          }, (item: RecipeCategory, index: number) => item.name + index)
        }
        .width(this.listLanes === 3 ? 92 : 180)
        .height('100%')
        .backgroundColor('#F1F3F5')
        .listDirection(Axis.Vertical) // 排列方向
        .scrollBar(BarState.Off)
        .contentStartOffset(12)
        .contentEndOffset(12)

        List({ space: 12, scroller: this.scroller }) {
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
                        Image($r(`app.media.${listItem.thumbnail}`))
                          .width(this.listLanes === 3 ? 76 : 116)
                          .height(this.listLanes === 3 ? 76 : 116)
                          .borderRadius(8)
                        Text(listItem.title)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('sys.color.font_primary'))
                          .textAlign(TextAlign.Center)
                          .constraintSize({ maxWidth: 76 })
                          .maxLines(2)
                          .margin({ top: 4 })
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                    }.onClick(() => {
                      this.onRecipeClick(listItem)
                    })
                  }, (listItem: RecipeBriefInfo) => `${item.id}${listItem.id}`)
                }
                .rowsGap(8)
                .columnsGap(8)
                .columnsTemplate(Array(this.listLanes).fill('1fr').join(' '))
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
      }.layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
    .constraintSize({ maxHeight: '100%' })
  }
}
