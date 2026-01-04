import { ProtocolRouterParams } from 'aggregated_login';
import { BarVM, CommonHeader, getPositionById, PositionInfo, RouterMap, TValueType } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PositionDetailPageBuilder } from 'position';

@Builder
export function DeliveryProgressPageBuilder(params: TValueType) {
  DeliveryProgressPage({ pageParams: params })
}

// 投递进度
@ComponentV2
export struct DeliveryProgressPage {
  @Param pageParams: TValueType = null;
  @Local content: string = '';
  @Local positionData?: PositionInfo;

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '投递进度',
          onReturnClick: () => {
            phoneRouterControl.popPage();
          },
        })

        if (this.positionData) {
          this.DeliveryProgressCard('已投递', '邀面试',
            '投递反馈：您好，您的工作经历符合我司需求，希望你能按照约定时间赴约面试，谢谢。')
        }
      }
      .padding({
        left: 16,
        right: 16,
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context) => {
      const params = context.pathInfo.param as ProtocolRouterParams;
      if (params) {
        const positionId = params.content;
        this.positionData = getPositionById(positionId)
      }
    })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }

  @Builder
  DeliveryProgressCard(startStatus: string, endStatus: string, feedback: string) {
    Column() {
      // 职位信息
      Row() {
        Column({ space: 4 }) {
          Text(this.positionData?.jobTitle || '')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text(this.positionData?.companyName || '')
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.positionData?.salary || '')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#564AF7')
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
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

      // 进度条
      this.ProgressBar(startStatus, endStatus)

      // 投递反馈
      if (feedback) {
        Text(feedback)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ top: 12 })
  }

  @Builder
  ProgressBar(startStatus: string, endStatus: string) {
    Column() {
      // 进度点
      Row() {
        ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8], (index: number) => {
          if (index !== 8) {
            Circle({ width: index === 0 ? 8 : 4, height: index === 0 ? 8 : 4 })
              .fill(this.getProgressColor(index / 2, startStatus, endStatus))
          } else {
            Image($r('app.media.complete_icon')).width(15).height(15)
          }
        }, (item: Number, index: number) => `${JSON.stringify(item)}_${index}}`)
      }
      .width('100%')
      .height(8)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 14, right: 10 })

      // 状态文字
      Row() {
        Text(startStatus)
          .fontSize(12)
          .fontColor(this.getTextColor(startStatus, endStatus, true))
          .layoutWeight(1)

        Text(endStatus)
          .fontSize(12)
          .fontColor(this.getTextColor(startStatus, endStatus, false))
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .margin({ top: 8 })
    }.width('90%')
  }

  // 获取进度点颜色
  getProgressColor(index: number, startStatus: string, endStatus: string): string {
    if (endStatus === '邀面试') {
      return index === 0 || index === 4 ? '#564AF7' : '#564AF7';
    } else if (endStatus === '已拒绝') {
      return index === 0 || index === 4 ? '#564AF7' : '#E0E0E0';
    }
    return index === 0 ? '#564AF7' : '#E0E0E0';
  }

  // 获取文字颜色
  getTextColor(startStatus: string, endStatus: string, isStart: boolean): string {
    if (isStart) {
      return '#564AF7';
    }
    if (endStatus === '邀面试') {
      return '#564AF7';
    } else if (endStatus === '已拒绝') {
      return '#564AF7';
    }
    return '#CCCCCC';
  }
}