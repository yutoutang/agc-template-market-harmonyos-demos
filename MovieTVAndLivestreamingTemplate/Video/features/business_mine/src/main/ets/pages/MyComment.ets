import { CircleShape } from '@kit.ArkUI';
import { CommonConstants, RouterMap, RouterUtils, TimeUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { AggregateNewsCommentModel } from '../common/ObservedModel';
import { MyCommentVM } from '../viewmodels/MyCommentVM';

@Builder
export function MyCommentBuilder() {
  MyComment()
}

@ComponentV2
struct MyComment {
  @Local vm: MyCommentVM = new MyCommentVM();
  @Local edit: boolean = true

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的评论',
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
          onBack: () => {
            this.vm.onBackPressed();
          },
        })
        Refresh({ refreshing: $$this.vm.loading }) {
          List({ space: CommonConstants.SPACE_L }) {
            ForEach(this.vm.list, (v: AggregateNewsCommentModel) => {
              ListItem() {
                this.mainItemBuilder(v)
              }
            }, (v: AggregateNewsCommentModel) => JSON.stringify(v))
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .padding({
            left: CommonConstants.PADDING_PAGE,
            right: CommonConstants.PADDING_PAGE,
            top: CommonConstants.SPACE_S,
            bottom: this.vm.windowModel.windowBottomPadding,
          })
        }
        .layoutWeight(1)
        .onRefreshing(() => {
          this.vm.onRefresh();
        })

        if (!this.edit) {
          this.toolBarBuilder()
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  mainItemBuilder(v: AggregateNewsCommentModel) {
    Row() {
      Checkbox()
        .width(18)
        .select(this.vm.selectedIds.includes(v.commentId))
        .shape(CheckBoxShape.CIRCLE)
        .onChange((value: boolean) => {
          this.vm.onChange(value, v);
        })
        .visibility(!this.edit ? Visibility.Visible : Visibility.None)
      Column({ space: CommonConstants.SPACE_S }) {
        this.topUserBuilder(v)
        this.middleCommentBuilder(v)
        this.replyBtnBuilder(v)
      }
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  topUserBuilder(v: AggregateNewsCommentModel) {
    Row({ space: CommonConstants.SPACE_S }) {
      Image(v.author.authorIcon)
        .width(24)
        .aspectRatio(1)
        .clipShape(new CircleShape({ width: 24, height: 24 }))
      Text(v.author.authorNickName)
        .fontSize(12)
        .fontColor('#7f7f7f')
        .lineHeight(17)
    }
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  middleCommentBuilder(v: AggregateNewsCommentModel) {
    Column({ space: CommonConstants.SPACE_S }) {
      // 评论/回复内容
      Row() {
        Text() {
          Span(this.vm.isReply(v) ? ' ' : ' ')
          Span(v.commentBody)
        }
        .fontSize(14)

        Row() {
          Text(`共${v.replyComments.length}条回复`)
            .fontSize(14)
            .fontColor('#FFFD603E')
          Image($r('app.media.ic_right_reply')).width($r('app.float.arrow_right_w'))
        }

        .visibility(v.replyComments.length > 0 ? Visibility.Visible : Visibility.None)
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)

      // 回复的评论引用
      Row() {
        Text(v.parentComment?.commentBody)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .lineHeight(22)
          .fontColor('#E6000000')
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)

      Text(TimeUtils.handleMsgTimeDiff(v.createTime))
        .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: CommonConstants.PADDING_XXXL,
    })

    .onClick(() => {
      this.vm.jumpMoreComment(v);
    })
  }

  @Builder
  replyBtnBuilder(v: AggregateNewsCommentModel) {
    Row() {
      Row() {
        Text(v.videoDetailInfo?.title)
          .fontSize(14)
          .fontColor('#FF666666')
          .textAlign(TextAlign.Start)// 文本内容左对齐
          .lineHeight(16)
        Blank()
        Image(v.videoDetailInfo?.coverUrl)
          .width(100)
          .height(56)
          .borderRadius(6)
      }
      .onClick(() => {
        const param: Record<string, Object> = {
          'videoId': v.videoId
        }
        RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
      })
      .borderRadius(8)
      .padding(8)
      .alignItems(VerticalAlign.Top) // 确保垂直方向顶部对齐
      .backgroundColor('#0D000000')
      .padding(8)
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_XXXL,
    })
  }

  @Builder
  rightPartBuilder() {
    Row() {
      if (this.edit) {
        Image($r('app.media.ic_Default'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.edit = !this.edit
          })
      } else {
        Text('取消')
          .fontColor('#99000000')
          .fontSize(14)
          .onClick(() => {
            this.edit = !this.edit
          })
      }
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
    .visibility(this.vm.list.length > 0 ? Visibility.Visible : Visibility.None)
  }

  @Builder
  toolBarBuilder() {
    Row() {
      Column({ space: CommonConstants.SPACE_XS }) {
        Button(this.vm.allSelected ? '取消全选' : '全选')
          .width(156)
          .height(40)
          .fontColor($r('sys.color.font_tertiary'))
          .backgroundColor($r('sys.color.font_on_primary'))
      }
      .width(CommonConstants.HALF_PERCENT)
      .padding(CommonConstants.PADDING_XS)
      .onClick(() => {
        this.vm.deleteAllConfirm();
      })

      Column({ space: CommonConstants.SPACE_XS }) {
        Button('删除')
          .width(156)
          .height(40)
      }
      .width(CommonConstants.HALF_PERCENT)
      .padding(CommonConstants.PADDING_XS)
      .onClick(() => {
        this.vm.deleteConfirm();
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ bottom: 30 })
  }
}