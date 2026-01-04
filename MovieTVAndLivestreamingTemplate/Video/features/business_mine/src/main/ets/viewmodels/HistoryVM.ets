import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { BaseViewModel, CommonConfirmDialog } from 'lib_common';
import { HistoryModel, HistoryResponse, MineServiceApi } from 'lib_video_api';

@ObservedV2
export class HistoryViewModel extends BaseViewModel {
  @Trace isEditMode: boolean = true;
  @Trace toDeleteList: string[] = [];
  @Trace history: HistoryModel = AppStorageV2.connect(HistoryModel, () => new HistoryModel())!;
  @Trace allSelected: boolean = false;

  @Computed
  get allowDelete() {
    return this.toDeleteList.length > 0;
  }

  @Computed
  get allowEnterEdit() {
    return this.history.historyList.length > 0;
  }

  isTodayHistory(item: HistoryResponse): boolean {
    // 这里需要根据您的实际数据结构实现日期判断
    // 假设item有一个watchTime字段表示观看时间
    const today = new Date();
    const watchDate = new Date(item.time);
    return watchDate.toDateString() === today.toDateString();
  }

  getItemUniqueId(item: HistoryResponse): string {
    // 将 videoId 和 sectionNo 拼接成一个唯一字符串
    return `${item.videoId}-${item.sectionNo}`;
  }

  callDeleteApi(isDelAll: boolean, toDeleteList: string[]) {
    // toDeleteList 现在存储的是 "videoId-sectionNo" 格式的字符串
    if (isDelAll) {
      MineServiceApi.deleteFromHistory(this.history.historyList.map(v => v.videoId));
      this.history.historyList = [];
    } else {
      // 从唯一ID中解析出 videoId 来调用API
      const videoIdsToDelete = toDeleteList.map(uniqueId => uniqueId.split('-')[0]);
      MineServiceApi.deleteFromHistory(videoIdsToDelete);

      // 在本地列表中，使用完整的唯一ID进行过滤
      this.history.historyList = this.history.historyList.filter(item =>
      !toDeleteList.includes(this.getItemUniqueId(item))
      );
    }
    this.toDeleteList = [];
  }

  onChange(value: boolean, v: HistoryResponse) {
    const uniqueId = this.getItemUniqueId(v); // 使用新的唯一ID
    if (value) {
      if (!this.toDeleteList.includes(uniqueId)) {
        this.toDeleteList.push(uniqueId);
      }
    } else {
      this.toDeleteList = this.toDeleteList.filter(id => id !== uniqueId);
    }
    this.allSelected = this.toDeleteList.length === this.history.historyList.length;
  }

  deleteAllConfirm() {
    if (this.history.historyList.length === 0) {
      promptAction.showToast({ message: '列表为空，无法操作' });
      return;
    }
    if (!this.allSelected) {
      // 全选时，收集所有条目的唯一ID
      this.toDeleteList = this.history.historyList.map(item => this.getItemUniqueId(item));
      this.allSelected = true;
    } else {
      this.toDeleteList = [];
      this.allSelected = false;
    }
  }

  deleteConfirm() {
    if (this.toDeleteList.length === 0) {
      promptAction.showToast({ message: '至少选择一条数据' });
      return
    }
    const dialogText: string =
      this.toDeleteList.length === 1 ? '删除动作不可恢复，是否删除所选播放记录？' : '删除动作不可恢复，是否删除播放记录？';
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: dialogText,
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        this.callDeleteApi(false, this.toDeleteList);
        this.quitEdit();
        promptAction.showToast({ message: '已删除' });
      },
    })
  }

  enterEdit() {
    this.isEditMode = true;
  }

  quitEdit() {
    this.isEditMode = false;
  }

  onBackPressed() {
    if (this.isEditMode) {
      this.isEditMode = false;
      return true;
    }
    return false;
  }
}