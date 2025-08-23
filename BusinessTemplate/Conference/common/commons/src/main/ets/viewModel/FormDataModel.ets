import { CardAgendaModel } from './ItineraryAndCardAgendaModel';


export class FormDataModel {
  formId: string = '';
  day: string = ''; // 倒计时卡片时间
  _day: number = 0;
  qrcode?: string = ''; // 门票卡片的二维码
  agendaList_2x2?: CardAgendaModel = {
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
    isShowNext: false,
    allNum: 1
  }; // 门票卡片的二维码
  agendaList_2x4?: CardAgendaModel[] = []; // 门票卡片的二维码
  agendaList_4x4?: CardAgendaModel[][] = []; // 门票卡片的二维码

  constructor(formId: string) {
    this.formId = formId;
  }
}
