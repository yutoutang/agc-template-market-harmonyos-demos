import { PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants, RouterMap, RouterUtils, UserInfoModel } from 'lib_common';
import { ArticleTextEllipsis } from './ArticleTextEllipsis';
import { FeedSingleImageSize } from './FeedSingleImageSize';
import { PostImgList, FeedCardInfoModel } from '../model/RecommendModel';
import { calculateDimensions, getColumnsTemplate, getDateDiff } from '../utils/Index';

/*
 * 动态中心内容
 * */

const TAG = '[FeedDetail]';

@ComponentV2
export struct FeedDetail {
  @Require @Param componentId: string = ''
  @Require @Param curFeedCardInfo: FeedCardInfoModel
  @Require @Param isDynamicsSingleDetail: boolean
  @Param isAll: boolean = false
  @Param fontSizeRatio: number = 1
  @Param searchKey: string = ''
  @Param showUserBar: boolean = true;
  @Param showTimeBottom: boolean = false;
  @Param showImagePreviewLayer: boolean = true;
  @Param isWatch: boolean = false
  @Param isFeedSelf: boolean = false
  @BuilderParam followBuilderParam: () => void = this.followBuilder;
  @BuilderParam publishCustomTimeBuilder: () => void = this.publishTimeBuilder;
  @Event onGoUserInfo: (authorId: string) => void = () => {
  }
  @Event onAddWatch: () => void = () => {
  }
  @Event onAddLike: () => void = () => {
  }
  @Event onAddComment: () => void = () => {
  }
  @Event onVideo: () => void = () => {
  }
  @Local currentTextCount: number | undefined = undefined
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local clickedIndex: number = 0;
  @Local isFirstPageShow: boolean = true;
  @Local truncatedCount: number = 0

  @Computed
  get getAuthorIcon() {
    return this.isFeedSelf ? this.userInfoModel.authorIcon : this.curFeedCardInfo.author.authorIcon
  }

  @Computed
  get getAuthorName() {
    return this.isFeedSelf ? this.userInfoModel.authorNickName : this.curFeedCardInfo.author.authorNickName
  }

  @Computed
  get oneImageSize() {
    /*
     * 一张图的时候需要固定父容器高度
     * */
    return this.computeImageCount().length === 1 ?
    calculateDimensions(this.curFeedCardInfo.postImgList?.[0].surfaceUrl ?
    this.curFeedCardInfo.postImgList?.[0].surfaceUrl :
    this.curFeedCardInfo.postImgList?.[0].picVideoUrl).height : 'auto'
  }

  @Builder
  followBuilder() {
  };

  @Builder
  publishTimeBuilder() {
    if (this.isDynamicsSingleDetail) {
      Column() {
        Text(this.curFeedCardInfo.relativeTime)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_tertiary'))
      }.width(CommonConstants.FULL_PERCENT).alignItems(HorizontalAlign.Start)
    }

  };

  getImageList(value: PostImgList[]): ResourceStr[] {
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

  onIndexChange(index: number): void {
    this.clickedIndex = index;
  }

  onBack(): void {
    this.isFirstPageShow = true;
  }

  computeImageCount() {
    if (!this.curFeedCardInfo.postImgList) {
      return []
    }
    const rules = new Map([
      [5, 4], // 5张时保留4张
      [6, 6], // 6张时保留6张
      [7, 6], // 7张时保留6张
      [8, 6], // 8张时保留6张
      [9, 9],// 9张时保留9张
    ]);
    const originalCount = this.curFeedCardInfo.postImgList.length;
    const count = Math.min(originalCount, 9);
    const keepCount = rules.get(count) ?? count;
    this.truncatedCount = originalCount - keepCount;
    return this.curFeedCardInfo.postImgList.slice(0, keepCount);
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row({ space: 8 }) {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Image(this.getAuthorIcon || $r('app.media.icon_default'))
              .alt($r('app.media.icon_default'))
              .width(40)
              .height(40)
              .borderRadius('50%')
              .clip(true)
              .accessibilityText(this.getAuthorName + '头像')
              .onClick(() => {
                this.onGoUserInfo(this.curFeedCardInfo.author.authorId)
              })
          }

          Column({ space: 8 }) {
            Text(this.getAuthorName)
              .fontColor($r('sys.color.font_primary'))
              .fontSize(14 * this.fontSizeRatio)
              .fontWeight(FontWeight.Medium)
              .constraintSize({
                maxWidth: 'calc(100% - 48vp)'
              })
            this.publishCustomTimeBuilder()
          }.alignItems(HorizontalAlign.Start)
        }
        .flexGrow(1)

        this.followBuilderParam()
      }
      .margin({
        bottom: 12,
      })
      .visibility(this.showUserBar ? Visibility.Visible : Visibility.None)

      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
          ArticleTextEllipsis({
            text: this.curFeedCardInfo.title,
            fontSizeRatio: this.fontSizeRatio,
            isAll: this.isAll,
            searchKey: this.searchKey,
          })
        }.width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .accessibilityLevel('yes')
      .accessibilityText(this.curFeedCardInfo.title)

      Column() {
        Grid() {
          ForEach(this.computeImageCount(),
            (item: PostImgList, index: number) => {
              GridItem() {
                Column() {
                  if (this.clickedIndex !== index || (this.isFirstPageShow)) {
                    FeedSingleImageSize({
                      curFeedCardInfo: this.curFeedCardInfo,
                      componentId: this.componentId,
                      isLast: this.computeImageCount().length - 1 === index,
                      truncatedCount: this.truncatedCount,
                      postImgListItem: item,
                      onImageClick: () => {
                        let param: Record<string, Object> = {};
                        this.clickedIndex = index;
                        param.selectedIndex = this.clickedIndex;
                        param.onIndexChange = (index: number) => {
                          this.onIndexChange(index);
                        };
                        param.componentId = this.componentId
                        param.onBackToFirstPage = () => {
                          this.onBack();
                        }
                        param.curFeedCardInfo = this.curFeedCardInfo
                        param.watchOperation = () => {
                          this.onAddWatch();
                        };
                        param.newsLike = () => {
                          this.onAddLike();
                        };
                        param.onAddComment = () => {
                          this.onAddComment();
                        };
                        param.showImagePreviewLayer = this.showImagePreviewLayer;
                        this.getUIContext().animateTo({
                          duration: 150,
                          curve: Curve.EaseIn,
                        }, () => {
                          RouterUtils.pushPathByName(RouterMap.IMAGE_PREVIEW, param, () => {
                          }, false)
                          this.isFirstPageShow = false;
                        })
                      },
                      onVideo: () => {
                        this.onVideo()
                      },
                    })
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .height(this.oneImageSize)
              }
            }, (item: PostImgList) => JSON.stringify(item))
        }
        .columnsTemplate('1fr '.repeat(getColumnsTemplate(this.computeImageCount().length ?? 0)))
        .columnsGap(8)
      }

      if (this.showTimeBottom) {
        Column() {
          Text(getDateDiff(this.curFeedCardInfo?.createTime))
            .fontSize(12 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 8 })
      }
    }
  }
}