import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BinaryMessageType, LENGTH_READ_FILE_CHUNK, WorkerMessageType } from '../common/Constant';
import { ConnectionVo } from '../model/ConnectionVo';
import { WorkerMessage } from '../model/WorkerMessage';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FileVo } from '../model/FileVo';
import { FileReaderService } from '../service/FileReadService';
import { TransferUtil } from '../utils/TransferUtil';
import { ContactMessage, FileCountMessage, FileEndMessage, FileStartMessage } from '../model/BinaryProtocol';
import { TcpClient } from '../service/TcpClient';
import { BufferUtil } from '../utils/BufferUtil';
import { BinaryProtocolCodec } from '../utils/BinaryProtocolCodec';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

const tcpSocket = socket.constructTCPSocketInstance();

workerPort.onmessage = (event: MessageEvents) => {
  let data = event.data as WorkerMessage;
  switch (data.type) {
    case WorkerMessageType.CONNECT:
      connectServerAddress(data.data as ConnectionVo);
      break;
    case WorkerMessageType.SEND_FILE_COUNT:
      sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(data.data as FileCountMessage),
        BinaryMessageType.FILE_COUNT)
      break;
    case WorkerMessageType.SEND_CONTACT:
      sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(data.data as ContactMessage),
        BinaryMessageType.CONTACT)
      break;
    case WorkerMessageType.SEND:
      readFileData(data.data as FileVo)
      break;
    case WorkerMessageType.CLOSE_CLIENT:
      closeClient();
      break;
    default:
      break;
  }
};

workerPort.onmessageerror = (event: MessageEvents) => {
};

workerPort.onerror = (event: ErrorEvent) => {
};

function connectServerAddress(data: ConnectionVo) {
  tcpSocket.connect({
    address: {
      address: data.ip,
      port: data.port,
    },
    timeout: 2000,
  }).then(() => {
    workerPort.postMessage({
      type: WorkerMessageType.CONNECT,
      data: 'success',
    } as WorkerMessage);
  }).catch((err: Error) => {
    workerPort.postMessage({
      type: WorkerMessageType.CONNECT,
      data: `code: ${err.message}`,
    } as WorkerMessage);
  });
}

// 读取文件
async function readFileData(fileVo: FileVo) {
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
    sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(startMessage),
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
          sendBinaryData(transferBufferData, BinaryMessageType.FILE_CHUNK);
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
    sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(endMessage),
      BinaryMessageType.FILE_END);
    // if (this.fileTransferCallback.onComplete) {
    //   this.fileTransferCallback.onComplete(fileVo)
    // }
  } catch (error) {
    console.error('文件发送失败:', JSON.stringify(error));
  } finally {
    streamReader?.destroy() // 销毁流式读取器
  }
}

// 发送二进制数据
function sendBinaryData(data: ArrayBuffer, dataType: BinaryMessageType): void {
  let headerBuffer = TcpClient.generateBinaryDataHeader(data.byteLength, dataType);
  let sendData = BufferUtil.mergeArrayBuffer(headerBuffer, data)
  try {
    tcpSocket.send({
      data: sendData,
    }, (err: BusinessError) => {
      if (err) {
        workerPort.postMessage({
          type: WorkerMessageType.SEND,
          data: `code: ${err.code}, message: ${err.message}`,
        } as WorkerMessage);
      } else {
        workerPort.postMessage({
          type: WorkerMessageType.SEND,
          data: 'success',
        } as WorkerMessage);
      }
    });
  } catch (error) {
    workerPort.postMessage({
      type: WorkerMessageType.SEND,
      data: `encoding error: ${error}`,
    } as WorkerMessage);
  }
}

function closeClient() {
  tcpSocket.close(() => {
    hilog.info(0x0001, 'testTag', '%{public}s', '客户端关闭成功');
  });
}
