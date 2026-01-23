import { CommonConstants, Title } from '@ohos_agcit/children_education_utils';
import { Feedback, FeedbackItemType } from 'feed_back';

@Builder
export function FeedbackBuilder() {
  FeedbackPage();
}

@ComponentV2
export struct FeedbackPage {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Feedback({
        des: 100,
        num: 3,
        butOnClick: (val: FeedbackItemType) => {
          this.getUIContext().getPromptAction().showToast({ message: '提交成功', duration: 2000 });
          this.appPathStack.pop();
        }
      })
    }
    .title(Title('意见反馈'))
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
  }
}