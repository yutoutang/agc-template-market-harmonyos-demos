import { CommentModel } from '../commons/Models';
import { StoreItem, SubmitCommentRequest } from '../commons/Types';
import { CommentApis } from '../https/Apis';
import { promptAction } from '@kit.ArkUI';
import { FormatUtil } from 'module_ui_base';

@ObservedV2
export class SubmitCommentVM {
  @Trace hotelList: StoreItem[] = [];
  @Trace checkedHotel: StoreItem | null = null;
  @Trace commentModel: CommentModel = new CommentModel();
  @Trace stack?:NavPathStack

  public async getHotelList() {
    const res = await CommentApis.getStoreList();
    if (res) {
      this.hotelList = res;
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
    if (!this.checkedHotel) {
      promptAction.showToast({ message: '请选择门店' });
      return undefined;
    }
    if (!this.commentModel.desc) {
      promptAction.showToast({ message: '请输入评论' });
      return undefined;
    }

    const data: SubmitCommentRequest = {
      comment: this.commentModel.desc,
      environmentScore: this.commentModel.detailRate.environment,
      deviceScore: this.commentModel.detailRate.device,
      hotelId: this.checkedHotel.id,
      isAnonymous: this.commentModel.isAnonymous,
      overallScore: this.commentModel.totalRate,
      experienceScore: this.commentModel.detailRate.experience,
      serviceScore: this.commentModel.detailRate.service,
      commentTime: FormatUtil.formatFullDate(new Date()),
      userId: '',
    };
    return data;
  }
}