import { LineCollectionModel } from '../models/LineCollectionModel'

export class CollectionService {
  public getLineCollectionList(): LineCollectionModel {
    const lineCollectionModel: LineCollectionModel = new LineCollectionModel()
    return lineCollectionModel
  }
}

const instance = new CollectionService();

export { instance as CollectionServiceApi };