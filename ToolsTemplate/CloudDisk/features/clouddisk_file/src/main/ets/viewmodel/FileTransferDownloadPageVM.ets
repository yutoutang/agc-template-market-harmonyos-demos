import { promptAction } from '@kit.ArkUI';
import {
  CacheUtil, FileInfo, FileTransferProgressingStatus,
  MockService, RouterMap,
  TCLogger, TimeUtil } from 'common';
import {
  DownloadFileStatus,
  DownloadFileStatusCode,
  FileOperationUtil,
  FileSelectPickerUtil
} from 'module_cloud_upload';
import { FileListSelectViewVM } from 'clouddisk_file_select';
import { NewFileFolderOperationSelectVM } from 'clouddisk_file_operation';
import { phoneRouterControl } from 'oh_router';
import { NavPageInfo } from 'oh_router/src/main/ets/router/interface/RouterPageInfo';
import { FailedFileType, FileTransferManagerPageVM, ProgressingFileType } from './FileTransferManagerPageVM';
import { FileTransferManagerPageBuilder } from '../pages/FileTransferManagerPage';
import { FileManagerPageVM } from './FileManagerPageVM';
import { DirectorDetailPageBuilder } from '../pages/DirectorDetailPage';

@ObservedV2
export class FileTransferDownloadPageVM {
  private readonly logTag: string = 'FileTransferDownloadPageVM'
  private static _rootInstance: FileTransferDownloadPageVM;

  public static get rootInstance(): FileTransferDownloadPageVM {
    if (FileTransferDownloadPageVM._rootInstance === undefined) {
      FileTransferDownloadPageVM._rootInstance = new FileTransferDownloadPageVM()
    }
    return FileTransferDownloadPageVM._rootInstance;
  }

  // 下载文件更新列表
  @Trace downloadFileProgressingList: FileInfo[] = []
  // 文件下载更新提示
  @Trace downloadFileUpdate: FileTransferProgressingStatus = new FileTransferProgressingStatus()
  // 云存储是否登录成功
  private fileOperationUtil: FileOperationUtil = new FileOperationUtil();
  // 下载工具
  private downloadFileOperationUtil: FileOperationUtil = new FileOperationUtil();
  // 下载进行中的文件类型
  @Trace downloadProgressingFileType: ProgressingFileType[] = [
    {
      id: 1,
      name: '样例视频.mp4',
      img: $r('app.media.video_icon'),
      progress: 60,
      progressDes: '256K/1.3M',
      speed: '640K/s',
      vipStatus: true,
      isStop: true,
      path: 'media/SVID_20251017_151401_1.mp4'
    }
  ]
  // 下载进行中的文件类型
  @Trace downloadFailedFileType: FailedFileType[] = [
    {
      name: 'IMG_20251105_195704.jpg',
      img: $r('app.media.picture_icon'),
      des: '下载失败',
      isRetry: false,
      path: 'media/IMG_20251105_195704.jpg'
    },
    {
      name: '欢迎使用华为文件管理.pdf',
      img: $r('app.media.picture_icon'),
      des: '下载失败',
      isRetry: false,
      path: 'document/欢迎使用华为文件管理.pdf'
    }
  ]
  // 显示上拉操作栏
  @Trace isShowOperation: boolean = false;
  // 下载已完成的文件
  @Trace downloadSelectVM: FileListSelectViewVM = new FileListSelectViewVM(this.createDownloadCompleteFileArray());

  // 静态方法：创建已完成文件数组
  private createDownloadCompleteFileArray(): FileInfo[] {
    let fileArray: FileInfo[] = [];
    // 创建第一个文件
    let file1: FileInfo = new FileInfo(1, '个人影集个人影集.png', '2025-11-04 14:55:00');
    file1.des = '303K 下载到：缓存/文件夹'
    fileArray.push(file1);

    let file2: FileInfo = new FileInfo(1, '图片.png', '2025-11-04 14:55:00');
    file2.des = '303K 下载到：缓存/文件夹'
    fileArray.push(file2);

    let file3: FileInfo = new FileInfo(2, '视频.mp4', '2025-11-04 14:55:00');
    file3.des = '303K 下载到：缓存/文件夹'
    fileArray.push(file3);
    return fileArray;
  }

  // 开启下载文件任务
  public startDownloadFileTask(fileInfo: FileInfo) {
    this.downloadFileOperationUtil.setDownloadProgressUtil((downloadFileStatus: DownloadFileStatus) => {
      // 更新下载进度
      this.updateDownloadFileStatus(downloadFileStatus, fileInfo, false, false)
    })
    // 初始化云存储登录
    if (!FileOperationUtil.isInitSuccess) {
      this.fileOperationUtil.init().then((res: boolean) => {
        FileOperationUtil.isInitSuccess = true
        this.downloadFileTask(fileInfo)
      })
      return
    }
    this.downloadFileTask(fileInfo)
  }

  // 下载文件任务
  private downloadFileTask(fileInfo: FileInfo) {
    this.downloadFileOperationUtil.checkAndDownloadFile(fileInfo).then((result) => {
      // 成功
      if (result.code === DownloadFileStatusCode.SUCCESS) {
        promptAction.showToast({
          message: result.fileName + ' 下载成功！'
        })
        // 添加文件
        this.updateDownloadFileStatus(result, fileInfo, true)
        FileTransferManagerPageVM.rootInstance.downloadSelectedCompleteStatus = '已完成'
        TCLogger.info(this.logTag, `downloadFile succeeded, result: ${JSON.stringify(result)}`)
      } else {
        promptAction.showToast({
          message: result.fileName + ' 下载失败！'
        })
        // 上传失败了
        this.updateDownloadFileStatus(result, fileInfo, true, false)
        FileTransferManagerPageVM.rootInstance.downloadSelectedCompleteStatus = '任务失败'
        TCLogger.info(this.logTag, `downloadFile failed, result: ${JSON.stringify(result)}`)
      }
    })
  }

  // 上报下载进度
  updateDownloadFileStatus(item: DownloadFileStatus, fileInfoItem: FileInfo, isCompleted: boolean = false,
    isSucceed: boolean = true) {
    // 文件类型
    const filename: string = item.fileName.split('/').pop() as string
    const fileType: string = filename.split('.').pop() as string
    item.fileSuffix = FileSelectPickerUtil.getFileType(fileType)
    // 创建时间
    item.createTime =
      `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_HYPHEN)} ${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_COLON)}`;
    // 创建文件对象
    const fileInfo: FileInfo = new FileInfo(item.fileSuffix, item.fileName.split('/').pop() as string, item.createTime);
    // 文件的fileId
    fileInfo.fileId = fileInfoItem.fileId
    fileInfo.parentFileId = fileInfoItem.parentFileId
    fileInfo.path = item.filePath
    fileInfo.fileSize = CacheUtil.formatCacheFileSize(item.fileSize)
    fileInfo.fileSizeByte = item.fileSize
    fileInfo.updateTime = item.createTime
    fileInfo.progress = item.progress
    fileInfo.progressDes =
      `${CacheUtil.formatCacheFileSize(item.progress)}/${CacheUtil.formatCacheFileSize(item.fileSize)}`
    fileInfo.speed = CacheUtil.formatCacheFileSpeed(item.progress, item.progressTime)
    fileInfo.vipStatus = item.vipStatus
    fileInfo.des = `${CacheUtil.formatCacheFileSize(item.fileSize)} 下载到：缓存/`
    fileInfo.downloadUrl = item.fileName
    fileInfo.isCompleted = isCompleted
    fileInfo.isSucceed = isSucceed
    // 添加更新下载列表文件
    this.updateAndAddDownloadFileStatus(fileInfo)
  }

  // 跳转文件传输页面
  private updateAndAddDownloadFileStatus(file: FileInfo, isJump: boolean = true,
    newFileFolderVm?: NewFileFolderOperationSelectVM) {
    const fileInfoList: FileInfo[] =
      this.downloadFileProgressingList.filter((fileInfo: FileInfo, i: number) => {
        if (this.downloadFileProgressingList[i].name === file.name &&
          this.downloadFileProgressingList[i].isCompleted === false) {
          this.downloadFileProgressingList[i] = file
          // 修改文件传输状态
          this.downloadFileUpdate.index = i
          this.downloadFileUpdate.isNewAdd = false
          this.addFileToDownloadProgressingList()
          TCLogger.info(this.logTag,
            'Update downloadFileUpdate: ' + file.name + ', progress: ' + (file.progress / file.fileSizeByte * 100) +
              ', downloadFileUpdate: ' + JSON.stringify(this.downloadFileUpdate));
          return true
        } else {
          return false
        }
      })
    if (fileInfoList.length === 0) {
      if (newFileFolderVm) {
        this.putFileInfoToDownloadList(file, isJump, newFileFolderVm)
      } else {
        this.putFileInfoToDownloadList(file, isJump)
      }
    }
  }

  // 添加记录到列表中
  putFileInfoToDownloadList(fileInfo: FileInfo, isJump: boolean = true,
    newFileFolderVm?: NewFileFolderOperationSelectVM) {
    this.downloadFileProgressingList.push(fileInfo)
    TCLogger.info(this.logTag,
      'Add downloadFileUpdate: ' + fileInfo.name + ', progress: ' + (fileInfo.progress / fileInfo.fileSizeByte * 100) +
        ', downloadFileUpdate: ' + JSON.stringify(this.downloadFileUpdate));
    // 修改文件传输状态
    this.downloadFileUpdate.index = this.downloadFileProgressingList.length - 1
    this.downloadFileUpdate.isNewAdd = true
    this.addFileToDownloadProgressingList()
    if (isJump) {
      if (newFileFolderVm) {
        // 隐藏上传文件上拉框
        newFileFolderVm.isShow = false
      }
      // 主动跳转文件传输页面
      this.jumpToFileTransferPage()
    }
  }

  /**
   * 添加下载进行中文件到列表中
   */
  addFileToDownloadProgressingList() {
    if (this.downloadFileUpdate.isNewAdd) {
      const item = this.downloadFileProgressingList[this.downloadFileUpdate.index]
      const progressingFile = new ProgressingFileType()
      progressingFile.id = item.fileId
      progressingFile.name = item.name.split('/').pop() as string
      progressingFile.img = FileListSelectViewVM.getImageSource(item.fileType)
      progressingFile.progress = (item.progress / item.fileSizeByte * 100)
      progressingFile.progressDes = item.progressDes
      progressingFile.speed = item.speed
      progressingFile.vipStatus = item.vipStatus
      progressingFile.isStop = false
      progressingFile.path = item.path
      this.downloadProgressingFileType.push(progressingFile)
    }
    // 更新进行中的文件
    const item = this.downloadFileProgressingList[this.downloadFileUpdate.index]
    const itemName = item.name.split('/').pop() as string
    for (let index = 0; index < this.downloadProgressingFileType.length; index++) {
      const progressingFile = this.downloadProgressingFileType[index]
      if (itemName === progressingFile.name) {
        progressingFile.name = item.name.split('/').pop() as string
        progressingFile.img = FileListSelectViewVM.getImageSource(item.fileType)
        progressingFile.progress = (item.progress / item.fileSizeByte * 100)
        progressingFile.progressDes = item.progressDes
        progressingFile.speed = item.speed
        progressingFile.vipStatus = item.vipStatus
        progressingFile.isStop = false
        progressingFile.path = item.path
        // 传输结束，从进行中列表中删除，添加到已完成、任务失败列表中
        this.handleDownloadProgressingFile(progressingFile, item)
        break;
      }
    }
  }

  // 传输完成，结果：已完成、任务失败
  handleDownloadProgressingFile(progressingFile: ProgressingFileType, item: FileInfo) {
    if (progressingFile.progress === 100 && item.isCompleted === true && item.isSucceed === true) {
      this.downloadProgressingFileType =
        this.downloadProgressingFileType.filter((item) => item.name !== progressingFile.name)
      // 加到已完成列表
      this.downloadSelectVM.fileList.push(item)
    } else if (item.isCompleted === true && item.isSucceed === false) {
      this.downloadProgressingFileType =
        this.downloadProgressingFileType.filter((item) => item.name !== progressingFile.name)
      // 加入到任务失败列表
      const failedFile: FailedFileType = {
        name: progressingFile.name,
        img: progressingFile.img,
        des: '下载失败',
        isRetry: false,
        path: progressingFile.path
      }
      this.downloadFailedFileType.push(failedFile)
    }
  }

  // 跳转文件传输页面
  jumpToFileTransferPage() {
    // 跳转下载tab的进行中标签
    FileTransferManagerPageVM.rootInstance.selectedTabTitle = '下载'
    FileTransferManagerPageVM.rootInstance.downloadSelectedCompleteStatus = '进行中'
    const navPageInfoList: NavPageInfo[] = phoneRouterControl.getNavPageInfoList().filter((navPageInfo) => {
      return navPageInfo.pageName === RouterMap.FILE_TRANSFER_MANAGER_PAGE
    })
    if (navPageInfoList.length === 0) {
      // 绑定vm操作对象
      phoneRouterControl.jumpPage({
        pageName: RouterMap.FILE_TRANSFER_MANAGER_PAGE,
        builder: wrapBuilder(FileTransferManagerPageBuilder),
      })
    }
  }

  // 根据文件id获取文件所在目录
  getFilePathByFileId(fileId: number, parentFileId: number): void {
    // 先判断是否在文件页面根目录下
    const isRoot: boolean =
      MockService.checkFileIsBasicPath(fileId, MockService.currentFileList)
    if (isRoot) {
      // 返回文件页面
      phoneRouterControl.popPage()
      return
    }
    const fileInfo: FileInfo | undefined =
      MockService.searchFileInfoBy(parentFileId, MockService.currentFileList)
    if (fileInfo) {
      // 跳转文件所在目录
      phoneRouterControl.jumpPage({
        pageName: RouterMap.DIRECTOR_DETAIL_PAGE,
        builder: wrapBuilder(DirectorDetailPageBuilder),
        param: fileInfo
      })
    } else {
      promptAction.showToast({
        message: '未找到文件位置'
      })
    }
  }
}