import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, LineModel, RouterMap, RouterUtils, StopLineBase, StopModel, WindowModel } from 'lib_common';
import { BusSubwayMap, SearchMockData, SearchServiceApi } from 'lib_api';
import { StopLineModelConvertUtil } from '../utils/StopLineModelConvertUtil';
import { searchData } from '../constants/SearchMockData';
import { CurrentLineDetailModel, LineDetailModel, StopDetailModel } from 'module_station_line_detail';

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
struct SearchPage {
  stack: NavPathStack = RouterUtils.getStack();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local searchHistory: StopLineBase[] = [];
  @Local searchText: string = '';
  @Local isSearching: boolean = false;
  @Local isLoading: boolean = false;
  @Local searchResults: StopLineBase[] = []
  @Local suggestedSearches: string[] = searchData.slice(0, 10);
  @Local presetPlaceholder: string = ''; // placeholder文本
  private searchTimer: number = 0; // 防抖定时器
  private currentSearchKeyword: string = ''; // 当前搜索关键词
  private currentLineDetailModel: CurrentLineDetailModel =
    AppStorageV2.connect(CurrentLineDetailModel, () => new CurrentLineDetailModel())!;

  aboutToAppear() {
    this.searchHistory = SearchMockData.searchHistory.slice();
    const preset = this.getPresetKeyword();
    if (preset && preset.trim().length > 0) {
      // 只设置placeholder，不填充搜索框，不执行搜索
      this.presetPlaceholder = preset;
    }
  }

  // 高亮显示文本
  @Builder
  buildHighlightSpans(text: string, query: string, baseFontSize: number = 14, normalColor: string = '#333333') {
    if (!query || query.trim() === '') {
      Span(text)
        .fontSize(baseFontSize)
        .fontColor(normalColor)
    } else {
      ForEach(this.splitTextForHighlight(text, query), (part: string, index: number) => {
        if (part.toLowerCase() === query.toLowerCase()) {
          Span(part)
            .fontSize(baseFontSize)
            .fontColor('#1f74f8')
            .fontWeight(FontWeight.Bold)
        } else {
          Span(part)
            .fontSize(baseFontSize)
            .fontColor(normalColor)
        }
      }, (v: string) => v)
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.searchHeaderBuilder()
        Column() {
          Scroll() {
            Column() {
              if (this.isLoading) {
                // 显示loading状态
                Column() {
                  LoadingProgress()
                    .width(40)
                    .aspectRatio(1)
                    .color($r('sys.color.icon_secondary'))
                    .margin({ bottom: 16 })

                  Text('搜索中...')
                    .fontSize(16)
                    .fontColor('#999999')
                }
                .width('100%')
                .height(200)
                .justifyContent(FlexAlign.Center)
              } else if (this.isSearching && this.searchResults.length > 0) {
                // 显示搜索结果
                Column() {
                  ForEach(this.searchResults, (item: StopLineBase, index: number) => {
                    Row() {
                      Image(this.getItemIcon(item))
                        .width(24)
                        .height(24)
                        .margin({ right: 12 })

                      Column() {
                        Text() {
                          this.buildHighlightSpans(item.name || '', this.searchText, 16, '#333333')
                        }
                        .fontWeight(FontWeight.Medium).margin({ bottom: 4 })

                        if (item instanceof LineModel) {
                          Row() {
                            Text('开往')
                              .fontSize(14)
                              .fontColor('#666666')
                              .margin({ right: 10 })

                            Text() {
                              this.buildHighlightSpans(item.endStop || '', this.searchText, 14, '#666666')
                            }
                          }
                          .alignItems(VerticalAlign.Center)
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                    }
                    .width('100%')
                    .padding({ top: 16, bottom: 16 })
                    .onClick(() => {
                      this.onSearchResultClick(item);
                    })

                    if (index < this.searchResults.length - 1) {
                      Divider()
                        .color($r('sys.color.comp_divider'))
                    }
                  }, (v: StopLineBase) => v.id + '_' + v.name)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              } else if (!this.isSearching) {
                // 同时显示搜索历史和猜你想搜
                Column() {
                  if (this.searchHistory.length > 0) {
                    // 搜索历史模块
                    Column() {
                      Row() {
                        Text('搜索历史')
                          .fontSize(16)
                          .fontColor('#333333')
                          .layoutWeight(1)

                        Image($r('app.media.trash'))
                          .width(20)
                          .height(20)
                          .onClick(() => {
                            this.confirmClearHistory();
                          })
                      }
                      .width('100%')
                      .margin({ bottom: 16 })

                      ForEach(this.searchHistory, (item: StopLineBase, index: number) => {
                        Row() {
                          Image(this.getItemIcon(item))
                            .width(24)
                            .height(24)
                            .margin({ right: 12 })

                          Column() {
                            Text(item.name || '')
                              .fontSize(16)
                              .fontColor('#333333')
                              .margin({ bottom: 4 })
                            if (item instanceof LineModel) {
                              Row() {
                                Text('开往')
                                  .fontSize(14)
                                  .fontColor('#666666')
                                  .margin({ right: 10 })

                                Text(item.endStop || '')
                                  .fontSize(14)
                                  .fontColor('#666666')
                              }
                              .alignItems(VerticalAlign.Center)
                            }
                          }
                          .alignItems(HorizontalAlign.Start)
                          .layoutWeight(1)
                        }
                        .width('100%')
                        .padding({ top: 16, bottom: 16 })
                        .onClick(() => {
                          this.onHistoryItemClick(item);
                        })

                        if (index < this.searchHistory.length - 1) {
                          Divider()
                            .color($r('sys.color.comp_divider'))
                        }
                      }, (v: StopLineBase) => v.id)
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                    .margin({ bottom: 24 })
                  }

                  // 猜你想搜模块
                  this.wantSearchBuilder()
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              } else if (this.isSearching && this.searchResults.length === 0) {
                // 无搜索结果
                Column() {
                  Image($r('app.media.ic_empty_content'))
                    .width(80)
                    .height(80)
                    .margin({ bottom: 16 })

                  Text('暂无搜索结果')
                    .fontSize(16)
                    .fontColor('#999999')
                }
                .width('100%')
                .height(200)
                .justifyContent(FlexAlign.Center)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .padding({
              bottom: this.windowModel.windowBottomPadding
            })
          }
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .height('100%')
      .padding({
        top: this.windowModel.windowTopPadding,
        left: CommonConstants.PADDING_PAGE,
        right: CommonConstants.PADDING_PAGE,
        bottom: this.windowModel.windowBottomPadding
      })
    }.hideTitleBar(true)
  }

  @Builder
  searchHeaderBuilder() {
    Row() {
      Image($r('app.media.ic_back'))
        .width($r('app.float.head_icon_width'))
        .margin({ right: 15 })
        .onClick(() => {
          RouterUtils.pop()
        })
      Search({
        placeholder: this.presetPlaceholder || $r('app.string.home_search_placeholder'),
        value: this.searchText
      })
        .layoutWeight(1)
        .onChange((value: string) => {
          this.onSearchChange(value);
        })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  // 猜你想搜
  @Builder
  wantSearchBuilder() {
    Column() {
      Text('猜你想搜')
        .fontSize(16)
        .fontColor('#333333')
        .margin({ bottom: 16 })

      Column() {
        ForEach(this.suggestedSearches, (item: string, index: number) => {
          Row() {
            Text((index + 1).toString())
              .fontSize(16)
              .fontColor(index < 3 ? '#E84026' : '#999999')
              .margin({ right: 12 })

            Text(item)
              .fontSize(16)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .onClick(() => {
            this.onSuggestedSearchClick(item);
          })
        }, (v: string) => v)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 预填参数类型
  private getPresetKeyword(): string | undefined {
    const param = RouterUtils.getParamByName<Record<string, string>>(RouterMap.SEARCH_PAGE)
    return param?.presetKeyword
  }

  // 搜索输入处理
  private onSearchChange(value: string) {
    this.searchText = value;

    // 清除之前的定时器
    if (this.searchTimer) {
      clearTimeout(this.searchTimer);
    }
    if (value.trim() === '') {
      this.searchResults = [];
      this.isSearching = false;
      this.isLoading = false;
    } else {
      // 设置防抖定时器，300ms后执行搜索
      this.searchTimer = setTimeout(() => {
        this.performSearch(value);
      }, 300);
    }
  }

  // 执行搜索
  private async performSearch(keyword: string) {
    // 更新当前搜索关键词
    this.currentSearchKeyword = keyword;
    this.isSearching = true;
    this.isLoading = true;

    try {
      const results = await SearchServiceApi.search(keyword);

      // 检查搜索结果是否对应当前的搜索关键词
      // 防止旧的搜索结果覆盖新的搜索结果
      if (this.currentSearchKeyword === keyword) {
        this.searchResults = results;
      }
    } catch (error) {
      // 只有在当前关键词匹配时才更新结果
      if (this.currentSearchKeyword === keyword) {
        this.searchResults = [];
      }
    } finally {
      // 只有在当前关键词匹配时才更新加载状态
      if (this.currentSearchKeyword === keyword) {
        this.isLoading = false;
      }
    }
  }

  // 搜索提交
  private onSearchSubmit(keyword: string) {
    const trimmed = keyword.trim();
    // 若无输入但有预设placeholder，则使用placeholder进行搜索并填充到输入框
    if (trimmed === '') {
      if (this.presetPlaceholder && this.presetPlaceholder.trim().length > 0) {
        this.searchText = this.presetPlaceholder;
        this.performSearch(this.presetPlaceholder);
      }
      return;
    }

    // 执行搜索
    this.performSearch(trimmed);
  }

  private clearSearchHistory() {
    SearchMockData.searchHistory = [];
    this.searchHistory = [];
  }

  // 全部清空弹窗
  private confirmClearHistory() {
    AlertDialog.show({
      title: '',
      message: '确定要清空搜索历史吗?',
      primaryButton: {
        value: '取消',
        fontColor: '#606060',
        backgroundColor: Color.Transparent,
        action: () => {
        }
      },
      secondaryButton: {
        value: '确定',
        fontColor: '#2667c1',
        backgroundColor: Color.Transparent,
        action: () => {
          this.clearSearchHistory()
        }
      },
      alignment: DialogAlignment.Center,
      gridCount: 2,
      autoCancel: true,
      width: '80%',
      height: 120
    });
  }

  // 点击历史记录项
  private onHistoryItemClick(item: StopLineBase) {
    // 跳转对应详情页
    this.onSearchResultClick(item);
  }

  // 点击建议搜索项
  private onSuggestedSearchClick(item: string) {
    this.searchText = item;
  }

  private addToSearchHistory(item: StopLineBase) {
    const exists: boolean =
      (SearchMockData.searchHistory as StopLineBase[]).some((historyItem: StopLineBase): boolean => {
        const sameId: boolean = historyItem.id === item.id;
        const sameName: boolean = historyItem.name === item.name;
        return sameId && sameName;
      });
    if (!exists) {
      SearchMockData.searchHistory.unshift(item);
      if (SearchMockData.searchHistory.length > 10) {
        SearchMockData.searchHistory.length = 10;
      }
    }
    // 同步回本地触发刷新
    this.searchHistory = SearchMockData.searchHistory.slice();
  }

  // 点击搜索结果项
  private async onSearchResultClick(item: StopLineBase) {

    // 添加到搜索历史
    this.addToSearchHistory(item);

    if (item instanceof StopModel) {
      const stopModel: StopModel = item as StopModel;
      try {
        const completeStopModel: StopModel = await SearchServiceApi.searchBusstopById(stopModel.id!);
        // 转换站点模型为详情模型（包含同名站台信息）
        const stopDetailModel: StopDetailModel = await StopLineModelConvertUtil.genStopDetailModel(completeStopModel);

        // 跳转到站点详情页
        RouterUtils.pushPathByName(RouterMap.STOPDETAIL_PAGE, stopDetailModel);
      } catch (error) {
        // 错误提示
      }
    } else {
      const lineModel: LineModel = item as LineModel;
      // 转换可分可合组件内部模型
      const lineDetailModel: LineDetailModel = await StopLineModelConvertUtil.genLineDetailModel(lineModel, null);
      this.currentLineDetailModel.lineDetailList.push(lineDetailModel)
      RouterUtils.pushPathByName(RouterMap.LINE_DETAIL_PAGE, lineDetailModel)
    }
  }

  // 获取图标
  private getItemIcon(item: StopLineBase): Resource {
    if (item instanceof LineModel) {
      // 线路
      return $r('app.media.line');
    } else {
      // 站点
      if (item.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
        return $r('app.media.metro'); // 地铁站点
      } else {
        return $r('app.media.bus'); // 公交站点
      }
    }
  }

  // 分割文本用于高亮
  private splitTextForHighlight(text: string, query: string): string[] {
    try {
      const escaped = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      const regex = new RegExp(`(${escaped})`, 'gi');
      return text.split(regex);
    } catch (_) {
      return [text];
    }
  }
}