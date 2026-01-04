import { PersistenceV2 } from '@kit.ArkUI'
import { ArrivalReminderEnum, CommonConstants, SettingModel } from 'lib_common'

// 线路公交卡片
@ComponentV2
export struct LineBusCard {
  @Param title: string = ''
  @Param stationText: string = '' // 站点
  @Param stopCount: number = 0 // 几站
  @Param stopTime: number = 0 // 时间
  @Param headingText: string = '' // 开往
  @Param @Require onCardClick?: () => void
  settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  @Computed
  get arrivalReminderStations() {
    // 计算还省多少站警告
    if (this.settingInfo.warnType === ArrivalReminderEnum.TIME) {
      const warnValue = this.settingInfo.warnValue
      return warnValue / (CommonConstants.HALF_TIME_BETWEEN_STOP * 2)
    } else {
      return this.settingInfo.warnValue
    }
  }

  build() {
    Row() {
      Column() {
        Text(this.title)
          .fontSize(16)
          .fontColor('#000000')
          .opacity(0.9).fontWeight(FontWeight.Medium)
        Row() {
          Row() {
            Text('站点').margin({ right: 5 }).fontColor('#777777').fontSize(15)
            Text(this.stationText)
              .fontColor('#777777')
              .fontSize(15)
              .width('40%')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .margin({ top: 18, bottom: 10 })

        Row() {
          Text('开往').margin({ right: 5 }).fontColor('#777777').fontSize(15)
          Text(this.headingText)
            .fontColor('#777777')
            .fontSize(15)
            .width('40%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }.alignItems(HorizontalAlign.Start)

      Column() {
        if (this.stopCount <= this.arrivalReminderStations && this.settingInfo.isArrivalReminder) {
          if (this.stopCount <= 1) {
            Row() {
              Text('即将进站').fontColor('#E84026').fontSize(16)
              Text('·').fontColor('#E84026').margin({ left: 1, right: 1 })
              Text(this.stopTime + '分钟').fontColor('#E84026').fontSize(16)
              Image($r('app.media.arrival_notice')).width(10).height(10)
                .offset({ y: -15 })
            }
          } else {
            Row() {
              Text(`${this.stopCount}站`).fontColor('#E84026').fontSize(16)
              Text('·').fontColor('#E84026').margin({ left: 1, right: 1 })
              Text(this.stopTime + '分钟').fontColor('#E84026').fontSize(16)
              Image($r('app.media.arrival_notice')).width(10).height(10)
                .offset({ y: -15 })
            }
          }

        } else {
          if (this.stopCount <= 1) {
            Row() {
              Text('即将进站').fontColor('#0A59F7').fontSize(16)
              Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 })
              Text(this.stopTime + '分钟').fontColor('#0A59F7').fontSize(16)
              Image($r('app.media.arrival')).width(10).height(10)
                .offset({ y: -15 })
            }
          } else {
            Row() {
              Text(`${this.stopCount}站`).fontColor('#0A59F7').fontSize(16)
              Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 })
              Text(this.stopTime + '分钟').fontColor('#0A59F7').fontSize(16)
              Image($r('app.media.arrival')).width(10).height(10)
                .offset({ y: -15 })
            }
          }
        }
      }
    }
    .width('100%')
    .borderRadius(16)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 17 })
    .padding({
      top: 15,
      bottom: 12,
      left: 12,
      right: 12
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick()
      }
    })
  }
}