import { Constants } from '../constant/Constants'
import { TCRouter } from '../comp/TCRouter'
import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, DialogParams, TSearch } from '../../../../Index';
import { SymbolGlyphModifier } from '@kit.ArkUI';

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

@Builder
export function BookCover(image?: PixelMap | ResourceStr | DrawableDescriptor, isFree?: string) {
  Stack({ alignContent: Alignment.TopEnd }) {
    Image($r(image?.toString()))
      .height(144)
      .width(104)
      .objectFit(ImageFit.Auto)
      .borderRadius(10)
    Column() {
      Text(getFreeText(isFree))
        .fontSize(10)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .height(20)
        .width(35)
        .backgroundColor(getFreeColor(isFree))
        .borderRadius(10)
    }
    .padding(8)
  }
}


@Builder
export function BookLikeCover(image?: PixelMap | ResourceStr | DrawableDescriptor, isFree?: string) {

  Stack() {
    Image($r(image?.toString()))
      .height(120)
      .width(88)
      .objectFit(ImageFit.Auto)
      .borderRadius(10)
    Column() {
      Text(getFreeText(isFree))
        .fontSize(10)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .height(20)
        .width(35)
        .backgroundColor(getFreeColor(isFree))
        .borderRadius(10)
    }
    .padding({ bottom: 110, left: 45 })
  }
}

@Builder
export function BookGroupCover(image?: PixelMap | ResourceStr | DrawableDescriptor) {

  Stack() {
    Image($r(image?.toString()))
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Auto)
      .borderRadius(5)
      .backgroundColor(Color.White)

  }
}


@ComponentV2
export struct ReturnButton {
  build() {
    Button() {
      SymbolGlyph($r('sys.symbol.chevron_backward'))
        .fontSize(24)
    }
    .width(40)
    .height(40)
    .padding({
      top: 8,
      left: 8,
      right: 8,
      bottom: 8
    })
    .borderRadius(1000)
    .backgroundColor('#0D000000')
    .onClick(() => {
      TCRouter.pop();
    })
  }
}


@ComponentV2
export struct NavHeaderBar {
  @Param title: ResourceStr | string = 'default';
  @Param hasBackButton: boolean = true;
  @Param hasBgColor: boolean = true;
  @Param backImg: ResourceStr = $r('app.media.ic_back');
  @Param hasBackgroundImg: boolean = true;
  @Param isMainPage: boolean = false;
  @Consumer('tabController') tabsController: TabsController = new TabsController();
  @Consumer('currentIndexTab') currentIndexTab: number = 0;
  @Consumer('isHistory') isHistory: boolean = false;
  // 搜索框
  @Param isSearch: boolean = false;
  // 书架页title
  @Param isShelf: boolean = false;
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77
  @Consumer('isGrid') isGrid: boolean = true;
  @Consumer('isDeleteShelf') isDeleteShelf: boolean = false;
  @Local isShown: boolean = false;
  @Event gridSheet: () => void = () => {
    this.isGrid = true;
    this.isShown = false;
  }
  @Event listSheet: () => void = () => {
    this.isGrid = false;
    this.isShown = false;
  }
  @Event trashSheet: () => void = () => {
    if (this.isDeleteShelf === false) {
      this.isDeleteShelf = true;
    } else {
      this.isDeleteShelf = false;
    }
    this.isShown = false;
  }
  @Local gridIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.square_grid_2x2'));
  @Local listIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.list_square'));
  @Local trashIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.trash'));
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  @Builder
  selectMenu() {
    Menu() {
      MenuItemGroup({ header: '书籍管理' }) {
        MenuItem({
          symbolStartIcon: this.gridIconModifier,
          content: '宫格模式',
          builder: this.gridSheet
        })
        MenuItem({
          symbolStartIcon: this.listIconModifier,
          content: '列表模式',
          builder: this.listSheet
        })
        MenuItem({
          symbolStartIcon: this.trashIconModifier,
          content: '删除',
          builder: this.trashSheet
        })
      }
    }
    .width(224)
  }

  build() {
    Column() {
      Row() {
        Row() {
          if (this.hasBackButton) {
            Image(this.backImg)
              .width(40)
              .height(40)
              .onClick(() => {
                TCRouter.pop();
              })
              .margin({ right: 12 })
          }
          Text(this.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(this.isMainPage ? $r('sys.float.Title_M') : $r('sys.float.Title_S'))
            .fontWeight(FontWeight.Medium)
        }

        if (this.isSearch) {
          Row() {
            TSearch({ widthLength: '100%' })
              .margin({ left: 24, right: 8 })
              .layoutWeight(1)
            Image($r('app.media.icon_history'))
              .height(40)
              .width(40)
              .onClick(() => {
                this.currentIndexTab = 0;
                this.tabsController.changeIndex(0)
                this.isHistory = true
              })
          }
          .layoutWeight(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 1 : 0)
          .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 'auto' : '50%')
        }
        if (this.isShelf) {
          Row() {
            Image($r('app.media.icon_shelf_search'))
              .height(40)
              .width(40)
              .margin({ right: 8 })
              .onClick(() => {
                TCRouter.push(Constants.SEARCH_ROUTE);
              })
            Image($r('app.media.icon_filled'))
              .height(40)
              .width(40)
              .onClick(() => {
                this.isShown = true
              })
              .bindContextMenu(this.isShown, this.selectMenu(), {
                aboutToDisappear: () => {
                  this.isShown = false
                }
              })

          }
        }
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .margin({ top: this.windowTopHeight })
    .padding({
      top: 8,
      bottom: 8,
      left: 16,
      right: 16
    })
    .width(Constants.FULL_SIZE)
    .height(56)
    .backgroundColor(this.hasBgColor ? $r('sys.color.background_primary') : '#00000000')
  }
}

/*
 * 弹窗
 * */
@Builder
export function dialogView(params: DialogParams) {

  Column() {
    Column() {
      Text(params.title)
        .fontSize(20)
        .fontColor('#323233')
        .width(263)
        .textAlign(TextAlign.Center)

      if (params.input) {
        TextInput({ text: params.content, placeholder: '请输入分组名称（最多12个文字）' })
          .width('100%')
          .maxLength(12)
          .onChange((value: string) => {
            params.content = value
          })
          .margin({ top: 15, bottom: 8 });
      } else {
        Text(params.content)
          .fontSize(14)
          .width('100%')
          .fontColor('#969799')
          .textAlign(TextAlign.Center)
          .margin({ top: 27, bottom: 12 })
      }

    }

    Row() {

      Button(params.leftButtonText)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.white'))
        .padding({
          left: 50,
          right: 50,
          top: 12,
          bottom: 12
        })
        .onClick(() => {
          params.leftEvent();
        });
      Button(params.rightButtonText)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('app.color.font_overdue'))
        .padding({
          left: 50,
          right: 50,
          top: 12,
          bottom: 12
        })
        .onClick(() => {
          if (params.input) {
            params.rightEvent(params.content);
          } else {
            params.rightEvent();
          }

        });
    }
    .padding({
      left: 4,
      right: 4
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }
  .width(328)
  .padding({
    top: 16,
    bottom: 16,
    right: 12,
    left: 12
  })
  .backgroundColor($r('sys.color.white'))
  .borderRadius(16);
}