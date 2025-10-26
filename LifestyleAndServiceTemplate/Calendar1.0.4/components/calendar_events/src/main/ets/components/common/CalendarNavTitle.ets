import { BaseTextStyleModifier } from 'base_apis'
import { ThemeVM } from '../../viewModel/ThemeController'
import CalendarEventVM from '../../viewModel/ViewModel'

@ComponentV2
export struct CalendarNavTitle {
  @Param title: ResourceStr = ''
  @Param bgImage: ResourceStr = ''
  @Local titleColor: ResourceStr = '#ffffff'
  @Local selectColor: ResourceStr = '#c4272b'
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local themeVM: ThemeVM = ThemeVM.instance;
  aboutToAppear(): void {
    this.titleColor = this.themeVM.titleColor
    this.selectColor = this.themeVM.selectColor
  }

  build() {
    Row({ space: 8 }) {
      Row() {
        Image($r('app.media.left')).width(24).height(24)
      }
      .width(40)
      .justifyContent(FlexAlign.Center)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius('50%')

      Text(this.title)
        .attributeModifier(new BaseTextStyleModifier(`${this.titleColor}/Title_S/Bold`))
    }
    .height(102)
    .width('100%')
    .onClick(() => {
      this.calendarEventVM.getPageInfo()?.pop()
    })
    .padding({ top: Number(AppStorage.get('topRectHeight')), left: 16, right: 16 })
    .backgroundColor(this.selectColor)
    .backgroundImage(this.bgImage)
    .backgroundImageSize(ImageSize.Cover)
  }
}