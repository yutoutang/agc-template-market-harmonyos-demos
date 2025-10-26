import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, util, worker } from '@kit.ArkTS';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WorkerMessageType } from '../common/Constant';
import { WorkerMessage } from '../model/WorkerMessage';
import { splitJsonStrings } from '../utils/FileUtil';
import Logger from '../common/Constant'

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
const socketServer = socket.constructTCPSocketServerInstance();

workerPort.onmessage = (event: MessageEvents) => {
  let data = event.data as WorkerMessage;
  switch (data.type) {
    case WorkerMessageType.LISTEN:
      listenServerAddress(data.data as string);
      break;
    default:
      break;
  }
};

workerPort.onmessageerror = (event: MessageEvents) => {
};

workerPort.onerror = (event: ErrorEvent) => {
};

function listenServerAddress(ip: string) {
  socketServer.listen({
    address: ip,
    port: 1234,
  } as socket.NetAddress, (err: BusinessError) => {
    if (err) {
      Logger.error('连接失败', JSON.stringify(err))
    }
    socketServer.on('connect', (client: socket.TCPSocketConnection) => {
      client.on('message', (data: socket.SocketMessageInfo) => {
        const buffer: ArrayBuffer = data.message;
        let decoder = util.TextDecoder.create('utf-8');
        let stringData = decoder.decodeToString(new Uint8Array(buffer));
        const jsonStringArr = splitJsonStrings(stringData)
        jsonStringArr.forEach((data) => {
          workerPort.postMessage({
            type: WorkerMessageType.RECEIVE,
            data: data,
          } as WorkerMessage);
        })
      })
    })
  })
}
