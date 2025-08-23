import { Feedback, FeedbackItemType } from '@agctemplate/feed_back';
import { NAV_PAGE_NAME } from '@agctemplate/resources';
import { appRouter, PreferenceUtil, PreferConstant } from '@agctemplate/utils';
import { AppStorageKeys, StatusBarHeight } from '@agctemplate/widgets';
import { Header } from '../component/Header';
import { AppStorageV2 } from '@kit.ArkUI';


@ComponentV2
export struct FeedbackPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  // 接收意见反馈har返回来的数据
  @Local feedList: FeedbackItemType = {
    description: '',
    stageImageUris: [],
    phone: '',
    time: ''
  }

  build() {
    NavDestination() {
      Column() {
        Header({
          title: '意见反馈',
          rightImageRes: $r('app.media.ic_public_feed_back_record'),
          rightOnClick: () => {
            appRouter.push({
              builderName: NAV_PAGE_NAME.FeedbackRecordPage.name
            })
          }
        })
        Feedback({
          des: 100,
          num: 5,
          butOnClick: (val: FeedbackItemType) => {
            this.feedList = val;
            let info =
              PreferenceUtil.getInstance(getContext()).get(
                PreferConstant.FEEDBACK_RECORD, []) as FeedbackItemType[]
            let arr: FeedbackItemType[] = []
            info.forEach((model: FeedbackItemType) => {
              arr.push(model)
            })
            arr.push(this.feedList)
            PreferenceUtil.getInstance(getContext()).put(PreferConstant.FEEDBACK_RECORD, arr)
            this.getUIContext().getPromptAction().showToast({ message: '提交成功', duration: 2000 });
            appRouter.back()
          }
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.background_secondary'))

    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: `${px2vp(this.statusBarHeight.value)}vp`, bottom: 36 })
    .hideTitleBar(true)
  }
}

@Builder
export function FeedbackPageBuilder() {
  FeedbackPage()
}
