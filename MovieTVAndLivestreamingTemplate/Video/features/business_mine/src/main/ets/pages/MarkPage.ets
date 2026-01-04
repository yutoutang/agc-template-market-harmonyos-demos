import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { VideoModel } from 'lib_video_api';
import { NavHeaderBar } from 'lib_widget';
import { MarkViewModel } from '../viewmodels/MarkVM';

@Builder
export function MarkPageBuilder() {
  MarkPage()
}

@ComponentV2
struct MarkPage {
  @Local vm: MarkViewModel = new MarkViewModel();
  @Local markEdit: boolean = true

  aboutToAppear() {
    this.vm.markLikeList()
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的收藏',
          rightPartBuilder: () => {
            this.rightViewBuilder()
          }
        })
        Column() {
          Scroll() {
            Column() {
              this.markListBuilder()
            }
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .width('100%')
          .align(Alignment.Top)

          if (!this.markEdit) {
            this.toolBarBuilder()
          }
        }.layoutWeight(1)
      }
      .backgroundColor('#F5F5F5')
      .padding({
        bottom: this.vm.windowModel.windowBottomPadding,
      })
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
  }

  @Builder
  rightViewBuilder() {
    Row() {
      if (this.markEdit) {
        Image($r('app.media.ic_Default'))
          .height(24)
          .width(24)
          .onClick(() => {
            this.markEdit = !this.markEdit
          })
      } else {
        Text('取消')
          .fontSize(14)
          .fontColor('#99000000')
          .onClick(() => {
            this.markEdit = !this.markEdit
          })
      }
    }
    .justifyContent(FlexAlign.End)
    .layoutWeight(1)
    .visibility(this.vm.markAllLikeList.length > 0 ? Visibility.Visible : Visibility.None)
  }

  @Builder
  markListBuilder() {
    List() {
      if (this.vm.markAllLikeList.length <= 0) {
        ListItem() {
          Column() {
            Image($r('app.media.ic_empty_content'))
              .height(120)
              .width(120)
            Text('暂无内容')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize(14)
          }
        }
        .height('100%')
        .width('100%')
      } else {
        ForEach(this.vm.markAllLikeList, (item: VideoModel) => {
          this.listBuilder(item)
        }, (item: VideoModel) => JSON.stringify(item))
      }
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  listBuilder(item: VideoModel) {
    ListItem() {
      Flex({ alignItems: ItemAlign.Center, direction: FlexDirection.Row }) {
        Row({ space: 15 }) {
          Checkbox()
            .shape(CheckBoxShape.CIRCLE)
            .select(this.vm.selectedIds.includes(item.videoId))
            .width(18)
            .onChange((value: boolean) => {
              this.vm.onChange(value, item);
            })
            .visibility(this.markEdit ? Visibility.None : Visibility.Visible)
          Image(item.coverUrl)
            .borderRadius(6)
            .height(56)
            .width(100)
          Text(item.title)
        }
        .onClick(() => {
          const param: Record<string, Object> = { 'videoId': item.videoId }
          RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
        })
      }
    }
    .padding({ bottom: CommonConstants.PADDING_M, top: CommonConstants.PADDING_M })

    Divider()
  }

  @Builder
  toolBarBuilder() {
    Row() {
      Column({ space: CommonConstants.SPACE_XS }) {
        Button(this.vm.allSelected ? '取消全选' : '全选')
          .fontColor($r('sys.color.font_tertiary'))
          .height(40)
          .width(156)
          .backgroundColor($r('sys.color.font_on_primary'))
      }
      .padding(CommonConstants.PADDING_XS)
      .width(CommonConstants.HALF_PERCENT)
      .onClick(() => {
        this.vm.deleteAllConfirm();
      })

      Column({ space: CommonConstants.SPACE_XS }) {
        Button('删除').width(156).height(40)
      }
      .padding(CommonConstants.PADDING_XS)
      .width(CommonConstants.HALF_PERCENT)
      .onClick(() => {
        this.vm.deleteConfirm();
      })
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}