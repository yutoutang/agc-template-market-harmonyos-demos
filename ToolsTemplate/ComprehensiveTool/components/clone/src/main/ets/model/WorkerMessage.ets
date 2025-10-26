import { WorkerMessageType } from '../common/Constant';

export interface WorkerMessage {
  type: WorkerMessageType,
  data: object | string,
  context?: Context
}