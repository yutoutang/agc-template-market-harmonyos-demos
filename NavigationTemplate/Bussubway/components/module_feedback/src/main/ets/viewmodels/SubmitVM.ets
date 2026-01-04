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
    // 检查是否已达到最大图片数量限制
    if (this.imgArr.length >= Constants.MAX_IMG_COUNT) {
      promptAction.showToast({ message: `最多只能选择${Constants.MAX_IMG_COUNT}张图片` });
      return;
    }

    try {
      const uriList = await MediaUtils.selectMedia(this.maxSelectNumber);

      // 计算还能添加多少张图片
      const remainingSlots = Constants.MAX_IMG_COUNT - this.imgArr.length;
      if (remainingSlots > 0 && Array.isArray(uriList)) {
        // 只添加剩余数量的图片
        const imagesToAdd = uriList.slice(0, remainingSlots);
        this.imgArr.push(...imagesToAdd);

        // 如果有图片被截断，给出提示
        if (imagesToAdd.length < uriList.length) {
          promptAction.showToast({ message: `已达到最大图片数量限制，只添加了${imagesToAdd.length}张图片` });
        }
      }
    } catch (error) {
    }
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
      contactPhone: this.contactPhone,
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
    if (this.contactPhone && !Constants.PHONE_REG.test(this.contactPhone)) {
      promptAction.showToast({ message: '请输入正确的手机号码' });
      return false;
    }
    return true;
  }
}