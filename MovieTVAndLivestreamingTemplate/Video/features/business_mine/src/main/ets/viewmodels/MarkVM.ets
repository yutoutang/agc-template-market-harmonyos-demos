import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, CommonConfirmDialog } from 'lib_common';
import { VideoModel, VideoServiceApi } from 'lib_video_api';

@ObservedV2
export class MarkViewModel extends BaseViewModel {
  @Trace list: VideoModel[] = [];
  @Trace markAllLikeList: VideoModel[] = [];
  @Trace selectedIds: string[] = []; // 存储选中的视频id
  @Trace allSelected: boolean = false;

  getList() {
    this.list = VideoServiceApi.videoList();
  }

  markLikeList() {
    this.markAllLikeList = VideoServiceApi.markList();
  }

  deleteSelectedItems() {
    if (this.selectedIds.length === 0) {
      return;
    }
    VideoServiceApi.changeMarkIds([...this.selectedIds], false);

    this.markAllLikeList = this.markAllLikeList.filter(
      (item: VideoModel) => !this.selectedIds.includes(item.videoId)
    );
    this.selectedIds = [];
  }

  onChange(selected: boolean, item: VideoModel) {
    if (selected) {
      // 如果选中，且不在selectedIds中，则添加
      if (!this.selectedIds.includes(item.videoId)) {
        this.selectedIds.push(item.videoId);
      }
    } else {
      const index = this.selectedIds.indexOf(item.videoId);
      if (index !== -1) {
        this.selectedIds.splice(index, 1);
      }
    }
    this.allSelected = this.selectedIds.length === this.markAllLikeList.length;
  }

  getSelectedCount(): number {
    return this.selectedIds.length;
  }

  deleteAllConfirm() {
    if (this.markAllLikeList.length === 0) {
      promptAction.showToast({ message: '列表为空，无法操作' });
      return;
    }
    if (!this.allSelected) {
      // 如果不是全选状态，则执行全选
      this.selectedIds = this.markAllLikeList.map(item => item.videoId);
      this.allSelected = true;
    } else {
      // 如果已是全选状态，则执行取消全选
      this.selectedIds = [];
      this.allSelected = false;
    }
  }

  deleteConfirm() {
    const dialogText: string =
      this.selectedIds.length === 1 ? '删除动作不可恢复，是否删除此条浏览记录？' :
        `删除动作不可恢复，是否删除 ${this.selectedIds.length} 条浏览记录？`;
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: dialogText,
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        if (this.selectedIds.length === 0) {
          promptAction.showToast({ message: '至少选择一条数据' });
          return
        }
        VideoServiceApi.changeMarkIds([...this.selectedIds], false);
        this.markAllLikeList = this.markAllLikeList.filter(
          (item: VideoModel) => !this.selectedIds.includes(item.videoId)
        );
        this.selectedIds = [];
        promptAction.showToast({ message: '已删除' });
      },
    })
  }
}
