import { TCRouter } from '../comp/TCRouter';
import { Constants } from '../constant/Constants';
import { BookInfo, GroupBook } from '../model/Book';
import { BookSubcategory } from '../model/BookSortInfo';
import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { BookCover, BookGroupCover, BookLikeCover } from './CommonUI';
import { LengthMetrics } from '@kit.ArkUI';


export interface CategoryInfo {
  category: string;
  isCategory: boolean
}
function getFreeText(isFree?: string): string | null {
  switch (isFree) {
    case '0':
      return '免费';
    case '1':
      return '会员';
    case '2':
      return '付费';
    default:
      return null;
  }
}

function getFreeColor(isFree?: string): string | null {
  switch (isFree) {
    case '0':
      return '#64BB5C';
    case '1':
      return '#F9A01E';
    case '2':
      return '#E84026';
    default:
      return null;
  }
}
/**
 * 图书小卡，仅有图片+书名 换行：评分+类型
 */
@ComponentV2
export struct BookLittleCardHome {
  @Param info: BookInfo | undefined = undefined;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($r(this.info?.coverUrl?.toString()))
          .width(this.curBreakpoint.value === BreakpointTypeEnum.SM?104:164)
          .height(this.curBreakpoint.value === BreakpointTypeEnum.SM?144:214)
          .objectFit(ImageFit.Auto)
          .borderRadius(10)
        Column() {
          Text(getFreeText(this.info?.isFree))
            .fontSize(10)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .height(20)
            .width(35)
            .backgroundColor(getFreeColor(this.info?.isFree))
            .borderRadius(10)
        }
        .padding(8)
      }
      Text(this.info?.name)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(this.curBreakpoint.value === BreakpointTypeEnum.SM?104:164)
        .textAlign(TextAlign.Start)
        .padding({ top: 5 })
      Row() {
        Text(this.info?.rate)
          .fontSize(12)
          .fontColor($r('sys.color.mask_secondary'))
        Text(this.info?.category)
          .fontSize(12)
          .fontColor($r('sys.color.mask_secondary'))
      }
      .width(this.curBreakpoint.value === BreakpointTypeEnum.SM?104:164)
      .align(Alignment.Start)
      .margin({ top: 8 })
    }
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}

/**
 * 图书猜你喜欢小卡
 */
@ComponentV2
export struct BookLittleCard {
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Param @Require info: BookInfo;
  @Event manageEvent: (book: BookInfo, isShowM: boolean) => void = (book: BookInfo, isShowM: boolean) => {
  };

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($r(this.info?.coverUrl?.toString()))
          .width(this.curBreakpoint.value === BreakpointTypeEnum.SM?104:164)
          .height(this.curBreakpoint.value === BreakpointTypeEnum.SM?144:214)
          .objectFit(ImageFit.Auto)
          .borderRadius(10)
        Column() {
          Text(getFreeText(this.info?.isFree))
            .fontSize(10)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .height(20)
            .width(35)
            .backgroundColor(getFreeColor(this.info?.isFree))
            .borderRadius(10)
        }
        .padding(8)
      }
      Text(this.info?.name)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(this.curBreakpoint.value === BreakpointTypeEnum.SM?104:164)
        .textAlign(TextAlign.Start)
        .padding({ top: 5 })
      Row() {
        Row() {
          Text(this.info?.rate)
            .fontSize(12)
            .fontColor($r('sys.color.mask_secondary'))
          Text(this.info?.category)
            .fontSize(12)
            .fontColor($r('sys.color.mask_secondary'))
        }

        Row() {
          Image($r('app.media.ic_public_ellipsis'))
            .height(12)
            .width(12)
            .objectFit(ImageFit.Auto)
        }.width(30).justifyContent(FlexAlign.End)
        .onClick(() => {
          this.manageEvent(this.info as BookInfo, true);
        })
      }
      .width(this.curBreakpoint.value === BreakpointTypeEnum.SM?104:164)
      .align(Alignment.Start)
      .margin({ top: 4 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}


/**
 * 管理书籍-猜你喜欢
 */
@ComponentV2
export struct BookLikeCard {
  @Param @Require info: BookInfo;
  @Event showEvent: (isShow: boolean) => void = (isShow: boolean) => {

  }

  build() {
    Column() {
      BookLikeCover(this.info?.coverUrl, this.info?.isFree);
      Text(this.info?.name)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(104)
        .textAlign(TextAlign.Start)
        .padding({ top: 5 })


    }
    .width(104)
    .align(Alignment.Start)
    .margin({ top: 4 })
    .justifyContent(FlexAlign.SpaceBetween)

    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
        this.showEvent(false)

      }
    })
  }
}


/**
 *  宫格模式图书组合打卡
 */
@ComponentV2
export struct BookGroupCard {
  @Param info: GroupBook | undefined = undefined;
  @Local numbers1: number[] = [1, 2, 3, 4];
  @Local numbers2: BookInfo[] = [];
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  build() {
    Column() {

      Column() {
        Grid() {
          ForEach(this.info?.groupBooks, (item: BookInfo) => {
            GridItem() {
              BookGroupCover(item.coverUrl);
            }
            .width(this.curBreakpoint.value === BreakpointTypeEnum.SM?40:64)
            .height(this.curBreakpoint.value === BreakpointTypeEnum.SM?56:89)

          }, (item: string) => JSON.stringify(item))

        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
      }
      .width(this.curBreakpoint.value === BreakpointTypeEnum.SM?104:164)
      .height(this.curBreakpoint.value === BreakpointTypeEnum.SM?144:214)
      .borderRadius(10)
      .backgroundColor(Color.White)


      Text(this.info?.groupName)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(104)
        .textAlign(TextAlign.Start)
        .padding({ top: 5 })
      Row() {
        if (this.info?.groupBooks?.length) {
          Text('共' + this.info?.groupBooks?.length.toString() + '本')
            .fontSize(12)
            .fontColor($r('sys.color.mask_secondary'))
        } else {
          Text('共' + 0 + '本')
            .fontSize(12)
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .width(104)
      .align(Alignment.Start)
      .margin({ top: 4 })
    }
  }
}

/**
 * 图书大卡，书名、介绍、评分
 */
@ComponentV2
export struct BookBigCard {
  @Param info: BookInfo | undefined = undefined;

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceBetween,
      space: { main: LengthMetrics.vp(12) }
    }) {
      BookCover(this.info?.coverUrl, this.info?.isFree);

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
        Column() {
          Row() {
            Text(this.info?.name)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
            Row() {
              Image($r('app.media.ic_public_star'))
                .height(15)
                .width(20)
                .padding({ right: 4 })
              Text(`${this.info?.rate}`)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
            }
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)

          Text(this.info?.description)
            .maxLines(3)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .padding({ top: 10, bottom: 20 })
            .alignSelf(ItemAlign.Start)
        }

        Column() {
          Text('作者：' + this.info?.author)
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .width('100%')
        }
        .margin({ top: 20 })

      }
      .layoutWeight(1)
    }
    .padding({ left: 12, right: 12 })
    .height(150)
    .width(Constants.FULL_SIZE)
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}

/**
 * 图书类别，图片、类别名
 */
@ComponentV2
export struct BookCategoryItem {
  @Param categoryInfo: BookSubcategory | undefined = undefined;
  @Local pushParam?: CategoryInfo

  build() {
    Column() {
      if (this.categoryInfo?.imgUrl) {
        Column() {
          Image($r(this.categoryInfo?.imgUrl?.toString()))
            .height(70)
            .width(70)
            .borderRadius(8)
          Text(this.categoryInfo?.subcategoryName)
            .fontSize(14)
            .width(70)
            .textAlign(TextAlign.Center)
        }
        .onClick(() => {
          this.pushParam = { category: this.categoryInfo?.subcategoryName!, isCategory: true }
          TCRouter.push(Constants.SEARCH_ROUTE, this.pushParam)
        })
      } else {
        Row() {
          Text(this.categoryInfo?.subcategoryName)
            .fontSize(14)
        }
        .height(28)
        .width(70)
        .borderRadius(14)
        .backgroundColor('#0d000000')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.pushParam = { category: this.categoryInfo?.subcategoryName!, isCategory: true }
          TCRouter.push(Constants.SEARCH_ROUTE, this.pushParam)
        })
      }
    }
  }
}

/**
 * 列表模式分组
 */
@ComponentV2
export struct GroupListCard {
  @Param info: GroupBook | undefined = undefined;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
      Grid() {
        ForEach(this.info?.groupBooks, (item: BookInfo) => {
          GridItem() {
            BookGroupCover(item.coverUrl);
          }
          .width(40)
          .height(56)

        }, (item: string) => JSON.stringify(item))

      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .height(144)
      .width(104)
      .borderRadius(10)
      .backgroundColor(Color.White)

      Blank()
        .width(16)
      Column() {

        Text(this.info?.groupName)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(104)
          .textAlign(TextAlign.Start)
          .padding({ top: 5 })

        Text('共' + this.info?.groupBooks?.length.toString() + '本')
          .fontSize(12)
          .fontColor($r('sys.color.mask_secondary'))

      }
      .height(150)
      .padding({
        bottom: 5
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
    }
    .height(150)
    .width(Constants.FULL_SIZE)
  }
}


/**
 * 组合card
 */
@ComponentV2
export struct GroupBookCheckCard {
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Param info: BookInfo | undefined = undefined;
  @Local isSelect: boolean = false;
  @Event manageGroupEvent: (book: BookInfo, isShowM: boolean) => void = (book: BookInfo, isShowM: boolean) => {
  };

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceBetween,
      space: { main: LengthMetrics.vp(12) }
    }) {
      BookCover(this.info?.coverUrl);

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
        Column() {
          Row() {
            Text(this.info?.name)
              .fontSize($r('sys.float.Subtitle_M'))
              .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
            Row() {
              Text(`${this.info?.rate}` + '分')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
            }.padding({ right: 30 })
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Row() {
              Text(this.info?.description)
                .maxLines(8).fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Regular)
            }.justifyContent(FlexAlign.Start).width(200)

            Row() {
              Image(this.isSelect ? $r('app.media.selected_yes') : $r('app.media.selected_no'))
                .height(20)
                .width(20)
            }.width(30).height(30).margin({ right: 5 })

          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            if (this.isSelect) {
              this.isSelect = false
            } else {
              this.isSelect = true
            }
            this.manageGroupEvent(this.info as BookInfo, this.isSelect);
          })
          .margin({ top: 10, right: 0 })

        }

        Column() {
          Row() {
            Text(this.info?.category)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular).textAlign(TextAlign.Start)

            Text(this.info?.count)
              .fontSize(12)
              .textAlign(TextAlign.Start)
              .padding({ left: 10 })
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
          }.width('100%').justifyContent(FlexAlign.Start)

        }
        .margin({ top: 20 })
      }
      .layoutWeight(1)
    }
    .height(150)
    .width(Constants.FULL_SIZE)
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}

/*
 * 列表组合card
 * */
@ComponentV2
export struct bookShelfCard {
  @Param @Require info: BookInfo;
  @Event manageEvent: (book: BookInfo, isShowM: boolean) => void = (book: BookInfo, isShowM: boolean) => {
  };

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceBetween,
      space: { main: LengthMetrics.vp(12) }
    }) {
      BookCover(this.info?.coverUrl);

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
        Column() {
          Row() {
            Text(this.info?.name)
              .fontSize($r('sys.float.Subtitle_M'))
              .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
            Row() {
              Text(`${this.info?.rate}` + '分')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
            }
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)

          Text(this.info?.description)
            .maxLines(3)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .padding({ top: 10, bottom: 20 })
            .alignSelf(ItemAlign.Start)
        }

        Row() {
          Row() {
            Text(this.info?.category)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular).textAlign(TextAlign.Start)

            Text(this.info?.count)
              .fontSize(12)
              .textAlign(TextAlign.Start)
              .padding({ left: 10 })
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
          }

          Row() {
            Image($r('app.media.ic_public_ellipsis'))
              .height(12)
              .width(12)
              .objectFit(ImageFit.Auto)
          }.width(30).justifyContent(FlexAlign.End)
          .onClick(() => {
            this.manageEvent(this.info as BookInfo, true);
          })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .margin({ top: 20 })
      }
      .layoutWeight(1)
    }
    .height(150)
    .width(Constants.FULL_SIZE)
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}

/**
 * 图书小卡，仅有图片+书名 换行：评分+类型
 */
@ComponentV2
export struct BookHomeCard {
  @Param info: BookInfo | undefined = undefined;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  build() {
    Column() {
      BookCover(this.info?.coverUrl, this.info?.isFree);
      Text(this.info?.name)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(104)
        .textAlign(TextAlign.Start)
        .padding({ top: 5 })
      Row() {
        Text(this.info?.rate)
          .fontSize(12)
          .fontColor($r('sys.color.mask_secondary'))
        Text(this.info?.category)
          .fontSize(12)
          .fontColor($r('sys.color.mask_secondary'))
      }
      .width(104)
      .align(Alignment.Start)
      .margin({ top: 4 })
    }
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}