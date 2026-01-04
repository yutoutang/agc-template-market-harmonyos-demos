import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { HistoryResponse } from 'lib_video_api';
import { emptyBuilder, NavHeaderBar } from 'lib_widget';
import { HistoryViewModel } from '../viewmodels/HistoryVM';

@Builder
export function HistoryPageBuilder() {
  HistoryPage()
}

@ComponentV2
struct HistoryPage {
  @Local vm: HistoryViewModel = new HistoryViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '播放历史',
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
        })
        Column() {
          Scroll() {
            Column() {
              this.historyBuilderList()
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .width('100%')
          .edgeEffect(EdgeEffect.Spring)

          if (!this.vm.isEditMode) {
            this.toolBarBuilder()
          }
        }
        .layoutWeight(1)
        .visibility(this.vm.history.historyList.length ? Visibility.Visible : Visibility.None)

        Column() {
          emptyBuilder({
            fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
          })
        }
        .layoutWeight(1)
        .visibility(this.vm.history.historyList.length ? Visibility.None : Visibility.Visible)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor('#F5F5F5')
      .padding({
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
  }

  @Builder
  historyBuilderList() {
    List() {
      ForEach(this.vm.history.historyList, (item: HistoryResponse) => {
        this.historyItemBuilder(item)
      }, (item: HistoryResponse) => JSON.stringify(item))
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .layoutWeight(1)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  historyItemBuilder(item: HistoryResponse) {
    ListItem() {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
        Row({ space: 12 }) {
          Checkbox()
            .width(18)
            .select(this.vm.toDeleteList.includes(`${item.videoId}-${item.sectionNo}`))
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value: boolean) => {
              this.vm.onChange(value, item);
            })
            .visibility(!this.vm.isEditMode ? Visibility.Visible : Visibility.None)
          Image(item.videoInfo.coverUrl)
            .width(100)
            .height(56)
            .borderRadius(6)
          Column({ space: 5 }) {
            Text(`${item.videoInfo.title} 第${item.sectionNo + 1}集`)
              .fontSize(14)
              .lineHeight(20)
              .fontWeight(FontWeight.Bold)

            Text(`观看至 ${(item.totalTime === 0 ? 0 : item.playTime / item.totalTime * 100).toFixed(1)}%`)
              .fontColor('#333')
              .fontSize(12)
              .lineHeight(17)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .onClick(() => {
          const param: Record<string, Object> = {
            'videoId': item.videoId,
            'index': item.sectionNo
          }
          RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
        })

      }
    }
    .padding({ top: CommonConstants.PADDING_M, bottom: CommonConstants.PADDING_M })

    Divider()
  }

  @Builder
  rightPartBuilder() {
    Row() {

      if (this.vm.isEditMode) {
        Image($r('app.media.ic_Default'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.isEditMode = !this.vm.isEditMode
          })
      } else {
        Text('取消')
          .fontColor('#99000000')
          .fontSize(14)
          .onClick(() => {
            this.vm.isEditMode = !this.vm.isEditMode
          })
      }
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
    .visibility(this.vm.history.historyList.length > 0 ? Visibility.Visible : Visibility.None)
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