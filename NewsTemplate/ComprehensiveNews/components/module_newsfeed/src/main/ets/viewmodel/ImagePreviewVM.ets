import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseViewModel, GlobalContextUtils, Logger } from 'lib_common';
import { FeedCardInfoModel } from '../model/RecommendModel';

const TAG = '[ImagePreviewVM]';

@ObservedV2
export class ImagePreviewVM extends BaseViewModel {
  @Trace imageList: string[] = []
  @Trace componentId: string = ''
  @Trace curFeedCardInfo: FeedCardInfoModel = new FeedCardInfoModel()
  @Trace index: number = 0
  @Trace timer: number = 0
  @Trace isExpand: boolean = false
  @Trace selectedIndex: number = 0;
  @Trace isDisabledSwiper: boolean = false
  @Trace showImagePreviewLayer: boolean = true;
  @Trace statusBarContentColor: string = ''
  private windowClass: window.Window | undefined = undefined

  @Computed
  get isFeedSelf() {
    return this.userInfoModel.authorId === this.curFeedCardInfo.author.authorId
  }

  @Computed
  get handlerCoverImage() {
    return this.curFeedCardInfo.postImgList?.[0]?.surfaceUrl ||
      this.curFeedCardInfo.postImgList?.[0]?.picVideoUrl as string
  }

  @Computed
  get getWatch() {
    return this.userInfoModel.isLogin && this.userInfoModel.watchers.includes(this.curFeedCardInfo.author.authorId)
  }

  setCurFeedCardInfo(curFeedCardInfo: FeedCardInfoModel) {
    this.curFeedCardInfo = curFeedCardInfo
  }

  public toggleExpand() {
    GlobalContextUtils.globalUIContext.animateTo({
      duration: 500,
      curve: Curve.EaseOut,
      playMode: PlayMode.Normal,
    }, () => {
      this.isExpand = !this.isExpand
    })
  }

  public expandAnimation() {
    if (this.timer) {
      clearTimeout(this.timer)
    }
    GlobalContextUtils.globalUIContext.animateTo({
      duration: 500,
      curve: Curve.EaseOut,
      playMode: PlayMode.Normal,
    }, () => {
      this.isExpand = true
      this.timer = setTimeout(() => {
        this.isExpand = false
      }, 2000)
    })
  }
}