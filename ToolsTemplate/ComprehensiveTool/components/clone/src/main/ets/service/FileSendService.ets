import { LENGTH_READ_FILE_CHUNK, BinaryMessageType, FileType } from '../common/Constant';
import { FileStartMessage, FileEndMessage, FileCountMessage, ContactMessage } from '../model/BinaryProtocol';
import { FileTransferCallback } from '../model/FileTransferCallback';
import { FileCount, FileVo } from '../model/FileVo';
import { BinaryProtocolCodec } from '../utils/BinaryProtocolCodec';
import { TransferUtil } from '../utils/TransferUtil';
import { FileReaderService } from './FileReadService';
import { TcpClient } from './TcpClient';
import { getLocalIPAddress } from '../utils/FileUtil';

class FileSendService {
  private fileTransferCallback: FileTransferCallback = {} as FileTransferCallback;

  // 设置进度回调
  setFileTransferCallback(fileTransferCallback: FileTransferCallback): void {
    this.fileTransferCallback = fileTransferCallback;
  }

  // 发送文件数量
  async sendFileCount(fileCount: FileCount) {
    const ipAddress = await getLocalIPAddress()
    const fileCountMessage: FileCountMessage = {
      ip: ipAddress,
      contact: {
        list: [...fileCount.contact.list],
        count: fileCount.contact.count,
        isSelected: fileCount.contact.isSelected,
        size: fileCount.contact.size,
        fileSize: fileCount.contact.fileSize,
        recvSize: fileCount.contact.recvSize,
      },
      image: {
        list: [...fileCount.image.list],
        count: fileCount.image.count,
        isSelected: fileCount.image.isSelected,
        size: fileCount.image.size,
        fileSize: fileCount.image.fileSize,
        recvSize: fileCount.image.recvSize,
      },
      video: {
        list: [...fileCount.video.list],
        count: fileCount.video.count,
        isSelected: fileCount.video.isSelected,
        size: fileCount.video.size,
        fileSize: fileCount.video.fileSize,
        recvSize: fileCount.video.recvSize,
      },
    }
    TcpClient.sendFileCount(fileCountMessage)
  }

  // 发送文件
  async sendFile(fileVo: FileVo): Promise<void> {
    // 发送的数据为联系人
    if (fileVo.type === FileType.CONTACT && fileVo.contactList) {
      const startMessage: ContactMessage = {
        fileType: fileVo.type,
        list: fileVo.contactList,
      };
      return
    }
    TcpClient.sendFileData(fileVo)
  }
}

const instance = new FileSendService();

export function registerFileSendTransferCallback(callback: FileTransferCallback) {
  instance.setFileTransferCallback(callback)
}

export function sendFile(fileVo: FileVo): Promise<void> {
  return new Promise((resolve, reject) => {
    instance.sendFile(fileVo).then(() => {
      resolve();
    }).catch(() => {
      reject()
    })
  })
}

export function sendFileCount(fileCount: FileCount) {
  instance.sendFileCount(fileCount)
}