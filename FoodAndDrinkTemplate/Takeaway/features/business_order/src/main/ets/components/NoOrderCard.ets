import { ContainerColumn } from 'lib_widget'

@Builder
export function buildNoOrderCard(canJump: boolean = false) {
  ContainerColumn() {
    Image($r('app.media.empty_status_logo'))
      .width(160)
      .height(160)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .margin({ bottom: $r('app.float.space_l') })
    Text('还没有相关的订单哟')
      .fontSize($r('app.float.font_size_14'))
      .fontColor($r('sys.color.mask_secondary'))
    if (canJump) {
      Text('快去首页选购心仪的商品吧~')
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('sys.color.mask_secondary'))
        .margin({ bottom: $r('app.float.space_xl') })
      Button('去选购')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.theme_color'))
        .width($r('app.string.size_percent_half'))
    }
    Blank().height($r('app.float.space_l'))
  }
}