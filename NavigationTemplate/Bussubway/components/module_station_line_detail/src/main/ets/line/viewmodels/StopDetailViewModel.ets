import { StopDetailModel } from '../../models/StopDetailModel';

@ObservedV2
export class StopDetailViewModel {
  @Trace stopDetailModel: StopDetailModel = new StopDetailModel();
  // 是否已收藏
  @Trace isFavorited?: boolean
}