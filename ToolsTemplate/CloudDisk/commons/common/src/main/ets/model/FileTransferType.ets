import { FileInfo } from './FileInfo'

/**
 * 文件传输类
 */
@ObservedV2
export class FileTransferProgressingType {
  // 文件信息
  @Trace fileInfo: FileInfo = new FileInfo(0, '', '')
  // 上传文件列表更新下标
  @Trace uploadFileIndex: number = 0
  // 更新状态
  @Trace isUpdateUploadFile: number = 0

  constructor(fileInfo: FileInfo, uploadFileIndex: number, isUpdateUploadFile: number) {
    this.fileInfo = fileInfo
    this.uploadFileIndex = uploadFileIndex
    this.isUpdateUploadFile = isUpdateUploadFile
  }

  // fileInfo、uploadFileIndex、isUpdateUploadFile均被@Trace装饰，能够监听变化
  @Monitor('fileInfo', 'uploadFileIndex', 'isUpdateUploadFile')
  onChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      console.info(`${path} change from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
    })
  }
}

/**
 * fileId保存类型
 */
@ObservedV2
export class FileIdSaveType {
  // 文件id
  @Trace index: number = 0;
  // 文件名
  @Trace fileId: number = 0;

  constructor(index: number, fileId: number) {
    this.index = index
    this.fileId = fileId
  }
}

/**
 * 更新进行中文件状态
 */
@ObservedV2
export class FileTransferProgressingStatus {
  // 更新数组的下标
  @Trace index: number = 0
  // fileId保存成数组
  @Trace fileIdList: Array<FileIdSaveType> = []
  // 文件传输文件下标
  @Trace transferIndex: number = 0
  // 是否新添加
  @Trace isNewAdd: boolean = false
}
