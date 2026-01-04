import { PersistenceV2, Type } from '@kit.ArkUI';
import { AddressModel, IAddressInfo } from '../types/Address';

@ObservedV2
export class HistoryListModel {
  @Type(AddressModel)
  @Trace list: AddressModel[] = [];
}

@ObservedV2
export class HistoryUtil {
  // 搜索历史记录
  private static _historyList: HistoryListModel =
    PersistenceV2.connect(HistoryListModel, 'historyList', () => new HistoryListModel())!;

  public static getHistoryList() {
    return HistoryUtil._historyList;
  }

  public static clearList() {
    HistoryUtil._historyList.list.length = 0;
  }

  public static addOne(info: IAddressInfo) {
    const index = HistoryUtil._findIndex(info.siteId ?? '');
    if (index !== -1) {
      HistoryUtil._removeHead(index, info);
      return;
    }
    HistoryUtil._historyList.list.unshift({
      siteId: info.siteId ?? '',
      name: info.name,
      addr: info.addr ?? '',
      location: info.location,
    });
  }

  private static _removeHead(index: number, info: IAddressInfo) {
    HistoryUtil._historyList.list.splice(index, 1);
    HistoryUtil._historyList.list.unshift({
      siteId: info.siteId ?? '',
      name: info.name,
      addr: info.addr ?? '',
      location: info.location,
    });
  }

  private static _findIndex(siteId: string) {
    return HistoryUtil.getHistoryList().list.findIndex(item => item.siteId === siteId);
  }
}
