import { LoginSheetUtils } from 'lib_account'
import { ContainerColumn } from 'lib_widget'

@Builder
export function buildNoCarCard(isLogin: boolean = false) {
  ContainerColumn() {
    Image($r('app.media.empty_status_logo'))
      .width(160)
      .height(160)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .margin({ bottom: $r('app.float.space_l') })
    Text(isLogin ? '快去加购喜欢的商品吧' : '登陆后可同步购物车中的商品')
      .fontSize($r('app.float.font_size_14'))
      .fontColor($r('sys.color.mask_secondary'))
    Button('登录')
      .width(100)
      .height(38)
      .backgroundColor($r('app.color.app_theme'))
      .fontColor($r('sys.color.comp_background_list_card'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .borderRadius($r('app.float.radius_20'))
      .margin({ top: $r('app.float.space_m') })
      .visibility(isLogin ? Visibility.None : Visibility.Visible)
      .onClick(() => {
        LoginSheetUtils.open()
      })
    Blank().height($r('app.float.space_l'))
  }
}