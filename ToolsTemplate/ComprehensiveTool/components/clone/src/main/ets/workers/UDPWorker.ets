import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WorkerMessage } from '../model/WorkerMessage';
import { WorkerMessageType } from '../common/Constant';
import Logger from '../common/Constant'

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
const tcpSocket = socket.constructTCPSocketInstance();
workerPort.onmessage = (event: MessageEvents) => {
  let data = event.data as WorkerMessage;
  switch (data.type) {
    case WorkerMessageType.CONNECT:
      connectServerAddress(data.data as string);
      break;
    case WorkerMessageType.SEND:
      sendUdpData(data.data as ArrayBuffer)
      break
    case WorkerMessageType.CLOSE_CLIENT:
      closeClient()
      break
    default:
      break;
  }
};
workerPort.onmessageerror = (event: MessageEvents) => {
};
workerPort.onerror = (event: ErrorEvent) => {
};

function connectServerAddress(ip: string) {
  tcpSocket.connect({
    address: {
      address: ip,
      port: 1234,
    },
    timeout: 2000,
  }).then(() => {
    workerPort.postMessage({
      type: WorkerMessageType.CONNECT,
      data: 'success',
    } as WorkerMessage)
  }).catch((err: Error) => {
    workerPort.postMessage({
      type: WorkerMessageType.CONNECT,
      data: `code: ${err.message}`,
    } as WorkerMessage)
    Logger.error('connect failure', JSON.stringify(err))
  })
}

function sendUdpData(data: ArrayBuffer): void {
  try {
    tcpSocket.send({
      data: data,
    }, (err: BusinessError) => {
      if (err) {
        Logger.error('udp Send binary data error:', err.message);
      }
    });
  } catch (error) {
    Logger.error(' udp Binary data encoding error:', error);
  }
}


function closeClient() {
  tcpSocket.close(() => {
    Logger.info('客户端关闭成功')
  })
}