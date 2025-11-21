import { DateUtils } from '../util/DateUtil';
import { CheckInHistoryDataItem } from '../types/Types';
import { CheckInHistoryItem } from './ClockInHistoryItem';
import { DataManager } from '../controller/DataManagerController';

@ComponentV2
export struct ClockInHistory {
  private checkInHistories: CheckInHistoryDataItem[] = []
  @Local month: string | Resource = '';
  private controller: Scroller = new Scroller();

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.month)
            .fontColor($r('app.string.black_90'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ top: 16 })
        }

        List({ scroller: this.controller }) {
          ForEach(this.checkInHistories, (item: CheckInHistoryDataItem, index) => {
            ListItem() {
              CheckInHistoryItem({
                'dayDesc': this.getDayDesc(item.dayOfWeek, item.day),
                'day': this.getDayNumber(item.day),
                'index': index,
                'details': item.details
              })
            }
          }, (item:CheckInHistoryDataItem) => JSON.stringify(item))
        }
        .width('100%')
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
      }
      .padding({ left: 16, right: 16 })
    }.align(Alignment.Bottom)
  }

  getDayDesc(dayOfWeek: number, day: string): Resource {
    if (DateUtils.isToday(day)) {
      return $r('app.string.today')
    }
    const dayOfWeekDesc = 'app.string.day_of_week_' + dayOfWeek;
    return $r(dayOfWeekDesc);
  }

  getDayNumber(day: string): string {
    return day.split('-')[2];
  }

  aboutToAppear() {
    const value = DataManager.queryCheckInHistories();
    this.checkInHistories = value;
    if (this.checkInHistories.length === 0) {
      return;
    }
    this.month = this.getMothDesc(value[0].day)
  }

  getMothDesc(day: string): Resource {
    const month: string = day.split('-')[1];
    const monthDesc = 'app.string.month_desc_' + month;
    return $r(monthDesc);
  }
}