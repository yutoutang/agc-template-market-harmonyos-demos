import { LineDetailModel } from './LineDetailModel'

/**
 * 线路模型
 */
@ObservedV2
export class LineCollectionInnerModel {
  // 标签
  @Trace tag?: string
  // 线路名称
  @Trace lineDetailList: LineDetailModel[] = []
}

@ObservedV2
export class LineCollectionModel {
  // 标签
  @Trace lineCollectionInnerModels: LineCollectionInnerModel[] = []
}

