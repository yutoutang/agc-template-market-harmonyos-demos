import { AppStorageV2, curves, PersistenceV2 } from '@kit.ArkUI';
import { FlexLayoutBreakPointVM, FlexLayoutPage } from 'lib_flex_layout';
import { HomeServiceApi, NewsResponse, RequestListData } from 'lib_news_api';
import { Highlight } from 'module_highlight';
import { BreakpointModel, CircleButtonModifier, CommonConstants, SettingModel, WindowModel } from 'lib_common';
import { LongTakeAnimationProperties } from 'module_transition';
import { HomeViewModel } from '../viewmodels/HomeViewModel';

@Builder
export function NewsSearchBuilder() {
  NewsSearch()
}

@ComponentV2
export struct NewsSearch {
  @Local searchValue: string = ''
  @Local hotDataList: RequestListData[] = []
  @Local isSearchCommit: boolean = false;
  @Local homeViewVM: HomeViewModel = new HomeViewModel()
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local homeViewModel: HomeViewModel = new HomeViewModel();
  controller: SearchController = new SearchController();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local componentId: string = ''
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  buttonModifier: CircleButtonModifier = new CircleButtonModifier();

  async aboutToAppear() {
    this.hotDataList = await HomeServiceApi.queryHomeRecommendList('hotTopChart');
  }

  @Builder
  searchBuilder() {
    Search({ value: this.searchValue, controller: this.controller })
      .cancelButton({
        style: CancelButtonStyle.CONSTANT,
      })
      .geometryTransition('news_search_transition_' + this.componentId)
      .transition(TransitionEffect.opacity(0.99))
      .onFocus(() => {
        this.isSearchCommit = false
      })
      .onChange((value) => {
        this.searchValue = value
        this.homeViewVM.searchChange(this.searchValue)
      })
      .fontColor($r('sys.color.font_primary'))
      .onSubmit(() => {
        this.homeViewVM.getSearchResultList(this.searchValue)
        this.isSearchCommit = true
      })
      .defaultFocus(true)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
      .flexGrow(1)
  }

  @Builder
  historySearch() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('历史搜索')
          .fontSize(14 * this.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_secondary'))
        Row({ space: 4 }) {
          Image($r('app.media.clear')).width(16).height(16)
          Text('清空')
            .fontSize(14 * this.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
        }
        .onClick(() => {
          this.homeViewVM.clearHistory()
        })
      }

      Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        Row() {
          Text('暂无历史搜索')
            .fontSize(12 * this.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
        }
        .visibility(this.homeViewVM.searchHistory.historyList.length <= 0 ? Visibility.Visible : Visibility.None)
        .width('100%')
        .justifyContent(FlexAlign.Center)

        ForEach(this.homeViewVM.searchHistory.historyList, (item: string) => {
          Row() {
            Text(item)
              .fontSize(14 * this.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .padding({
            left: 12,
            right: 12,
            top: 4,
            bottom: 4,
          })
          .onClick(() => {
            this.searchValue = item
            this.homeViewVM.getSearchResultList(this.searchValue)
            this.controller.stopEditing()
            this.isSearchCommit = true
          })
          .margin({ right: 12, bottom: 12 })
          .borderRadius(14)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .visibility(this.homeViewVM.searchHistory.historyList.length <= 0 ? Visibility.None : Visibility.Visible)
        }, (item: string) => item)
      }
      .margin({ top: 12, bottom: 12 })
    }
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .margin({ top: 16 })
  }

  @Builder
  searchResultListBuilder() {
    List() {
      if (this.homeViewVM.searchResultList.length <= 0) {
        ListItem() {
          Column() {
            Image($r('app.media.search_no_result')).width(120).height(120)
            Text('暂无搜索结果')
              .fontSize(14 * this.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        .width('100%')
        .height('100%')
      } else {
        ForEach(this.homeViewVM.searchResultList, (item: RequestListData) => {
          ListItem() {
            FlexLayoutPage({
              setting: JSON.parse(item.navInfo.setting),
              articles: item.articles,
              extraInfo: { 'searchKey': this.searchValue },
            })
          }
        }, (item: RequestListData) => JSON.stringify(item))
      }
    }
    .lanes(new FlexLayoutBreakPointVM().lanesCount.getLanes(), 16)
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({ left: CommonConstants.PADDING_L, right: CommonConstants.PADDING_L })
    .visibility(this.isSearchCommit ? Visibility.Visible : Visibility.None)
  }

  @Builder
  searchListBuilder() {
    List({ space: 21 }) {
      ListItem() {
        Column() {
          Image($r('app.media.search_no_result')).width(120).height(120)
          Text('暂无搜索结果')
            .fontSize(14 * this.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
        }
      }
      .visibility(this.homeViewVM.searchResultList.length <= 0 ? Visibility.Visible : Visibility.None)
      .width('100%')
      .height('100%')

      ForEach(this.homeViewVM.searchResultList, (item: RequestListData) => {
        ForEach(item.articles, (value: NewsResponse) => {
          ListItem() {
            Flex() {
              Row() {
                Image($r('app.media.search')).width(14).height(14)
                  .fillColor($r('sys.color.font_primary'))
              }
              .width(30)
              .height(18)
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center)

              Highlight({
                keywords: [this.searchValue],
                sourceString: value.title,
                textFontWeight: FontWeight.Medium,
                maxLines: 1,
                highLightColor: $r('app.color.app_theme'),
                overflow: TextOverflow.Ellipsis,
              })
                .flexGrow(1)
            }
          }
          .onClick(() => {
            this.homeViewVM.getSearchResultList(this.searchValue)
            this.controller.stopEditing()
            this.isSearchCommit = true
          })
          .visibility(this.homeViewVM.searchResultList.length <= 0 ? Visibility.None : Visibility.Visible)
        }, (value: NewsResponse) => JSON.stringify(value))
      }, (item: NewsResponse) => JSON.stringify(item))
    }
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .visibility(this.isSearchCommit ? Visibility.None : Visibility.Visible)
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .cachedCount(1)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  hotTopChartList() {
    List() {
      ListItem() {
        Row({ space: 5 }) {
          Image($r('app.media.hot_chart')).width(16).height(20)
          Text('热搜榜')
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(18 * this.settingInfo.fontSizeRatio)
        }
      }.padding({ left: this.breakPointModel.pagePadding })

      ForEach(this.hotDataList, (item: RequestListData) => {
        ListItem() {
          FlexLayoutPage({
            setting: JSON.parse(item.navInfo.setting),
            articles: item.articles,
            extraInfo: item.extraInfo,
          })
        }
        .padding({
          left: CommonConstants.PADDING_L,
          right: CommonConstants.PADDING_L,
        })
      }, (item: RequestListData) => JSON.stringify(item))
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .cachedCount(1)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  build() {
    NavDestination() {
      Column() {
        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Column() {
            Button() {
              SymbolGlyph($r('sys.symbol.chevron_backward'))
                .fontColor([$r('sys.color.font_primary')])
                .fontWeight(FontWeight.Normal)
                .fontSize($r('app.float.normal_img_size'))
            }
            .attributeModifier(this.buttonModifier)
            .accessibilityText('返回')
          }
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.homeViewModel.onLongTakeSearchBack(this.getUIContext());
          })
          .transition(TransitionEffect.asymmetric(
            TransitionEffect.OPACITY
              .animation({ duration: 200, delay: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1) }),
            TransitionEffect.OPACITY
              .animation({ duration: 200, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1) }),
          ))
          .margin({ right: 16 })

          this.searchBuilder()
        }
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding,
        })
        .width('100%')
        .height(50)

        if (this.searchValue.trim() !== '') {
          this.searchListBuilder()
          this.searchResultListBuilder()
        } else {
          this.historySearch()
          this.hotTopChartList()
        }
      }
      .backgroundColor($r('sys.color.background_primary'))
    }
    .padding({
      top: this.windowModel.windowTopPadding,
    })
    .transition(TransitionEffect.OPACITY)
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.componentId = context.pathInfo?.param as string
    })
    .onBackPressed(() => {
      this.homeViewModel.onLongTakeSearchBack(this.getUIContext())
      return true;
    })
  }
}