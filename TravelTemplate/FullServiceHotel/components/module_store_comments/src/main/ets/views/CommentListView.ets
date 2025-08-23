import { CommonButton } from 'module_ui_base';
import { COMMENT_ROUTER_MAP } from '../commons/Enums';
import { CommentItem, KeywordItem } from '../commons/Types';
import { CommentCard } from '../components/CommentCard';
import { CommentListVM } from '../viewmodels/CommentListVM';

@ComponentV2
export struct CommentListView {
  @Param
  stack: NavPathStack = new NavPathStack()
  vm: CommentListVM = new CommentListVM();

  aboutToAppear(): void {
    this.vm.getRatingSummary()
    this.vm.getCommentInfo()
  }

  build() {
    Column() {
      Column() {
        this.keywordBuilder();
        Divider()
          .margin({ top: $r('app.string.space_l'), bottom: $r('app.string.space_l') })
        this.listBuilder()
      }
      .width('100%')
      .padding(16)
      .layoutWeight(1)

      CommonButton({
        title: '去评价',
        handleClick: () => {
          this.stack.pushPath({
            name: COMMENT_ROUTER_MAP.SUBMIT_COMMENT,
            onPop: () => {
              this.vm.refreshCommentList()
            },
          })
        },
      })
    }

  }

  @Builder
  keywordBuilder() {
    Row() {
      ForEach(this.vm.keywordList, (item: KeywordItem) => {
        Row() {
          Text(`${item.desc} ${item.count.toFixed(1)}`)
            .fontSize($r('app.string.font_size_10'))
            .fontColor($r('app.color.theme_color'))
        }
        .backgroundColor($r('app.color.background_color_theme'))
        .padding($r('app.string.space_s'))
        .borderRadius($r('app.string.border_radius_8'))
      }, (item: KeywordItem) => JSON.stringify(item))
    }
    .width('100%')
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
    .layoutWeight(1)
    .columnsTemplate('1fr')
    .cachedCount(4)
    .rowsGap($r('app.string.space_l'))
    .edgeEffect(this.vm.edgeEffect)
    .onReachEnd(() => {
      this.vm.getCommentInfo();
    })
  }

  @Builder
  waterFlowFootBuilder() {
    Row() {
      if (this.vm.commentList.totalCount() && this.vm.isLoading) {
        LoadingProgress().width(32);
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