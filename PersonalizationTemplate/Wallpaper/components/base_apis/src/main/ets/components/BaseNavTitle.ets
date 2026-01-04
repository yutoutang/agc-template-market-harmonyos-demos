import { BaseTextStyleModifier } from '../model/TextStyleModifier';

@ComponentV2
export struct BaseNavTitle {
  @Param title: ResourceStr = ''
  @Param bgImage: ResourceStr = ''
  @Param routerModule: NavPathStack = new NavPathStack()
  @Param titleColor: ResourceStr = '#ffffff'
  @Param currentTheme: ResourceStr = '#c4272b'

  build() {
    Row({ space: 8 }) {
      Row() {
        Image($r('app.media.left')).width(24).height(24)
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius('50%')
      .justifyContent(FlexAlign.Center)

      Text(this.title)
        .attributeModifier(new BaseTextStyleModifier(`${this.titleColor}/Title_S/Bold`))
    }
    .height(102)
    .width('100%')
    .onClick(() => {
      this.routerModule.pop()
    })
    .padding({ top: Number(AppStorage.get('topRectHeight')), left: 16, right: 16 })
    .backgroundImage(this.bgImage)
    .backgroundImageSize(ImageSize.Cover)
    .backgroundColor(this.currentTheme)
  }
}