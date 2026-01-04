import { Breakpoint, BREAKPOINT_PROP_NAME } from 'ui_base';
import { AppStorageV2 } from '@kit.ArkUI';
import { DAY_WIDTH, SwiperDirection } from '../constant/CalendarConstant';
import { DayModel, MonthModel } from '../model/CalendarModel';
import { DateUtils } from '../util/DateUtils';
import { UICalendarVM } from '../viewmodels/UICalendarVM';

@ComponentV2
export struct MonthView {
  @Local breakpoint: string = AppStorageV2.connect(Breakpoint, BREAKPOINT_PROP_NAME, () => new Breakpoint('sm'))!.value;
  @Param calendarVM: UICalendarVM = new UICalendarVM();
  @Param month: MonthModel = new MonthModel(1, 1, []);
  @Local dayHeight: number = 0
  private isShowDisabledLabel: boolean = false;

  aboutToAppear(): void {
    this.isShowDisabledLabel = this.calendarVM.isShowDisabledLabel();
  }

  setMonthViewH() {
    if (this.calendarVM.isSwiper()) {
      return '100%';
    }
    return 'auto';
  }

  @Builder
  buildDay(item: DayModel) {
    Column() {
      Stack() {
        Column() {
          Text(item.day.toString())
            .fontSize(DateUtils.getConfigByBreakpoint(this.breakpoint).fontSize.day)
            .fontColor(this.calendarVM.getFontColor(item))
            .fontWeight(FontWeight.Medium)
            .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))

          // 减少不必要的render时间
          if (this.isShowDisabledLabel) {
            Text(this.calendarVM.isDisabledDate(item) ? this.calendarVM.disableDayLabel : ' ')
              .fontSize($r('sys.float.ohos_id_text_size_caption'))
              .fontColor(this.calendarVM.isSelected(item) ? $r('sys.color.ohos_id_color_text_primary_contrary') :
                this.calendarVM.customFontColor)
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
          } else {
            Text('')
          }

        }
        .width('100%')
        .height('100%')
        .opacity(this.calendarVM.isEnable(item) ? 1 : $r('sys.float.ohos_id_alpha_content_tertiary'))
        .onSizeChange((oldSize, newSize) => {
          this.dayHeight = newSize.height as number
        })
        .border({
          radius: this.dayHeight / 2,
          color: this.calendarVM.isSelected(item) ? $r('app.color.color_FF6017') : Color.Transparent,
          width: 1
        })
        .backgroundColor(this.getBgColor(item))
        .justifyContent(FlexAlign.Center)
        .stateStyles(
          {
            pressed: {
              .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
            },
          },
        )
      }
    }
    .visibility(this.calendarVM.isDayVisible(item))
    .width(DAY_WIDTH)
    .aspectRatio(1)
    .padding({
      left: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayLeft,
      right: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayLeft,
      top: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayTop,
      bottom: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayTop,
    })
    .enabled(this.calendarVM.isEnable(item))
    .onClick(() => {
      this.calendarVM.clickDate(item);
    })
  }

  getBgColor(item: DayModel) {
    if (!this.calendarVM.showRing) {
      return this.calendarVM.isSelected(item) ? $r('app.color.color_FF6017') : Color.Transparent
    }
    if (item.sportRecord?.totalTarget?.stepCount && !this.calendarVM.showRing) {
      return item.sportRecord!!.totalStepCount >= item.sportRecord?.totalTarget?.stepCount ?
        $r('app.color.color_FF6017') : $r('app.color.color_1AFF6017')
    }
    return ''
  }

  @Builder
  buildDayBg(item: DayModel) {
    Row() {
      Text('')
        .width('100%')
        .height('100%')
        .backgroundColor(this.calendarVM.isInRange(item) ? this.calendarVM.customColor : '')
        .opacity($r('sys.float.ohos_id_alpha_highlight_bg'))
        .borderRadius({
          topLeft: this.calendarVM.isStartDate(item) ? 4 : 0,
          topRight: this.calendarVM.isEndDate(item) ? 4 : 0,
          bottomLeft: this.calendarVM.isStartDate(item) ? 4 : 0,
          bottomRight: this.calendarVM.isEndDate(item) ? 4 : 0,
        })
        .pixelRound({
          start: PixelRoundCalcPolicy.NO_FORCE_ROUND,
          end: PixelRoundCalcPolicy.NO_FORCE_ROUND,
        })
    }
    .visibility(this.calendarVM.isDayVisible(item))
    .width(DAY_WIDTH)
    .aspectRatio(1)
    .pixelRound({
      start: PixelRoundCalcPolicy.NO_FORCE_ROUND,
      end: PixelRoundCalcPolicy.NO_FORCE_ROUND,
    })
    .padding({
      top: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayTop,
      bottom: DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayTop,
      left: this.calendarVM.isStartDate(item) ? DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayLeft : 0,
      right: this.calendarVM.isEndDate(item) ? DateUtils.getConfigByBreakpoint(this.breakpoint).margin.dayLeft : 0,
    })
  }

  @Builder
  dayView(item: DayModel) {
    if (this.calendarVM.isTypeRange()) {
      Stack() {
        this.buildDayBg(item)
        this.buildDay(item)
      }
      .pixelRound({
        start: PixelRoundCalcPolicy.NO_FORCE_ROUND,
        end: PixelRoundCalcPolicy.NO_FORCE_ROUND,
      })
    } else {
      Column() {
        this.buildDay(item)

        if (this.calendarVM.showRing) {
          if (this.calendarVM.swiperDirection === SwiperDirection.VERTICAL && !item.isCurrMonth) {
            Text(' ')
              .width(125 / 6)
          } else {
            if (item.getSportData().stepData[0] < 1) {
              Image($r('app.media.icon_thirdring_hui'))
                .width(125 / 6)
            } else {
              Image($r('app.media.icon_thirdring'))
                .width(125 / 6)
            }
          }
        }
      }
    }
  }

  build() {
    Flex({
      wrap: FlexWrap.Wrap,
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.SpaceBetween,
    }) {
      ForEach(this.month.data, (item: DayModel) => {
        this.dayView(item)
      }, (item: DayModel) => item.month + '__' + item.day)
    }
    .margin({ bottom: 8 })
    .height(this.setMonthViewH())
    .width('100%')
  }
}
