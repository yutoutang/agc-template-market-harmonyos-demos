import { DialogType, SwiperDirection, TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { HotelDateModel } from '../commons/Models';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct HotelDateSelector {
  @Param
  showTopLabel: boolean = true;
  @Local
  hotelDateModel: HotelDateModel = HotelDateModel.instance
  @Local
  today: Date = new Date()
  @Event
  paramChangeCallback: (data: HotelDateModel) => void = () => {
  };

  @Computed
  public get endDate() {
    const endDate = new Date(this.today);
    endDate.setMonth(endDate.getMonth() + 1);
    return endDate;
  }

  build() {
    Column() {
      if (this.showTopLabel) {
        this.titleBuilder();
      }
      this.datePickerBuilder();
      Divider()
        .margin({
          top: $r('app.string.space_l'),
          bottom: $r('app.string.space_l'),
        })
        .color($r('app.color.divider_color'))
      this.roomCountSelectorBuilder();
    }
    .width($r('app.string.size_percent_100'))
    .justifyContent(FlexAlign.SpaceBetween)
    .padding($r('app.string.space_m'))
    .borderRadius(this.showTopLabel ? $r('app.string.border_radius_16') : 0)
    .backgroundColor($r('app.color.background_color_white'));
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('入住').subLabelStyle();
      Text('共' + this.hotelDateModel.totalDays + '晚').subLabelStyle();
      Text('离店').subLabelStyle();
    }
    .width($r('app.string.size_percent_100'))
    .margin({ bottom: $r('app.string.space_l') })
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  datePickerBuilder() {
    UICalendarPicker({
      type: TypePicker.RANGE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.VERTICAL,
      startYear: this.today.getFullYear(),
      rangeLimit: [this.hotelDateModel.startDate],
      endYear: this.today.getFullYear() + 1,
      detents: [SheetSize.MEDIUM],
      selectDates: [this.hotelDateModel.checkInDate, this.hotelDateModel.checkOutDate],
      onSelected: (date: Date | Date[]) => {
        this.handleConfirm(date);
      },
    }) {
      Row() {
        Row() {
          Text(this.hotelDateModel.getDateLabel(this.hotelDateModel.checkInDate))
            .mainLabelStyle()
            .margin({ right: $r('app.string.space_s') });

          Text(this.hotelDateModel.getDateDescription(this.hotelDateModel.checkInDate))
            .subLabelStyle();
        };

        Text('--')
          .subLabelStyle()
          .margin({
            left: $r('app.string.space_l'),
            right: $r('app.string.space_l'),
          })

        Row() {
          Text(this.hotelDateModel.getDateLabel(this.hotelDateModel.checkOutDate))
            .mainLabelStyle()
            .margin({ right: $r('app.string.space_s') });

          Text(this.hotelDateModel.getDateDescription(this.hotelDateModel.checkOutDate))
            .subLabelStyle();
        };

        if (!this.showTopLabel) {
          Blank();
          Text('共' + this.hotelDateModel.totalDays + '晚')
            .subLabelStyle()
            .fontSize($r('app.string.font_size_14'))
        }
      }
      .width($r('app.string.size_percent_100'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
  }

  @Builder
  roomCountSelectorBuilder() {
    Row() {
      Text('房间数量').mainLabelStyle();
      Blank()
      Row() {
        Image($r('app.media.ic_subtract'))
          .width(16)
      }
      .countButtonStyle(this.hotelDateModel.roomCount > 1)
      .margin({ right: $r('app.string.space_xl') })
      .onClick(() => this.changeRoomCount(-1));

      Text(this.hotelDateModel.roomCount.toString())
        .mainLabelStyle()

      Row() {
        Image($r('app.media.ic_add'))
          .width(16)
      }
      .countButtonStyle(this.hotelDateModel.roomCount < this.hotelDateModel.maxRoomCount)
      .margin({ left: $r('app.string.space_xl') })
      .onClick(() => this.changeRoomCount(1));
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween);
  }

  public getDateMonth(date: Date) {
    return date.getMonth() + 1;
  }

  public handleConfirm(date: Date | Date[]) {
    let dates: Date[] = date as Date[];
    const curDate = new Date();
    if (
      dates[0].getFullYear() < curDate.getFullYear() ||
        dates[0].getMonth() < curDate.getMonth() ||
        dates[0].getMonth() === curDate.getMonth() && dates[0].getDate() < curDate.getDate()
    ) {
      promptAction.showToast({ message: '抵店日期不得小于当天，请重新选择' });
      return;
    }
    this.hotelDateModel.checkInDate = dates[0];
    this.hotelDateModel.checkOutDate = dates[1];
    this.paramChangeCallback?.(this.hotelDateModel)
  }

  public changeRoomCount(value: number) {
    let preview: number = this.hotelDateModel.roomCount + value;
    if (preview >= this.hotelDateModel.minRoomCount && preview <= this.hotelDateModel.maxRoomCount) {
      this.hotelDateModel.roomCount = preview;
      this.paramChangeCallback?.(this.hotelDateModel)
    }
  }
}

@Extend(Text)
function mainLabelStyle() {
  .fontSize($r('app.string.font_size_16'))
  .lineHeight(24)
  .fontColor($r('app.color.font_color_level1'))
  .fontWeight(FontWeight.Medium);
}

@Extend(Text)
function subLabelStyle() {
  .fontSize($r('app.string.font_size_14'))
  .fontColor($r('app.color.font_color_level2'));
}

@Extend(Row)
function countButtonStyle(enable: boolean = true) {
  .height(32)
  .width(32)
  .borderRadius($r('app.string.border_radius_capsule'))
  .backgroundColor($r('app.color.background_color_grey_light'))
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Center)
  .opacity(enable ? 1 : 0.4)
}