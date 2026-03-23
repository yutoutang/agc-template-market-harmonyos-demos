import { SearchResultCard } from 'book_home';
import {
  BookApi,
  BookInfo,
  BookLittleCard,
  BookGroupCard,
  BookLikeCard,
  Constants,
  GroupBook,
  MathUtil,
  NavHeaderBar,
  TCRouter,
  BookLittleCardHome,
  GroupListCard,
  dialogView,
  DialogParams,
  DialogUtil,
  bookShelfCard,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum
} from 'common';
import { DeleteBottomCard } from '../comps/DeleteBottomCard';
import { UserInfo } from 'base_common';
import { HashMap } from '@kit.ArkTS';
import { ShareBookCard } from 'book_read_kit'

@Builder
export function BookShelfPageBuilder() {
  BookShelfPage();
}

@ComponentV2
export struct BookShelfPage {
  @Local favBooks: GroupBook[] = [];
  @Local likeBooks: BookInfo[] = [];
  @Local myMap: HashMap<string, Array<BookInfo>> = new HashMap<string, Array<BookInfo>>();
  @Local historyBooks: BookInfo[] = [];
  @Local isEdit: boolean | undefined = false;
  @Consumer('isHistory') isHistory: boolean = false;
  @Local test: string[] = [];
  @Provider('isDeleteShelf') isDeleteShelf: boolean = false;
  @Local isShowManage: boolean = false;
  @Local isNewGroup: boolean = false;
  @Local isShowBind: boolean = false;
  @Local selectGroup: boolean = false;
  @Local deleteBooks: Set<string> = new Set();
  @Local deleteBooksGroup: Set<string> = new Set();
  @Consumer('userInfo') userInfo: UserInfo | undefined = undefined;
  @Param currentNumber: number = 0;
  @Consumer('tabController') tabsController: TabsController = new TabsController();
  @Consumer('currentIndexTab') currentIndexTab: number = 0;
  @Provider('isGrid') isGrid: boolean = true;
  @Local bookManage: GroupBook = new GroupBook();
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  scroller: Scroller = new Scroller()
  @Local wBuilder: WrappedBuilder<[DialogParams]> = wrapBuilder(dialogView);
  @Local changeItem: DialogParams = new DialogParams('新建分组', '', true, '取消', '确认', () => {
  }, () => {
  })

  // 删除弹窗
  deleteDialog() {
    DialogUtil.openDialog(this.wBuilder, new DialogParams(
      '是否删除此书籍？', '书籍将在同账号其他设备的书架同步删除。', false, '取消', '确认',
      () => {
        DialogUtil.close()
      },
      () => {
        this.deleteBooksGroup.add(this.bookManage?.bookName as string);
        this.deleteBookListGroup('favBooks', this.favBooks)
        DialogUtil.close()
      }))
  };

  // 新建分组弹窗
  changeDialog() {
    DialogUtil.openDialog(this.wBuilder, new DialogParams(
      this.changeItem.title, this.changeItem.content, this.changeItem.input, this.changeItem.leftButtonText,
      this.changeItem.rightButtonText,
      () => { // 取消
        DialogUtil.close()
      },
      (text?: string) => { // 分组
        if (text !== '') {
          let groupBook: GroupBook = new GroupBook()
          groupBook.isSelect = false;
          groupBook.groupName = text
          if (this.isDuplicate(text as string)) {
            this.favBooks.unshift(groupBook)
            AppStorage.set('favBooks', this.favBooks)
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '名字不能重复' })
          }
          DialogUtil.close()
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '输入不能为空' })
        }
      }
    ))
  };

  isDuplicate(text: string): boolean {
    for (let i = 0; i < this.favBooks.length; i++) {
      if (this.favBooks[i].groupName === text) {
        return false
      }
    }
    return true
  }

  async aboutToAppear(): Promise<void> {
    const params = TCRouter.getParams<boolean>(Constants.SHELF_ROUTER);
    this.isHistory = params === undefined ? false : params;
    const favRsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    const hisRsp = await BookApi.getBooksShelfList('historyBooks', Constants.API_GET_BOOK_HISTORY_PATH, '');
    const likeRsp = await BookApi.getBooksShelfList('likeBooks', Constants.API_GET_BOOK_LIKE_PATH, '');
    const userRsp = await BookApi.getUserInfo('');
    this.isDeleteShelf = false
    this.favBooks = favRsp.books;
    this.historyBooks = hisRsp.books;
    this.likeBooks = likeRsp.books;
  }

  deleteBookList(bookType: string, bookList: BookInfo[]) {
    let tmp: BookInfo[] = [];
    for (let i = 0; i < bookList.length; i++) {
      if (!this.deleteBooks.has(bookList[i].name)) {
        tmp.push(bookList[i]);
      }
    }

    bookList.length = tmp.length;
    for (let i = 0; i < tmp.length; i++) {
      bookList[i] = tmp[i];
    }

    AppStorage.set(bookType, tmp);
    this.isDeleteShelf = false;
  }

  deleteBookListGroup(bookType: string, bookListGroup: GroupBook[]) {
    let tmp: GroupBook[] = [];
    for (let i = 0; i < bookListGroup.length; i++) {
      if (!this.deleteBooksGroup.has(bookListGroup[i].bookName as string)) {
        tmp.push(bookListGroup[i]);
      }
    }

    bookListGroup.length = tmp.length;
    for (let i = 0; i < tmp.length; i++) {
      bookListGroup[i] = tmp[i];
    }

    AppStorage.set(bookType, tmp);
    this.isDeleteShelf = false;
  }

  // 该分组加入当前书籍 name为当前选择的组名
  addGroupList(name: string) {
    for (let i = 0; i < this.favBooks.length; i++) {
      if (this.favBooks[i].groupName === name) {
        this.favBooks[i].isSelect = false;
        this.favBooks[i].groupBooks?.push(this.bookManage.singleBook as BookInfo)
      }
    }
    MathUtil.sortFav(this.favBooks)
    // 修改组数据 删除掉
    let k = 0;
    for (let i = 0; i < this.favBooks.length; i++) {
      if (this.favBooks[i].singleBook === this.bookManage.singleBook) {
        k = i;
      }
    }
    this.favBooks.splice(k, 1)
    AppStorage.set('favBooks', this.favBooks)
  }

  @Builder
  readingInfo() {
    Column({ space: 20 }) {
      Row({ space: 5 }) {
        Image($r('app.media.icon_read'))
          .height(24)
          .width(24)
        Text($r('app.string.today_read'))
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('app.color.90per_000000'))
          .margin({ left: 10 })
        Text(`${this.userInfo ? this.userInfo.totalReading : 0}`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('app.color.free_color'))
        Text($r('app.string.minute'))
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('app.color.90per_000000'))
      }
      .alignSelf(ItemAlign.Start)
    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .backgroundImage($r('app.media.reading_info_bg'))
    .backgroundImageSize({ width: '100%' })
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      top: 20,
      bottom: 20,
    })
    .margin({
      top: 30
    })
  }

  // 宫格模式
  @Builder
  bookShelfGrid(infos: GroupBook[], isHistory: boolean) {
    Column() {
      Grid(this.scroller) {
        ForEach(this.favBooks, (info: GroupBook) => {
          GridItem() {
            Stack({ alignContent: Alignment.BottomEnd }) {
              if (info.groupName === '' || info.groupName === undefined) {
                BookLittleCard({
                  info: info.singleBook, manageEvent: (book: BookInfo, isShowM: boolean) => {
                    this.isShowManage = isShowM;
                    this.isShowBind = isShowM;
                    this.isNewGroup = false;
                    this.bookManage.isSelect = false;
                    this.bookManage.groupName = book.groupName
                    this.bookManage.iconString = '';
                    this.bookManage.bookName = book.name;
                    this.bookManage.singleBook = book
                  }
                })
                  .gesture(GestureGroup(GestureMode.Parallel, LongPressGesture()
                    .onAction((event: GestureEvent) => {
                      // 针对书架列表
                      this.isDeleteShelf = true;
                    })
                  ))

                if (this.isDeleteShelf) {
                  Checkbox({ name: 'delete', group: 'deleteGroup' })
                    .selectedColor($r('app.color.slider_selected_color'))
                    .unselectedColor($r('sys.color.icon_tertiary'))
                    .select(false)
                    .shape(CheckBoxShape.CIRCLE)
                    .onChange((value: boolean) => {
                      if (value) {
                        this.deleteBooksGroup.add(info.singleBook?.name as string);
                      } else {
                        this.deleteBooksGroup.delete(info.singleBook?.name as string);
                      }
                    })
                    .margin({ bottom: 12, right: 12 })
                }
              } else {
                BookGroupCard({ info: info })
                  .gesture(GestureGroup(GestureMode.Parallel,
                    LongPressGesture()
                      .onAction((event: GestureEvent) => {
                        // 针对书架列表
                        this.isDeleteShelf = true;
                      })
                  ))
                  .onClick(() => {
                    TCRouter.push(Constants.GROUP_ROUTE, { group: info, groups: this.favBooks })
                  })
              }
            }
          }
          .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 113 : 164)
        }, (item: GroupBook, index: number) => {
          return item.timestamp.toString()
        })

        GridItem() {
          Column() {
            Image($r('app.media.ic_public_plus'))
              .height(40)
              .width(40)
            Text($r('app.string.go_and_go_home'))
              .width(104)
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Body_M'))
              .textAlign(TextAlign.Center)
              .padding({ top: 8 })
          }
        }
        .borderRadius(10)
        .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
        .height(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 144 : 214)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .onClick(() => {
          this.currentIndexTab = 1;
          this.tabsController.changeIndex(1)
        })
      }
      .scrollBar(BarState.Off)
      .enableScrollInteraction(true)
      .columnsGap(5)
      .rowsGap(8)
      .edgeEffect(EdgeEffect.Spring)
      .width(Constants.FULL_SIZE)
    }
    .padding({ bottom: 15 })
  }

  // 宫格模式-历史
  @Builder
  bookShelfGridHistory(infos: BookInfo[], isHistory: boolean) {
    Column() {
      Grid(this.scroller) {
        ForEach(infos, (info: BookInfo) => {
          GridItem() {
            Stack({ alignContent: Alignment.BottomEnd }) {
              BookLittleCardHome({
                info: info
              })
                .gesture(GestureGroup(GestureMode.Parallel, LongPressGesture()
                  .onAction((event: GestureEvent) => {
                    // 针对书架列表
                    this.isDeleteShelf = true;
                  })
                ))
              if (this.isDeleteShelf) {
                Checkbox({ name: 'delete', group: 'deleteGroup' })
                  .select(false)
                  .selectedColor($r('app.color.slider_selected_color'))
                  .unselectedColor($r('sys.color.icon_tertiary'))
                  .shape(CheckBoxShape.CIRCLE)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.deleteBooks.add(info.name as string);
                    } else {
                      this.deleteBooks.delete(info.name as string);
                    }
                  })
                  .margin({ bottom: 12, right: 12 })
              }
            }
          }
          .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 113 : 164)
        }, (item: BookInfo, index: number) => {
          return MathUtil.generateRandomNumber(16).toString();
        })

        GridItem() {
          Column() {
            Image($r('app.media.ic_public_plus'))
              .width(40)
              .height(40)
            Text($r('app.string.go_and_go_home'))
              .width(104)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .textAlign(TextAlign.Center)
              .padding({ top: 8 })
          }
        }
        .borderRadius(10)
        .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
        .height(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 144 : 214)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .onClick(() => {
          this.currentIndexTab = 1;
          this.tabsController.changeIndex(1)
        })
      }
      .scrollBar(BarState.Off)
      .enableScrollInteraction(true)
      .columnsGap(5)
      .rowsGap(8)
      .edgeEffect(EdgeEffect.Spring)
      .width(Constants.FULL_SIZE)
    }
    .padding({ bottom: 15 })
  }

  //管理书籍
  @Builder
  manageBook() {
    if (this.isNewGroup) {
      this.newGroup();
    } else {
      Column() {
        Row() {
          Row() {
            Image($r(this.bookManage?.singleBook?.coverUrl?.toString()))
              .height(120)
              .width(90)
              .objectFit(ImageFit.Auto)
              .borderRadius(10)
            Column() {
              Text(this.bookManage?.bookName)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .width(104)
                .textAlign(TextAlign.Start)
                .padding({ top: 5 })
              Row() {
                Row() {
                  Text(this.bookManage?.singleBook?.rate)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                  Text(this.bookManage?.singleBook?.category)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                }
              }.padding({ top: 10 })
            }
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 16, right: 12 })
          }.alignItems(VerticalAlign.Top)

          Row() {
            Button('阅读')
              .width(60)
              .height(25)
              .backgroundColor($r('sys.color.multi_color_08'))
              .margin({ right: 10 })
              .onClick(() => {
                TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.bookManage.singleBook);
                this.isShowBind = false;
              })
          }.alignItems(VerticalAlign.Bottom)
          .justifyContent(FlexAlign.End)
          .height('100%')

        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%').height(120).margin({ right: 10 })


        Row() {
          Column() {
            ShareBookCard({ book: this.bookManage?.singleBook, isShelf: true })
          }
          .height(70)

          Column({ space: 5 }) {
            Image($r('app.media.ic_public_folder'))
              .height(24)
              .width(24)
              .margin({ top: 5 })
            Row() {
              Text($r('app.string.change_group'))
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Caption_L'))
                .fontWeight(FontWeight.Regular)
            }
          }
          .onClick(() => {
            this.isShowManage = false;
            this.isNewGroup = true;
            this.isShowBind = true;
          })
          .height(70)


          Column({ space: 5 }) {
            Image($r('app.media.ic_delete_book'))
              .width(24)
              .height(24)
              .margin({ top: 5 })
            Row() {
              Text($r('app.string.delete'))
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.multi_color_08'))
                .fontWeight(FontWeight.Regular)
            }
          }.onClick(() => {
            this.deleteDialog()
          })
          .height(70)

        }.height(70)
        .width('100%')
        .padding({ top: 37 })
        .justifyContent(FlexAlign.SpaceEvenly)

        Column() {
          Row() {
            Text($r('app.string.book_like'))
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Row() {
              Text($r('app.string.go_book_shop'))
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.font_secondary'))
              Image($r('app.media.arrow_right'))
                .height(16)
                .width(16).padding({ left: '6vp' })
            }.justifyContent(FlexAlign.SpaceBetween).padding({ right: '12vp' })
          }.justifyContent(FlexAlign.SpaceBetween).width('100%')
          .padding({ left: 10, top: 10 })

          Grid(this.scroller) {
            ForEach(this.likeBooks, (info: BookInfo) => {
              GridItem() {
                Stack() {
                  BookLikeCard({
                    info: info, showEvent: (isShow: boolean) => {
                      this.isShowManage = isShow
                      this.isShowBind = isShow
                    }
                  })
                }
              }
              .width(113)
              .height(170)
              .padding({ left: 5, right: 5, top: 1 })
            }, (item: BookInfo, index: number) => {
              return MathUtil.generateRandomNumber(16).toString();
            })
          }
          .scrollBar(BarState.Off)
          .enableScrollInteraction(true)
          .maxCount(3)
          .rowsGap(10)
          .columnsGap(10)
          .edgeEffect(EdgeEffect.Spring)
          .columnsTemplate('1fr 1fr 1fr')
          .width(Constants.FULL_SIZE)
          .margin({ top: 1, bottom: 10 })
        }
        .margin({ top: 22 })
        .borderRadius(10)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .width('100%')
        .height(220)
        .alignItems(HorizontalAlign.Start)
      }.alignItems(HorizontalAlign.Start)
      .height('95%').width('100%')
      .padding({ left: 12, right: 12 })
    }
  }

  @Builder
  newGroup() {
    Column() {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_public_plus'))
              .height(15)
              .width(15).padding({ right: '6vp' })
            Text($r('app.string.new_group'))
              .fontSize($r('sys.float.Caption_L'))
              .fontColor($r('sys.color.multi_color_08'))
              .fontWeight(FontWeight.Regular)
          }
          .justifyContent(FlexAlign.SpaceBetween).padding({ right: '12vp' })
          .onClick(() => {
            this.changeDialog()
          })
        }.width('100%').justifyContent(FlexAlign.End).margin({ top: 16 })

        Scroll() {
          Column() {
            ForEach(this.favBooks, (item: GroupBook, index: number) => {
              if (item.groupName !== '') {
                Row() {
                  Row() {
                    Radio({ value: item.groupName, group: 'radioGroup' })
                      .height(20)
                      .width(20)
                      .radioStyle({
                        checkedBackgroundColor: $r('app.color.font_overdue')
                      })
                      .margin({ left: 14 })
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          item.isSelect = isChecked
                        }
                      })
                    Text(item.groupName)
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ left: 10 })
                  }
                  .height('100%')

                  if (item.groupBooks?.length) {
                    Text('共' + item.groupBooks?.length + '本')
                      .fontSize($r('sys.float.Caption_L'))
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                      .height('100%')
                  } else {
                    Text('共' + 0 + '本')
                      .fontSize($r('sys.float.Caption_L'))
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.comp_background_list_card'))
                      .height('100%')
                  }
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Top)
                .width('100%')
                .height(48)
                .margin({ top: 12 })
                .padding({ right: 16 })
                .backgroundColor($r('sys.color.comp_background_list_card'))
                .borderRadius(10)
              }
            }, (item: GroupBook) => item.timestamp.toString())
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .margin({ top: 16 })
        }
        .edgeEffect(EdgeEffect.Spring)
      }

      Button('确定')
        .width(304)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.multi_color_08'))
        .onClick(() => {
          for (let i = 0; i < this.favBooks.length; i++) {
            if (this.favBooks[i].isSelect) {
              this.addGroupList(this.favBooks[i].groupName as string)
              this.isShowBind = false;
            }
          }
        })
    }
    .height('90%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 12, right: 12 })
  }

  // 列表模式
  @Builder
  bookShelfList(infos: GroupBook[] | undefined, isHistory: boolean) {
    Scroll(this.scroller) {
      Column() {
        ForEach(this.favBooks, (info: GroupBook) => {
          Stack({ alignContent: Alignment.BottomEnd }) {
            if (info.groupName === '') {
              bookShelfCard({
                info: info.singleBook, manageEvent: (book: BookInfo, isShowM: boolean) => {
                  this.isShowManage = isShowM;
                  this.isShowBind = isShowM;
                  this.isNewGroup = false;
                  this.bookManage.isSelect = false;
                  this.bookManage.groupName = book.groupName
                  this.bookManage.iconString = '';
                  this.bookManage.bookName = book.name;
                  this.bookManage.singleBook = book
                }
              })
                .gesture(GestureGroup(GestureMode.Parallel, LongPressGesture()
                  .onAction((event: GestureEvent) => {
                    // 针对书架列表
                    this.isDeleteShelf = true;
                  })
                ))
              if (this.isDeleteShelf) {
                Checkbox({ name: 'delete', group: 'deleteGroup' })
                  .select(false)
                  .unselectedColor($r('sys.color.icon_tertiary'))
                  .selectedColor($r('app.color.slider_selected_color'))
                  .shape(CheckBoxShape.CIRCLE)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.deleteBooksGroup.add(info.singleBook?.name as string);
                    } else {
                      this.deleteBooksGroup.delete(info.singleBook?.name as string);
                    }
                  })
                  .margin({ bottom: 12, right: 12 })
              }

            } else {
              GroupListCard({ info: info })
                .gesture(GestureGroup(GestureMode.Parallel,
                  LongPressGesture()
                    .onAction((event: GestureEvent) => {
                      // 针对书架列表
                      this.isDeleteShelf = true;
                    })
                ))
                .onClick(() => {
                  TCRouter.push(Constants.GROUP_ROUTE, { group: info, groups: this.favBooks }) //////
                })
            }
          }
        }, (item: GroupBook, index: number) => {
          return MathUtil.generateRandomNumber(16).toString();
        })

        Column() {
          Column() {
            Image($r('app.media.ic_public_plus'))
              .width(40)
              .height(40)
            Text($r('app.string.go_and_go_home'))
              .width(104)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .textAlign(TextAlign.Center)
              .padding({ top: 8 })
          }
          .justifyContent(FlexAlign.Center)
          .borderRadius(10)
          .width(104)
          .height(144)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .margin({ top: 10 })
          .onClick(() => {
            this.currentIndexTab = 1;
            this.tabsController.changeIndex(1)
          })
        }
        .width(Constants.FULL_SIZE)
        .alignItems(HorizontalAlign.Start)
      }
      .padding({ top: '20vp' })
      .padding({ bottom: 15 })
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .align(Alignment.Top)
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  // 列表模式-浏览历史
  @Builder
  bookShelfListHistory(infos: BookInfo[] | undefined, isHistory: boolean) {
    Scroll(this.scroller) {
      Column() {
        ForEach(infos, (info: BookInfo) => {
          Stack({ alignContent: Alignment.BottomEnd }) {
            SearchResultCard({ info: info })
              .gesture(GestureGroup(GestureMode.Parallel,
                LongPressGesture()
                  .onAction((event: GestureEvent) => {
                    // 针对书架列表
                    this.isDeleteShelf = true;
                  })
              ))
            if (this.isDeleteShelf) {
              Checkbox({ name: 'delete', group: 'deleteGroup' })
                .select(false)
                .selectedColor($r('app.color.slider_selected_color'))
                .unselectedColor($r('sys.color.icon_tertiary'))
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  if (value) {
                    this.deleteBooks.add(info.name);
                  } else {
                    this.deleteBooks.delete(info.name);
                  }
                })
                .margin({ bottom: 12, right: 12 })
            }
          }
        }, (item: BookInfo, index: number) => {
          return MathUtil.generateRandomNumber(16).toString();
        })

        Column() {
          Column() {
            Image($r('app.media.ic_public_plus'))
              .width(40)
              .height(40)
            Text($r('app.string.go_and_go_home'))
              .width(104)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .textAlign(TextAlign.Center)
              .padding({ top: 8 })
          }
          .justifyContent(FlexAlign.Center)
          .borderRadius(10)
          .width(104)
          .height(144)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .margin({ top: 10 })
          .onClick(() => {
            this.currentIndexTab = 1;
            this.tabsController.changeIndex(1)
          })
        }
        .width(Constants.FULL_SIZE)
        .alignItems(HorizontalAlign.Start)
      }
      .padding({ top: '20vp' })
      .padding({ bottom: 15 })
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .align(Alignment.Top)
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  shelfHeader() {
    Column() {
      Row({ space: 10 }) {
        Row() {
          Text($r('app.string.book_list'))
            .fontSize(20)
            .fontColor(this.isHistory ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
          Text(`(${this.favBooks?.length || 0})`)
            .fontSize(15)
            .fontColor(this.isHistory ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
        }
        .onClick(() => {
          this.isHistory = false;
          this.isDeleteShelf = false;
        })

        Text('|')
        Row() {
          Text($r('app.string.history'))
            .fontSize(20)
            .fontColor(this.isHistory ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
          Text(`(${this.historyBooks?.length || 0})`)
            .fontSize(15)
            .fontColor(this.isHistory ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
        }
        .onClick(() => {
          this.isHistory = true;
          this.isDeleteShelf = false
        })
      }
      .alignSelf(ItemAlign.Start)
      .width(Constants.FULL_SIZE)
      .padding({
        left: 12,
        right: 16,
        top: 24,
        bottom: 10,
      })
    }.alignItems(HorizontalAlign.Start)
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column() {
        NavHeaderBar({
          title: $r('app.string.book_shelf'),
          hasBackButton: false,
          hasBgColor: false,
          isMainPage: true,
          isShelf: true,
        })

        Column() {
          this.readingInfo();
          this.shelfHeader();
          Scroll() {
            Column() {
              if (this.isGrid) {
                if (this.isHistory) {
                  this.bookShelfGridHistory(this.historyBooks, this.isHistory);
                } else {
                  this.bookShelfGrid(this.favBooks, this.isHistory);
                }
              } else {
                if (this.isHistory) {
                  this.bookShelfListHistory(this.historyBooks, this.isHistory);
                } else {
                  this.bookShelfList(this.favBooks, this.isHistory);
                }
              }
            }
          }
          .align(Alignment.Top)
          .layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .padding({
          left: 12,
          right: 12,
        })
      }
      .onClick(() => {
        if (this.isDeleteShelf) {
          this.isDeleteShelf = false;
        }
      })
      .bindSheet($$this.isShowBind, this.manageBook(), {
        detents: [SheetSize.MEDIUM, SheetSize.LARGE, 800],
        height: this.isShowManage ? SheetSize.FIT_CONTENT : SheetSize.MEDIUM,
        preferType: SheetType.BOTTOM,
        title: { title: this.isShowManage ? $r('app.string.manage_book') : $r('app.string.change_group') },
        onWillDismiss: () => {
          this.isShowManage = false;
          this.isNewGroup = false;
          this.isShowBind = false;
        }
      })

      if (this.isDeleteShelf) {
        DeleteBottomCard({
          delete: () => {
            let bookType = this.isHistory ? 'historyBooks' : 'favBooks';
            if (bookType === 'historyBooks') {
              this.deleteBookList(bookType, this.historyBooks)
            } else {
              this.deleteBookListGroup(bookType, this.favBooks)
            }
          }
        })
      }
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}