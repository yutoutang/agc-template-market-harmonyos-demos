import { hide } from '@abner/dialog';

@Builder
export function addMineDialog() {
  Column() {
    Text('温馨提示').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_primary'));
    Text('已成功添加到我的卡包')
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .margin({ top: 28, bottom: 20 });
    Text('我知道了').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_emphasize')).onClick(() => {
      hide();
    });
  }
  .alignItems(HorizontalAlign.Center)
  .borderRadius(32)
  .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK, {
    colorMode: ThemeColorMode.LIGHT,
    adaptiveColor: AdaptiveColor.DEFAULT,
    scale: 1.0
  })
  .width('90%')
  .padding(16)
  .height(160)
  .justifyContent(FlexAlign.Center);
}