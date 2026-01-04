import { CollectionSaveTagMockData } from '../models/CollectionSaveTagMockData';
import { CollectionSaveTagModel } from '../models/CollectionSaveTagModel';

export class TagService {
  public getCollectionSaveTags(): CollectionSaveTagModel {
    const tagModel: CollectionSaveTagModel = new CollectionSaveTagModel()
    tagModel.tagNames.push(...CollectionSaveTagMockData.tagNames)
    return tagModel
  }
}

const instance = new TagService();

export { instance as TagServiceApi };