import { AppStorageV2 } from '@kit.ArkUI';
import { BusSubwayMap } from '../constants/Enums';
import { CommonConstants, StopDetailModel } from 'module_station_line_detail';
import { MapWindowModel } from '../models/MapWindowModel';

@Builder
export function SearchMapBuilder(searchStop: (keyWord: string) => Promise<StopDetailModel[]>,
  confirm: (stopDetail: StopDetailModel) => void,
  back: () => void
) {
  SearchMap({
    searchStop: searchStop,
    confirm: confirm,
    back: back
  })
}


@ComponentV2
struct SearchMap {
  @Local presetPlaceholder: string = '站点搜索'; // placeholder文本
  @Local searchText: string = '';
  @Local searchResults: StopDetailModel[] = [];
  @Local isSearching: boolean = false;
  @Local isLoading: boolean = false;
  @Event searchStop: (keyWord: string) => Promise<StopDetailModel[]>
  @Event confirm: (stopDetail: StopDetailModel) => void
  @Event back: () => void
  private searchTimer: number = 0; // 防抖定时器
  private currentSearchKeyword: string = ''; // 当前搜索关键词
  private searchController: SearchController = new SearchController();
  private windowModel: MapWindowModel = AppStorageV2.connect(MapWindowModel, () => new MapWindowModel())!;

  @Builder
  searchHeaderBuilder() {
    Row() {
      Image($r('app.media.ic_back'))
        .width($r('app.float.head_icon_width'))
        .margin({ right: 15 })
        .onClick(() => {
          this.searchController.stopEditing()
          this.back();
        })
      Search({
        placeholder: this.presetPlaceholder,
        value: this.searchText,
        controller: this.searchController,
      })
        .layoutWeight(1)
        .onChange(async (value: string) => {
          this.onSearchChange(value);
        })
        .onSubmit(async (value: string) => {
          this.onSearchChange(value);
        })
    }
    .width('100%')
    .margin({ bottom: 20 })
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
                  ForEach(this.searchResults, (item: StopDetailModel, index: number) => {
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
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                    }
                    .width('100%')
                    .padding({ top: 16, bottom: 16 })
                    .onClick(() => {
                      this.searchController.stopEditing()
                      this.confirm(item);
                    })

                    if (index < this.searchResults.length - 1) {
                      Divider()
                        .color($r('sys.color.comp_divider'))
                    }
                  }, (v: StopDetailModel) => v.siteId)
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
      const results = await this.searchStop(keyword)

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

  // 获取图标
  private getItemIcon(item: StopDetailModel): Resource {
    // 站点
    if (item.stopType === BusSubwayMap.BUS_SUBWAY_TYPE_SUBWAY) {
      return $r('app.media.metro'); // 地铁站点
    } else {
      return $r('app.media.bus'); // 公交站点
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
