export class GuestModel {
  seminarGuestId: string
  isPublic: string
  guestsOrder: string
  name: string
  duty: string | null
  enterprise: string | null

  constructor(seminarGuestId: string, isPublic: string, guestsOrder: string, name: string, duty: string | null,
    enterprise: string | null) {
    this.seminarGuestId = seminarGuestId
    this.isPublic = isPublic
    this.guestsOrder = guestsOrder
    this.name = name
    this.duty = duty
    this.enterprise = enterprise
  }
}

export class AgendaItemModel {
  agendaId: string
  name: string
  startTime: string
  endTime: string
  guests: GuestModel[]

  constructor(agendaId: string, name: string, startTime: string, endTime: string, guests: GuestModel[]) {
    this.agendaId = agendaId
    this.name = name
    this.startTime = startTime
    this.endTime = endTime
    this.guests = guests
  }
}


export class AgendaModel {
  agendaDate: number
  agendas: AgendaItemModel[]

  constructor(agendaDate: number, agendas: AgendaItemModel[]) {
    this.agendaDate = agendaDate
    this.agendas = agendas
  }
}

@Observed
export class AgendaDetailModel {
  subSeminarId: string
  name: string
  startTime: string
  endTime: string
  hotel: string
  mAgendaType: string
  mParseIntro: string
  mThirdSeminarId: string
  agendaList: AgendaModel[]
  _agendaList?: AgendaItemModel[]
  mMeetingTypeCn: string
  isCollect: boolean
  favoriteId: string
  mLiveUrl: string
  mTestLive: string
  mLikeMeeting: string
  mLiveStatus: string
  mJingDu: string
  agendaCorrelationData: string
  agendMapName: string

  constructor(subSeminarId: string, name: string, startTime: string, endTime: string, hotel: string,
    mAgendaType: string,
    mParseIntro: string, agendaList: AgendaModel[], mMeetingTypeCn: string, mThirdSeminarId: string,
    isCollect: boolean = false, favoriteId: string, mLiveUrl: string, mTestLive: string, mLikeMeeting: string,
    mLiveStatus: string, mJingDu: string,
    agendaCorrelationData: string, agendMapName: string) {
    this.subSeminarId = subSeminarId
    this.name = name.replace('|', '').split('###')[0] || '';
    this.startTime = startTime
    this.endTime = endTime
    this.hotel = hotel
    this.mAgendaType = mAgendaType
    this.mParseIntro = mParseIntro
    this.agendaList = agendaList
    this.mMeetingTypeCn = mMeetingTypeCn
    this.mThirdSeminarId = mThirdSeminarId
    this.isCollect = isCollect
    this.favoriteId = favoriteId
    this.mLiveUrl = mLiveUrl
    this.mTestLive = mTestLive
    this.mLikeMeeting = mLikeMeeting
    this.mLiveStatus = mLiveStatus || '未开始'
    this.mJingDu = mJingDu
    this.agendaCorrelationData = agendaCorrelationData
    this.agendMapName = agendMapName
  }
}


export interface AgendaDetail {
  detail: AgendaDetailModel
}


export interface liveItem {
  liveId: string,
  status: string
}

