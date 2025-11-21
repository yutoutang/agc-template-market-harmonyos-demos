import { CalendarVM, ThemeModel } from 'common';
import { RouterModule } from 'router_module'
import { YiJiQuery } from 'yiji_query'
import { PersistenceV2 } from '@kit.ArkUI';

@Builder
export function QueryJiDayToolsBuilder() {
  QueryJiDayTools()
}

@ComponentV2
export struct QueryJiDayTools {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  vm: CalendarVM = CalendarVM.instance;
  build() {
    Column(){
      YiJiQuery({
        routerModule:RouterModule.getStack(),
        selectColor:this.theme.themeState.current,
        titleColor:this.theme.themeState.titleColor,
        selectedDate:new Date(this.vm.selectDate.format('YYYY-MM-DD'))
      })
    }
  }
}