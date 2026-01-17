import { AppStorageV2 } from '@kit.ArkUI'
import { formatDate } from '../common/Utils'
import { EditModel } from '../viewmodels/EditPersonVM'

@ComponentV2
export struct DatePickerDialog {
  @Param date: Date = new Date();
  @Event cancel: () => void = () => {}
  @Event confirm: (date: Date) => void = (date: Date) => {}
  @Local selectedDate: Date = new Date(this.date);
  @Local editModel: EditModel = AppStorageV2.connect(EditModel, () => new EditModel())!;
  private weekMap = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

  @Computed
  get dateText() {
    let date = formatDate(this.selectedDate, 'YYYY年MM月DD日');
    let day = this.selectedDate.getDay();
    return date + ' ' + this.weekMap[day];
  }

  @Computed
  get dialogWidth(): Length {
    if (this.editModel.currentBreakpoint === 'sm') {
      return 'calc(100% - 32px)'
    }
    return 360;
  }

  build() {
    Column({ space: 40 }) {
      Text(this.dateText)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(27)

      DatePicker({
        start: new Date('1900-1-1'),
        end: new Date(),
        selected: this.selectedDate,
      })
        .margin({left: 32, right: 32 })
        .disappearTextStyle({
          font: { size: $r('sys.float.Subtitle_S'), weight: FontWeight.Regular },
        })
        .textStyle({
          color: $r('sys.color.font_primary'),
          font: { size: $r('sys.float.Subtitle_M'), weight: FontWeight.Regular },
        })
        .selectedTextStyle({
          color: $r('sys.color.font_emphasize'),
          font: { size: $r('sys.float.Title_S'), weight: FontWeight.Medium }
        })
        .onDateChange((value: Date) => {
          this.selectedDate = value;
        })

      Row() {
        Button('取消', {buttonStyle: ButtonStyleMode.TEXTUAL})
          .height(40)
          .onClick(() => {
            this.cancel();
          })
        Button('确定', {buttonStyle: ButtonStyleMode.TEXTUAL})
          .height(40)
          .onClick(() => {
            this.confirm(this.selectedDate);
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width(this.dialogWidth)
    .padding({ left: 16, right: 16, top: 16 })
    .borderRadius(32)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }
}