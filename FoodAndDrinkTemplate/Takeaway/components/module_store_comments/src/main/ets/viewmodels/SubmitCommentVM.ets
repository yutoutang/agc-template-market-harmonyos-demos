import { promptAction } from '@kit.ArkUI';
import { CommentModel } from '../commons/Models';
import { StoreItem, SubmitCommentRequest } from '../commons/Types';
import { CommentApis } from '../https/Apis';
import { FormatUtil } from 'module_ui_base';

@ObservedV2
export class SubmitCommentVM {
  @Trace storeList: StoreItem[] = [];
  @Trace checkedStore: StoreItem | null = null;
  @Trace orderNo: string = '';
  @Trace commentModel: CommentModel = new CommentModel();
  @Trace stack?: NavPathStack

  public async getHotelList() {
    const res = await CommentApis.getStoreList();
    if (res) {
      this.storeList = res;
    }
  }

  public async submitComment() {
    const data = this._getSubmitData();
    if (data) {
      const res = await CommentApis.submitComment(data)
      if (res === 0) {
        promptAction.showToast({ message: '提交成功' });
        const timer = setTimeout(() => {
          clearTimeout(timer);
          this.stack?.pop(1)
        }, 1000);
      }
    }
  }

  private _getSubmitData() {
    if (!this.checkedStore) {
      promptAction.showToast({ message: '请选择门店' });
      return undefined;
    }
    if (!this.commentModel.totalRate) {
      promptAction.showToast({ message: '请选择综合评分' });
      return undefined;
    }
    if (!this.commentModel.detailRate.taste) {
      promptAction.showToast({ message: '请选择味道评分' });
      return undefined;
    }
    if (!this.commentModel.detailRate.packing) {
      promptAction.showToast({ message: '请选择包装评分' });
      return undefined;
    }
    if (!this.commentModel.detailRate.delivery) {
      promptAction.showToast({ message: '请选择配送评分' });
      return undefined;
    }
    if (!this.commentModel.desc) {
      promptAction.showToast({ message: '请输入评论' });
      return undefined;
    }

    const data: SubmitCommentRequest = {
      overallScore: this.commentModel.totalRate,
      taste: this.commentModel.detailRate.taste,
      packing: this.commentModel.detailRate.packing,
      delivery: this.commentModel.detailRate.delivery,
      storeId: this.checkedStore.id,
      orderNo: this.orderNo,
      userId: '',
      isAnonymous: this.commentModel.isAnonymous,
      commentTime: FormatUtil.formatFullDate(new Date()),
      comment: this.commentModel.desc,
    };
    return data;
  }
}