import fs from '@ohos.file.fs'
import { BusinessError, request } from '@kit.BasicServicesKit'
import { DownloadStatus, UrlModel } from '../model/DownloadModel'
import { MediaItemModel } from '../model/MediaItemModel'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { util } from '@kit.ArkTS'

type DownloadEvent =
  | 'taskAdded'
  | 'downloadStart'
  | 'progress'
  | 'taskComplete'
  | 'taskFailed'
  | 'taskCancelled'
  | 'taskPaused'
  | 'taskResumed'
  | 'queueEmpty'

interface DownloaderOptions {
  maxConcurrent: number
}

@ObservedV2
export class DownloadTask {
  @Trace id: string = ''
  @Trace url: UrlModel = new UrlModel('', DownloadStatus.Cancel, '')
  @Trace videoId: string = ''
  @Trace mediaItem: MediaItemModel = new MediaItemModel()
  @Trace status: 'pending' | 'downloading' | 'paused' | 'completed' | 'failed' | 'cancelled' = 'pending'
  @Trace downloadTask?: request.DownloadTask
  @Trace uri: string = ''
  @Trace receivedSize: number = 0
  @Trace totalSize: number = 0
  @Trace sectionNo: number = 0
}

export interface DownloadFile {
  title: string
  tasks: DownloadTask[]
  size: number,
  icon: string
}

const TAG = '[QueueDownloader]'

@ObservedV2
export class QueueDownloader {
  private context: Context
  @Trace tasks: DownloadTask[] = []
  @Trace cachedTasks: DownloadFile[] = []
  private activeTasks: number = 0
  private maxConcurrent: number
  private eventListeners: Map<DownloadEvent, ((task: DownloadTask, ...args: Object[]) => void)[]> = new Map()

  constructor(context: Context, options: Partial<DownloaderOptions> = {}) {
    this.context = context
    this.maxConcurrent = options.maxConcurrent || 2
  }

  /**
   * 下载任务完成后，对下载任务按名称分类
   */
  @Monitor('tasks')
  onTasksChange() {
    hilog.info(0x0000, TAG, 'Monitor tasks onTasksChange');
    const cachedTasks = this.tasks.reduce((acc, task) => {
      if (task.status === 'completed') {
        const title = task.mediaItem.title;
        const element = acc.find(e => e.title === title)
        if (element) {
          element.tasks.push(task)
        } else {
          acc.push({
            title: title,
            tasks: [task],
            size: task.totalSize,
            icon: task.mediaItem.coverUrl
          })
        }
      }
      return acc;
    }, [] as DownloadFile[])
    this.cachedTasks = cachedTasks
  }

  /**
   * 添加下载任务到队列
   * @param url 下载地址
   * @param mediaItem 下载媒体对象
   * @param sectionNo 集数
   * @returns 任务ID
   */
  addTask(url: UrlModel, mediaItem: MediaItemModel, sectionNo: number): string {

    // 判断是否已加入任务
    const index = this.tasks.findIndex((item) => {
      return item.videoId === mediaItem.videoId && item.url === url && item.sectionNo === sectionNo
    })

    // 未加入，则加入
    if (index === -1) {
      // 生成唯一的任务ID
      const taskId = Date.now().toString(36) + util.generateRandomUUID().replace(/-/g, '').substring(2, 15)
      const task: DownloadTask = new DownloadTask()
      task.id = taskId
      task.url = url
      task.mediaItem = mediaItem
      task.videoId = mediaItem.videoId
      task.sectionNo = sectionNo
      this.tasks.push(task)
      this.emit('taskAdded', task)
      // 尝试立即开始下载（如果有空闲位置）
      this.processQueue()
      return taskId
    }
    return ''
  }

  /**
   * 开始处理下载队列
   */
  start(): void {
    this.processQueue()
  }

  /**
   * 暂停指定任务
   * @param taskId 任务ID
   */
  pauseTask(taskId: string): void {
    const task = this.findTaskById(taskId)
    if (!task || task.status !== 'downloading') {
      return
    }
    try {
      task.downloadTask?.suspend()
      this.activeTasks--
      this.processQueue() // 继续处理队列中的下一个任务
    } catch (e) {
      hilog.error(0x0000, TAG, 'task.downloadTask.suspend error: %{public}s', JSON.stringify(e));
    }

    task.status = 'paused'
    this.emit('taskPaused', task)
  }

  /**
   * 继续暂停的任务
   * @param taskId 任务ID
   */
  resumeTask(taskId: string): void {
    const task = this.findTaskById(taskId)
    if (!task || task.status !== 'paused') {
      return
    }
    task.status = 'downloading'
    task.downloadTask?.restore()
    this.emit('taskResumed', task)
    this.processQueue()
  }

  /**
   * 取消指定任务
   * @param taskId 任务ID
   */
  cancelTask(taskId: string): void {
    const task = this.findTaskById(taskId)
    if (!task) {
      return
    }
    if (task.status === 'downloading' && task.downloadTask) {
      this.activeTasks--
      task.downloadTask.delete()
    }
    task.status = 'cancelled'

    this.emit('taskCancelled', task)

    // 从队列中移除
    this.tasks = this.tasks.filter(t => t.id !== taskId)
    this.processQueue()
  }

  /**
   * 取消所有任务
   */
  cancelAll(): void {
    this.tasks.forEach(task => {
      if (task.status === 'downloading' && task.downloadTask) {
        task.downloadTask.delete()
      }
      task.status = 'cancelled'
      this.emit('taskCancelled', task)
    })
    this.tasks = []
    this.activeTasks = 0
  }

  /**
   * 获取所有任务
   * @returns 任务列表
   */
  getTasks(): DownloadTask[] {
    return [...this.tasks]
  }

  /**
   * 获取指定任务
   * @param taskId 任务ID
   * @returns 任务信息或undefined
   */
  getTask(taskId: string): DownloadTask | undefined {
    return this.findTaskById(taskId)
  }

  /**
   * 添加事件监听器
   * @param event 事件类型
   * @param listener 事件处理函数
   */
  on(event: DownloadEvent, listener: (task: DownloadTask, ...args: Object[]) => void): void {
    if (!this.eventListeners.has(event)) {
      this.eventListeners.set(event, [])
    }
    this.eventListeners.get(event)!.push(listener)
  }

  /**
   * 移除事件监听器
   * @param event 事件类型
   * @param listener 要移除的事件处理函数
   */
  off(event: DownloadEvent, listener: (task: DownloadTask, ...args: Object[]) => void): void {
    if (this.eventListeners.has(event)) {
      this.eventListeners.set(
        event,
        this.eventListeners.get(event)!.filter(l => l !== listener)
      )
    }
  }

  /**
   * 处理下载队列，开始尽可能多的并发下载
   */
  private processQueue(): void {
    // 如果当前活跃任务数小于最大并发数，并且还有等待的任务
    while (this.activeTasks < this.maxConcurrent && this.tasks.some(task => task.status === 'pending')) {
      const nextTask = this.tasks.find(task => task.status === 'pending')
      if (nextTask) {
        this.startDownload(nextTask)
      }
    }

    // 检查队列是否为空
    if (this.tasks.length === 0 && this.activeTasks === 0) {
      for (let index = 0; index < this.tasks.length; index++) {
        this.emit('queueEmpty', this.tasks[0])
      }
    }
  }

  /**
   * 开始下载指定任务
   * @param task 下载任务
   */
  private startDownload(task: DownloadTask): void {
    this.activeTasks++
    task.status = 'downloading'
    this.emit('downloadStart', task)

    // 检测应用沙箱目录是否存在,不存则创建
    let filesDir = `${this.context.filesDir}/video_cache`
    try {
      if (!fs.accessSync(filesDir)) {
        fs.mkdirSync(filesDir)
      }
    } catch (err) {
      hilog.error(0x0000, TAG, 'mkdirSync error %{public}s', JSON.stringify(err))
    }

    let pathList = task.url.url.split('/')
    //文件名称
    let fileName = pathList[pathList.length-1]
    let filePath = filesDir + '/' + fileName


    try {
      // 判断沙箱内文件是否存在
      fs.access(filePath).then((res: boolean) => {
        if (res) {
          hilog.info(0x0000, TAG, '%{public}s', 'the file exists')
          fs.unlinkSync(filePath)
        }

        // 文件下载
        request.downloadFile(this.context, {
          url: task.url.url,
          filePath: filePath
        }).then((downloadTask: request.DownloadTask) => {
          task.downloadTask = downloadTask
          // 下载进度
          downloadTask.on('progress', (receivedSize: number, totalSize: number) => {
            hilog.info(0x0000, TAG, '%{public}s', 'download receivedSize:' + receivedSize + ' totalSize:' + totalSize)
            task.receivedSize = receivedSize
            task.totalSize = totalSize
            this.emit('progress', task)
          })

          //下载完成
          downloadTask.on('complete', () => {
            hilog.info(0x0000, TAG, 'download complete receivedSize: %{public}s', fs.lstatSync(filePath).size)
            task.status = 'completed'
            let file: fs.File | null = null;
            try {
              file = fs.openSync(filePath)
              task.uri = 'fd://' + file.fd
              this.emit('taskComplete', task)
              this.cleanupTask(task)
              this.onTasksChange()
            } catch (error) {
              hilog.error(0x0000, TAG, '%{public}s', ' fs.openSync error: ' + JSON.stringify(error))
            } finally {
              if (file) {
                setTimeout(() => {
                  fs.closeSync(file)
                }, 1000000)
              }
            }
          })

          downloadTask.on('pause', () => {
            hilog.info(0x0000, TAG, '%{public}s', 'download receivedSize')
          })

          downloadTask.on('fail', (error: number) => {
            task.status = 'failed'
            this.emit('taskFailed', task, error)
            this.cleanupTask(task)
          })

        }).catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, `downloadTask failed, code is ${err.code}, message is ${err.message}`)
        })

      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `access failed with error = ${JSON.stringify(err)}`)
      })
    } catch (error) {
      let err: BusinessError = error as BusinessError
      hilog.error(0x0000, TAG, `access failed with error = ${JSON.stringify(err)}`)
    }
  }

  /**
   * 清理完成的任务
   * @param task 任务
   */
  private cleanupTask(task: DownloadTask): void {
    this.activeTasks--
    task.downloadTask = undefined
    this.processQueue() // 继续处理队列中的下一个任务
  }

  /**
   * 查找指定ID的任务
   * @param taskId 任务ID
   * @returns 任务或undefined
   */
  private findTaskById(taskId: string): DownloadTask | undefined {
    return this.tasks.find(task => task.id === taskId)
  }

  /**
   * 触发事件
   * @param event 事件类型
   * @param task 任务
   * @param args 其他参数
   */
  private emit(event: DownloadEvent, task: DownloadTask, ...args: Object[]): void {
    if (this.eventListeners.has(event)) {
      this.eventListeners.get(event)!.forEach(listener => {
        listener(task, ...args)
      })
    }
  }
}
