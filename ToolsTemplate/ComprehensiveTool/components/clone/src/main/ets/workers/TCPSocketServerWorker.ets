import { ErrorEvent, JSON, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WorkerMessage } from '../model/WorkerMessage';
import { LENGTH_TRANSFER_HEADER, WorkerMessageType } from '../common/Constant';
import { ConnectionVo } from '../model/ConnectionVo';
import { BufferUtil } from '../utils/BufferUtil';
import { BinaryProtocolData, BinaryProtocolHeader } from '../model/BinaryProtocol';
import { BinaryProtocolCodec } from '../utils/BinaryProtocolCodec';
import Logger from '../common/Constant'

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

const socketServer= socket.constructTCPSocketServerInstance();

/** 二进制消息缓冲区映射 */
let binaryBufferMap: Map<string, BinaryMessageBuffer> = new Map();

workerPort.onmessage = (event: MessageEvents) => {
  let data = event.data as WorkerMessage;
  switch (data.type) {
    case WorkerMessageType.LISTEN:
      listenServerAddress(data.data as ConnectionVo);
      break;
    default:
      break;
  }
};

workerPort.onmessageerror = (event: MessageEvents) => {
};

workerPort.onerror = (event: ErrorEvent) => {
};

function listenServerAddress(data: ConnectionVo) {
  socketServer.listen({
    address: data.ip,
    port: 0,
  } as socket.NetAddress, (err: BusinessError) => {
    if (err) {
      workerPort.postMessage({
        type: WorkerMessageType.LISTEN,
        data: `code: ${err.code}, message: ${err.message}`,
      } as WorkerMessage)
      return;
    }
    socketServer.getLocalAddress().then((value: socket.NetAddress) => {
      workerPort.postMessage({
        type: WorkerMessageType.LISTEN,
        data: value.port + '',
      } as WorkerMessage)
    });
    socketServer.on('connect', (client: socket.TCPSocketConnection) => {
      workerPort.postMessage({
        type: WorkerMessageType.CONNECT,
        data: 'success',
      } as WorkerMessage)

      // 为每个客户端创建二进制消息缓冲区
      binaryBufferMap.set(client.clientId + '', new BinaryMessageBuffer());
      client.on('message', (data: socket.SocketMessageInfo) => {
        handleClientBinaryMessage(client.clientId, data);
      })
    })
  })
}

/**
 * 处理客户端发送的二进制消息
 */
function handleClientBinaryMessage(clientId: number, data: socket.SocketMessageInfo): void {
  try {
    const buffer: ArrayBuffer = data.message;
    const messageBuffer: BinaryMessageBuffer | undefined = binaryBufferMap.get(clientId + '');

    if (!messageBuffer) {
      Logger.error('未找到客户端消息缓冲区:', JSON.stringify(clientId));
      return;
    }
    // 添加数据到缓冲区并解析完整消息
    const binaryProtocolDataList = messageBuffer.resolveClientData(buffer);
    // 处理每个完整的消息
    binaryProtocolDataList.forEach(binaryProtocolData => {
      // 根据消息类型发送到主线程
      workerPort.postMessage({
        type: WorkerMessageType.RECEIVE,
        data: binaryProtocolData,
      } as WorkerMessage, [binaryProtocolData.data]);
    });
  } catch (error) {
    Logger.error('处理二进制消息失败:', error);
  }
}

/**
 * 二进制消息缓冲区类
 * 负责处理不完整的二进制消息拼接和解析
 */
class BinaryMessageBuffer {
  /** 数据缓冲区 */
  private buffer: ArrayBuffer = new ArrayBuffer(0);

  /**
   * 添加数据到缓冲区并解析完整消息
   * @param data 新接收的数据
   * @returns 解析出的完整消息数组
   */
  public resolveClientData(data: ArrayBuffer): Array<BinaryProtocolData> {
    // 合并缓冲区数据
    this.buffer = BufferUtil.mergeArrayBuffer(this.buffer, data);
    const messages: Array<BinaryProtocolData> = [];
    // 循环解析完整消息
    while (this.buffer.byteLength >= LENGTH_TRANSFER_HEADER) { // 至少需要头部长度
      try {
        // 解析头部
        const header: BinaryProtocolHeader = BinaryProtocolCodec.parseHeader(this.buffer);
        // 检查是否有完整消息
        if (this.buffer.byteLength < header.dataLength + LENGTH_TRANSFER_HEADER) {
          break; // 数据不完整，等待更多数据
        }
        this.buffer = this.buffer.slice(LENGTH_TRANSFER_HEADER) // 去除HEADER内容
        // 提取完整消息
        const messageBuffer: ArrayBuffer = this.buffer.slice(0, header.dataLength);
        messages.push({
          type: header.type,
          data: messageBuffer,
        });
        // 移除已处理的消息
        this.buffer = this.buffer.slice(header.dataLength);
      } catch (error) {
        Logger.error('解析二进制消息失败:', error);
        // 清空缓冲区避免持续错误
        this.buffer = new ArrayBuffer(0);
        break;
      }
    }
    return messages;
  }
}