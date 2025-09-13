import { BaseTextStyleModifier } from '../../model/TextStyleModifier'
import CalendarEventVM from '../../viewModel/ViewModel'

@ComponentV2
export struct CalendarNavTitle {
  @Param title: ResourceStr = ''
  @Local titleColor: ResourceStr = $r('sys.color.background_primary')
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @BuilderParam rightBuilder?: () => void;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Row({ space: 8 }) {
        Row() {
          Image($r('app.media.back_left')).width(40).height(40)
        }
        .width(40)
        .justifyContent(FlexAlign.Center)
        .height(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius('50%')

        Text(this.title)
          .attributeModifier(new BaseTextStyleModifier(`${this.titleColor}/Title_S/Bold`))
      }
      .onClick(() => {
        this.calendarEventVM.getPageInfo()?.pop()
      })

      if (this.rightBuilder) {
        this.rightBuilder()
      }
    }
    .padding({ left: 16, right: 16, bottom: 16 })
  }
}