import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { VideoModel } from 'lib_video_api';
import { NavHeaderBar } from 'lib_widget';
import { LikeViewModel } from '../viewmodels/LikeVM';

@Builder
export function LikePageBuilder() {
  LikePage()
}

@ComponentV2
struct LikePage {
  @Local vm: LikeViewModel = new LikeViewModel();
  @Local likeEdit: boolean = true

  aboutToAppear() {
    this.vm.likeList()
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的点赞',
          rightPartBuilder: () => {
            this.rightPartBuilder()
          }
        })
        Column() {
          Scroll() {
            Column() {
              this.likeListBuilder()
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .width('100%')

          if (!this.likeEdit) {
            this.toolBarBuilder()
          }
        }.layoutWeight(1)

      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
  }

  @Builder
  rightPartBuilder() {
    Row() {
      if (this.likeEdit) {
        Image($r('app.media.ic_Default'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.likeEdit = !this.likeEdit
          })
      } else {
        Text('取消')
          .fontColor('#99000000')
          .fontSize(14)
          .onClick(() => {
            this.likeEdit = !this.likeEdit
          })
      }
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
    .visibility(this.vm.allLikeList.length > 0 ? Visibility.Visible : Visibility.None)
  }

  @Builder
  likeListBuilder() {
    List() {
      if (this.vm.allLikeList.length <= 0) {
        ListItem() {
          Column() {
            Image($r('app.media.ic_empty_content')).width(120).height(120)
            Text('暂无内容')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        .width('100%')
        .height('100%')
      } else {
        ForEach(this.vm.allLikeList, (item: VideoModel) => {
          this.listBuilder(item)
        }, (item: VideoModel) => JSON.stringify(item))
      }
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .padding({ left: 16, right: 16 })
    .width('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  listBuilder(item: VideoModel) {
    ListItem() {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
        Row({ space: 15 }) {
          Checkbox()
            .width(18)
            .select(this.vm.selectedIds.includes(item.videoId))
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value: boolean) => {
              this.vm.onChange(value, item);
            })
            .visibility(!this.likeEdit ? Visibility.Visible : Visibility.None)
          Image(item.coverUrl)
            .width(100)
            .height(56)
            .borderRadius(6)
          Column({ space: 5 }) {
            Text(item.title)
              .fontColor('#E6000000')
              .fontSize(14)
              .lineHeight(16)
              .width('100%')
              .textAlign(TextAlign.Start) // 添加这行实现文字左对齐
            if (item.contentType === 'tv_movie') {
              Text(`${item.videoUrl.length}集全`)
                .fontColor('#999999')
                .fontSize(12)
                .lineHeight(14)
                .width('100%')
                .textAlign(TextAlign.Start) // 添加这行实现文字左对齐
            }
          }
          .layoutWeight(1)
        }
        .onClick(() => {
          const param: Record<string, Object> = {
            'videoId': item.videoId
          }
          RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
        })

      }

    }
    .padding({ top: CommonConstants.PADDING_M, bottom: CommonConstants.PADDING_M })

    Divider()
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
  }
}