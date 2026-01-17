import {
  BookApi,
  BookInfo,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  GetBookApiRsp,
  NavHeaderBar,
  TSearch,
  WindowUtils
} from 'common';
import { BookListCard } from '../comps/BookListCard';

import { BookSwiperCard } from '../comps/BookSwiperCard';
import { BookViewCard } from '../comps/BookViewCard';
import { BookWaterFlowCard } from '../comps/BookWaterFlowCard';
import { LazyDataVM } from 'swiper_card';

@Builder
export function BookListPageBuilder() {
  BookListPage();
}


@ComponentV2
export struct BookListPage {
  @Local books: LazyDataVM<BookInfo> | undefined = undefined;
  @Local recommendBooks: LazyDataVM<BookInfo> | undefined = undefined;
  @Local swiperImg: Resource[] = new Array(4).fill('').map((item: string, index) => {
    return index % 2 ? $r(`app.media.swiper_list_0`) : $r(`app.media.swiper_list_1`)
  })
  @Local categoryText: Resource[] = [];
  @Local currentIndex: number = 0;
  @Param currentNumber: number = 0;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  async aboutToAppear(): Promise<void> {
    await this.getHomeBooks();
    await this.getRecommendBooks();
    this.categoryText.push($r('app.string.recommend'));
    this.categoryText.push($r('app.string.boys_channel'));
    this.categoryText.push($r('app.string.girls_channel'));
  }

  async getHomeBooks() {
    const rsp: GetBookApiRsp = await BookApi.getBookList();
    this.books = new LazyDataVM<BookInfo>(rsp.books);
  }

  async getRecommendBooks() {
    const rsp: GetBookApiRsp = await BookApi.getRecommendBookList();
    this.recommendBooks = new LazyDataVM<BookInfo>(rsp.books);
  }

  // 区分各类频道
  async filterBook(status: string) {
    const rsp: GetBookApiRsp = await BookApi.getBookList();
    let tmp: BookInfo[] = [];
    for (let i = 0; i < rsp.books.length; i++) {
      if (rsp.books[i].gender === status) {
        tmp.push(rsp.books[i]);
      }
    }
    this.books = new LazyDataVM<BookInfo>(tmp);
  }

  @Builder
  swiperInfo() {
    Swiper() {
      ForEach(this.swiperImg, (item: Resource) => {
        Image(item)
          .height(168)
          .width(Constants.FULL_SIZE)
          .borderRadius(10)
      }, (item: string) => new Date().toString())
    }
    .autoPlay(true)
    .padding({ top: 20, left: 18, right: 18 })
  }

  @Builder
  categoryTab() {
    Row() {
      ForEach(this.categoryText, (item: ResourceStr, index: number) => {
        Text(item)
          .textAlign(TextAlign.Center)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(this.currentIndex === index ? Color.White : $r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .height(36)
          .width(96)
          .backgroundColor(this.currentIndex === index ? Color.Black : '#0d000000')
          .borderRadius(21)
          .onClick(async () => {
            this.currentIndex = index
            if (index === 0) {
              await this.getHomeBooks();
            } else if (index === 1) {
              // await this.getHomeBooks();
              await this.filterBook('2');
            } else {
              // await this.getHomeBooks();
              await this.filterBook('1');
            }
          })
      }, (item: string) => new Date().toString())
    }
    .padding({
      top: 10,
      bottom: 10,
      left: 16,
      right: 16
    })
    .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? Constants.FULL_SIZE : '50%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  bookList(books: LazyDataVM<BookInfo> | undefined, recommendBooks: LazyDataVM<BookInfo> | undefined) {
    BookListCard({ books: recommendBooks, categoryName: $r('app.string.daily_recommendation') });
    BookViewCard({ books: books, categoryName: $r('app.string.recommend_for_you') });
  }

  @Builder
  dailyRecommendation(books: LazyDataVM<BookInfo> | undefined) {
    BookListCard({ books: books, categoryName: $r('app.string.daily_recommendation') });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        NavHeaderBar({
          title: $r('app.string.book_case'),
          hasBackButton: false,
          hasBgColor: false,
          isMainPage: true,
          isSearch: true
        })

        Scroll() {
          Column() {
            Column() {
              this.categoryTab();
            }
            .alignSelf(ItemAlign.Start)

            BookSwiperCard({ books: this.books });

            if (this.currentIndex === 0) {
              this.bookList(this.books, this.recommendBooks);
            } else if (this.currentIndex === 1) {
              this.bookList(this.books, this.recommendBooks);
            } else {
              this.bookList(this.books, this.recommendBooks);
            }
          }
        }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
      }
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor('#F1F3F5')
  }
}