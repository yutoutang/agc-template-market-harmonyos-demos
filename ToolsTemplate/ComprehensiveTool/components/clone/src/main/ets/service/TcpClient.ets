import { MessageEvents, worker } from '@kit.ArkTS';
import { WorkerMessageType, BinaryMessageType, LENGTH_TRANSFER_HEADER } from '../common/Constant';
import { ConnectionVo } from '../model/ConnectionVo';
import { TcpCallback } from '../model/TcpCallback';
import { WorkerMessage } from '../model/WorkerMessage';
import { BufferUtil } from '../utils/BufferUtil';
import { checkStringContent } from '../utils/FileUtil';

export class TcpClient {
  private static tcpWorker = new worker.ThreadWorker('../workers/TCPSocketWorker.ets');
  private static tcpCallback: TcpCallback = {}
  public static isConnected: boolean = true

  static init(connectionVo: ConnectionVo, tcpCallback: TcpCallback) {
    TcpClient.tcpCallback = tcpCallback
    TcpClient.tcpWorker.onmessage = (event: MessageEvents) => {
      const data = event.data as WorkerMessage;
      TcpClient.isConnected = checkStringContent(JSON.stringify(data))
      switch (data.type) {
        case WorkerMessageType.CONNECT:
          TcpClient.handleConnectionCallback(data.data as string)
          break;
        case WorkerMessageType.SEND:
          TcpClient.handleSendCallback(data.data as string);
          break;
        default:
          break;
      }
    }
    TcpClient.tcpWorker.postMessage({
      type: WorkerMessageType.CONNECT,
      data: connectionVo,
    } as WorkerMessage)
  }

  static handleSendCallback(data: string) {
  }

  static handleConnectionCallback(data: string) {
    if (data === 'success') {
      if (TcpClient.tcpCallback.onConnected) {
        TcpClient.tcpCallback.onConnected();
      }
    } else {
      if (TcpClient.tcpCallback.onFailed) {
        TcpClient.tcpCallback.onFailed(data);
      }
    }
  }

  /**
   * 发送二进制数据
   */
  static sendBinaryData(data: ArrayBuffer, dataType: BinaryMessageType): void {
    let headerBuffer = TcpClient.generateBinaryDataHeader(data.byteLength, dataType);
    let sendData = BufferUtil.mergeArrayBuffer(headerBuffer, data)
    TcpClient.tcpWorker.postMessage({
      type: WorkerMessageType.SEND,
      data: sendData,
    } as WorkerMessage, [sendData])
  }

  static close() {
    TcpClient.tcpWorker.postMessage({
      type: WorkerMessageType.CLOSE_CLIENT,
      data: '',
    } as WorkerMessage)
  }

  private static generateBinaryDataHeader(binaryDataLength: number, dataType: BinaryMessageType): ArrayBuffer {
    // 创建缓冲区
    const buffer: ArrayBuffer = new ArrayBuffer(LENGTH_TRANSFER_HEADER);
    const view: DataView = new DataView(buffer); // 用于读取和写入 ArrayBuffer 中的数据的视图对象
    // 写入头部
    view.setUint32(0, binaryDataLength, false); // 大端序
    view.setUint8(4, dataType);
    return buffer;
  }
}