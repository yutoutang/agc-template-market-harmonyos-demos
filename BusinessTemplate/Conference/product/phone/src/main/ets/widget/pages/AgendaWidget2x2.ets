import { CardAgendaModel } from 'commons';
import dayjs from 'dayjs'
import { RouterType } from '../model/FormCardConstant';

let localStorage = new LocalStorage();

@Entry(localStorage)
@Component
struct Agenda2x2Card {
  @LocalStorageProp('formId') formId: string = '';
  @LocalStorageProp('agendaList_2x2') agendaList_2x2: CardAgendaModel = {
    name: '',
    startTime: '',
    endTime: '',
    mPlace: '',
    intro: '',
    mMategoryI: [],
    mMeetingTypeCn: [],
    subSeminarId: '',
    mThirdSeminarId: '',
    onlyOneTab: false,
    isShowNext: true,
    allNum: 1
  };
  @State index: number = 0;

  build() {
    Column() {
      Column() {
        Column() {
          Text(`${dayjs(Number(this.agendaList_2x2.startTime + '000'))
            .format('MM/DD HH:mm')}-${dayjs(Number(this.agendaList_2x2.endTime + '000')).format('HH:mm')}`)
            .fontSize(12)
            .fontColor('#606162')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ bottom: 2 })

        Column() {
          Text(this.agendaList_2x2.name)
            .fontSize(12)
            .lineHeight(16)
            .fontColor('#171718')
            .fontWeight(700)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .height(32)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ bottom: 4 })

        Row() {
          Image($r('app.media.agenda_address_icon1'))
            .width(10)
            .height(10)
            .margin({ right: 2 })

          Text(this.agendaList_2x2.mPlace)
            .fontSize(10)
            .fontColor('#909193')
        }
        .width('100%')
        .height(13)
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 5 })
      }
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {
            type: RouterType.AGENDADETAIL,
            agendaId: this.agendaList_2x2.subSeminarId
          }
        });
      })

      Column() {
        Text('全部议程')
          .fontSize(10)
          .fontColor(Color.White)
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgb(242, 64, 61)')
      .borderRadius(40)
      .width('100%')
      .height(28)
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {
            type: RouterType.AGENDA
          }
        });
      })
    }
    .padding(12)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
  }
}