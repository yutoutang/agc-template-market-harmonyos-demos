import { PersistenceV2, promptAction } from '@kit.ArkUI'
import { BaseViewModel, CommonConfirmDialog } from 'lib_common'
import { VideoModel } from 'lib_video_api'
import { DownloadTask, QueueDownloader } from 'video_interaction'

@ObservedV2
export class CachingViewModel extends BaseViewModel {
  @Trace isEditMode: boolean = true
  @Trace toDeleteList: string[] = []
  @Trace list: VideoModel[] = []
  @Trace allSelected: boolean = false
  @Trace queueDownloader: QueueDownloader = PersistenceV2.connect(QueueDownloader,
    () => new QueueDownloader(getContext())
  )!

  callDeleteApi(isDelAll: boolean, toDeleteList: string[]) {
    if (this.queueDownloader) {
      if (isDelAll) {
        this.queueDownloader.cancelAll()
        this.toDeleteList = []
      } else {
        this.toDeleteList = toDeleteList.filter((taskId) => {
          this.queueDownloader.cancelTask(taskId)
          return false
        })
      }
    }
  }

  onChange(value: boolean, task: DownloadTask) {
    if (value) {
      if (!this.toDeleteList.includes(task.id)) {
        this.toDeleteList.push(task.id)
      }
    } else {
      this.toDeleteList = this.toDeleteList.filter(id => id !== task.id);
    }
    const cachingTaskListLength = this.queueDownloader.tasks.filter(v => v.status !== 'completed').length
    this.allSelected = this.toDeleteList.length === cachingTaskListLength
  }

  deleteAllConfirm(queueDownloader: QueueDownloader) {
    if (!this.allSelected) {
      this.toDeleteList = queueDownloader.tasks.filter(v => v.status !== 'completed').map(item => item.id)
      this.allSelected = true
    } else {
      this.toDeleteList = []
      this.allSelected = false
    }
  }

  deleteConfirm() {
    if (this.toDeleteList.length === 0) {
      promptAction.showToast({ message: '至少选择一条缓存' })
      return
    }
    let dialogText: string = ''
    if (this.toDeleteList.length === 1) {
      dialogText = '删除动作不可恢复，是否删除所选缓存？'
    } else {
      dialogText = `删除动作不可恢复，是否删除 ${this.toDeleteList.length} 条缓存？`
    }
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: dialogText,
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        promptAction.showToast({ message: `已删除 ${this.toDeleteList.length} 条缓存` })
        this.callDeleteApi(false, this.toDeleteList)
        this.quitEdit()
      },
    })
  }

  enterEdit() {
    this.isEditMode = true
  }

  quitEdit() {
    this.isEditMode = false
  }

  onBackPressed() {
    if (this.isEditMode) {
      this.quitEdit()
      return true
    }
    return false
  }


  @Computed
  get allowDelete() {
    return this.toDeleteList.length > 0
  }

  @Computed
  get allowEnterEdit() {
    return this.list.length > 0
  }
}