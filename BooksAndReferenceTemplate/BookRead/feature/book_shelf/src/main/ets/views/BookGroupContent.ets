import {
  BookApi,
  BookInfo,
  Constants,
  GetBookApiRsp,
  GetHotBookListRsp,
  GroupBook,
  TCRouter,
  GroupBookCheckCard,
  DialogUtil,
  DialogParams,
  dialogView
} from 'common';
import { SearchResultCard } from 'book_home';
import { ManageGroupBottomCard } from '../comps/ManageGroupBottomCard';
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { loginComponentManager } from '@hms.core.account.LoginComponent';

let customDialogId: number = 0

export interface CategoryInfo {
  group: GroupBook;
  groups: GroupBook[]
}

@ComponentV2
export struct BookGroupContent {
  @Provider('isDeleteGroup') isDeleteGroup: boolean = false;
  @Local bookGroup: GroupBook | undefined = undefined;
  @Local fBooks: BookInfo[] = [];
  @Local manageBooksSet: Set<string> = new Set();
  @Local num: number = 0;
  @Local selectGroupNum: number = 0;
  @Local isShowBind: boolean = false;
  @Local groupBooks: GroupBook[] = [];
  @Local isShown: boolean = false;
  @Local submitValue: string | undefined = '';
  @Local groupName: string | undefined = '';
  @Local selectGroupBook: boolean = false;
  @Local favBooks: GroupBook[] = [];
  @Local folderIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.folder'));
  @Local renameIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.highlighter_line'));
  @Local trashIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.trash'));
  @Local wBuilder: WrappedBuilder<[DialogParams]> = wrapBuilder(dialogView);
  @Local changeItem: DialogParams = new DialogParams('新建分组', '', true, '取消', '确认', () => {
  }, () => {
  })
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Event manageGroup: () => void = () => {
    if (this.isDeleteGroup) {
      this.isDeleteGroup = false;
    } else {
      this.isDeleteGroup = true;
    }
    this.isShown = false;
  }
  @Event nameGroup: () => void = () => {
    this.isShown = false;
    this.renameDialog()
  }
  @Event deleteGroup: () => void = () => {
    this.isShown = false;
    this.disbandDialog()
  }

  // 重命名弹窗
  renameDialog() {
    DialogUtil.openDialog(this.wBuilder, new DialogParams(
      '修改组名', '', true, '取消', '确认',
      () => { // 取消
        DialogUtil.close()
      },
      (text?: string) => { // 分组
        this.groupBooks.forEach((item: GroupBook, index: number) => {
          if (item.groupName === this.bookGroup?.groupName) {
            this.bookGroup!.groupName = text
            item.groupName = text
          }
        })
        this.groupName = this.bookGroup!.groupName
        DialogUtil.close()
      }))
  };

  // 解散弹窗
  disbandDialog() {
    DialogUtil.openDialog(this.wBuilder, new DialogParams(
      '是否解散此分组', '解散分组后，组内书籍不会被删除，将自动移入书架。', false, '取消', '确认',
      () => {
        DialogUtil.close()
      },
      () => {
        this.groupBooks.forEach((item: GroupBook, index: number) => {
          if (item.groupName === this.bookGroup?.groupName) {
            this.num = this.groupBooks.indexOf(item);
          }
        })
        this.groupBooks.splice(this.num, 1)
        this.fBooks.forEach((item: BookInfo, index: number) => {
          let groupBook: GroupBook = new GroupBook()
          groupBook.bookName = item.name
          groupBook.isSelect = false;
          groupBook.groupName = ''
          groupBook.singleBook = item
          this.groupBooks.push(groupBook)
        })
        DialogUtil.close()
        TCRouter.pop();
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
          this.groupBooks.unshift(groupBook)
          AppStorage.set('favBooks', this.groupBooks)
          DialogUtil.close()
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '输入不能为空' })
        }
      }
    ))
  };

  aboutToAppear(): void {
    const p = TCRouter.getParams<CategoryInfo>(Constants.GROUP_ROUTE);
    this.bookGroup = p?.group;
    this.groupBooks = p?.groups as GroupBook[];
    this.fBooks = this.bookGroup?.groupBooks as BookInfo[];
    this.groupName = this.bookGroup?.groupName
  }

  //从分组中删除
  deleteBookFromGroup(bookList: BookInfo[]) {
    let tmp: BookInfo[] = [];
    for (let i = 0; i < bookList.length; i++) {
      if (!this.manageBooksSet.has(bookList[i].name)) {
        tmp.push(bookList[i]);
      }
    }
    bookList.length = tmp.length;
    for (let i = 0; i < tmp.length; i++) {
      bookList[i] = tmp[i];
    }
    this.isDeleteGroup = false;
  }

  @Builder
  selectMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: this.folderIconModifier,
        content: '管理分组',
        builder: this.manageGroup
      })
      MenuItem({
        symbolStartIcon: this.renameIconModifier,
        content: '重命名分组',
        builder: this.nameGroup
      })
      MenuItem({
        symbolStartIcon: this.trashIconModifier,
        content: '解散分组',
        builder: this.deleteGroup
      })
    }
    .width(224)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.ic_back')).height('40vp').width('40vp')
                .margin({ top: 16 + this.windowTopHeight, right: '8vp' })
                .onClick(() => {
                  TCRouter.pop();
                })

              Text(this.groupName)
                .fontSize($r('sys.float.Title_S'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 10, top: 16 + this.windowTopHeight })
            }

            Image($r('app.media.icon_select_all_off'))
              .height(40)
              .width(40)
              .margin({ top: 16 + this.windowTopHeight })
              .onClick(() => {
                this.isShown = true
              })
              .bindContextMenu(this.isShown, this.selectMenu(), {
                aboutToDisappear: () => {
                  this.isShown = false
                }
              })
          }
          .padding({ left: '16vp', right: '16vp' }).justifyContent(FlexAlign.SpaceBetween)
          .width('100%')

          List({ space: 10 }) {
            ForEach(this.fBooks, (item: BookInfo, index: number) => {
              ListItem() {
                if (this.isDeleteGroup) {
                  GroupBookCheckCard({
                    info: item, manageGroupEvent: (book: BookInfo, isShowM: boolean) => {
                      if (isShowM) {
                        this.manageBooksSet.add(book.name as string);
                      } else {
                        this.manageBooksSet.delete(book.name as string);
                      }
                    }
                  })
                } else {
                  SearchResultCard({ info: item })
                }
              }
            }, (item: BookInfo) => `${item.id}+${new Date().toString()}`)
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .cachedCount(3)
          .margin({ left: 16, right: 16, top: 20 })
          .layoutWeight(1)

          if (this.isDeleteGroup) {

            ManageGroupBottomCard({
              delete: () => { //删除
                let promptAction = this.getUIContext().getPromptAction();
                if (this.manageBooksSet.size !== 0) {
                  promptAction.showDialog({
                    title: $r('app.string.delete_book_flag'),
                    message: $r('app.string.q_delete_book_flag'),
                    buttons: [
                      {
                        text: $r('app.string.cancel'),
                        color: $r('app.color.button_color')
                      },
                      {
                        text: $r('app.string.delete'),
                        color: $r('app.color.button_color')
                      }
                    ]
                  }, (err, data) => {
                    if (data.index === 1) {
                      this.deleteBookFromGroup(this.fBooks)
                      promptAction.showToast({ message: $r('app.string.delete_book_success') })
                    }
                  })
                }
              },
              groupChange: () => { //移至分组事件
                if (this.manageBooksSet.size !== 0) {
                  this.isShowBind = true;
                }
              }

            }).margin({ bottom: 20 }).position({ bottom: 0 })
          }
        }
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE)
        .alignItems(HorizontalAlign.Start)

        .bindSheet($$this.isShowBind, this.newGroupEdit(), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 800],
          height: this.isShowBind ? SheetSize.FIT_CONTENT : SheetSize.MEDIUM,
          preferType: SheetType.BOTTOM,
          title: { title: this.bookGroup?.groupName },
          onWillDismiss: () => {
            this.isShowBind = false;
          }

        })
      }
    }
    .hideTitleBar(true)
  }

  @Builder
  newGroupEdit() {
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
          }.justifyContent(FlexAlign.SpaceBetween).padding({ right: '12vp' })
          .onClick(() => {
            this.changeDialog()
          })

        }.width('100%').justifyContent(FlexAlign.End).margin({ top: 16 })


        Column() {
          ForEach(this.groupBooks, (item: GroupBook, index: number) => {
            if (item.groupName !== '' && item.groupName !== this.groupName) {
              Row() {
                Row() {
                  Image(item.isSelect ? $r('app.media.selected_yes') :
                    $r('app.media.selected_no'))
                    .height(20)
                    .width(20).margin({ left: 14 })

                  Text(item.groupName)
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ left: 10 })
                }
                .height('100%')

                Text('共' + item.groupBooks?.length + '本')
                  .fontSize($r('sys.float.Caption_L'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
                  .height('100%')
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Top)
              .width('100%')
              .height(48)
              .margin({ top: 12 })
              .padding({ right: 16 })
              .backgroundColor($r('sys.color.white'))
              .borderRadius(10)
              .onClick(() => {
                item.iconString = 'app.media.selected_yes'
                item.isSelect = !item.isSelect
                this.selectGroupBook = false;
                this.selectGroupBook = item.isSelect
              })
            }
          }, (item: GroupBook) => item.timestamp.toString())
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ top: 16 })
      }

      Button('确定')
        .width(304)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.multi_color_08'))
        .onClick(() => {
          let groupBookNow: GroupBook = this.groupBooks[this.selectGroupNum];
          for (let i = 0; i < this.fBooks.length; i++) {
            if (this.manageBooksSet.has(this.fBooks[i].name)) {
              groupBookNow.groupBooks?.push(this.fBooks[i])
              let tmp = this.bookGroup?.groupBooks?.findIndex(book => this.fBooks[i].id === book.id) || 0
              this.bookGroup?.groupBooks?.splice(tmp, 1)
            }
          }
          this.isShowBind = false;
          this.isDeleteGroup = false;
        })
    }
    .height('90%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 12, right: 12 })
  }
}



