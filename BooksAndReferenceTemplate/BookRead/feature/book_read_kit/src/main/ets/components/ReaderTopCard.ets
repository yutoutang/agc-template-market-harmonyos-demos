import { BookApi, BookInfo, Constants, GroupBook, TCRouter } from 'common';
import { ShareBookCard } from './ShareBookCard';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';
import { fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { Logger } from '@hw-agconnect/ui-base';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { UserInfo } from 'base_common';
@ComponentV2
export struct ReaderTopCard {
  @Param @Require book: BookInfo
  @Local isAddSuccess: boolean = false;
  @Local isLogin: boolean = false;
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;

  setShareData() {
    const contextFaker: Context = this.getUIContext().getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/book_image_1.png';
    let i = this.book.coverUrl
    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.png', utd.UniformDataType.IMAGE);

    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: fileUri.getUriFromPath(filePath),
      title: 'Picture Title',
      description: 'Picture Description',
    });

    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      Logger.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      Logger.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    });
  }

  async aboutToAppear(): Promise<void> {
    this.isLogin = AppStorage.get<UserInfo>('userInfo') !== undefined;
    const rsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    let books: GroupBook[] = rsp.books;
    books.forEach((book) => {
      if (book.singleBook?.id === this.book.id && this.isLogin) {
        this.isAddSuccess = true;
        return;
      }
    });
  }

  async addBook2Shelf(isAdd: boolean, toast: ResourceStr) {
    const favRsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    const hisRsp = await BookApi.getBooksShelfList('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '')
    let favBooks: GroupBook[] = favRsp.books;
    let hisBooks: BookInfo[] = hisRsp.books
    if (isAdd) {
      let temp: GroupBook = new GroupBook()
      temp.isSelect = false;
      temp.groupName = this.book.groupName
      temp.bookName = this.book.name
      temp.singleBook = this.book
      favBooks.push(temp);
      AppStorage.set('favBooks', favBooks);
      this.isAddSuccess = true;
    } else {
      let index = hisBooks.findIndex(book => this.book.id === book.id)
      let fIndex = favBooks.findIndex(book => this.book.id === book.singleBook?.id)
      for (let i = 0; i < favBooks.length; i++) {
        let tmp = favBooks[i].groupBooks?.findIndex(book => this.book.id === book.id) || 0
        if (tmp !== -1) {
          this.isAddSuccess = false;
          favBooks[i].groupBooks?.splice(tmp, 1)
        }
      }
      if (index !== -1) {
        hisBooks.splice(index, 1);
        this.isAddSuccess = false;
      }
      if (fIndex !== -1) {
        favBooks.splice(fIndex, 1);
        this.isAddSuccess = false;
      }
      AppStorage.set('favBooks', favBooks);
      AppStorage.set('historyBooks', hisBooks)
    }
    this.getUIContext().getPromptAction().showToast({
      message: toast,
      duration: 2000
    });
  }

  build() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(35)
        .height(35)
        .onClick(() => {
          TCRouter.pop();
        })


      Row({space: 8}) {
        Image(this.isAddSuccess ? $r('app.media.ic_add_book_shelf_success') : $r('app.media.ic_add_book_shelf'))
          .width(35)
          .height(35)
          .onClick(async () => {
            const userInfo = AppStorage.get<UserInfo>('userInfo');
            if (userInfo === undefined) {
              TCRouter.push(Constants.LOGIN_ROUTE);
            } else if (!this.isAddSuccess) {
              await this.addBook2Shelf(true, $r('app.string.add_shelf_success'));
            } else if (this.isAddSuccess) {
              //   再次点击从书架删除
              await this.addBook2Shelf(false, $r('app.string.del_shelf_success'));
            }
          })

        ShareBookCard({ book: this.book })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width(Constants.FULL_SIZE)
    .padding({
      top: this.windowTopHeight + 8,
      left: 18,
      right: 18,
      bottom: 8
    })
  }
}