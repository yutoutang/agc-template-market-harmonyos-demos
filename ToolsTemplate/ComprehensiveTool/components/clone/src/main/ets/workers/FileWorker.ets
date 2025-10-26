import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { FileType } from '../common/Constant';
import { FileSaveVo } from '../model/FileSaveVo';
import { saveImageToAlbum, saveVideoToAlbum } from '../utils/FileUtil';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

workerPort.onmessage = (event: MessageEvents) => {
  const fileSaveVo: FileSaveVo = event.data.data
  if (fileSaveVo.type === FileType.IMAGE) {
    saveImageToAlbum(event.data.context, fileSaveVo.data)
  } else {
    saveVideoToAlbum(event.data.context, fileSaveVo.data)
  }
};

workerPort.onmessageerror = (event: MessageEvents) => {
};

workerPort.onerror = (event: ErrorEvent) => {
};