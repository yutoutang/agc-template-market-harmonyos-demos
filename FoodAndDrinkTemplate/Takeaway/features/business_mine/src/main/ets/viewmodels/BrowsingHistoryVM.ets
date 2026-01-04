import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, CommonConfirmDialog } from 'lib_common';
import { StoreModel, StoreServiceApi } from 'lib_takeaway_api';

@ObservedV2
export class BrowsingHistoryViewModel extends BaseViewModel {
  @Trace list: StoreModel[] = [];
  @Trace toDeleteList: string[] = [];

  constructor() {
    super();
    this.queryList();
  }

  queryList() {
    this.list = StoreServiceApi.queryMyBrowsingHistory().map(v => new StoreModel(v));
  }

  callDeleteApi(isDelAll: boolean, toDeleteList: string[]) {
    if (isDelAll) {
      this.list.forEach(v => {
        StoreServiceApi.deleteFromBrowsingHistory(v.id);
      })
    } else {
      toDeleteList.forEach(v => {
        StoreServiceApi.deleteFromBrowsingHistory(v);
      })
    }

    this.toDeleteList = [];
  }

  deleteAllConfirm() {
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: '删除动作不可恢复，是否删除全部历史记录',
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        this.callDeleteApi(true, []);
        this.queryList();
        promptAction.showToast({ message: '已清空' });
      },
    })
  }

  deleteConfirm() {
    const dialogText: string =
      this.toDeleteList.length === 1 ? '删除动作不可恢复，是否删除此条浏览记录？' :
        `删除动作不可恢复，是否删除 ${this.toDeleteList.length} 条浏览记录？`;
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: dialogText,
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        this.callDeleteApi(false, this.toDeleteList);
        this.queryList();
        promptAction.showToast({ message: '已删除' });
      },
    })
  }
}