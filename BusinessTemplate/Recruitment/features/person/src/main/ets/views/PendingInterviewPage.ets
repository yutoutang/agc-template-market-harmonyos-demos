import { calendarManager } from '@kit.CalendarKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { ProtocolRouterParams } from 'aggregated_login';
import {
  CommonHeader,
  getInterviewTime,
  getPositionById,
  PositionInfo,
  RouterMap,
  TValueType,
  CalendarId,
  BarVM
} from 'common';
import { phoneRouterControl } from 'oh_router';
import { PositionDetailPageBuilder } from 'position';

@Builder
export function PendingInterviewPageBuilder(params: TValueType) {
  PendingInterviewPage({ pageParams: params })
}

// 投递进度
@ComponentV2
export struct PendingInterviewPage {
  @Param pageParams: TValueType = null;
  @Local content: string = '';
  @Local positionData?: PositionInfo;
  @Local calendarIds: CalendarId = AppStorageV2.connect<CalendarId>(CalendarId, () => new CalendarId())!;
  @Local hasAdd: boolean = false

  setSchedule() {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() + 1);
    startDate.setHours(10, 30, 0, 0);

    const endDate = new Date();
    endDate.setDate(endDate.getDate() + 1);
    endDate.setHours(11, 0, 0, 0);

    const event: calendarManager.Event = {
      title: `${this.positionData?.companyName}${this.positionData?.jobTitle}面试`,
      type: calendarManager.EventType.NORMAL,
      startTime: startDate.getTime(),
      endTime: endDate.getTime()
    };
    const calendarMgr = calendarManager.getCalendarManager(getContext(this));
    calendarMgr?.editEvent(event).then((eventId: number): void => {
      promptAction.showToast({ message: '添加日程成功', duration: 2000 });
      this.calendarIds.ids.push(this.positionData!.id)
      this.hasAdd = true
    }).catch((err: BusinessError) => {
    });
  }

  @Builder
  buildHeader() {
    Stack({ alignContent: Alignment.End }) {
      CommonHeader({
        title: '',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })

      Row() {
        Text('添加日程')
          .fontSize(16)
          .fontColor(this.hasAdd ? 'rgba(0,0,0,0.4)' : '#5B6FFF')
          .onClick(() => {
            if (this.hasAdd) {
              return
            }
            this.setSchedule()
          })
      }.justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(56)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  buildTitle() {
    Row() {
      Text('待面试')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .margin({ top: 20, bottom: 24 })
    }.width('100%')
  }

  @Builder
  buildCompanyInfo() {
    Row() {
      Row() {
        Text('logo')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width(64)
      .height(64)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)

      Column({ space: 4 }) {
        Text(this.positionData?.companyName || '')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')

        Text(this.positionData?.hrName || '')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.60)')
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding({ top: 20, left: 16, right: 16 })
  }

  @Builder
  buildInterviewTime() {
    Row() {
      Text('面试时间')
        .fontSize(14)
        .fontColor('rgba(0,0,0,0.90)')
        .width(80)

      Text(getInterviewTime())
        .fontSize(14)
        .fontColor('rgba(0,0,0,0.90)')
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .margin({ top: 24 })
  }

  @Builder
  buildPositionInfo() {
    Row() {
      Text('职位')
        .fontSize(14)
        .fontColor('rgba(0,0,0,0.90)')
        .width(80)

      Text(`${this.positionData?.jobTitle}·${this.positionData?.salary}`)
        .fontSize(14)
        .fontColor('#5B6FFF')
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .margin({ top: 20 })
    .onClick(() => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.POSITION_DETAIL_PAGE,
        param: {
          content: this.positionData?.id,
          isSheet: false,
        } as ProtocolRouterParams,
        builder: wrapBuilder(PositionDetailPageBuilder),
      })
    })
  }

  @Builder
  buildRecruiterInfo() {
    Row() {
      Text('招聘者')
        .fontSize(14)
        .fontColor('rgba(0,0,0,0.90)')
        .width(80)

      Row({ space: 8 }) {
        Image($r('app.media.avatar'))
          .width(24)
          .height(24)
          .borderRadius(12)

        Text(this.positionData?.hrName || '吴先生')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.90)')

        Image($r('app.media.chat_icon'))
          .width(18)
          .height(16)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .margin({ top: 20 })
  }

  @Builder
  buildAddressInfo() {
    Row() {
      Text('地址')
        .fontSize(14)
        .fontColor('rgba(0,0,0,0.90)')
        .width(80)

      Text(this.positionData?.location || '软件大道XX软件公司')
        .fontSize(14)
        .fontColor('rgba(0,0,0,0.90)')
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 24 })
    .margin({ top: 20 })
  }

  @Builder
  buildInterviewCard() {
    Column() {
      this.buildCompanyInfo()
      this.buildInterviewTime()
      this.buildPositionInfo()
      this.buildRecruiterInfo()
      this.buildAddressInfo()
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        this.buildTitle()
        this.buildInterviewCard()
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .onReady((context) => {
      const params = context.pathInfo.param as ProtocolRouterParams;
      if (params) {
        const positionId = params.content;
        this.positionData = getPositionById(positionId)
        if (this.calendarIds.ids.includes(positionId)) {
          this.hasAdd = true
        }
      }
    })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}