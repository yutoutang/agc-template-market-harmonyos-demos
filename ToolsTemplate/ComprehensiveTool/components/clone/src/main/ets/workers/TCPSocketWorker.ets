import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WorkerMessageType } from '../common/Constant';
import { ConnectionVo } from '../model/ConnectionVo';
import { WorkerMessage } from '../model/WorkerMessage';
import { hilog } from '@kit.PerformanceAnalysisKit';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

const tcpSocket = socket.constructTCPSocketInstance();

workerPort.onmessage = (event: MessageEvents) => {
  let data = event.data as WorkerMessage;
  switch (data.type) {
    case WorkerMessageType.CONNECT:
      connectServerAddress(data.data as ConnectionVo);
      break;
    case WorkerMessageType.SEND:
      sendBinaryData(data.data as ArrayBuffer);
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

/**
 * 发送二进制数据
 */
function sendBinaryData(data: ArrayBuffer): void {
  try {
    // 发送二进制数据
    tcpSocket.send({
      data: data,
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
