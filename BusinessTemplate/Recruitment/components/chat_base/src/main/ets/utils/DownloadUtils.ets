import { common } from '@kit.AbilityKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { CommonConstants } from './CommonConstants';
import { TaskConstants } from './TaskConstants';

let isNetPause = false;

class DownloadUtils {
  progressCallback: Function | undefined = undefined; // 进度回调
  completedCallback: Function | undefined = undefined; // 完成回调
  failedCallback: Function | undefined = undefined; // 失败回调
  private context = getContext(this) as common.UIAbilityContext;
  private downloadTask: request.agent.Task | undefined = undefined; // 下载任务

  /**
   * 第一种方式
   * 下载图片到沙箱路径，并且保存到相册
   */
  async downloadImage(imageUrl: string, callback: (localPath: string) => void) {
    // 获取沙箱路径
    let splitUrl = imageUrl.split('//')[1].split('/');
    // 下载保存的本地路径
    let localPath = `download/${splitUrl[splitUrl.length-1]}`;
    try {
      // 将web页面的图片下载到沙箱路径
      request.downloadFile(this.context, {
        url: imageUrl,
        filePath: localPath
      })
        .then((downloadTask: request.DownloadTask) => {
          downloadTask.on('complete', async () => {
            // 下载成功后图片的沙箱路径
            callback(localPath);
          })
        }).catch((err: BusinessError) => {
      });
    } catch (error) {
    }
  }

  /**
   * 第二种方法
   * 下载文件
   */
  async downloadFile(url: string,
    callback: (progress: number, isSuccess: boolean, localPath: string) => void) {
    // Found an ongoing download task, prompted and returned.
    try {
      let tasks = await request.agent.search({
        state: request.agent.State.RUNNING,
        action: request.agent.Action.DOWNLOAD,
        mode: request.agent.Mode.FOREGROUND
      });
      if (tasks.length > 0) {
        return;
      }
    } catch (error) {
    }
    let splitUrl = url.split('//')[1].split('/');
    // 下载保存的本地路径
    let localPath = `download/${splitUrl[splitUrl.length-1]}`;
    let downloadConfig: request.agent.Config = {
      action: request.agent.Action.DOWNLOAD,
      url: url,
      method: 'GET',
      title: 'download',
      mode: request.agent.Mode.BACKGROUND,
      retry: true,
      network: request.agent.Network.ANY,
      saveas: `./${localPath}`,
      overwrite: true
    }
    try {
      this.downloadTask = await request.agent.create(this.context, downloadConfig);
      // 监听下载进度
      this.downloadTask.on('progress', this.progressCallback = (progress: request.agent.Progress) => {
        let processed = Number(progress.processed.toString()).valueOf();
        let size = progress.sizes[0];
        let process: number = Math.floor(processed / size * CommonConstants.PROGRESS_MAX);
        if (process < CommonConstants.PROGRESS_MAX) {
          callback(process, false, '');
        }
      })
      // 监听下载完成
      this.downloadTask.on('completed', this.completedCallback = (progress: request.agent.Progress) => {
        callback(CommonConstants.PROGRESS_MAX, true, localPath);
        this.deleteTask();
      })
      // 监听暂停事件
      this.downloadTask.on('pause', this.failedCallback = async (progress: request.agent.Progress) => {
        if (this.downloadTask) {
          let taskInfo = await request.agent.show(this.downloadTask.tid);
          isNetPause = taskInfo.faults === 0;
          if (isNetPause) {
            callback(TaskConstants.TASK_NET_PAUSE_MSG, isNetPause, '');
          } else {
            callback(TaskConstants.TASK_PAUSE_MSG, isNetPause, '');
          }
        }
      })
      // 监听恢复下载事件
      this.downloadTask.on('resume', this.failedCallback = async (progress: request.agent.Progress) => {
        if (this.downloadTask) {
          let taskInfo = await request.agent.show(this.downloadTask.tid);
          if (isNetPause) {
            isNetPause = false;
            callback(TaskConstants.TASK_NET_RESUME_MSG, isNetPause, '');
          } else {
            callback(TaskConstants.TASK_RESUME_MSG, isNetPause, '');
          }
        }
      })
      // 监听下载失败事件
      this.downloadTask.on('failed', this.failedCallback = async (progress: request.agent.Progress) => {
        if (this.downloadTask) {
          let taskInfo = await request.agent.show(this.downloadTask.tid);
        }
        callback(CommonConstants.PROGRESS_MAX, false, '');
        this.deleteTask();
      })
      await this.downloadTask.start();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      callback(CommonConstants.PROGRESS_MAX, false, '');
    }


  }

  // 取消任务
  async deleteTask() {
    if (this.downloadTask) {
      try {
        this.downloadTask.off('progress');
        this.progressCallback = undefined;
        this.downloadTask.off('completed');
        this.completedCallback = undefined
        this.downloadTask.off('failed');
        this.failedCallback = undefined
        await request.agent.remove(this.downloadTask.tid);
      } catch (err) {
      }
    }
    this.downloadTask = undefined;
  }
}

export const downloadUtils = new DownloadUtils()