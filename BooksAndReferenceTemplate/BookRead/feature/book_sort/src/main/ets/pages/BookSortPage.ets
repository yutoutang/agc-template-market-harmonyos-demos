import {
  BookApi,
  BookCategory,
  BookSubcategory,
  NavHeaderBar,
  GetBookCategoryRsp,
  BookCategoryItem,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum
} from 'common';

@Builder
export function BookSortPageBuilder() {
  BookSortPage();
}

@ComponentV2
export struct BookSortPage {
  @Local categoryChannel: Resource[] = [];
  @Local currentSortIndex: number = 0;
  @Local currentTitleId: number = 0;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  private categoryList: Array<BookCategory> = [];
  private navTitleScroller: Scroller = new Scroller();
  private bookListScroller: Scroller = new Scroller();

  async aboutToAppear(): Promise<void> {
    this.categoryChannel.push($r('app.string.boys_channel'));
    this.categoryChannel.push($r('app.string.girls_channel'));
    this.categoryChannel.push($r('app.string.free_channel'));
    this.getBooksCategory();
  }

  async getBooksCategory() {
    const rsp: GetBookCategoryRsp = await BookApi.getBookCategoryList();
    this.categoryList = rsp.category;
  }

  @Builder
  categoryTab() {
    Row() {
      ForEach(this.categoryChannel, (item: ResourceStr, index: number) => {
        ListItem() {
          Row() {
            Text(item)
              .fontSize($r('sys.float.Body_L'))
              .fontColor(this.currentSortIndex === index ? Color.White : $r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .height(40)
          .width(92)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.currentSortIndex === index ? Color.Black : '#0d000000')
          .borderRadius(20)
          .onClick(async () => {
            this.currentSortIndex = index
          })
        }
      }, (item: ResourceStr) => JSON.stringify(item))
    }
    .padding({ left: 12, right: 12 })
    .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? '100%' : '50%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  goodsHeaderBuilder(headerName: string) {
    Row() {
      Text(headerName)
        .fontSize(16)
        .fontWeight(500)
    }
    .width('100%')
    .height(56)
    .padding({ left: 8 })
    .backgroundColor($r('sys.color.white'))
  }

  listChange(index: number, isGoods: boolean) {
    if (this.currentTitleId !== index) {
      this.currentTitleId = index;
      if (isGoods) {
        this.bookListScroller.scrollToIndex(index);
      } else {
        this.navTitleScroller.scrollToIndex(index);
      }
    }
  }

  @Builder
  SecondaryLevelList() {
    Column() {
      Row() {
        List({ space: 8, scroller: this.navTitleScroller }) {
          ForEach(this.categoryList, (item: BookCategory, index: number) => {
            ListItem() {
              Row() {
                Text(item.categoryName)
                  .width('100%')
                  .height(56)
                  .fontSize(this.currentTitleId === index ? 16 : 14)
                  .textAlign(TextAlign.Center)
                  .fontColor(this.currentTitleId === index ? '#ffffff' : '#000000')
                  .opacity(this.currentTitleId === index ? 1 : 0.6)
                  .fontWeight(this.currentTitleId === index ? FontWeight.Bold :
                    FontWeight.Normal)
                  .onClick(() => {
                    this.listChange(index, true);
                  })
              }
              .width(88)
              .height(40)
              .borderRadius({
                topRight: 12,
                bottomRight: 12
              })
              .backgroundColor(this.currentTitleId === index ? '#E84026' : '')
            }
          }, (item: BookCategory) => JSON.stringify(item.categoryName))
        }
        .width(100)
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .backgroundColor('#F1F3F5')
        .padding({ top: 12 })

        List({ scroller: this.bookListScroller }) {
          ForEach(this.categoryList, (item: BookCategory) => {
            ListItemGroup({ space: 8, header: this.goodsHeaderBuilder(item.categoryName) }) {
              ForEach(item.subcategory, (bookCategoryItem: BookSubcategory) => {
                ListItem() {
                  BookCategoryItem({ categoryInfo: bookCategoryItem })
                }
              }, (bookCategoryItem: BookSubcategory) => JSON.stringify(bookCategoryItem.subcategoryId))
            }

          }, (item: BookCategory) => JSON.stringify(item.subcategory))
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .lanes(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 3 :
          (this.curBreakpoint.value === BreakpointTypeEnum.MD ? 6 : 10))
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.Header)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ left: 8, right: 12 })
        .backgroundColor('#ffffff')
        .onScrollIndex((index: number) => {
          this.listChange(index, false)
        })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignSelf(ItemAlign.Start)
      .margin({ top: 12 })
    }

  }

  build() {
    Column() {
      NavHeaderBar({
        title: $r('app.string.book_sort'),
        hasBackButton: false,
        hasBgColor: false,
        isMainPage: true,
      })

      Scroll() {
        Row() {
          this.categoryTab()
        }
        .justifyContent(FlexAlign.Start)
      }
      .alignSelf(ItemAlign.Start)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        this.SecondaryLevelList()
      }
      .width('100%')
      .layoutWeight(1)
    }
    .layoutWeight(1)
  }
}

