import { WorkerMessageType } from '../common/Constant';
import { WorkerMessage } from '../model/WorkerMessage';
import { MessageEvents, worker } from '@kit.ArkTS';

export class UdpServer {
  private static tcpWorker = new worker.ThreadWorker('../workers/UDPServerWorker.ets');

  static create(ip: string, func: Function) {
    UdpServer.tcpWorker.onmessage = (event: MessageEvents) => {
      const data = event.data as WorkerMessage;
      switch (data.type) {
        case WorkerMessageType.RECEIVE:
          func(data)
          break;
        default:
          break;
      }
    }
    UdpServer.tcpWorker.postMessage({
      type: WorkerMessageType.LISTEN,
      data: ip,
    } as WorkerMessage)
  }
}
