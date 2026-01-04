import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, TempBarHeight } from 'common';

@ComponentV2
export struct MessageNavigationBar {
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Param title: string = ''
  @Local isShowMenu: boolean = false;
  @Event cleanUnreadMessageCount: () => void = () => {
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
        Image($r('app.media.clean_icon'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            this.cleanUnreadMessageCount();
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