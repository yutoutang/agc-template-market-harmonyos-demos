import { promptAction } from '@kit.ArkUI';
import auth from '@hw-agconnect/auth';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { cloudCommon, cloudStorage } from '@kit.CloudFoundationKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { FileInfo, FileType, GlobalContext, TCLogger } from 'common';
import {
  DownloadFileStatus,
  DownloadFileStatusCode,
  UploadFileStatus,
  UploadFileStatusCode
} from '../model/DocumentTypeClass';
import { SafetyRuleConstants } from '../constant/Constants';

export class FileOperationUtil {
  public readonly logTag: string = 'FileOperationUtil'
  //todo 替换为AGC云存储服务中创建的实际bucket名称
  private storageBucket: cloudStorage.StorageBucket = cloudStorage.bucket('cloud-disk-kow6o');
  // 文件
  private static uploadFileStatusList: UploadFileStatus[] = [];
  // 下载文件列表
  private static downloadFileStatusList: DownloadFileStatus[] = [];
  // 初始化成功标志
  public static isInitSuccess: boolean = false;
  // 上传进度接口对象
  progressUtil: (uploadFileStatus: UploadFileStatus) => void = (uploadFileStatus: UploadFileStatus) => {
  }
  // 下载进度接口对象
  downloadProgressUtil: (downloadFileStatus: DownloadFileStatus) => void = (downloadFileStatus: DownloadFileStatus) => {
  }

  // 设置通知进度变化
  public setProgressUtil(progressUtil: (uploadFileStatus: UploadFileStatus) => void) {
    this.progressUtil = progressUtil
  }

  // 设置下载上报进度变化
  public setDownloadProgressUtil(progressUtil: (downloadFileStatus: DownloadFileStatus) => void) {
    this.downloadProgressUtil = progressUtil
  }

  // 初始化登录和云存储
  //todo 替换为AGC云存储服务中创建的实际bucket名称
  public init(cloudStorageName: string = 'cloud-disk-kow6o'): Promise<boolean> {
    return new Promise((resolve, reject) => {
      if (SafetyRuleConstants.MODIFY_SAFETY_RULE) {
        auth.signOut().then(() => {
          // 登出成功
          this.loginAndInit().then(res => {
            // 重新初始化云存储
            this.storageBucket = cloudStorage.bucket(cloudStorageName);
            // // 云存储初始化成功
            promptAction.showToast({
              message: `云存储初始化${res ? '成功' : '失败'}`
            })
            resolve(res)
          })
        }).catch((error: BusinessError) => {
          // 登出失败
          this.loginAndInit().then(res => {
            // 重新初始化云存储
            this.storageBucket = cloudStorage.bucket(cloudStorageName);
            // // 云存储初始化成功
            promptAction.showToast({
              message: `云存储初始化${res ? '成功' : '失败'}`
            })
            resolve(res)
          })
        })
      } else {
        resolve(false)
      }
    })

  }

  /**
   * 登录并初始化
   */
  private loginAndInit(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      auth.signIn({
        autoCreateUser: true,
        credentialInfo: {
          kind: 'hwid'
        }
      }).then(signInResult => {
        TCLogger.info(this.logTag, `signInHwid success. result: ${signInResult.getUser().getUid()}`);
        let authProvider = auth.getAuthProvider();
        cloudCommon.init({
          region: cloudCommon.CloudRegion.CHINA,
          authProvider: authProvider,
          functionOptions: { timeout: 10 * 1000 },
          storageOptions: { mode: request.agent.Mode.BACKGROUND, network: request.agent.Network.ANY },
          databaseOptions: { schema: 'schema.json', traceId: 'traceId' }
        })
        resolve(true)
      })
        .catch((error: BusinessError) => {
          TCLogger.info(this.logTag, `signInHwid error, Code: ${error.code}, message: ${error.message}`);
          resolve(false)
        })
    })

  }

  /**
   * 上传文件
   */
  public uploadFile(localPath: string, cloudPath: string, filePath: string = ''): Promise<UploadFileStatus> {
    const uploadFileStatus: UploadFileStatus = {
      fileName: '',
      filePath: filePath,
      fileSuffix: FileType.PrivateSpace,
      progress: 0,
      code: UploadFileStatusCode.FAILED,
      fileSize: 0,
      createTime: '',
      startTime: Date.now(),
      progressTime: 0,
      vipStatus: true
    };
    // 检查是否有重复文件名，有则改名
    cloudPath = this.checkSameFileName(uploadFileStatus, cloudPath)
    FileOperationUtil.uploadFileStatusList.push(uploadFileStatus)

    return new Promise((resolve, reject) => {
      this.storageBucket.uploadFile(GlobalContext.getUIAbilityContext(), {
        localPath: localPath, // 本地文件路径（context.cacheDir目录下的文件路径）
        cloudPath: cloudPath   // 云侧路径，支持传入“文件目录/文件名”（如“screenshot/demo.jpg”），或仅传入文件名。
      }).then((task: request.agent.Task) => {
        task.on('progress', (progress) => {
          TCLogger.info(this.logTag, `on progress ${JSON.stringify(progress)}`);
          // 回调上报进度更新
          this.reportProgressing(uploadFileStatus, progress)
          this.progressUtil(uploadFileStatus)
        });
        task.on('completed', (progress) => {
          TCLogger.info(this.logTag, `on completed ${JSON.stringify(progress)}`);
          // 上传成功
          uploadFileStatus.code = UploadFileStatusCode.SUCCESS
          // 文件大小
          uploadFileStatus.fileSize = progress.sizes[0]
          // 进度条
          uploadFileStatus.progress = progress.processed;
          // 传输时间（秒）
          uploadFileStatus.progressTime = (Date.now() - uploadFileStatus.startTime) / 1000
          resolve(uploadFileStatus)
        });
        task.on('failed', (progress) => {
          TCLogger.info(this.logTag, `on failed ${JSON.stringify(progress)}`);
          // 上传失败
          uploadFileStatus.code = UploadFileStatusCode.FAILED
          // 文件大小
          uploadFileStatus.fileSize = progress.sizes[0]
          resolve(uploadFileStatus)
        });
        task.on('response', (response) => {
          TCLogger.info(this.logTag, `on response ${JSON.stringify(response)}`);
        });

        // start task
        task.start((err: BusinessError) => {
          if (err) {
            TCLogger.info(this.logTag,
              `Failed to start a file upload task, code: ${err.code}, message: ${err.message}`);
          } else {
            TCLogger.info(this.logTag, `Succeeded in starting a file upload task.`);
          }
          // 开始上传任务
          uploadFileStatus.fileName = cloudPath
        });
      }).catch((err: BusinessError) => {
        TCLogger.info(this.logTag, `Failed to upload file, code: ${err.code}, message: ${err.message}`);
        // 失败任务
        uploadFileStatus.code = UploadFileStatusCode.FAILED
      })
    })
  }

  // 下载文件
  public download(fileName: string, cloudName: string): Promise<DownloadFileStatus> {
    const downloadFileStatus: DownloadFileStatus = {
      fileName: GlobalContext.getUIAbilityContext().cacheDir + '/' + fileName,
      filePath: cloudName,
      fileSuffix: FileType.PrivateSpace,
      progress: 0,
      code: DownloadFileStatusCode.FAILED,
      fileSize: 0,
      createTime: '',
      startTime: Date.now(),
      progressTime: 0,
      vipStatus: true
    };
    // 检查是否有重复文件名，有则改名
    downloadFileStatus.fileName = this.checkSameDownloadFileName(downloadFileStatus)
    FileOperationUtil.downloadFileStatusList.push(downloadFileStatus)

    return new Promise((resolve, reject) => {
      // 获取云存储默认实例中fileName文件，保存至本地
      this.storageBucket.downloadFile(GlobalContext.getUIAbilityContext(), {
        localPath: downloadFileStatus.fileName, // 文件将会保存在context.cacheDir目录下
        cloudPath: cloudName  // 云侧文件路径，支持传入“文件目录/文件名”，或仅传入文件名
      }).then((task: request.agent.Task) => {
        task.on('progress', (progress) => {
          TCLogger.info(this.logTag, `download file on progress ${JSON.stringify(progress)} `);
          // 回调上报进度更新
          this.reportProgressing(downloadFileStatus, progress)
          this.downloadProgressUtil(downloadFileStatus)
        });
        task.on('completed', (progress) => {
          TCLogger.info(this.logTag, `download file on completed ${JSON.stringify(progress)} `);
          // 下载成功
          downloadFileStatus.code = DownloadFileStatusCode.SUCCESS
          // 文件大小
          downloadFileStatus.fileSize = progress.sizes[0]
          // 进度条
          downloadFileStatus.progress = progress.processed;
          // 传输时间（秒）
          downloadFileStatus.progressTime = (Date.now() - downloadFileStatus.startTime) / 1000
          resolve(downloadFileStatus)
        });
        task.on('failed', (progress) => {
          TCLogger.info(this.logTag, `download file on failed ${JSON.stringify(progress)} `);
          // 下载失败
          downloadFileStatus.code = DownloadFileStatusCode.FAILED
          // 文件大小
          downloadFileStatus.fileSize = progress.sizes[0]
          // 下载失败
          resolve(downloadFileStatus)
        });
        task.on('response', (response) => {
          TCLogger.info(this.logTag, `download file on response ${JSON.stringify(response)} `);
        });
        task.start((err: BusinessError) => {
          if (err) {
            TCLogger.info(this.logTag,
              `Failed to start a file download task, code: ${err.code}, message: ${err.message}`);
          } else {
            TCLogger.info(this.logTag, `Succeeded in starting a file download task. result: ${task.tid}`);
          }
        });
      }).catch((err: BusinessError) => {
        TCLogger.info(this.logTag, `Failed to download file, code: ${err.code}, message: ${err.message}`);
        // 失败任务
        downloadFileStatus.code = DownloadFileStatusCode.FAILED
        resolve(downloadFileStatus)
      })
    })
  }

  // 检查下载文件是否在缓存中
  public checkAndDownloadFile(file: FileInfo): Promise<DownloadFileStatus> {
    return new Promise((resolve, reject) => {
      try {
        if (file.downloadUrl === '') {
          TCLogger.info(this.logTag, `check and download file on response, downloadUrl empty `);
          const downloadFileStatus: DownloadFileStatus = {
            fileName: '',
            filePath: '',
            fileSuffix: FileType.PrivateSpace,
            progress: 0,
            code: DownloadFileStatusCode.FAILED,
            fileSize: 0,
            createTime: '',
            startTime: Date.now(),
            progressTime: 0,
            vipStatus: true
          };
          resolve(downloadFileStatus)
        }
        // 本地缓存目录下
        const name: string = file.downloadUrl.split('/').pop() as string;
        const cacheFilePath: string = GlobalContext.getUIAbilityContext().cacheDir + '/' + name;
        // 删除cache目录临时文件
        fs.unlink(cacheFilePath).then(() => {
          this.download(name, file.downloadUrl).then((downloadFileStatus) => {
            TCLogger.info(this.logTag, `check and download file on response ${JSON.stringify(downloadFileStatus)} `);
            resolve(downloadFileStatus)
          })
        }).catch((err: BusinessError) => {
          TCLogger.info(this.logTag,
            `check and download Failed to unlink, code: ${err.code}, message: ${err.message}.`);
          // 如果文件不存在，则开始下载
          this.download(name, file.downloadUrl).then((downloadFileStatus) => {
            TCLogger.info(this.logTag, `check and download file on response ${JSON.stringify(downloadFileStatus)} `);
            resolve(downloadFileStatus)
          })
        });
      } catch (e) {
        TCLogger.info(this.logTag, `check and download file failed ${e.message}`);
        const name: string = file.downloadUrl.split('/').pop() as string;
        this.download(name, file.downloadUrl).then((downloadFileStatus) => {
          TCLogger.info(this.logTag, `check and download file on response ${JSON.stringify(downloadFileStatus)} `);
          resolve(downloadFileStatus)
        })
      }
    })
  }

  /**
   * 获取云测文件的下载地址
   *
   * @param cloudPath 云测文件路径
   */
  public getCloudFileDownloadUrl(cloudPath: string): Promise<string> {
    return new Promise((resolve, reject) => {
      this.storageBucket.getDownloadURL(cloudPath).then((url: string) => {
        TCLogger.info(this.logTag, `Succeeded to get cloud file download url, downloadUrl: ${url}`);
        resolve(url)
      }).catch((err: BusinessError) => {
        TCLogger.info(this.logTag, `Failed to get cloud file download url, code: ${err.code}, message: ${err.message}`);
        resolve('')
      })
    })
  }

  /**
   * 根据下载地址，下载到缓存目录
   */
  downloadFileToSandbox(cloudPath: string, url: string): Promise<string> {
    return new Promise(async (resolve, reject) => {
      const fileName = cloudPath.split('/').pop() as string; // 从URL提取文件名
      const filePath = `${GlobalContext.getUIAbilityContext().cacheDir}/${fileName}`; // 拼接沙箱路径

      try {
        if (fs.accessSync(filePath)) {
          // 如果文件已存在，则直接返回
          resolve(filePath)
          return
        }
        await request.downloadFile(GlobalContext.getUIAbilityContext(), {
          url: url,
          filePath: filePath, // 必须为沙箱路径（如 filesDir 或 cacheDir）
          enableMetered: true  // 允许按流量计费网络下载
        });
        TCLogger.info(this.logTag, `Succeeded to get cloud file download file`);
        resolve(filePath)
      } catch (err) {
        TCLogger.info(this.logTag,
          `Failed to get cloud file download file, code: ${err.code}, message: ${err.message}`);
        resolve('')
      }
    })

  }

  /**
   * 上报进度，包括progress和complete两个地方引用
   */
  private reportProgressing(uploadFileStatus: UploadFileStatus | DownloadFileStatus, progress: request.agent.Progress) {
    // 进度条
    uploadFileStatus.progress = progress.processed;
    // 文件大小
    uploadFileStatus.fileSize = progress.sizes[0]
    // 传输时间（秒）
    uploadFileStatus.progressTime = (Date.now() - uploadFileStatus.startTime) / 1000
    // 当前状态传输中
    uploadFileStatus.code = UploadFileStatusCode.PROGRESSING
  }

  /**
   * 检查是否有相同的文件名
   */
  private checkSameFileName(uploadFileStatus: UploadFileStatus, cloudPath: string): string {
    let name: string = cloudPath
    let fileName: string = cloudPath.split('/').pop() as string
    let dir: string = cloudPath.split('/')[0]
    let fileType: string = fileName.split('.')[fileName.split('.').length - 1]
    const sameFileNameList: UploadFileStatus[] = FileOperationUtil.uploadFileStatusList.filter((item) => {
      return item.filePath === uploadFileStatus.filePath
    })
    if (sameFileNameList.length !== 0) {
      name = `${dir}/${fileName.split(`.${fileType}`)[0] + '(' + sameFileNameList.length + ')' + '.' + fileType}`
    }
    return name
  }

  /**
   * 检查是否有相同的文件名
   */
  private checkSameDownloadFileName(downloadFileStatus: DownloadFileStatus): string {
    let name: string = downloadFileStatus.fileName
    let fileName: string = name.split('/').pop() as string
    let dir: string = name.split(`/${fileName}`)[0]
    let fileType: string = fileName.split('.')[fileName.split('.').length - 1]
    const sameFileNameList: DownloadFileStatus[] = FileOperationUtil.downloadFileStatusList.filter((item) => {
      return item.filePath === downloadFileStatus.filePath
    })
    if (sameFileNameList.length !== 0) {
      name = `${dir}/${fileName.split(`.${fileType}`)[0] + '(' + sameFileNameList.length + ')' + '.' + fileType}`
      downloadFileStatus.fileName = name
      // 如果有重复的文件名，再删除一次
      fs.unlink(downloadFileStatus.fileName).then(() => {
        TCLogger.info(this.logTag, `Succeed to delete same download file, fileName: ${downloadFileStatus.fileName}`);
      }).catch((err: BusinessError) => {
        TCLogger.info(this.logTag, `Failed to delete same download file, code: ${err.code}, message: ${err.message}`);
      })
    }

    return downloadFileStatus.fileName
  }

  /**
   * 从云存储拉取文件列表
   */
  public getFileList(dir: string): Promise<string[]> {
    return new Promise((resolve, reject) => {
      // 获取云存储默认实例中根路径下的文件列表
      this.storageBucket.list(dir).then((result: cloudStorage.ListResults) => {
        TCLogger.info(this.logTag, `Succeeded in listing files, result: ${JSON.stringify(result)}`);
        const fileNames: string[] = []
        // 先删除列表
        fileNames.push(...result.files)
        resolve(fileNames)
      }).catch((err: BusinessError) => {
        TCLogger.info(this.logTag, `Failed to list files, code: ${err.code}, message: ${err.message}`);
      })
    })
  }

  /**
   * 从云存储获取文件夹目录
   */
  public getDirList(): Promise<string[]> {
    return new Promise((resolve, reject) => {
      this.storageBucket.list('').then((result: cloudStorage.ListResults) => {
        TCLogger.info(this.logTag, `Succeeded in listing files, result: ${JSON.stringify(result)}`);
        const directories: string[] = []
        // 先删除列表
        directories.push(...result.directories)
        resolve(directories)
      }).catch((err: BusinessError) => {
        TCLogger.info(this.logTag, `Failed to list files, code: ${err.code}, message: ${err.message}`);
      })
    })
  }

  /**
   * 从云存储删除文件
   */
  public deleteFile(fileName: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      this.storageBucket.deleteFile(fileName).then(() => {
        TCLogger.info(this.logTag, `delete file ${fileName} success`);
        resolve(true)
      }).catch((error: BusinessError) => {
        TCLogger.info(this.logTag, `delete file ${fileName} failed, code: ${error.code}, message: ${error.message}`);
        resolve(false)
      })
    })
  }

  /**
   * 复制文件
   */
  public copyFile(srcPath: string, dstPath: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      let srcFile: fs.File | null = null;
      let dstFile: fs.File | null = null;
      try {
        srcFile = fs.openSync(srcPath);
        dstFile = fs.openSync(dstPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        // 读取文件的第一个字节
        const buffer = new ArrayBuffer(1); // 申请1字节缓冲区
        const readLen = fs.readSync(srcFile.fd, buffer); // 读取首字节
        // 读取长度为0即文件为空
        if (readLen === 0) {
          resolve(false)
          return;
        }
        fs.copyFileSync(srcFile.fd, dstFile.fd);
        resolve(true)
      } catch (e) {
        TCLogger.info(this.logTag, `copy file failed ${e.message}`);
        resolve(false);
        return;
      } finally {
        if (srcFile) {
          fs.closeSync(srcFile);
        }
        if (dstFile) {
          fs.closeSync(dstFile);
        }
      }
    })

  }

  /**
   * 判断文件是否存在
   */
  public isFileExist(filePath: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      fs.access(filePath).then((res: boolean) => {
        if (res) {
          resolve(true)
        } else {
          resolve(false)
        }
      }).catch((err: BusinessError) => {
        resolve(false);
      });
    });

  }
}