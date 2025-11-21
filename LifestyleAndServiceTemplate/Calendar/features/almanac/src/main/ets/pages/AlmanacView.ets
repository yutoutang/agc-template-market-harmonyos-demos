import { CalendarVM, ServiceTitle, ThemeModel } from 'common'
import { PersistenceV2 } from '@kit.ArkUI';
import { CalendarController } from 'base_calendar';
import { VernacularContainer } from '../components/VernacularContainer';
import { CalendarAlmanac } from 'calendar_almanac';
import dayjs from 'dayjs';

@Preview
@ComponentV2
export struct Almanac {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  calendarController: CalendarController = new CalendarController();
  vm: CalendarVM = CalendarVM.instance

  @Builder
  almanacVernacular() {
    VernacularContainer()
  }

  build() {
    Column() {
      ServiceTitle({
        title: '黄历',
        titleColor: this.theme.themeState.titleColor,
      })
      List() {
        ListItem() {
          CalendarAlmanac({
            selectDate: new Date(this.vm.selectDate.format('YYYY-MM-DD')),
            selectTextColor: this.theme.themeState.buttonColor,
            arrowColor: this.theme.themeState.id,
            onDateChange: (date: Date) => {
              this.vm.selectDate = dayjs(date)
              this.calendarController.setSelectDate(date)
              this.vm.getTodayYiJi()
              console.log('current date' + date)
            },
          })
        }
        ListItem() {
          this.almanacVernacular()
        }
      }
      .scrollBar(BarState.Off)
    }
    .justifyContent(FlexAlign.Start)

    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}