import { https, IBasicHouse, IHistoryDeleteRequest, Logger, Record } from 'foundation';
import { HouseHistory } from '../model/Index';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class MineVM {
  @Trace houseTypeIndex: number = 0;
  @Trace historyList: HouseHistory[] = [];
  @Trace loading: boolean = false;
  @Trace checkedHouses: Record[] = [];
  private static _instance: MineVM;

  public static get instance() {
    if (!MineVM._instance) {
      MineVM._instance = new MineVM();
    }
    return MineVM._instance;
  }

  deleteHistory(records: Record[]) {
    records.forEach(item => {
      this.historyList = this.historyList?.map(history => {
        if (history.date === item.date) {
          // 取差集
          let result = history.houses.filter(house => !item.houses.includes(house.houseId));
          return {
            date: history.date,
            houses: result,
          } as HouseHistory;
        } else {
          return {
            date: history.date,
            houses: [],
          };
        }
      });
    });
    Logger.info('history after delete is ' + this.historyList.length);
  }

  handleCheckBoxResult(value: boolean, date: string, houseId: string) {
    if (value) {
      // 如为勾选
      let exist = this.checkedHouses.some(item => item.date === date);
      if (!exist) {
        // 存在该日期勾选内容
        this.checkedHouses.push({
          date: date,
          houses: [houseId],
        });
      } else {
        let index = this.checkedHouses.findIndex(item => item.date === date);
        let history = this.checkedHouses[index];
        if (history) {
          history.houses.push(houseId);
          this.checkedHouses.splice(index, 1, history);
        }
      }
    } else {
      // 如为取消勾选
      let index = this.checkedHouses.findIndex(item => item.date === date);
      let history = this.checkedHouses[index];
      if (history) {
        history.houses = history.houses.filter(item => item !== houseId);
        this.checkedHouses.splice(index, 1, history);
      }
    }
  }

  handleCheckBoxGroupResult(result: CheckboxGroupResult) {
    if (result.status === SelectStatus.None) {
      this.checkedHouses = [];

    } else if (result.status === SelectStatus.All) {
      this.checkedHouses = this.historyList.map((history: HouseHistory) => {
        let houseIds: string[] = history.houses.map((house: IBasicHouse) => {
          return house.houseId;
        });
        let checked = {
          date: history.date,
          houses: houseIds,
        } as Record;
        return checked;
      });
    }
  }

  getHistoryList() {
    https.queryHistoryList(this.houseTypeIndex + 1).then((res) => {
      let list = Array.from(res.data);

      this.historyList = list.map((item => {
        return {
          date: item[0],
          houses: item[1],
        } as HouseHistory;
      }));
      this.loading = false;
      Logger.info('get history list success with ' + this.historyList.length);
    });
  }

  deleteRemoteHistory(type: number, records: Record[], uiContext: UIContext) {
    let param: IHistoryDeleteRequest = {
      type: type,
      records: records,
    };
    https.deleteHistory(param).then((res) => {
      if (res.code === 0) {
        uiContext.getPromptAction().showToast({ message: '删除成功', duration: 1000 });
        this.loading = true;
        this.getHistoryList();
      }
    });
  }
}