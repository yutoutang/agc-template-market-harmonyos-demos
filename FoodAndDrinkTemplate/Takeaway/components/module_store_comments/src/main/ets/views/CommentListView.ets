import { CommentItem, KeyWordItem } from '../commons/Types';
import { CommentCard } from '../components/CommentCard';
import { CommentScoringItem } from '../components/CommentScoringItem';
import { CommentListVM } from '../viewmodels/CommentListVM';

@ComponentV2
export struct CommentListView {
  @Param
  stack: NavPathStack = new NavPathStack()
  @Param
  windowBottomPadding: number = 28
  vm: CommentListVM = new CommentListVM();
  @Event
  updateCommentTotal?: (totalNum: number) => void = () => {
    // do nothing
  };

  aboutToAppear(): void {
    this.vm.getRatingSummary()
    this.vm.getCommentInfo()
  }

  build() {
    Column() {
      Column() {
        this.keywordBuilder();
        this.listBuilder()
      }
      .width('100%')
      .layoutWeight(1)
    }
    .padding({
      bottom: this.windowBottomPadding
    })
    .width('100%')

  }

  @Builder
  keywordBuilder() {
    Row() {
      ForEach(this.vm.keywordList, (item: KeyWordItem) => {
        CommentScoringItem({ desc: item.desc, count: item.count, layoutType: item.layoutType })
      }, (item: KeyWordItem) => JSON.stringify(item))
    }
    .height(52)
    .width('100%')
    .padding({
      left: 20,
    })
    .margin({
      bottom: $r('app.string.space_s')
    })
    .borderRadius($r('app.string.border_radius_12'))
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  listBuilder() {
    WaterFlow({
      scroller: this.vm.scroller,
      footer: this.waterFlowFootBuilder(),
    }) {
      LazyForEach(this.vm.commentList, (item: CommentItem) => {
        FlowItem() {
          CommentCard({
            commentItem: item,
          });
        };
      }, (item: CommentItem, index: number) => index + '__' + item.desc);
    }
    .backgroundColor('#F1F3F5')
    .layoutWeight(1)
    .columnsTemplate('1fr')
    .cachedCount(4)
    .rowsGap($r('app.string.space_m'))
    .edgeEffect(this.vm.edgeEffect)
    .onReachEnd(() => {
      this.vm.getCommentInfo();
      this.updateCommentTotal?.(this.vm.totalNum)
    })
  }

  @Builder
  waterFlowFootBuilder() {
    Row() {
      if (this.vm.commentList.totalCount() && this.vm.isLoading) {
        LoadingProgress()
          .size({ width: 32, height: 32})
      } else if (!this.vm.isLoading) {
        Text(this.vm.reachEnd ? '已经到达底部' : '向上滑动加载数据')
          .fontSize(12)
          .fontColor($r('app.color.font_color_level3'));
      }
    }
    .width('100%')
    .height(100)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Top)
    .padding(16);
  }
}