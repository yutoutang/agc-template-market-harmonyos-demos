import { AppStorageV2 } from '@kit.ArkUI'
import { BreakpointModel, TempBarHeight } from 'common';

@ComponentV2
export struct AddressBookNavigationBar {
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column() {
      Text($r('app.string.addressbook_main_title'))
        .fontSize(26)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
        .lineHeight($r('app.float.vp_30'))
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({top: this.tempBarHeight.topTempValue, left: this.breakPointModel.pagePadding})
    .height(56 + this.tempBarHeight.topTempValue)
  }
}