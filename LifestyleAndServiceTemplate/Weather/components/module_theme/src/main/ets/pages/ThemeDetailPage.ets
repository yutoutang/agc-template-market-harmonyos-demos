import { CommonHeader } from '../components/CommonHeader';
import { ThemeSwiper } from '../components/ThemeSwiper';
import { IThemeInfo } from '../types/Types';
import { ThemeController } from '../utils/ThemeController';
import { WindowUtil } from '../utils/WindowUtil';

@ComponentV2
export struct ThemeDetailPage {
  @Local stack: NavPathStack | undefined;
  @Local theme: IThemeInfo | undefined;
  @Local themePics: Resource[] = [];

  build() {
    NavDestination() {
      CommonHeader({ title: this.theme?.label, stack: this.stack })

      Scroll() {
        Column() {
          ThemeSwiper({
            imgWidth: 188,
            imgHeight: 400,
            imgList: this.themePics,
            shadowRatio: 2,
            indicator: true,
            isLoop: true,
            autoPlay: true,
          })

          Text(this.theme?.label)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .margin({ top: 56, bottom: 8 })

          Text(this.theme?.desc)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))

          Blank().layoutWeight(1)
        }
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      Text(ThemeController.getThemeId() === this.theme?.id ? '使用中' : '立即使用')
        .width('calc(100% - 32vp)')
        .backgroundColor('#3F7EF7')
        .height(40)
        .borderRadius('50%')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .textAlign(TextAlign.Center)
        .onClick(() => {
          ThemeController.change(this.theme!.id);
        })
    }
    .hideTitleBar(true)
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
    .backgroundColor($r('sys.color.background_primary'))
    .onReady(res => {
      this.stack = res.pathStack;
      const id = (this.stack.getParamByName('ThemeDetail') as number[]).pop()!;
      this.theme = ThemeController.getThemeById(id);
      this.themePics = ThemeController.getThemePicsById(id);
    })
  }
}


@Builder
export function themeDetailPageBuilder() {
  ThemeDetailPage()
}