import { CommonHeader } from '../components/CommonHeader';
import { ThemeSwiper } from '../components/ThemeSwiper';
import { THEME_LIST } from '../constants/Constants';
import { IThemeInfo } from '../types/Types';
import { ThemeController } from '../utils/ThemeController';
import { WindowUtil } from '../utils/WindowUtil';

@ComponentV2
export struct ThemeListPage {
  @Local stack: NavPathStack | undefined;

  build() {
    NavDestination() {
      CommonHeader({ title: '个性主题', stack: this.stack })

      Scroll() {
        Column() {
          ThemeSwiper({
            imgWidth: 135,
            imgHeight: 280,
            imgList: ThemeController.themePics,
            isLoop: true,
            onImageClick: () => {
              this.stack?.pushPathByName('ThemeDetail', ThemeController.getThemeId());
            },
          })

          Text(ThemeController.themeLabel)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .margin({ bottom: 8, top: 8 })

          Text('使用中')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize($r('sys.float.Body_M'))
            .width(88)
            .height(28)
            .borderRadius('50%')
            .textAlign(TextAlign.Center)
            .backgroundColor('#3F7EF7')

          Grid() {
            ForEach(THEME_LIST, (theme: IThemeInfo) => {
              GridItem() {
                Column({ space: 8 }) {
                  Image($r(`app.media.${theme.pics[0]}`))
                    .width('100%')
                    .height(212)
                    .borderRadius(16)
                    .onClick(() => {
                      this.stack?.pushPathByName('ThemeDetail', theme.id);
                    })

                  Row() {
                    Text(theme.label)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .fontSize($r('sys.float.Body_M'))

                    Text(ThemeController.getThemeId() === theme.id ? '使用中' : '使用')
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_emphasize'))
                      .fontSize($r('sys.float.Body_M'))
                      .width(72)
                      .height(28)
                      .borderRadius('50%')
                      .textAlign(TextAlign.Center)
                      .backgroundColor($r('sys.color.comp_background_tertiary'))
                      .onClick(() => {
                        ThemeController.change(theme.id);
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                }
              }
            }, (theme: IThemeInfo, index) => JSON.stringify(theme) + '_' + index)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .scrollBar(BarState.Off)
          .padding({ top: 24, bottom: WindowUtil.getAvoidArea().bottom })

          Blank().layoutWeight(1)
        }
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_primary'))
    .onReady(res => {
      this.stack = res.pathStack;
    })
  }
}


@Builder
export function themeListPageBuilder() {
  ThemeListPage()
}