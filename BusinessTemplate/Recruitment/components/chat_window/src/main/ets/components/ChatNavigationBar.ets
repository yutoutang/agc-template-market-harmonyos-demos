import { AppStorageV2 } from '@kit.ArkUI'
import { ChatBreakpoint } from 'chat_base';

@ComponentV2
export struct ChatNavigationBar {
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param title: string = ''
  @Param companyName: string = ''
  @Param fontWightParam: FontWeight | number = 700
  @Param backgroundColorParam: ResourceStr | undefined = $r('sys.color.background_secondary')
  @Param rowFlexAlign: FlexAlign | undefined = FlexAlign.Start
  @Param leftImageMargin: Length | undefined = undefined;
  @Param isShowLeftImage: boolean = true;
  @Param @Require onReturnClick?: () => void
  @Param rightImageRes: Resource | undefined = undefined
  @Param rightImageMargin: Length | undefined = undefined;
  @Param isShowRightImage: boolean = false;
  @Local isShowMenu: boolean = false;
  @Param menuList: MenuElement[] = [];
  @Event rightOnClick: () => void = () => {
  }

  build() {
    Column() {
      Row() {
        if (this.isShowLeftImage) {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontSize($r('app.float.vp_24'))
              .fontColor([$r('sys.color.icon_primary')])
              .fontWeight(FontWeight.Normal)
          }
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ left: this.leftImageMargin ?? this.chatBreakpoint.pagePadding })
          .type(ButtonType.Circle)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            if (this.onReturnClick) {
              this.onReturnClick?.()
            }
          })
        }
        Column() {
          Text(this.title)
            .size({ height: $r('app.float.vp_40') })
            .fontSize(20)
            .fontWeight(this.fontWightParam)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
            .margin({
              left: this.isShowLeftImage ?
                this.chatBreakpoint.pagePadding / 2 :
              this.leftImageMargin
            })
            .width('80%')
          if (this.companyName) {
            Text(this.companyName)
              .size({ height: $r('app.float.vp_40') })
              .fontSize(14)
              .fontColor('rgba(0,0,0,0.6)')
              .layoutWeight(1)
              .maxLines(1)
              .textAlign(TextAlign.Start)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('80%')
              .margin({
                left: this.isShowLeftImage ?
                  this.chatBreakpoint.pagePadding / 2 :
                this.leftImageMargin,
              })
          }
        }


        if (this.isShowRightImage) {
          Image(this.rightImageRes)
            .size({ width: 24, height: 24 })
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
          Blank().width(this.rightImageMargin ?? this.chatBreakpoint.pagePadding)
        }
      }
      .height(46)
      .width('100%')
      .justifyContent(this.rowFlexAlign)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.backgroundColorParam)

      Blank().height($r('app.float.vp_12'))
    }
    .width('100%')
    .height($r('app.float.vp_52'))
  }
}