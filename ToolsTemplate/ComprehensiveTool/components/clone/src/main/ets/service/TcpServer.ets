import { WorkerMessageType } from '../common/Constant';
import { BinaryProtocolData } from '../model/BinaryProtocol';
import { ConnectionVo } from '../model/ConnectionVo';
import { TcpCallback } from '../model/TcpCallback';
import { WorkerMessage } from '../model/WorkerMessage';
import fileReceiverService from './FileReceiverService';
import { worker, MessageEvents } from '@kit.ArkTS';

export class TcpServer {
  private static tcpWorker = new worker.ThreadWorker('../workers/TCPSocketServerWorker.ets');
  private static tcpCallback: TcpCallback = {}

  static create(ip: string, tcpCallback: TcpCallback) {
    TcpServer.tcpCallback = tcpCallback;
    TcpServer.tcpWorker.onmessage = (event: MessageEvents) => {
      const data = event.data as WorkerMessage;
      switch (data.type) {
        case WorkerMessageType.LISTEN:
          TcpServer.handleListenCallback(data.data as string);
          break;
        case WorkerMessageType.CONNECT:
          TcpServer.handleConnectionCallback();
          break;
        case WorkerMessageType.RECEIVE:
          TcpServer.handleBinaryReceiveCallback(data.data as BinaryProtocolData);
          break;
        default:
          break;
      }
    }
    TcpServer.tcpWorker.postMessage({
      type: WorkerMessageType.LISTEN,
      data: {
        ip: ip,
        port: 0,
      } as ConnectionVo,
    } as WorkerMessage)
  }

  static refresh(ip: string) {
    TcpServer.tcpWorker.postMessage({
      type: WorkerMessageType.LISTEN,
      data: {
        ip: ip,
        port: 0,
      } as ConnectionVo,
    } as WorkerMessage)
  }

  static handleConnectionCallback() {
    if (TcpServer.tcpCallback.onConnected) {
      TcpServer.tcpCallback.onConnected();
    }
  }

  /**
   * 处理二进制数据接收回调
   */
  static handleBinaryReceiveCallback(binaryProtocolData: BinaryProtocolData) {
    try {
      // 转发给文件接收服务处理
      fileReceiverService.handleBinaryFileMessage(binaryProtocolData.type, binaryProtocolData.data);
    } catch (error) {
      console.error('处理二进制接收数据失败:', error);
    }
  }

  static handleListenCallback(data: string) {
    if (data.startsWith('code')) {
      if (TcpServer.tcpCallback.onFailed) {
        TcpServer.tcpCallback.onFailed(data)
      }
    } else {
      if (TcpServer.tcpCallback.onPrepared) {
        TcpServer.tcpCallback.onPrepared(Number(data))
      }
    }
  }
}
