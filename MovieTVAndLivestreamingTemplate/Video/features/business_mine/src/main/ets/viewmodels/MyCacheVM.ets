import { PersistenceV2, promptAction, UIUtils } from '@kit.ArkUI'
import { BaseViewModel, CommonConfirmDialog } from 'lib_common'
import { VideoModel, VideoResponse, VideoServiceApi } from 'lib_video_api'
import { QueueDownloader } from 'video_interaction'

@ObservedV2
export class MyCacheVM extends BaseViewModel {
  @Trace isEditMode: boolean = true
  @Trace toDeleteList: string[] = []
  @Trace list: VideoModel[] = []
  @Trace allSelected: boolean = false
  @Trace queueDownloader: QueueDownloader =
    PersistenceV2.connect(QueueDownloader, () => new QueueDownloader(getContext()))!
  @Trace relatedVideoList: VideoResponse[] = []

  init() {
    this.relatedVideoList = UIUtils.makeObserved(VideoServiceApi.getRandomVideoList())
  }

  callDeleteApi(isDelAll: boolean, toDeleteList: string[]) {
    if (!this.queueDownloader) {
      return
    }
    // 如果选择下载目录【caching】，则保留 completed
    if (toDeleteList.includes('caching')) {
      const tasks = this.queueDownloader.tasks.filter(task => {
        return task.status !== 'completed'
      })
      tasks.forEach((task) => {
        this.queueDownloader.cancelTask(task.id)
      })
    }

    // 过滤不删除的任务
    const remainingTasks = this.queueDownloader.tasks.filter(task => {
      if (isDelAll) {
        return false
      } else {
        return !toDeleteList.includes(task.mediaItem.title) || task.status !== 'completed'
      }
    })
    this.queueDownloader.tasks = remainingTasks
    this.toDeleteList = []
  }

  onChange(value: boolean, title: string) {
    if (value) {
      if (!this.toDeleteList.includes(title)) {
        this.toDeleteList.push(title)
      }
    } else {
      this.toDeleteList = this.toDeleteList.filter(item => item !== title);
    }
    const titles = this.queueDownloader.cachedTasks.map(v => v.title)
    this.allSelected = this.toDeleteList.length === ['caching', ...titles].length
  }

  deleteAllConfirm() {
    if (!this.allSelected) {
      this.toDeleteList = this.queueDownloader.cachedTasks.map(item => item.title)
      this.toDeleteList.push('caching')
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