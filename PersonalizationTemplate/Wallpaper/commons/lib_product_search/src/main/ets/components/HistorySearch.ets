import { HistorySearchItem } from '../commons/Types';
import { LengthMetrics, PromptAction } from '@kit.ArkUI';
import { Constants } from '../commons/Constants';
import { Logger } from '../utils/Logger';
import { SearchController } from '../controller/SearchController';

const TAG: string = '[HistorySearch]';

@ComponentV2
export struct HistorySearch {
  @Param historyList: HistorySearchItem[] = [];
  @Event handleClickItem: (label: string) => void;
  @Event updateList: (list: HistorySearchItem[]) => void;
  @Local isEdit: boolean = false;
  @Local tempHistoryList: HistorySearchItem[] = [];
  @Local showAll: boolean = true;
  private searchController: SearchController = SearchController.instance;

  @Computed
  get listMaxHeight() {
    if (this.showAll) {
      return Infinity;
    }
    return 80;
  }

  @Monitor('historyList')
  getListView() {
    this.tempHistoryList = this.historyList;
  }

  aboutToAppear(): void {
    this.getListView();
    this.syncFromController();
  }

  // 搜索控制器同步数据
  syncFromController() {
    const controllerHistory = this.searchController.historySearch;
    if (controllerHistory.length > 0 && this.tempHistoryList.length === 0) {
      this.tempHistoryList = controllerHistory.map(label => {
        const historyItem: HistorySearchItem = {
          label: label,
          latestSearch: new Date().getTime()
        };
        return historyItem;
      });
    }
  }

  build() {
    if (this.tempHistoryList.length) {
      Column() {
        Row() {
          Text('搜索历史')
            .fontSize(16).height(56)
            .fontColor(Constants.FONT_COLOR_LEVEL1)
            .fontWeight(FontWeight.Bold);
          if (!this.isEdit) {
            Image($r('app.media.ic_delete'))
              .width(24)
              .height(24)
              .fillColor(Constants.FONT_COLOR_LEVEL2)
              .margin({ right: Constants.SPACE_XS })
              .onClick(() => {
                this.isEdit = true;
              });

          } else {
            Row() {
              Text('全部删除')
                .labelStyle()
                .onClick(() => {
                  this.deleteAll();
                });
              Divider()
                .height(16)
                .vertical(true)
                .margin({ left: Constants.SPACE_S, right: Constants.SPACE_S });
              Text('完成')
                .labelStyle()
                .onClick(() => {
                  this.updateList?.(this.tempHistoryList);
                  this.isEdit = false;
                  this.syncToController();
                });
            }.height('100%');
          }
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        // 历史搜索项列表
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
          ForEach(this.tempHistoryList, (item: HistorySearchItem) => {
            this.historyItemBuilder(item);
          }, (item: HistorySearchItem, index: number) => index + '__' + item.label);
        }
        .constraintSize({ maxHeight: this.listMaxHeight })
        .clip(true)
        .onSizeChange((_old, newVal) => {
          if (newVal.height && newVal.height < this.listMaxHeight) {
            this.showAll = true;
          }
        });
      };
    }
  }

  @Builder
  historyItemBuilder(item: HistorySearchItem) {
    Row() {
      Text(item.label)
        .height(36)
        .padding({ left: 16, right: 16 })
        .fontColor('rgba(0,0,0,0.9)')
        .labelStyle();
      if (this.isEdit) {
        // 编辑模式下的删除按钮
        Image($r('app.media.ic_close'))
          .fillColor(Constants.FONT_COLOR_LEVEL2)
          .width(12)
          .height(12)
          .margin({ left: Constants.SPACE_XS, right: Constants.SPACE_XS })
          .onClick(() => {
            this.tempHistoryList = this.tempHistoryList.filter((it) => it.label !== item.label);
            const index = this.searchController.historySearch.indexOf(item.label);
            if (index !== -1) {
              this.searchController.deleteHistoryItem(index);
            }
            this.updateList?.(this.tempHistoryList);
          });
      }
    }
    .backgroundColor('rgba(0,0,0,0.05)')
    .borderRadius(Constants.BORDER_RADIUS_CAPSULE)
    .onClick(() => {
      if (this.isEdit) {
        return;
      }
      this.handleClickItem?.(item.label);
      this.searchController.updateHistorySearch(item.label);
    });
  }

  // 删除所有历史记录
  deleteAll() {
    let uiContext = this.getUIContext();
    let promptAction: PromptAction = uiContext.getPromptAction();
    try {
      promptAction.showDialog({
        message: '确定要清空所有搜索历史吗？',
        buttons: [
          {
            text: '取消',
            color: Constants.FONT_COLOR_LEVEL2,
          },
          {
            text: '删除',
            color: '0A59F7',
          },
        ],
      }, (err, data) => {
        if (err) {
          Logger.error(TAG, 'handle dialog failed. error:' + JSON.stringify(err));
        }
        if (data.index === 1) {
          this.tempHistoryList = [];
          this.updateList?.([]);
          this.isEdit = false;
          this.searchController.clearAllHistory();
        }
      });
    } catch (error) {
      Logger.error(TAG, 'open dialog failed. error:' + JSON.stringify(error));
    }
  }

  // 同步数据到搜索控制器
  private syncToController() {
    const labels = this.tempHistoryList.map(item => item.label);
    this.searchController.fullHistorySearch = labels;
    this.searchController.updateDisplayHistory();
  }
}

@Extend(Text)
function labelStyle() {
  .fontSize(14)
  .fontColor(Constants.FONT_COLOR_LEVEL2)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis });
}