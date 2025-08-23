import dayjs from 'dayjs'
import { AgendaDetailModel, AgendaItemModel, GuestModel } from '../viewModel/AgendaDetailModel'
import { MyConfig, spacing } from 'commons'

@Extend(Text)
function textExtend(fontColor: ResourceColor | string, fontSize: number, lineHeight: number) {
  .fontSize(fontSize)
  .fontColor(fontColor)
  .lineHeight(lineHeight)
}

@Component
export struct ScheduleItem {
  @Prop item: AgendaItemModel
  @Prop agendaDetail: AgendaDetailModel
  @Prop isLast: boolean

  build() {
    Column() {
      Row() {
        Column() {
          Text(dayjs(parseInt(this.item.startTime) * 1000).format('HH:mm'))
            .textExtend($r('sys.color.black'), 14, 14)
            .margin({ top: 5 })
          if (this.agendaDetail?.mAgendaType === '议程') {
            Image(`${MyConfig.URL}agenda2%2Fline2.png?token=82af29ab-1d1f-49fc-9301-28900a6d6082`).width(7).margin({
              top: 4, bottom: 4
            })
          } else {
            Image(`${MyConfig.URL}agenda2%2Fline.png?token=acfb2348-d0c4-44d6-b74f-abd56b9723f3`).width(7).margin({
              top: 4, bottom: 4
            })
          }
          Text(dayjs(parseInt(this.item.endTime) * 1000).format('HH:mm'))
            .textExtend($r('sys.color.mask_secondary'), 14, 14)
            .margin({ bottom: 5 })
        }
        .margin({ right: 18 })

        Column() {
          Text(this.item.name).fontSize(14).fontColor($r('sys.color.black')).lineHeight(20).fontWeight(500)
          if (this.item.guests.length > 0) {

            Column({ space: 4 }) {
              ForEach(this.item.guests, (guest: GuestModel) => {
                Row() {
                  Text(spacing(guest.name)).fontSize(12).fontColor('#66000000').lineHeight(18)
                  if (guest.enterprise || guest.duty) {
                    Column()
                      .width(1)
                      .height(12)
                      .margin({ left: 6, right: 6, top: 4 })
                      .backgroundColor('#66000000')
                    Column() {
                      Text() {
                        Span(guest.enterprise)
                        Span(guest.duty)
                      }
                      .fontSize(12)
                      .fontColor('#66000000')
                      .lineHeight(17)
                    }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                  }
                }.width('100%').alignItems(VerticalAlign.Top)
              }, (guest: GuestModel) => guest.seminarGuestId)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ top: 8 })
          }
        }
        .justifyContent(FlexAlign.Center)
        .constraintSize({
          minHeight: 76,
        })
        .padding({
          bottom: 12,
        })
        .border({
          width: {
            bottom: this.isLast ? 0 : 1,
          },
          color: '#1a000000',
          style: BorderStyle.Dashed
        })
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ top: 12 })
      .alignItems(VerticalAlign.Top)
    }

  }
}