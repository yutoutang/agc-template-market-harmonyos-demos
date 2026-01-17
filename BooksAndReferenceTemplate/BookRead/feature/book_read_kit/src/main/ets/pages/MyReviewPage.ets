import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, Constants, NavHeaderBar, TCRouter } from 'common';
import { ReviewInfo } from '../model/ReviewModels';
import { ReviewDataUtil } from '../utils/ReviewDataUtil';
import { ExpandableText } from '../components/ExpandableText';
import { emitter } from '@kit.BasicServicesKit';

@ComponentV2
export struct MyReviewPage {
  @Local myReviewList: ReviewInfo[] = [];
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  aboutToAppear(): void {
    // 初始化评论系统，确保用户信息同步
    ReviewDataUtil.initialize();

    this.loadMyReviews();

    try {
      // 监听用户信息变更事件
      emitter.on(Constants.LOGIN_CHANGE, () => {
        ReviewDataUtil.updateCurrentUserReviews();
        this.loadMyReviews();
      });
    } catch (e) {
      console.error('Failed to emitter on login change. Cause: ' + JSON.stringify(e));
    }

  }

  onPageShow(): void {
    this.loadMyReviews();
  }

  // 加载我的评价数据
  loadMyReviews(): void {
    this.myReviewList = ReviewDataUtil.getMyReviews();
    console.info('加载我的评价，共' + this.myReviewList.length + '条');
  }

  // 格式化日期为中文格式
  formatDateToChinese(dateStr: string): string {
    const date = new Date(dateStr);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${year}年${month}月${day}日`;
  }

  // 构建星级评分组件
  @Builder
  buildStarRating(rating: number) {
    Row() {
      ForEach(Array.from<number, number>({ length: 5 }, (_, index) => index + 1), (star: number) => {
        Image($r('app.media.ic_public_star'))
          .width(16)
          .height(16)
          .margin({ right: 4 })
          .fillColor(star <= rating ? '#FFD700' : '#E0E0E0')
      }, (item: string) => JSON.stringify(item))
    }
  }

  // 构建单个评价项
  @Builder
  buildMyReviewItem(review: ReviewInfo, index: number) {
    Column() {
      // 评论时间
      Row() {
        Text(this.formatDateToChinese(review.createTime))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(500)
          .fontSize(16)
          .lineHeight(21)
          .letterSpacing(0)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 8 })

      // 评分星级
      Row() {
        this.buildStarRating(review.rating)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 12 })

      // 评价内容
      Column() {
        ExpandableText({
          content: review.content.toString(),
          fontSize: 14,
          lineHeight: 20,
          fontColor: $r('sys.color.ohos_id_color_text_primary'),
          widthRatio: 0.9
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 书籍信息
      if (review.bookInfo) {
        Row() {
          // 书籍封面
          Image(review.bookInfo.coverUrl)
            .width(68)
            .height(90)
            .borderRadius(0)
            .objectFit(ImageFit.Cover)
            .margin({ right: 12 })

          // 书籍信息
          Column() {
            // 书籍名称
            Text(review.bookInfo.name)
              .fontFamily('HarmonyHeiTi')
              .fontWeight(500)
              .fontSize(16)
              .lineHeight(21)
              .letterSpacing(0)
              .textAlign(TextAlign.Start)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ bottom: 4 })

            // 书籍类别
            Text(review.bookInfo.category)
              .fontFamily('HarmonyHeiTi')
              .fontWeight(400)
              .fontSize(12)
              .lineHeight(16)
              .letterSpacing(0)
              .textAlign(TextAlign.Start)
              .fontColor($r('sys.color.ohos_id_color_text_hint'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }

      // 分割线（最后一项不显示）
      if (index < this.myReviewList.length - 1) {
        Divider()
          .margin({ top: 16, bottom: 20 })
      } else {
        // 最后一项增加额外的底部间距
        Blank()
          .height(20)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 20 })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: $r('app.string.my_evaluation'),
          hasBackButton: true,
          hasBgColor: false,
          isMainPage: true,
        })

        if (this.myReviewList.length > 0) {
          // 有评价数据时显示列表
          Scroll() {
            Column() {
              ForEach(this.myReviewList, (review: ReviewInfo, index: number) => {
                this.buildMyReviewItem(review, index);
              }, (review: ReviewInfo) => review.id)
            }
            .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : Constants.FULL_SIZE)
          }
          .align(Alignment.Top)
          .layoutWeight(1)
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .padding({ bottom: 40 })
        } else {
          Column() {
            Text('暂无评价记录')
              .fontSize(16)
              .fontColor($r('sys.color.ohos_id_color_text_hint'))
              .margin({ bottom: 8 })

            Text('去看看有什么好书吧~')
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_hint'))
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    }
    .hideTitleBar(true)
  }
} 