import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';

@ComponentV2
export struct ListEndSwiperAction {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Require @Param userEventInfo: UserEventItem;
  @Event onDelete: () => void = () => {
  };

  build() {
    Row() {
      Text('删除')
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize(14)
    }
    .onClick(() => {
      this.calendarEventVM.deleteUserEventInfo(this.userEventInfo,this.onDelete)
    })
    .justifyContent(FlexAlign.Center)
    .width(64)
    .height('100%')
    .borderRadius({
      topRight: 16,
      bottomRight: 16,
    })
    .backgroundColor('#E84026')
    .margin({ left: -10 })
  }
}