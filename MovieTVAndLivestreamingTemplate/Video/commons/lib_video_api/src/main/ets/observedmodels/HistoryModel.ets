import { HistoryResponse } from '../params/response/HistoryResponse';

@ObservedV2
export class HistoryModel {
  @Trace historyList: HistoryResponse[] = [];
}
