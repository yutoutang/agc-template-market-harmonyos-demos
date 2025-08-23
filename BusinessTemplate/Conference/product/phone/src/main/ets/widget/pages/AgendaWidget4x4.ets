import { RouterType } from '../model/FormCardConstant';
import { CardAgendaModel } from 'commons';
import dayjs from 'dayjs'

let localStorage = new LocalStorage();

@Entry(localStorage)
@Component
struct AgendaBigWidgetCard {
  @LocalStorageProp('formId') formId: string = '';
  @State isTabActive: number = 0
  @State address: string = '大广场'
  @LocalStorageProp('agendaList_4x4') agendaList_4x4: CardAgendaModel[][] = [[]];

  aboutToAppear(): void {
  }

  @Builder
  agendaItem(item: CardAgendaModel) {
    Column() {
      // 时间
      Row() {
        Text(`${dayjs(Number(item.startTime) * 1000).format('MM/DD')} `)
          .fontSize(12)
          .fontColor('#606162')
          .fontWeight(700)

        Text(`${dayjs(Number(item.startTime) * 1000).format('HH:mm')}-${dayjs(Number(item.endTime) * 1000)
          .format('HH:mm')}`)
          .fontSize(12)
          .fontColor('#606162')

        Blank().layoutWeight(1)

        Column() {
          Text(item.mMeetingTypeCn + '')
            .fontSize(10)
            .fontColor(item.mMeetingTypeCn + '' === '主题演讲' ? '#f2403d' : '#153ad1')
            .fontWeight(500)
        }
        .height(16)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 6, right: 6 })
        .backgroundColor(item.mMeetingTypeCn + '' === '主题演讲' ? '#fff8f5' : '#e9f8fe')
        .borderRadius(4)
      }
      .height(16)

      // 标题
      Column() {
        Text(item.name)
          .fontSize(14)
          .lineHeight(18)
          .fontColor('#171718')
          .fontWeight(700)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(36)
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 6 })

      // 地点
      if (item.mPlace) {
        Row() {
          Image($r('app.media.agenda_address_icon1'))
            .width(10)
            .height(10)
            .margin({ right: 2 })

          Text(item.mPlace)
            .fontSize(10)
            .fontColor('#909193')
        }
        .height(13)
        .margin({ top: 6 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: {
          type: RouterType.AGENDADETAIL,
          agendaId: item.subSeminarId
        }
      });
    })
  }

  @Builder
  bottomItem(icon: Resource, name: string, backColor: string, type: string) {
    Column() {
      Column() {
        Image(icon)
          .width(32)
          .height(32)

        Text(name)
          .fontColor('#606162')
          .fontSize(10)
          .margin({ top: -1 })
      }
      .padding({ top: 4 })
    }
    .flexGrow(1)
    .constraintSize({ maxWidth: 66 })
    .height(54)
    .margin({ right: 4 })
    .borderRadius(8)
    .backgroundColor(backColor)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: { type }
      });
    })
  }

  build() {
    Column() {
      Column() {
        Swiper() {
          ForEach(this.agendaList_4x4, (subItem: CardAgendaModel[], subIndex: number) => {
            Column() {
              ForEach(subItem, (item: CardAgendaModel, index?: number) => {
                this.agendaItem(item)

                if (subItem.length === 2 && index === 0) {
                  Column()
                    .width('100%')
                    .height(1)
                    .margin({ top: 12, bottom: 12 })
                    .border({
                      width: { bottom: 1 },
                      color: 'rgba(0, 0, 0, 0.1)',
                      style: BorderStyle.Dashed
                    })
                }
              }, (item: CardAgendaModel) => JSON.stringify(item.name))
            }
            .padding({ left: 4, right: 4, bottom: 23 })
            .width('100%')
          }, (item: CardAgendaModel[]) => JSON.stringify(item))
        }
        .indicator(this.agendaList_4x4.length > 1 ?
        new DotIndicator()
          .bottom(0)
          .itemWidth(6)
          .itemHeight(6)
          .selectedItemWidth(12)
          .selectedItemHeight(6)
          .color($r('sys.color.comp_background_secondary'))
          .selectedColor($r('sys.color.comp_background_emphasize')) : false
        )
        .loop(true)
        .margin({ bottom: -4 })
      }
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1)

      Row() {
        this.bottomItem($r('app.media.agenda_ticket_icon'), '我的门票', '#fff9f5', RouterType.TICKET)
        this.bottomItem($r('app.media.agenda_date_icon1'), '全部议程', '#ecf9ee', RouterType.AGENDA)
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(12)
    .width('100%')
    .height('100%')
  }
}