export class ItineraryAndCardAgendaModel {
  name: string
  startTime: string
  endTime: string
  mPlace: string
  intro: string
  mMategoryI: string[];
  mMeetingTypeCn: string[]
  subSeminarId: string
  mThirdSeminarId: string
  onlyOneTab: boolean
  isShowNext: boolean
  allNum: number

  constructor(data: ItineraryAndCardAgendaModel) {
    this.name = data.name;
    this.startTime = data.startTime;
    this.endTime = data.endTime;
    this.intro = data.intro;
    this.mPlace = data.mPlace;
    this.mThirdSeminarId = data.mThirdSeminarId;
    this.mMategoryI = data.mMategoryI || []
    this.mMeetingTypeCn = data.mMeetingTypeCn || []
    this.subSeminarId = data.subSeminarId || ''
    this.subSeminarId = data.subSeminarId || ''
    this.onlyOneTab = data.onlyOneTab || false
    this.isShowNext = data.isShowNext || true
    this.allNum = data.allNum || 0
  }
}

export class ItineraryAndCardAgendaItemsByTypeModel {
  type: number
  items: ItineraryAndCardAgendaModel[]

  constructor(data: ItineraryAndCardAgendaItemsByTypeModel) {
    this.type = data.type;
    this.items = data.items;

  }
}

export interface Card2x2Model {
  isLastData: boolean //  是否是最后一个
  onlyOneTab: boolean, //  是否只有一条数据
  sanList: CardAgendaModel[],
  xiList: CardAgendaModel[],
}

export interface Card4x4Model {
  sanList: CardAgendaModel[][],
  xiList: CardAgendaModel[][],
}

export interface Card2x4Model {
  sanList: CardAgendaModel[],
  xiList: CardAgendaModel[],
}

export interface CardAgendaModel {
  name: string
  startTime: string
  endTime: string
  mPlace: string
  intro: string
  mMategoryI: string[];
  mMeetingTypeCn: string[]
  subSeminarId: string
  mThirdSeminarId: string,
  onlyOneTab: boolean, //  是否只有一条数据
  isShowNext: boolean,
  allNum: number
}


export class ItineraryEntry {
  isShow: number = 0 // 是否显示，0不显示，1显示
  time: string = ''
  address: string = ''
  address2: string = ''
  addressDetail: string = ''
}

export class ItineraryKeyNote {
  isShow: number = 0
  mMeetingTypeCn: string[] = []
  startTime: string = ''
  endTime: string = ''
  name: string = ''
  intro: string = ''
  subSeminarId: string = ''
  mThirdSeminarId: string = ''
  mPlace: string = ''
  from: string = ''
  mMategoryI: string[] = []
}


export class ItineraryAgendas {
  isShow: number = 0
  items: ItineraryAndCardAgendaModel[] = []
  itemsByType: ItineraryAndCardAgendaItemsByTypeModel[] = []
  startTime: string = ''
  endTime: string = ''
}


export class ItineraryGala {
  isShow: number = 0
  type: string = ''
  time: string = ''
  name: string = ''
  address: string = ''
}

export class ItineraryTrafficInfo {
  isShow: number = 0
  name: string = ''
  from: string = ''
  to: string = ''
}

export class ItineraryRecommend {
  entry: ItineraryEntry
  keyNote: ItineraryKeyNote
  agendaList: ItineraryAgendas
  gala: ItineraryGala
  trafficInfo: ItineraryTrafficInfo

  constructor() {
    this.entry = new ItineraryEntry()
    this.keyNote = new ItineraryKeyNote()
    this.agendaList = new ItineraryAgendas()
    this.gala = new ItineraryGala()
    this.trafficInfo = new ItineraryTrafficInfo()
  }
}


export interface RecommendParams {
  token?: string;
  time: string; // 请求日期，时间戳格式
  meetDay?: string[]; //  参会人的可参会日期
  address?: string; // 推荐行程的地点 溪流村庄、大广场
  reqForType?: string,
  cardType?: number,
}


export interface CardAgendaEventParams {
  message: string,
  action: string,
  eventName: string,
  tabName: string,
  showIndex: number,
}

export const agenda2x2Data: Card2x2Model = {
  isLastData: false, //  是否是最后一个
  onlyOneTab: false, //  是否只有一条数据
  sanList: [{
    name: '主题演讲',
    startTime: '1758868200',
    endTime: '1758877200',
    mPlace: '篮球中心',
    intro: '',
    mMategoryI: ['东莞'],
    mMeetingTypeCn: ['主题演讲'],
    subSeminarId: '2506143542386969',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }],
  xiList: [{
    name: '【某鸿蒙智家】创新智慧屏交互形态，打造全屋智能新体验',
    startTime: '1758936600',
    endTime: '1758944700',
    mPlace: 'B3 321',
    intro: '',
    mMategoryI: ['大广场'],
    mMeetingTypeCn: ['HarmonyOS 公开课'],
    subSeminarId: '2506113033645225',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }],
}

export const agenda2x4Data: Card2x4Model = {
  sanList: [{
    name: '主题演讲',
    startTime: '1758868200',
    endTime: '1758877200',
    mPlace: '篮球中心',
    intro: '',
    mMategoryI: ['东莞'],
    mMeetingTypeCn: ['主题演讲'],
    subSeminarId: '2506143542386969',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }, {
    name: '【某鸿蒙智家】创新智慧屏交互形态，打造全屋智能新体验',
    startTime: '1758936600',
    endTime: '1758944700',
    mPlace: 'B3 321',
    intro: '',
    mMategoryI: ['大广场'],
    mMeetingTypeCn: ['HarmonyOS 公开课'],
    subSeminarId: '2506113033645225',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }],
  xiList: [{
    name: '音视频AI多模态融合，媒体重塑行业数字化新价值',
    startTime: '1758934800',
    endTime: '1758939300',
    mPlace: 'G10-1B12',
    intro: '测试',
    mMategoryI: ['溪流村庄'],
    mMeetingTypeCn: ['高峰论坛'],
    subSeminarId: '2506111340601082',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }, {
    name: '【语言与框架】高效语言与框架让应用开发更简单',
    startTime: '1758936600',
    endTime: '1758944700',
    mPlace: 'B3 212',
    intro: '',
    mMategoryI: ['大广场'],
    mMeetingTypeCn: ['HarmonyOS 公开课'],
    subSeminarId: '2506041319910020',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }],
}

export const agenda4x4Data: Card4x4Model = {
  sanList: [[{
    name: '主题演讲',
    startTime: '1758868200',
    endTime: '1758877200',
    mPlace: '篮球中心',
    intro: '',
    mMategoryI: ['东莞'],
    mMeetingTypeCn: ['主题演讲'],
    subSeminarId: '2506143542386969',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }, {
    name: '【某鸿蒙智家】创新智慧屏交互形态，打造全屋智能新体验',
    startTime: '1758936600',
    endTime: '1758944700',
    mPlace: 'B3 321',
    intro: '',
    mMategoryI: ['大广场'],
    mMeetingTypeCn: ['HarmonyOS 公开课'],
    subSeminarId: '2506113033645225',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }]],
  xiList: [[{
    name: '音视频AI多模态融合，媒体重塑行业数字化新价值',
    startTime: '1758934800',
    endTime: '1758939300',
    mPlace: 'G10-1B12',
    intro: '测试',
    mMategoryI: ['溪流村庄'],
    mMeetingTypeCn: ['高峰论坛'],
    subSeminarId: '2506111340601082',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }, {
    name: '【语言与框架】高效语言与框架让应用开发更简单',
    startTime: '1758936600',
    endTime: '1758944700',
    mPlace: 'B3 212',
    intro: '',
    mMategoryI: ['大广场'],
    mMeetingTypeCn: ['HarmonyOS 公开课'],
    subSeminarId: '2506041319910020',
    mThirdSeminarId: '',
    onlyOneTab: false, //  是否只有一条数据 只有一条不显示切换按钮
    isShowNext: true,
    allNum: 1
  }]],
}