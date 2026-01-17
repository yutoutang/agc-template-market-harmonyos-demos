import { BaseViewModel, LoadingModel, PopViewUtils } from 'lib_common';
import { MineServiceApi, NewsModel, NewsResponse } from 'lib_news_api';
import { cancelDialogBuilder, CancelDialogParams } from '../components/CancelDialogBuilder';

@ObservedV2
export class MarkViewModel extends BaseViewModel {
  @Trace list: NewsModel[] = [];
  @Trace loadingModel: LoadingModel<NewsResponse[]> = new LoadingModel(MineServiceApi.queryMyMarks);

  constructor() {
    super();
    this.queryList();
  }

  queryList(showLoading: boolean = true) {
    this.loadingModel.callApi({
      pageLoading: showLoading,
      dialogLoading: false,
    }).then((list) => {
      this.list = list.map(v => new NewsModel(v))
    })
  }

  async cancelMark(v: NewsModel) {
    await MineServiceApi.cancelMark(v.id);
    PopViewUtils.closePopView();
    this.contextModel.showToast({ message: '取消收藏成功' });
    this.queryList(false);
  }

  popDialog(v: NewsModel) {
    PopViewUtils.showPopView(wrapBuilder(cancelDialogBuilder), {}, {
      btnText: '取消收藏',
      onCancel: () => {
        this.cancelMark(v);
      },
    } as CancelDialogParams);
  }
}