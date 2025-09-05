import { PersistenceV2 } from '@kit.ArkUI';
import {  SettingModel, UserInfoModel } from 'lib_common';
import { FeedCardInfoModel } from 'module_newsfeed';
import { LongTakeAnimationProperties } from 'module_transition';
import { PostImgList } from 'lib_news_api';

@ObservedV2
export class ImagePreviewVM {
  public onFirstPageShow: () => void = () => {};
  public watchOperation: () => void = () => {};
  public newsLike: () => void = () => {};
  public onAddComment: () => void = () => {};
  public onIndexChange: (index: number) => void = (_index: number) => {}
  public backToFirstPage: () => void = () => {
    animateTo({
      duration: 200,
      curve: Curve.EaseIn,
    }, () => {
      this.onFirstPageShow();
      this.pageInfo.pop(false);
    })
  }
  @Trace imageList: string[] = []
  @Trace componentId: string = ''
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace curFeedCardInfo: FeedCardInfoModel = new FeedCardInfoModel()
  @Trace index: number = 0
  @Trace timer: number = 0
  @Trace isExpand: boolean = false
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Trace userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Trace selectedIndex: number = 0;
  @Trace isDisabledSwiper: boolean = false
  @Trace showImagePreviewLayer: boolean = true;
  public pageInfo: NavPathStack = new NavPathStack();
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

  public getImageList(value: PostImgList[]): string[] {
    if (!Array.isArray(value)) {
      return [];
    }

    return value.map((item: PostImgList) => {
      if (!item.surfaceUrl) {
        return item.picVideoUrl;
      }
      return item.surfaceUrl
    });
  }

  public toggleExpand() {
    animateTo({
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
    animateTo({
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

  public getNavigationParams(context: NavDestinationContext) {
    let param = context.pathInfo?.param as Record<string, Object | FeedCardInfoModel>;
    this.curFeedCardInfo = param.curFeedCardInfo as FeedCardInfoModel
    this.index = param.index as number
    this.imageList = this.getImageList(this.curFeedCardInfo.postImgList ?? [])
    this.pageInfo = context.pathStack;
    if (param === undefined) {
      return;
    }
    this.selectedIndex = param.selectedIndex as number;
    this.onIndexChange = param.onIndexChange as (index: number) => void;
    this.onFirstPageShow = param.onBackToFirstPage as () => void;
    this.watchOperation = param.watchOperation as () => void;
    this.onAddComment = param.onAddComment as () => void;
    this.componentId = param.componentId as string
    this.newsLike = param.newsLike as () => void;
    this.showImagePreviewLayer = param.showImagePreviewLayer as boolean;
  }
}