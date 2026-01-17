import { LengthMetrics } from '@kit.ArkUI';
import { IFormData, StoreInfo } from '../common/Type';
import { ConstantsHome, PHONE_REG } from '../common/Constant';
import { DayModel, get7Days, getAllowTimes } from '../common/TimeUtils';
import { getColorWithOpacity } from '../common/ColorUtils';
import { PopViewUtils } from '../common/PopViewUtils';
import { StoreListPopSheetBuilder, StoreSheetBuilderParam } from './StoreListView';

@ComponentV2
export struct ReservationForm {
  // 预约门店列表数据
  @Param storeList: StoreInfo[] = [];
  // 预约项目名称
  @Param projectName: string = '';
  // 主题色，十六进制，带#
  @Param themeColor: string = '#0A59F7';
  // 提交按钮文字
  @Param btnLabel: ResourceStr = '提交';
  // 提交按钮loading防暴力点击
  @Param isSubmitLoading: boolean = false;
  // 提交表单信息
  @Event submitForm: (formData: IFormData) => void = () => {
  };
  @Local selectStoreId: string = '1';
  @Local dates: DayModel[] = [];
  @Local times: string[] = [];
  @Local selectDateIndex: number = 0;
  @Local selectTimeIndex: number = 0;
  @Local contactUserName: string = '';
  @Local contactPhone: string = '';
  @Local inputNum: number = 1;
  @Local remark: string = '';
  @Local opacityThemeColor: string = '#EBF1FE';
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    PopViewUtils.init(this.getUIContext())
    this.opacityThemeColor = getColorWithOpacity(this.themeColor, 8);
    this.dates = get7Days();
    this.getTodayTimes();
  }

  @Computed
  get selectedStoreInfo() {
    const storeInfo = this.storeList.find((item) => item.id === this.selectStoreId);
    return storeInfo ?? this.storeList[0]
  }

  build() {
    Column() {
      List({ scroller: this.scroller, space: 16 }) {
        ListItem() {
          // 预约门店
          this.SelectStore()
        }
        ListItem() {
          // 预约时间卡片
          this.SelectDateTime()
        }

        ListItem() {
          // 预约信息卡片
          this.AppointmentInfo()
        }
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .padding({ bottom: 10 })

      Column({space: 8}) {
        Button(this.btnLabel)
          .width('100%')
          .height(40)
          .backgroundColor(this.themeColor)
          .enabled(!this.isSubmitLoading)
          .onClick(this.onSubmit)
      }
    }
    .width('100%')
    .height('100%')
  }

  getTodayTimes() {
    const today = new Date();
    const startTime = today.getTime();
    today.setHours(19);
    today.setMinutes(30);
    today.setSeconds(0);
    const endTime = today.getTime();
    this.times = getAllowTimes(startTime, endTime);

    if (this.times.length) {
      this.selectTimeIndex = 0;
    } else {
      this.selectTimeIndex = -1;
    }
  }

  getOtherDayTimes() {
    const date = this.dates[this.selectDateIndex].date;
    date.setHours(8);
    date.setMinutes(0);
    date.setSeconds(0);
    const startTime = date.getTime();

    date.setHours(19);
    date.setMinutes(30);
    date.setSeconds(0);
    const endTime = date.getTime();
    this.times = getAllowTimes(startTime, endTime);
  }

  isInValid(): boolean {
    const promptAction = this.getUIContext().getPromptAction()
    // 当天无可选时间
    if (this.selectTimeIndex === -1) {
      promptAction.showToast({ message: $r('app.string.book_good_toast_time') });
      return true;
    }
    // 联系人未填
    if (!this.contactUserName) {
      promptAction.showToast({ message: $r('app.string.book_good_toast_name') });
      return true;
    }
    // 手机号未填写
    if (!this.contactPhone) {
      promptAction.showToast({ message: $r('app.string.book_good_toast_phone') });
      return true;
    }
    // 手机号格式不正确
    if (!PHONE_REG.test(this.contactPhone)) {
      promptAction.showToast({ message: $r('app.string.book_good_toast_phone_correct') });
      return true;
    }

    return false;
  }

  buildParams() {
    const selectedDate = this.dates[this.selectDateIndex].date;
    const selectTime = this.times[this.selectTimeIndex].split(':').map(v => Number(v));
    selectedDate.setHours(selectTime[0]);
    selectedDate.setMinutes(selectTime[1]);
    selectedDate.setSeconds(0);

    const selectedDateTime = selectedDate;

    const data: IFormData = {
      // 联系人姓名
      name: this.contactUserName,
      // 联系人手机号
      phone: this.contactPhone,
      // 预约时间，时间戳类型
      reserveTime: selectedDateTime.getTime(),
      // 预约备注
      remarks: this.remark,
      // 预约人数
      numbers: this.inputNum.toString(),
      // 预约门店Id
      storeId: this.selectStoreId,
    };
    return data;
  }

  onSubmit: () => void = () => {
    if (this.isInValid()) {
      return;
    }
    const data = this.buildParams();
    this.submitForm(data);
  };

  onSelectDate(index: number) {
    this.selectDateIndex = index;
    if (this.selectDateIndex === 0) {
      this.getTodayTimes();
    } else {
      this.getOtherDayTimes();
    }
    if (this.times.length) {
      this.selectTimeIndex = 0;
    } else {
      this.selectTimeIndex = -1;
    }
  }

  dateUpFgColor(index: number) {
    return this.selectDateIndex === index ? this.themeColor : '#434343';
  }

  dateDownFgColor(index: number) {
    return this.selectDateIndex === index ? this.themeColor : '#999999';
  }

  dateBgColor(index: number) {
    return this.selectDateIndex === index ? this.opacityThemeColor : '#F7F7F9';
  }

  timeFgColor(index: number) {
    return this.selectTimeIndex === index ? this.themeColor : '#434343';
  }

  timeBgColor(index: number) {
    return this.selectTimeIndex === index ? this.opacityThemeColor : '#F7F7F9';
  }

  openStoreSheet() {
    const builderParam: StoreSheetBuilderParam= {
      storeList: this.storeList,
      currentStoreId: this.selectStoreId,
      onSelect: (id: string) => {
        this.selectStoreId = id;
        PopViewUtils.closeSheet();
      }
    }
    PopViewUtils.showSheet(wrapBuilder(StoreListPopSheetBuilder), {
      title: { title: '适用门店' },
      showClose: true,
      preferType: SheetType.CENTER,
      height: SheetSize.MEDIUM,
    }, builderParam)
  }

  @Builder
  SelectStore() {
    Column() {
      Text($r('app.string.book_good_store')).subTitle()

      Row() {
        Image($r('app.media.ic_appIcon')).width(40).height(40).borderRadius(20)
        Row() {
          Text(this.selectedStoreInfo.storeName).fontSize(18).fontWeight(500)
            .margin({left: 4 })
            .maxLines(1)
            .constraintSize({maxWidth: 'calc(100% - 24vp)'})
            .textOverflow({overflow: TextOverflow.Ellipsis})
          SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(18).fontColor([$r('sys.color.icon_primary')])
            .margin({left: 8 })
        }
        .layoutWeight(1)

        Blank()

        Text() {
          Span('距您').fontColor($r('sys.color.font_secondary'))
          Span(this.selectedStoreInfo.distance ?? '0m').fontColor($r('sys.color.multi_color_07'))
        }
        .fontSize(12).fontWeight(400)
      }
      .width('100%')
      .margin({top: 20})
      .onClick(() => {
        this.openStoreSheet()
      })

      Row({space: 4}) {
        SymbolGlyph($r('sys.symbol.local')).fontSize(16).fontColor([$r('sys.color.icon_primary')])
        Text(this.selectedStoreInfo.address).fontSize(12).fontWeight(400)
      }
      .margin({top: 10})
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({
      top: 24,
      bottom: 12,
      left: 12,
      right: 12,
    })
    .borderRadius(16)
  }

  @Builder
  SelectDateTime() {
    Column() {
      Text($r('app.string.book_good_appoint_time')).subTitle()
      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.dates, (v: DayModel, index) => {
            Column({ space: 2 }) {
              Text(v.weekDesc)
                .fontSize(14)
                .fontColor(this.dateUpFgColor(index))
              Text(v.dateDesc)
                .fontSize(14)
                .fontColor(this.dateDownFgColor(index))
            }
            .padding({
              top: 7,
              bottom: 7,
              left: 21,
              right: 21,
            })
            .backgroundColor(this.dateBgColor(index))
            .borderRadius(22)
            .onClick(() => {
              this.onSelectDate(index);
            })
          }, (item: DayModel) => JSON.stringify(item))
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .scrollable(ScrollDirection.Horizontal)
      .margin({ top: 10, bottom: 10 })

      customDivider()

      if (this.times.length) {
        Grid() {
          ForEach(this.times, (v: string, index: number) => {
            GridItem() {
              Text(v)
                .fontSize(14)
                .fontColor(this.timeFgColor(index))
                .backgroundColor(this.timeBgColor(index))
                .width('100%')
                .padding({ top: 14, bottom: 14 })
                .borderRadius(20)
                .textAlign(TextAlign.Center)
            }.onClick(() => {
              this.selectTimeIndex = index;
            })
          }, (day: string) => day)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .width('100%')
        .height(160)
        .margin({ top: 10 })
        .scrollBar(BarState.Off)
        .nestedScroll({
          scrollForward: NestedScrollMode.SELF_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST,
        })
      } else {
        Image($r('app.media.empty_time'))
          .width(50)
          .height(50)
          .margin({ top: 32, bottom: 14 })
        Text($r('app.string.book_good_times_empty'))
          .fontSize(14)
          .fontColor('#B6B6B6')
          .margin({ bottom: 32 })
      }
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({
      top: 24,
      bottom: 12,
      left: 12,
      right: 12,
    })
    .borderRadius(16)
  }

  @Builder
  AppointmentInfo() {
    Column() {
      Text($r('app.string.book_good_appoint_info')).subTitle()
      Row() {
        Text($r('app.string.book_good_appoint_project')).fontSize(16).fontColor('#212121')
        Text(this.projectName)
          .fontSize(16)
          .fontColor('#212121')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: '60%' })
      }
      .itemContainer()
      .margin({ top: 10 })

      customDivider()

      Row() {
        Row({ space: 4 }) {
          Text($r('app.string.book_good_appoint_contact_name'))
            .fontSize(16)
            .fontColor('#212121')
          Text($r('app.string.common_required'))
            .fontSize(12)
            .fontColor(this.themeColor)
        }

        TextInput({ placeholder: $r('app.string.book_contact_name_place'), text: $$this.contactUserName })
          .id('userNameId')
          .fontSize($r('sys.float.Body_L'))
          .placeholderFont({size: $r('sys.float.Body_L')})
          .inputItem()
          .onFocus(() => {
            setTimeout(() => {
              this.scroller.scrollToIndex(2, true, ScrollAlign.START, { extraOffset: LengthMetrics.vp(76) });
            }, 100)
          })
          .onWillInsert(() => {
            if (this.contactUserName.length >= ConstantsHome.MAX_CONTACT_NAME_LENGTH) {
              return false;
            }
            return true;
          })

      }
      .itemContainer()

      customDivider()

      Row() {
        Row({ space: 4 }) {
          Text($r('app.string.book_good_appoint_phone'))
            .fontSize(16)
            .fontColor('#212121')
          Text($r('app.string.common_required'))
            .fontSize(11)
            .fontColor(this.themeColor)
        }

        TextInput({ placeholder: $r('app.string.book_phone_place'), text: $$this.contactPhone })
          .id('phoneInputId')
          .type(InputType.PhoneNumber)
          .maxLength(11)
          .fontSize($r('sys.float.Body_L'))
          .placeholderFont({size: $r('sys.float.Body_L')})
          .inputItem()
          .onFocus(() => {
            setTimeout(() => {
              this.scroller.scrollToIndex(2, true, ScrollAlign.START, { extraOffset: LengthMetrics.vp(76) });
            }, 100)
          })
      }
      .id('phoneId')
      .itemContainer()

      customDivider()

      Column({ space: 10 }) {
        Text($r('app.string.book_good_appoint_remark'))
          .fontSize(16)
          .fontColor('#212121')
          .alignSelf(ItemAlign.Start)
        TextArea({ placeholder: $r('app.string.book_remark_place'), text: $$this.remark })
          .id('remarkId')
          .maxLines(3)
          .height(70)
          .fontSize($r('sys.float.Body_L'))
          .placeholderFont({size: $r('sys.float.Body_L')})
          .placeholderColor('#C7C7C7')
          .maxLength(ConstantsHome.MAX_REMARK_LENGTH)
          .showCounter(true, { highlightBorder: false })
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding(0)
          .onFocus(() => {
            setTimeout(() => {
              this.scroller.scrollEdge(Edge.Bottom);
            }, 100)
          })
      }
      .id('remarkId')
      .margin({ top: 12 })
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({
      top: 24,
      bottom: 12,
      left: 12,
      right: 12,
    })
    .borderRadius(16)
  }
}

@Extend(Text)
function subTitle() {
  .fontSize(18)
  .fontColor('#212121')
  .fontWeight(FontWeight.Bold)
  .alignSelf(ItemAlign.Start)
}

@Extend(TextInput)
function inputItem() {
  .constraintSize({ maxWidth: '60%' })
  .placeholderColor($r('sys.color.font_secondary'))
  .backgroundColor(Color.Transparent)
  .textAlign(TextAlign.End)
  .padding(0)
  .borderRadius(0)
}

@Extend(Row)
function itemContainer() {
  .padding({ top: 12, bottom: 12 })
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween)
}

@Extend(Button)
function buttonCircle() {
  .type(ButtonType.Circle)
  .width(24)
  .height(24)
  .backgroundColor('#F5F5F5')
}

@Builder
function customDivider() {
  Divider()
}
