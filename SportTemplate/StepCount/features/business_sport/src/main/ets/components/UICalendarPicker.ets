import {
  DialogType,
  END_YEAR,
  MAX_GAP_DEFAULT,
  START_YEAR,
  SwiperDirection,
  TypePicker
} from '../constant/CalendarConstant';
import { DateUtils } from '../util/DateUtils';
import { UICalendarView } from './UICalendarView';

@Extend(Text)
function textStyle() {
  .fontSize($r('sys.float.ohos_id_text_size_body1'))
  .lineHeight(19)
}

@ComponentV2
export struct UICalendarPicker {
  @BuilderParam customBuildPanel: () => void;
  /**
   * 日期选择器的类型
   */
  @Param type: TypePicker = TypePicker.SINGLE;
  /**
   * 弹窗类型
   */
  @Param dialogType: DialogType = DialogType.SHEET;
  /**
   * 滑动方向
   */
  @Param swiperDirection: SwiperDirection = SwiperDirection.HORIZONTAL;
  /**
   * 定制主题色
   */
  @Param customColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary_activated');
  /**
   * 定制文字颜色
   */
  @Param customFontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  /**
   * 一周起始天，默认是星期天，取值范围 0 - 6
   */
  @Param startDayOfWeek: number = 0;
  /**
   * 切换年月的起始年份
   */
  @Param startYear: number = START_YEAR;
  /**
   * 切换年月的结束年份
   */
  @Param endYear: number = END_YEAR;
  /**
   * 单日期，支持传入默认值
   */
  @Param selected: Date | null = null;
  /**
   * 多日期，支持传入默认值
   */
  @Param selectDates: Date[] = [];
  /**
   * y方向上的偏移
   */
  @Param yOffset: number = 0;
  /**
   * 设置可选范围
   */
  @Param rangeLimit: Date[] = [];
  /**
   * 设置禁选日期，仅针对单日期、多日期生效
   */
  @Param disabledDates: Date[] = [];
  /**
   * 禁止使用日期的自定义文字
   */
  @Param disableDayLabel: ResourceStr = $r('app.string.disable_day_label');
  /**
   * 针对时间段类型，设置起止日期的跨度
   */
  @Param maxGap: number = MAX_GAP_DEFAULT;
  /**
   * 支持选择时间
   */
  @Param enableSelectTime: boolean = false;
  /**
   * 针对时间选择，展示时间是否为24小时制
   */
  @Param isMilitaryTime: boolean = false;
  /**
   * 半模态弹窗标题文字
   */
  @Param sheetTitle: ResourceStr = '';
  /**
   * 半模态弹窗高度，水平滑动
   */
  @Param sheetH: SheetSize | Length = 500;
  /**
   * 半模态弹窗高度档位，垂直滑动
   */
  @Param detents: [
    (SheetSize | Length),
    (SheetSize | Length)?,
    (SheetSize | Length)?
  ] = [SheetSize.MEDIUM, SheetSize.LARGE];
  @Local isShowSheet: boolean = false;
  @Param clickDateClose: boolean = true
  controller: CustomDialogController = new CustomDialogController({
    builder: this.buildDialog,
    customStyle: true,
  });
  /**
   * 显示三环数据
   */
  @Param showRing: boolean = false;
  @Event $selected: (selected: Date) => void = (selected: Date) => {
    // do nothing
  }
  @Event $selectDates: (selectDates: Date[]) => void = (selectDates: Date[]) => {
    // do nothing
  }
  /**
   * 确认选择后的回调
   */
  @Event onSelected: (date: Date | Date[]) => void = () => {
    // do nothing
  };
  /**
   * 点击日期的回调
   */
  @Event onClickDate: (date: Date) => void = () => {
    // do nothing
  };
  /**
   * 取消选择的回调
   */
  @Event cancel: () => void = () => {
    // do nothing
  };

  @Builder
  buildDialog() {
    UICalendarView({
      type: this.type,
      dialogType: this.dialogType,
      swiperDirection: this.swiperDirection,
      customColor: this.customColor,
      customFontColor: this.customFontColor,
      startDayOfWeek: this.startDayOfWeek,
      startYear: this.startYear,
      endYear: this.endYear,
      selected: this.selected,
      selectDates: this.selectDates,
      yOffset: this.yOffset,
      rangeLimit: this.rangeLimit,
      disabledDates: this.disabledDates,
      disableDayLabel: this.disableDayLabel,
      maxGap: this.maxGap,
      enableSelectTime: this.enableSelectTime,
      isMilitaryTime: this.isMilitaryTime,
      sheetTitle: $r('app.string.select_date'),
      onSelected: (date: Date | Date[]) => {
        if (date instanceof Date) {
          this.$selected(date)
        } else {
          this.$selectDates(date)
        }
        this.onSelected(date);
      },
      cancel: () => {
        this.cancel();
      },
      onClickDate: (date: Date) => {
        this.onClickDate(date);
        if (this.clickDateClose) {
          this.close()
        }
      },
      close: () => {
        this.close()
      },
      showRing: this.showRing
    })
  }

  close() {
    if (this.dialogType === DialogType.DIALOG) {
      this.controller?.close();
    } else {
      this.isShowSheet = false;
    }
  }

  getSingleDateLabel() {
    if (!this.selected) {
      return $r('app.string.select_placeholder');
    }
    return DateUtils.formatDate(this.selected);
  }

  getSingleDateTimeLabel() {
    if (!this.selected) {
      return $r('app.string.select_placeholder');
    }
    return DateUtils.formatDateTime(this.selected);
  }

  getMultiDateLabel() {
    if (!this.selectDates.length) {
      return $r('app.string.select_placeholder');
    }
    const listCut = [...this.selectDates];
    listCut.splice(2);
    let label = listCut.map((item) => {
      return DateUtils.formatDate(item);
    }).join('; ')
    if (this.selectDates.length > 2) {
      label += '...'
    }

    return label;
  }

  getDateRangeLabel() {
    if (this.selectDates.length <= 0) {
      return $r('app.string.select_placeholder');
    }
    if (this.selectDates.length === 1) {
      return `${DateUtils.formatDate(this.selectDates[0])}-`;
    }
    return `${DateUtils.formatDate(this.selectDates[0])}-${DateUtils.formatDate(this.selectDates[1])}`;
  }

  @Builder
  buildPanel() {
    Row({ space: 4 }) {
      if (this.type === TypePicker.SINGLE) {
        if (this.enableSelectTime) {
          Text(this.getSingleDateTimeLabel()).textStyle()
        } else {
          Text(this.getSingleDateLabel()).textStyle()
        }
      } else if (this.type === TypePicker.MULTIPLE) {
        Text(this.getMultiDateLabel()).textStyle()
      } else {
        Text(this.getDateRangeLabel()).textStyle()
      }
      Image($r('app.media.ic_public_arrow_right'))
        .width(12)
        .height(20)
        .fillColor($r('sys.color.ohos_id_color_primary'))
        .objectFit(ImageFit.Contain)
        .interpolation(ImageInterpolation.High)
    }
  }

  build() {
    Column() {
      if (this.customBuildPanel) {
        this.customBuildPanel()
      } else {
        this.buildPanel()
      }
    }
    .onClick(() => {
      if (this.dialogType === DialogType.DIALOG) {
        this.controller.open();
      } else {
        this.isShowSheet = true;
      }
    })
    .bindSheet($$this.isShowSheet, this.buildDialog(), {
      showClose: false,
      preferType: SheetType.CENTER,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      detents: this.swiperDirection === SwiperDirection.VERTICAL ?
        this.detents : [this.sheetH],
      backgroundColor: this.swiperDirection === SwiperDirection.VERTICAL ?
        $r('sys.color.ohos_id_color_dialog_bg') : null,
    })
  }
}