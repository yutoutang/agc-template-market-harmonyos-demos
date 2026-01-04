import { PersistenceV2, promptAction } from '@kit.ArkUI'
import { BaseViewModel, CommonConfirmDialog } from 'lib_common'
import { VideoModel, VideoResponse, VideoServiceApi } from 'lib_video_api'
import { DownloadTask, QueueDownloader } from 'video_interaction'

@ObservedV2
export class CachedViewModel extends BaseViewModel {
  @Trace isEditMode: boolean = true
  @Trace toDeleteList: string[] = []
  @Trace list: VideoModel[] = []
  @Trace allSelected: boolean = false
  @Trace queueDownloader: QueueDownloader =
    PersistenceV2.connect(QueueDownloader, () => new QueueDownloader(getContext()))!
  @Trace title: string = ''
  @Trace video: VideoResponse = {} as VideoResponse

  init() {
    const video = VideoServiceApi.getVideoByTitle(this.title)
    if (video) {
      this.video = video
    }
  }

  callDeleteApi(isDelAll: boolean, toDeleteList: string[]) {
    if (!this.queueDownloader) {
      return
    }
    const remainingTasks = this.queueDownloader.tasks.filter(task => {
      return isDelAll ? false : !toDeleteList.includes(task.id)
    })
    this.queueDownloader.tasks = remainingTasks
    this.toDeleteList = []
  }

  onChange(value: boolean, task: DownloadTask) {
    if (value) {
      if (!this.toDeleteList.includes(task.id)) {
        this.toDeleteList.push(task.id)
      }
    } else {
      this.toDeleteList = this.toDeleteList.filter(id => id !== task.id);
    }
    const cachedList = this.queueDownloader.tasks.filter(v => {
      return v.status === 'completed' && v.mediaItem.title === this.title
    })
    this.allSelected = this.toDeleteList.length === cachedList.length
  }

  deleteAllConfirm(queueDownloader: QueueDownloader) {
    if (!this.allSelected) {
      this.toDeleteList = queueDownloader.tasks.filter(v => {
        return v.status === 'completed' && v.mediaItem.title === this.title
      }).map(item => item.id)
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

    const dialogText = this.toDeleteList.length === 1 ? '删除动作不可恢复，是否删除所选缓存？' :
      `删除动作不可恢复，是否删除 ${this.toDeleteList.length} 条缓存？`
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: dialogText,
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        this.callDeleteApi(false, this.toDeleteList)
        this.quitEdit()
        promptAction.showToast({ message: `已删除 ${this.toDeleteList.length} 条缓存` })
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