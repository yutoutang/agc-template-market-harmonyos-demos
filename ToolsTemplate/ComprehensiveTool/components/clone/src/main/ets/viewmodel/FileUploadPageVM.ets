import { FileVo, SendType } from '../model/FileVo';
import { promptAction } from '@kit.ArkUI';
import { FileUtil, getLocalIPAddress } from '../utils/FileUtil';
import { FileBasic, FileType, MainFile, TransferState } from '../common/Constant';
import { common } from '@kit.AbilityKit';
import { contact } from '@kit.ContactsKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { dataSharePredicates } from '@kit.ArkData';
import { sendFile, sendFileCount } from '../service/FileSendService';
import { TcpClient } from '../service/TcpClient';

@ObservedV2
export class FileUploadPageVM {
  private static _instance: FileUploadPageVM
  @Trace context: common.UIAbilityContext | null = null
  @Trace selectedFiles: FileVo[] = [] // 已选文件列表
  @Trace contactList: contact.Contact[] = []
  @Trace contact: MainFile = new MainFile()
  @Trace image: MainFile = new MainFile()
  @Trace video: MainFile = new MainFile()
  @Trace stateList: TransferState[] = [TransferState.BEFORE, TransferState.BEFORE, TransferState.BEFORE]
  @Trace state: TransferState = TransferState.BEFORE
  @Trace timer: number = 0

  public static get instance() {
    if (!FileUploadPageVM._instance) {
      FileUploadPageVM._instance = new FileUploadPageVM();
    }
    return FileUploadPageVM._instance;
  }

  clear() {
    this.selectedFiles = []
    this.contactList = []
    this.contact = new MainFile()
    this.image = new MainFile()
    this.video = new MainFile()
    this.stateList = [TransferState.BEFORE, TransferState.BEFORE, TransferState.BEFORE]
    this.state = TransferState.BEFORE
    clearInterval(this.timer)
  }

  // 获取克隆数据
  async getCloneFiles() {
    // 联系人
    this.contactList = await contact.queryContacts(getContext())
    this.contact.size = this.contactList.length
    // 图片和视频
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.context);
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates,
    };
    let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
      await phAccessHelper.getAssets(fetchOption);
    fetchResult.getAllObjects((err, photoAssetList) => {
      if (photoAssetList !== undefined) {
        photoAssetList.forEach((data) => {
          if (data.photoType === 1) {
            this.image.list.push({
              uri: data.uri,
              size: 0,
            })
            this.image.size += 1
          } else {
            this.video.list.push({
              uri: data.uri,
              size: 0,
            })
            this.video.size += 1
          }
        })
        // 处理数据
        this.handleCloneFiles()
      } else {
        console.error(`photoAsset failed with err:${err.code}, ${err.message}`);
      }
    });
  }

  // 文件处理
  async handleCloneFiles() {
    if (!this.context) {
      return
    }

    // 处理图片
    if (this.image.size > 0) {
      for (let index = 0; index < this.image.list.length; index++) {
        const data = this.image.list[index];
        const fileInfo = await FileUtil.getFileInfo(data.uri, FileType.IMAGE)
        if (fileInfo) {
          data.size = fileInfo.size
        }
      }
      this.image.fileSize = this.getAllSize(this.image.list)
    }

    // 处理视频
    if (this.video.size > 0) {
      for (let index = 0; index < this.video.list.length; index++) {
        const data = this.video.list[index];
        const fileInfo = await FileUtil.getFileInfo(data.uri, FileType.VIDEO)
        if (fileInfo) {
          data.size = fileInfo.size
        }
      }
      this.video.fileSize = this.getAllSize(this.video.list)
    }
    const ipAddress = await getLocalIPAddress()
    // UdpServer.create(ipAddress, (data: WorkerMessage) => {
    //   try {
    //     const stringData = data.data as string
    //     const parsedData: SendType = JSON.parse(stringData);
    //
    //     // 提取type和size的值
    //     const typeValue = parsedData.type;
    //     const sizeValue = parsedData.size;
    //     const countValue = parsedData.count
    //
    //     if (typeValue === FileType.IMAGE) {
    //       this.image.recvSize = sizeValue
    //       this.image.count = countValue
    //       if (this.image.recvSize === this.image.fileSize) {
    //         this.stateList[1] = TransferState.AFTER
    //       }
    //     } else {
    //       this.video.recvSize = sizeValue
    //       this.video.count = countValue
    //       if (this.video.recvSize === this.video.fileSize) {
    //         this.stateList[2] = TransferState.AFTER
    //       }
    //     }
    //     this.checkIsTransferAll()
    //   } catch (error) {
    //     // 处理JSON解析错误
    //     console.error('解析JSON失败:', error);
    //   }
    // })
    // 将文件数据发送给新机
    sendFileCount({
      contact: this.contact,
      image: this.image,
      video: this.video,
    })
  }

  getAllSize(fileList: FileBasic[]) {
    let size = 0
    fileList.forEach((data) => {
      size = size + data.size
    })
    return size
  }

  async getSelectedFile() {
    if (!this.contact.isSelected) {
      this.contact = new MainFile()
    }
    if (this.contactList.length > 0 && this.contact.isSelected) {
      const fileVo: FileVo = {
        uri: '',
        name: '',
        type: FileType.CONTACT,
        size: 0,
        contactList: this.contactList,
      }
      this.selectedFiles.push(fileVo)
      this.stateList[0] = TransferState.MIDDLE
    }
    if (!this.image.isSelected) {
      this.image = new MainFile()
    }
    if (this.image.size > 0 && this.image.isSelected) {
      for (let index = 0; index < this.image.list.length; index++) {
        const data = this.image.list[index];
        const fileInfo = await FileUtil.getFileInfo(data.uri, FileType.IMAGE)
        if (fileInfo) {
          this.selectedFiles.push(fileInfo)
        }
      }
      this.stateList[1] = TransferState.MIDDLE
    }
    if (!this.video.isSelected) {
      this.video = new MainFile()
    }
    if (this.video.size > 0 && this.video.isSelected) {
      for (let index = 0; index < this.video.list.length; index++) {
        const data = this.video.list[index];
        const fileInfo = await FileUtil.getFileInfo(data.uri, FileType.VIDEO)
        if (fileInfo) {
          this.selectedFiles.push(fileInfo)
        }
      }
      this.stateList[2] = TransferState.MIDDLE
    }
  }

  async uploadFile() {
    this.checkIsConnected()
    if (this.state === TransferState.ERROR) {
      console.log('hello', '链接断开')
    }
    await this.getSelectedFile()
    if (this.selectedFiles.length === 0) {
      promptAction.showToast({ message: '请选择文件' })
      return;
    }
    this.state = TransferState.MIDDLE
    for (let idx = 0; idx < this.selectedFiles.length; idx++) {
      await sendFile(this.selectedFiles[idx])
      this.stateList[0] = TransferState.AFTER
    }
  }

  checkIsTransferAll() {
    if (this.contact.recvSize === this.contact.fileSize && this.image.recvSize === this.image.fileSize &&
      this.video.recvSize === this.video.fileSize) {
      this.state = TransferState.AFTER
    }
  }

  checkIsConnected() {
    this.timer = setInterval(() => {
      if (!TcpClient.isConnected) {
        this.state = TransferState.ERROR
        for (let i = 0; i < this.stateList.length; i++) {
          if (this.stateList[i] !== TransferState.AFTER) {
            this.stateList[i] = TransferState.ERROR
          }
        }
      }
    }, 500)
  }
}
