import { getNextDays, FormatUtil } from 'commonlib';
import { https, ExplainTicketRequest, ExplainTicketInfo } from 'network';
import { CardItem } from 'module_card_swiper';
import { DayItem } from '../types/Index';


const TAG = '[ExplainPageVM]';


@ObservedV2
export class ExplainPageVM {
  @Trace cardList: CardItem[] = [];
  @Trace daysList: DayItem[] = [];
  @Trace explainTicketData: ExplainTicketInfo[] = [];
  @Trace curSwiperIndex: number = 0;
  @Trace curDayIndex: number = 0;
  private static _instance: ExplainPageVM;

  public static get instance() {
    if (!ExplainPageVM._instance) {
      ExplainPageVM._instance = new ExplainPageVM();
    }
    return ExplainPageVM._instance;
  }

  @Monitor('curDayIndex','curSwiperIndex')
  onChange() {
    this.getExplainTicket();
  }

  public async intData() {
    await this.getExplain();
    await this.getExplainTicket();
  }

  public handleDaysList() {
    const arr: DayItem[] = getNextDays(5).map((item) => {
      const obj: DayItem = {
        dayLabel: FormatUtil.dateAsDay(item.date),
        name: item.day,
        date: item.date,
      };
      return obj;
    });
    arr[0].name = '今天';
    arr[1].name = '明天';
    this.daysList = arr;
  }


  public async getExplain() {
    const res = await https.getExplain();
    if (res.code === 0) {
      this.cardList = res.data;
    }
  }

  public async getExplainTicket() {
    const data: ExplainTicketRequest = {
      day: this.daysList[this.curDayIndex].date.toString(),
      explain: this.cardList[this.curSwiperIndex].title,
    };
    const res = await https.getExplainTicketList(data);
    if (res.code === 0) {
      this.explainTicketData = res.data;
    }
  }
}
