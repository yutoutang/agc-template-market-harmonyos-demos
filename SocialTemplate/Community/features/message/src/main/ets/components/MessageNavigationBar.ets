import { AppStorageV2 } from '@kit.ArkUI'
import { BreakpointModel, TempBarHeight } from 'common';

@ComponentV2
export struct MessageNavigationBar {
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Param title: string = ''
  @Param menuList: MenuElement[] = [];
  @Local isShowMenu: boolean = false;
  @Event onSearchClick: () => void = () => {
  }

  build() {
    Column() {
      Blank().height(this.tempBarHeight.topTempValue);
      Row() {
        Text($r('app.string.message_main_title'))
          .fontSize(26)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .lineHeight($r('app.float.vp_30'))

        Blank().layoutWeight(1)
        Image($r('app.media.message_search_icon'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .objectFit(ImageFit.Fill)
          .onClick(() => {
            this.onSearchClick();
          })

        Blank().width($r('app.float.vp_8'))
        Image($r('app.media.message_more_icon'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .objectFit(ImageFit.Fill)
          .onClick(() => {
            this.isShowMenu = !this.isShowMenu;
          })
          .bindMenu(this.isShowMenu, this.menuList,
            {
              placement: Placement.BottomRight,
              onDisappear: () => {
                this.isShowMenu = false;
              }
            })
      }
      .layoutWeight(1)
      .width('100%')
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
    }
    .width('100%')
    .height(56 + this.tempBarHeight.topTempValue)
  }
}