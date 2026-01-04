import { BaseMineCustomerServiceQA } from '../database/MineCustomerServiceQAType';
import { MockQA } from './mockdata/MockQA';

/**
 * 客服问答base类
 */
export class BaseQAService {
  /**
   * 查询数据库字段
   * @returns
   */
  public getAllQA(): BaseMineCustomerServiceQA[] {
    return MockQA.list;
  }
}

const instance = new BaseQAService();

export { instance as BaseQAServiceApi };