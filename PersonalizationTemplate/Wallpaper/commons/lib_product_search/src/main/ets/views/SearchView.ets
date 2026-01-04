import { Constants } from '../commons/Constants';
import { HistorySearch } from '../components/HistorySearch';
import { CardItem, GuessLikeParams, SearchVM } from '../viewmodels/SearchVM';
import { HotSearchItem } from '../commons/Types';
import { SearchBar } from '../components/SearchBar';
import { ImageInfo, ImageInfos } from 'module_wallpaper_details';
import { RouterMap, RouterUtils } from 'lib_common';
import { WallpaperController, WallpaperList } from 'lib_widget';
import { WaterFlowComponent } from 'module_waterflow';
import { ComponentDetailTitle } from 'module_waterflow/src/main/ets/models/DataSource';
import { WallpaperServiceApi } from 'lib_wallpaper_api';

@ComponentV2
export struct SearchView {
  @Local sortText: string = '按热度';
  @Param defaultSearch: string = '';
  @Param routerStack: NavPathStack = new NavPathStack();
  @Param initialKeyword: string = ''; // 初始关键词参数
  @Param fromCarousel: boolean = false; // 是否来自轮播点击
  @Local animate: boolean = false;
  @Local refreshRotateVal: number = 0;
  vm: SearchVM = new SearchVM();
  @Local currentTab: number = 0; // 当前标签页：0:综合 1:在线 2:组件
  @Local shouldShowSuggestions: boolean = false; // 是否显示联想
  @Local placeholderText: string = '请输入搜索内容';
  @Local cardData: CardItem[] = [];
  @Local finished: boolean = false;
  @Local params: GuessLikeParams = {
    page: 1,
    pageSize: 6
  }
  @Local allTotal: number = 1;
  @Provider('searchNewWords') searchNewWords: string = '';
  private hotColor: string = '#E84026';
  private flowController: WallpaperController = new WallpaperController();
  @Param handleSearch: (value: string) => void = () => {
  };
  @Param onBack: () => void = () => {
  };

  // 页面显示时初始化数据
  aboutToAppear(): void {
    this.vm.initData();
    const params = RouterUtils.getParamByName<Record<string, string>>(RouterMap.SEARCH_PAGE);
    this.placeholderText = params?.initialKeyword ?? '';
    const searchWord = this.initialKeyword || this.defaultSearch;
    if (searchWord) {
      this.vm.searchWords = searchWord;
      this.vm.searchController.updateSearchCondition(searchWord);

      // 轮播点击不执行搜索不显示联想
      if (this.fromCarousel) {
        this.vm.isShowResult = false;
        this.vm.searchController.isShowResult = false;
        this.vm.suggestedKeywords = [];
        this.shouldShowSuggestions = false; // 轮播点击不显示联想
      } else if (searchWord.trim()) {
        // 正常搜索逻辑
        this.vm.performSearch(this.vm.searchWords);
        this.vm.isShowResult = true;
        this.vm.searchController.isShowResult = true;
        this.shouldShowSuggestions = true; // 正常搜索显示联想
      }
    }
  }

  // 排序方式切换
  handleSortChange(): void {
    this.vm.sortBy = this.vm.sortBy === 'hot' ? 'last' : 'hot';
    this.sortText = this.vm.sortBy === 'hot' ? '按热度' : '按最新';

    if (this.vm.sortBy === 'hot') {
      // 热度降序
      this.vm.filteredResults = [...this.vm.filteredResults].sort((a, b) => b.hotValue - a.hotValue);
    } else {
      // 时间降序
      this.vm.filteredResults = [...this.vm.filteredResults].sort((a, b) => b.time - a.time);
    }
  }

  async queryGuessData(tabName: string, refresh?: boolean) {
    const result: ESObject =
      await WallpaperServiceApi.getDesktopComponents(tabName, this.params.page, this.params.pageSize)
    if (refresh) {
      this.cardData = result.cardItem
    } else {
      this.cardData = this.cardData.concat(result.cardItem)
    }
    this.cardData = [...this.cardData]
    this.allTotal = result.total
    this.params.page++
  }

  async onLoad() {
    if (this.vm.searchWords === '天' || this.vm.searchWords === '气' || this.vm.searchWords === '天气') {
      await this.queryGuessData('weather')
    } else if (this.vm.searchWords === '木' || this.vm.searchWords === '鱼' || this.vm.searchWords === '木鱼') {
      await this.queryGuessData('woodenFish')
    }
  }

  // 切换标签页
  async switchTab(tabIndex: number) {
    if (this.currentTab !== tabIndex) {
      this.currentTab = tabIndex;
      this.vm.currentTab = tabIndex; // 同步到视图

      // 切换标签页时重新执行搜索
      if (this.vm.isShowResult && this.vm.searchWords.trim()) {
        this.vm.performSearch(this.vm.searchWords);
      }

      this.params.page = 1
      this.cardData = []
      if (this.vm.searchWords === '天' || this.vm.searchWords === '气' || this.vm.searchWords === '天气') {
        await this.queryGuessData('weather')
      } else if (this.vm.searchWords === '木' || this.vm.searchWords === '鱼' || this.vm.searchWords === '木鱼') {
        await this.queryGuessData('woodenFish')
      }
    }
  }

  // 获取3个壁纸数据
  getWallpaperResults(): ImageInfo[] {
    return this.vm.getFilteredResultsByTab(0).slice(0, 3);
  }

  getWidgetResults(): ImageInfo[] {
    return this.vm.getFilteredResultsByTab(2).slice(0, 3);
  }

  build() {
    NavDestination() {
      Column() {
        this.buildSearchBar()
        this.resultBuilder()
      }
      .margin({ top: 40 })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .backgroundColor(Constants.BACKGROUND_COLOR_GREY)
    }
    .hideTitleBar(true)
  }

  // 内容
  @Builder
  resultBuilder() {
    // 是否显示搜索结果切换界面
    if (this.vm.isShowResult) {
      // 显示搜索结果
      this.searchResultBuilder();
    } else {
      // 显示搜索首页内容
      Scroll() {
        Column() {
          // 非轮播点击且有联想关键词时才显示联想搜索
          if (this.vm.suggestedKeywords.length > 0 && this.shouldShowSuggestions) {
            this.suggestedKeywordsBuilder();
          } else {
            // 只有当没有联想词时才显示历史搜索、猜你喜欢、热搜榜
            HistorySearch({
              historyList: this.vm.historyList,
              handleClickItem: async (value) => {
                this.searchNewWords = value;
                this.vm.handleHistoryItemClick(value, this.getUIContext());
                this.shouldShowSuggestions = true; // 点击历史项后显示联想
                this.params.page = 1;
                this.cardData = [];
                if (this.vm.searchWords === '天' || this.vm.searchWords === '气' ||
                  this.vm.searchWords === '天气') {
                  await this.queryGuessData('weather')
                } else if (this.vm.searchWords === '木' || this.vm.searchWords === '鱼' ||
                  this.vm.searchWords === '木鱼') {
                  await this.queryGuessData('woodenFish')
                }
              },
              updateList: (list) => {
                this.vm.updateHistoryList(list);
              },
            });

            this.hotSearchBuilder();
          }
        };
      }
      .layoutWeight(1)
      .width('100%')
      .align(Alignment.Top)
      .padding({ left: 16, right: 16 });
    }
  }

  @Builder
  buildSearchBar() {
    SearchBar({
      vm: this.vm,
      placeholderText: this.placeholderText,
      autoFocus: false,
      clickBack: () => {
        if (this.vm.isShowResult) {
          this.vm.backToSearchHome(); // 返回搜索首页
          this.shouldShowSuggestions = false; // 返回时重置联想状态
        } else {
          this.routerStack.pop();
        }
      },
      updateSearchWords: (value) => {
        this.vm.updateSearchWords(value);
        // 输入文字时显示联想，删除到空时也显示联想
        if (value.trim() && this.shouldShowSuggestions) {
          this.vm.updateSuggestedKeywords(value);
        } else if (!value.trim()) {
          this.vm.suggestedKeywords = []; // 清空时隐藏联想
        }
      },
      submitSearch: () => {
        this.vm.submitSearch(this.getUIContext(), this.handleSearch);
        this.shouldShowSuggestions = false; // 提交搜索后隐藏联想
      },
      onInputFocus: () => {
        // 点击输入框时，如果有搜索词且不是轮播进入，显示联想
        if (this.vm.searchWords.trim() && !this.fromCarousel) {
          this.shouldShowSuggestions = true;
          this.vm.updateSuggestedKeywords(this.vm.searchWords);
        } else if (this.vm.searchWords.trim() && this.fromCarousel) {
          // 轮播进入且有搜索词时，点击输入框也显示联想
          this.shouldShowSuggestions = true;
          this.vm.updateSuggestedKeywords(this.vm.searchWords);
        }
      },
      searchComponent: async () => {
        this.params.page = 1
        this.cardData = []
        if (this.vm.searchWords === '天' || this.vm.searchWords === '气' || this.vm.searchWords === '天气') {
          await this.queryGuessData('weather')
        } else if (this.vm.searchWords === '木' || this.vm.searchWords === '鱼' || this.vm.searchWords === '木鱼') {
          await this.queryGuessData('woodenFish')
        }
      }
    });
  }

  @Builder
  searchResultBuilder() {
    Column() {
      // 标签页切换
      Row() {
        ForEach(['综合', '壁纸', '组件'], (tab: string, index: number) => {
          this.TabItem(tab, index);
        }, (tab: string, index: number) => tab + '_' + index)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)

      // 根据当前标签页显示不同内容
      if (this.currentTab === 0) {
        // 综合标签页，同时显示壁纸和组件
        this.comprehensiveTabBuilder();
      } else if (this.currentTab === 1) {
        // 在线标签页：只显示壁纸
        this.onlineTabBuilder();
      } else {
        // 组件标签页：只显示组件
        this.widgetTabBuilder();
      }
    }
    .layoutWeight(1)
  }

  @Builder
  TabItem(tab: string, index: number) {
    Column({ space: 7 }) {
      Text(tab)
        .fontSize(18)
        .lineHeight(21)
        .fontColor(index === this.currentTab ? '#E6000000' : '#99000000')
        .fontWeight(index === this.currentTab ? FontWeight.Bold : FontWeight.Normal)
        .onClick(() => {
          this.switchTab(index);
        });
      Text()
        .width(16)
        .height(2)
        .backgroundColor(index === this.currentTab ? '#0A59F7' : Color.Transparent)
    }
    .height(56)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  comprehensiveTabBuilder() {
    Column() {
      Scroll() {
        Column() {
          // 壁纸区域
          if (this.getWallpaperResults().length > 0) {
            this.wallpaperSectionBuilder('壁纸', this.getWallpaperResults(), 1);
          }
          // 组件区域
          Column() {
            this.widgetSectionBuilder('组件', this.getWidgetResults(), 2);
          }

          // 如果没有搜索结果，显示空状态
          if (this.getWallpaperResults().length === 0 && this.getWidgetResults().length === 0) {
            this.emptyStateBuilder();
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .layoutWeight(1)
  }

  // 壁纸标签页
  @Builder
  onlineTabBuilder() {
    if (this.vm.getFilteredResultsByTab(1).length === 0) {
      this.emptyStateBuilder();
    } else {
      Row() {
        Image($r('app.media.icon_text_and_arrow_down'))
          .width(20)
          .height(20)
          .fillColor($r('sys.color.icon_secondary'))
        Text(this.sortText)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(16)
          .lineHeight(19)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 16 })
      .onClick(() => this.handleSortChange())

      WallpaperList({
        controller: this.flowController,
        dataSource: this.vm.filteredResults, onLoad: (async () => {
          this.flowController.refreshData()
          return false
        })
      }).layoutWeight(1)
    }
  }

  // 组件标签页
  @Builder
  widgetTabBuilder() {
    if (this.cardData.length <= 0) {
      this.emptyStateBuilder();
    } else {
      Column() {
        Scroll() {
          WaterFlowComponent({
            dataSource: this.cardData,
            isLazy: false,
            finished: Math.ceil(this.allTotal / this.params.pageSize) < this.params.page,
            onLoad: async () => {
              await this.onLoad()
            },
            toComponentDetail: async (params: ComponentDetailTitle) => {
              await this.toComponentDetail(params)
            }
          })
        }
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
      }
      .visibility(this.isTargetString(this.vm.searchWords) ? Visibility.Visible : Visibility.None)
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
  }

  // 壁纸区域 只显示3张图
  @Builder
  wallpaperSectionBuilder(title: string, wallpapers: ImageInfo[], targetTab: number) {
    Column() {
      // 壁纸 + 更多
      Row() {
        Text(title)
          .fontSize(18)
          .fontColor(Constants.FONT_COLOR_LEVEL1)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('更多')
          .fontSize(14)
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            this.switchTab(targetTab); // 跳转到对应标签页
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      this.wallpageListBuilder(wallpapers);

    }
    .width('100%')
  }

  isTargetString(str: string): boolean {
    return str === '天' || str === '气' || str === '天气' || str === '木' || str === '鱼' || str === '木鱼';
  }

  async toComponentDetail(params: ComponentDetailTitle) {
    await RouterUtils.pushPathByName(RouterMap.COMPONENT_DETAIL_PAGE, params);
  }

  // 组件区域显示浅灰色占位
  @Builder
  widgetSectionBuilder(title: string, widgets: ImageInfo[], targetTab: number) {
    Column() {
      // 组件 + 更多
      Row() {
        Text(title)
          .fontSize(18)
          .fontColor(Constants.FONT_COLOR_LEVEL1)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('更多')
          .fontSize(14)
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            this.switchTab(targetTab); // 跳转到组件标签页
          })
      }
      .visibility(this.isTargetString(this.vm.searchWords) ? Visibility.Visible : Visibility.None)
      .width('100%')
      .margin({ bottom: 12 })

      //组件区域显示浅灰色占位
      Row() {
        Column() {
          Scroll() {
            WaterFlowComponent({
              dataSource: this.cardData.length >= 1 ? [this.cardData[0]] : [],
              isLazy: false,
              finished: Math.ceil(this.allTotal / this.params.pageSize) < this.params.page,
              onLoad: async () => {
                await this.onLoad()
              },
              toComponentDetail: async (params: ComponentDetailTitle) => {
                await this.toComponentDetail(params)
              }
            })
          }
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
        }
        .visibility(this.isTargetString(this.vm.searchWords) ? Visibility.Visible : Visibility.None)
        .height('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .borderRadius(8)
    }
    .width('100%')
  }

  // 空状态构建器
  @Builder
  emptyStateBuilder() {
    Column() {
      Image($r('app.media.no_search_result_found'))
        .width(120)
        .height(120)
      Text(this.getEmptyStateText())// 根据标签页显示不同数据
        .fontSize(14)
        .fontColor(Constants.FONT_COLOR_LEVEL2)
        .margin({ top: 16 })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 空状态文本
  getEmptyStateText(): string {
    switch (this.currentTab) {
      case 0: // 综合
        return '暂无相关壁纸和组件';
      case 1: // 在线
        return '暂无相关壁纸';
      case 2: // 组件
        return '暂无相关组件';
      default:
        return '暂无相关内容';
    }
  }

  // 想搜索关键词 高亮
  @Builder
  suggestedKeywordsBuilder() {
    Column() {
      ForEach(this.vm.suggestedKeywords, (keyword: string) => {
        Row() {
          Image($r('app.media.search'))
            .width(16)
            .height(16)
            .margin({ right: 8 })
            .objectFit(ImageFit.Contain);
          Text() {
            this.buildHighlightSpans(keyword, this.vm.searchWords, 16, '#000000') // 高亮
          }
          .layoutWeight(1)
          .textAlign(TextAlign.Start);
        }
        .height(30)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .padding({
          left: Constants.SPACE_M,
          right: Constants.SPACE_M,
          top: Constants.SPACE_S,
          bottom: Constants.SPACE_S
        })
        .border({
          width: { bottom: 1 },
          color: { bottom: '#F0F0F0' }
        })
        .onClick(() => {
          this.vm.updateSearchWords(keyword);
          this.vm.submitSearch(this.getUIContext(), this.handleSearch); // 直接提交搜索
        });
      }, (keyword: string, index: number) => index + '__' + keyword);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 高亮Span的方法
  @Builder
  buildHighlightSpans(text: string, query: string, baseFontSize: number = 14,
    normalColor: string = Constants.FONT_COLOR_LEVEL1) {
    if (!query || query.trim() === '') {
      Span(text)
        .fontSize(baseFontSize)
        .fontColor(normalColor)
    } else {
      ForEach(this.splitTextForHighlight(text, query), (part: string) => {
        if (part.toLowerCase() === query.toLowerCase()) {
          Span(part)
            .fontSize(baseFontSize)
            .fontColor($r('sys.color.font_emphasize')) // 高亮颜色
        } else {
          Span(part)
            .fontSize(baseFontSize)
            .fontColor(normalColor)
        }
      }, (part: string, index: number) => index + '__' + part);
    }
  }

  @Builder
  hotSearchBuilder() {
    Column() {
      Text('热搜榜')
        .fontSize(16)
        .fontColor(Constants.FONT_COLOR_LEVEL1)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      ForEach(this.vm.hotSearchList, (item: HotSearchItem, index: number) => {
        Row({ space: 16 }) {
          Text(`${index + 1} `)
            .fontSize(16)
            .width(22)
            .height(22)
            .fontColor(index < 3 ? this.hotColor : 'rgba(0,0,0,0.3)')
            .maxLines(1)
            .textAlign(TextAlign.Center)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Text(item.label)
            .fontSize(16)
            .fontColor(Constants.FONT_COLOR_LEVEL1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .height(30)
        .width('100%')
        .onClick(() => {
          this.searchNewWords = item.label;
          this.vm.handleHotSearchClick(item.label, this.getUIContext());
        });
      }, (item: HotSearchItem, index: number) => index + '__' + item.label);
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding(16)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 24 })
    .width('100%');
  }

  @Builder
  wallpageListBuilder(imagelist: ImageInfo[]) {
    Grid() {
      ForEach(imagelist, (item: ImageInfo) => {
        GridItem() {
          Stack() {
            Column() {
              Image(item.url)
                .objectFit(ImageFit.Cover)
                .width('100%')
                .aspectRatio(0.565)
                .borderRadius(6)
                .onClick(async () => {
                  try {
                    const imageInfos: ImageInfos = {
                      url: item.url, list: imagelist
                    };

                    // 跳转到详情页
                    RouterUtils.pushPathByName(RouterMap.NEW_ROUTER_MAP_WALLPAPER_DETAIL, imageInfos);
                  } catch (error) {
                  }
                })

              Row() {
                Image(item.userAvatar)
                  .width(16)
                  .height(16)
                  .margin({ right: 4 })
                  .objectFit(ImageFit.Cover)
                  .borderRadius(90)

                Text(item.userName)
                  .fontSize(10)
                  .fontColor($r('sys.color.font_secondary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
              }
              .height(16)
              .margin({ top: 2 })
            }

            if (item.isVideo) {
              Image($r('app.media.ic_live'))
                .objectFit(ImageFit.Cover)
                .width(24)
                .height(24).margin(4)
            }
          }.alignContent(Alignment.TopStart)

        }
      }, (item: object, index: number) => `${index}_${JSON.stringify(item)}}`)
    }
    .columnsTemplate('1fr 1fr 1fr')
    .columnsGap(8)
    .rowsGap(8)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring)
  }

  // 文本分割方法
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