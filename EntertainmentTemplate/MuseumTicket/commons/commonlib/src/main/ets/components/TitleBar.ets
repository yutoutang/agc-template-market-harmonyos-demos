import { RouterModule } from '../utils/RouterModule';

@ComponentV2
export struct TitleBar {
  @Param text: string = '';

  build() {
    Row({ space: 8 }) {
      Row() {
        Image($r('app.media.title_left')).width(9).height(16);
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        RouterModule.pop();
      });

      Text(this.text)
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'));
    }.height(56).width('100%').padding({ left: 16, right: 16 });
  }
}