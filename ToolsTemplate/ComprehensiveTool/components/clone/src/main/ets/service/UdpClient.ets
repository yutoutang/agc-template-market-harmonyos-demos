import { MessageEvents, worker } from '@kit.ArkTS';
import { WorkerMessageType } from '../common/Constant';
import { WorkerMessage } from '../model/WorkerMessage';

export class UdpClient {
  private static tcpWorker = new worker.ThreadWorker('../workers/UDPWorker.ets');

  static init(ip: string) {
    UdpClient.tcpWorker.postMessage({
      type: WorkerMessageType.CONNECT,
      data: ip,
    } as WorkerMessage)
  }

  static send(data: ArrayBuffer) {
    UdpClient.tcpWorker.postMessage({
      type: WorkerMessageType.SEND,
      data: data,
    } as WorkerMessage)
  }
}