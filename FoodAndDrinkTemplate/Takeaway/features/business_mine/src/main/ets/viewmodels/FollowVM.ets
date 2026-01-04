import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, PopViewUtils } from 'lib_common';
import { StoreModel, StoreServiceApi } from 'lib_takeaway_api';
import { cancelDialogBuilder, CancelDialogParams } from '../components/CancelDialogBuilder';

@ObservedV2
export class FollowViewModel extends BaseViewModel {
  @Trace list: StoreModel[] = [];

  constructor() {
    super();
    this.queryList();
  }

  queryList() {
    this.list = StoreServiceApi.queryMyFollows().map(v => new StoreModel(v));
  }

  cancelFollow(v: StoreModel) {
    StoreServiceApi.cancelFollow(v.id);
    PopViewUtils.closePopView();
    promptAction.showToast({ message: '取消关注成功' });
    this.queryList();
  }

  popDialog(v: StoreModel) {
    PopViewUtils.showPopView(wrapBuilder(cancelDialogBuilder), {}, {
      btnText: '取消关注',
      onCancel: () => {
        this.cancelFollow(v);
      },
    } as CancelDialogParams);
  }
}