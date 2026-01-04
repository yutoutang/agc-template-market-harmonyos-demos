import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { Constants, RouterMap } from '../common/Constants';
import { MediaUtils } from '../common/MediaUtils';
import { FeedbackModel } from '../common/FeedbackModel';
import { FeedbackService } from '../services/FuncService';
import { SubmitFeedbackParams } from '../services/RequestModel';

@ObservedV2
export class SubmitVM {
  @Trace feedbackModel: FeedbackModel = AppStorageV2.connect(FeedbackModel, () => new FeedbackModel())!;
  @Trace body: string = '';
  @Trace imgArr: string[] = [];
  @Trace contactPhone: string = '';
  @Trace maxSelectNumber: number = Constants.MAX_IMG_COUNT;
  @Trace stack: NavPathStack = new NavPathStack();
  @Trace loading: boolean = false;

  async selectPhoto() {
    const uriList = await MediaUtils.selectMedia(this.maxSelectNumber);
    this.imgArr.push(...uriList);
  }

  submit() {
    const isValid = this.validInfo();
    if (!isValid) {
      return;
    }
    this.loading = true;
    const cacheImgList = this.imgArr.map((v: string) => {
      return MediaUtils.handleUri(v);
    })
    const params: SubmitFeedbackParams = {
      problemDesc: this.body,
      screenShots: cacheImgList,
      contactPhone: this.encryptPhoneNo(this.contactPhone),
    };
    FeedbackService.addFeedback(params).then(() => {
      promptAction.showToast({ message: '提交成功' });
      setTimeout(() => {
        this.stack.pop();
        this.stack.pushPathByName(RouterMap.FEEDBACK_RECORD_LIST_PAGE, null);
      }, 300);
    }).finally(() => {
      this.loading = false;
    });
  }

  validInfo() {
    if (!this.body) {
      promptAction.showToast({ message: '请描述您的问题' });
      return false;
    }
    if (this.contactPhone && this.contactPhone.length !== 11 && !Constants.PHONE_REG.test(this.contactPhone)) {
      promptAction.showToast({ message: '请输入正确的手机号码' });
      return false;
    }
    return true;
  }

  /**
   * 号码中间四位隐藏
   * @param phoneNo
   * @returns
   */
  public encryptPhoneNo(phoneNo: string): string {
    if (phoneNo && phoneNo.length === 11) {
      const str = phoneNo.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
      return str
    }
    return phoneNo
  }
}