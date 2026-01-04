import { CollectionLineTagModel } from 'lib_common';
import { CollectionLineTagMockData } from './mockdata/CollecionLineTagMockData';

export class TagService {
  /**
   * 获取收藏标签
   * @returns
   */
  public getCollectionLineTags(): CollectionLineTagModel {
    const tagModel: CollectionLineTagModel = new CollectionLineTagModel()
    tagModel.tagNames.push(...CollectionLineTagMockData.tagNames)
    return tagModel
  }
}

const instance = new TagService();

export { instance as TagServiceApi };