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
    TcpClient.sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(fileCountMessage),
      BinaryMessageType.FILE_COUNT)
  }

  // 发送文件
  async sendFile(fileVo: FileVo): Promise<void> {
    // 发送的数据为联系人
    if (fileVo.type === FileType.CONTACT && fileVo.contactList) {
      const startMessage: ContactMessage = {
        fileType: fileVo.type,
        list: fileVo.contactList,
        deviceImgData: fileVo.deviceImgData,
        deviceName: fileVo.deviceName,
      };
      TcpClient.sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(startMessage),
        BinaryMessageType.CONTACT)
      return
    }
    let streamReader: FileReaderService | null = null
    try {
      // 1. 读取文件信息
      // 创建流式文件读取器
      streamReader = new FileReaderService(LENGTH_READ_FILE_CHUNK);
      // 打开文件
      await streamReader.openFile(fileVo);
      const fileData = streamReader.getFileInfo();
      // 添加null检查
      if (!fileData) {
        console.error('文件读取失败，无法发送文件:', fileVo.name);
        return;
      }
      const totalChunks = fileData.totalChunks

      // 2. 发送文件开始消息
      const startMessage: FileStartMessage = {
        fileName: fileVo.name,
        fileSize: fileVo.size,
        fileType: fileVo.type,
        totalChunks: totalChunks,
        chunkSize: fileData.chunkSize,
        deviceImgData: fileVo.deviceImgData,
        deviceName: fileVo.deviceName,
      };
      TcpClient.sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(startMessage),
        BinaryMessageType.FILE_START)

      // 3. 分片发送
      for (let i = 0; i < totalChunks; i++) {
        const chunk = await streamReader?.readNextChunk()
        if (!chunk) {
          console.error('文件读取失败，无法发送文件:', fileVo.name);
          return;
        }
        // 计算最优分片大小
        const optimalTransferChunkSize = TransferUtil.calculateOptimalChunkSize(chunk.size);
        const transferBatches = chunk.size / optimalTransferChunkSize + 1
        for (let index = 0; index < transferBatches; index++) {
          let transferBufferData = chunk.data.slice(0, optimalTransferChunkSize);
          if (transferBufferData.byteLength > 0) {
            TcpClient.sendBinaryData(transferBufferData, BinaryMessageType.FILE_CHUNK);
          }
          chunk.data = chunk.data.slice(optimalTransferChunkSize)
        }
      }

      // 4. 发送文件结束消息
      const endMessage: FileEndMessage = {
        fileName: fileVo.name,
        fileSize: fileVo.size,
        totalChunks: totalChunks,
      };
      TcpClient.sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(endMessage),
        BinaryMessageType.FILE_END);
      if (this.fileTransferCallback.onComplete) {
        this.fileTransferCallback.onComplete(fileVo)
      }
    } catch (error) {
      console.error('文件发送失败:', JSON.stringify(error));
    } finally {
      streamReader?.destroy() // 销毁流式读取器
    }
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