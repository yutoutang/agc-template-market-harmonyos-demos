import { BaseViewModel } from 'lib_common';
import { BaseQAServiceApi } from 'lib_takeaway_api';
import { BaseMineCustomerServiceQA } from 'lib_takeaway_api/src/main/ets/database/MineCustomerServiceQAType';

@ObservedV2
export class MineCustomerServiceViewModel extends BaseViewModel {
  @Trace list: BaseMineCustomerServiceQA[] = [];
  @Trace item: BaseMineCustomerServiceQA | undefined = undefined;

  constructor() {
    super();
    this.queryAllQA();
  }

  queryAllQA() {
    this.list = BaseQAServiceApi.getAllQA();
  }
}