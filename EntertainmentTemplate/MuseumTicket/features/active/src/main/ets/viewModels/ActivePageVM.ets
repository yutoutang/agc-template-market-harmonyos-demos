import { ActiveInfo, https } from 'network';
import { ActiveType } from '../types/Index';


const TAG = '[ActivePageVM]';


@ObservedV2
export class ActivePageVM {
  @Trace activeTypes: ActiveType[] = [
    {
      label: '全部活动',
      value: '0',
    },
    {
      label: '预约中',
      value: '1',
    },
    {
      label: '待开放',
      value: '2',
    },
    {
      label: '已结束',
      value: '3',
    },
  ];
  @Trace curIndex: number = 0;
  @Trace activeData: ActiveInfo[] = [];
  private static _instance: ActivePageVM;

  public static get instance() {
    if (!ActivePageVM._instance) {
      ActivePageVM._instance = new ActivePageVM();
    }
    return ActivePageVM._instance;
  }

  @Monitor('curIndex')
  onchange() {
    this.getActiveInfo();
  }

  public async getActiveInfo() {
    const res = await https.getActiveInfo();
    if (res.code === 0) {
      if (this.curIndex === 0) {
        this.activeData = res.data;
      } else {
        this.activeData = res.data.filter((item) => item.type === this.curIndex.toString());
      }
    }
  }
}
