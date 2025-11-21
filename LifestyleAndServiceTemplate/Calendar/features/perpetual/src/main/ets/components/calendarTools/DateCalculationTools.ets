import { CalendarVM, NavigationTitle, ThemeModel } from 'common'
import { PersistenceV2 } from '@kit.ArkUI'
import { DateToolsCalculate } from 'date_calculation'

@Builder
export function DateCalculationToolsBuilder() {
  DateCalculationTools()
}

@ComponentV2
export struct DateCalculationTools {
  vm: CalendarVM = CalendarVM.instance;
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;

  build() {
    NavDestination() {
      NavigationTitle({
        title: '日期计算',
      })
      DateToolsCalculate({
        startDate: new Date(this.vm.selectDate.format('YYYY-MM-DD')),
        buttonColor: this.theme.themeState.current,
        textColor: this.theme.themeState.titleColor,
      })
    }
    .hideTitleBar(true)
  }
}