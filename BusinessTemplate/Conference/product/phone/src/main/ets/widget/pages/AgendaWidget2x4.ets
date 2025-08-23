import { RouterType } from '../model/FormCardConstant';
import { CardAgendaModel } from 'commons';
import dayjs from 'dayjs'

let localStorage = new LocalStorage();

@Entry(localStorage)
@Component
struct AgendaMediumWidgetCard {
  @LocalStorageProp('agendaList_2x4') agendaList_2x4: CardAgendaModel[] = [];

  build() {
    Row() {
      Swiper() {
        ForEach(this.agendaList_2x4, (item: CardAgendaModel, index: number) => {
            Column() {
              Text(`${dayjs(Number(item.startTime + '000')).format('MM/DD HH:mm')}-${dayjs(Number(item.endTime +
                '000'))
                .format('HH:mm')}`)
                .fontSize(12)
                .height(17)
                .fontColor('#606162')
                .margin({ bottom: 2 })

              Column() {
                Text(item.name)
                  .fontSize(14)
                  .lineHeight(18)
                  .fontColor('#171718')
                  .fontWeight(700)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .height(36)

              Row() {
                Image($r('app.media.agenda_address_icon1'))
                  .width(10)
                  .height(10)
                  .margin({ right: 2 })

                Text(item.mPlace)
                  .fontSize(10)
                  .fontColor('#909193')
              }
              .width('100%')
              .height(13)
              .margin({ top: 12 })
            }
            .width(206)
            .height('100%')
            .alignSelf(ItemAlign.Stretch)
            .alignItems(HorizontalAlign.Start)
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
        }, (item: CardAgendaModel) => JSON.stringify(item.name))
      }
      .layoutWeight(1)
      .indicator(this.agendaList_2x4.length > 1 ?
      new DotIndicator()
        .bottom(0)
        .left('50%')
        .itemWidth(6)
        .itemHeight(6)
        .selectedItemWidth(12)
        .selectedItemHeight(6)
        .color($r('sys.color.comp_background_secondary'))
        .selectedColor($r('sys.color.comp_background_emphasize')) : false
      )
      .height('100%')

      Column() {
        Column() {
          Image($r('app.media.agenda_date_icon1'))
            .width(32)
            .height(32)

          Text('全部议程')
            .fontColor('#606162')
            .fontSize(10)
            .margin({ top: -1 })
        }
        .padding({ top: 4 })
      }
      .width(54)
      .height(54)
      .margin({
        left: 4,
        bottom: 12
      })
      .borderRadius(8)
      .backgroundColor('#ecf9ee')
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: { type: RouterType.AGENDA }
        });
      })
    }
    .padding(12)
    .width('100%')
    .height('100%')
  }
}