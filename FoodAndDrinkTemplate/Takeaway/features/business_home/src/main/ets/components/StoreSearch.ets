import { RequestStoreListData, SearchParam, StoreEnum } from 'lib_takeaway_api';
import { NavHeaderBar } from 'lib_widget';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { ProductWaterFlow, RequestType } from 'lib_product_waterflow';
import { CommonConstants, Logger, MY_TAB_BAR_HOME, RouterMap, RouterUtils } from 'lib_common';
import { Highlight, TabComp } from 'lib_native_components';
import { StoreResponse } from 'lib_takeaway_api/src/main/ets/params/response/StoreResponse';
import { promptAction, PromptAction, SymbolGlyphModifier } from '@kit.ArkUI';

const TAG: string = '[HistorySearch]';

@Builder
export function StoreSearchBuilder() {
  StoreSearch()
}

@ComponentV2
export struct StoreSearch {
  @Provider() searchValue: string = ''
  @Local isSearchCommit: boolean = false;
  @Local homeViewVM: HomeViewModel = new HomeViewModel()
  @Param scroller: Scroller = new Scroller();
  controller: SearchController = new SearchController();
  @Local index: number = 0;
  @Local refreshing: boolean[] = [];
  @Local storeEnumIndex: StoreEnum[] = [StoreEnum.FOOD, StoreEnum.SUPERMARKET, StoreEnum.FRUIT, StoreEnum.PHARMACY];
  @Local isEdit: boolean = false;
  @Local defaultSearchValue: string = this.homeViewVM.searchHistory.hotSearchListLimit[0];
  @Local
  tempHistoryList: string[] = [];
  @Event
  handleClickItem: (label: string) => void;
  @Event
  updateList: (list: string[]) => void;

  async aboutToAppear() {
    this.getListView();
  }

  @Monitor('historyList')
  getListView() {
    this.tempHistoryList = this.homeViewVM.searchHistory.historyList;
  }

  @Builder
  searchBuilder(index: number) {
    Search({ value: this.searchValue, controller: this.controller, placeholder: this.defaultSearchValue })
      .cancelButton({
        style: CancelButtonStyle.CONSTANT,
        icon: new SymbolGlyphModifier($r('sys.symbol.xmark'))
      })
      .onFocus(() => {
        this.isSearchCommit = false
      })
      .onChange((value) => {
        if (value === '') {
          //每次清空,随机替换默认搜索词
          this.defaultSearchValue = this.homeViewVM.searchHistory.getRandomSixSimple()[0]
        }
        this.searchValue = value
        this.homeViewVM.searchChange(this.searchValue, false, index)
      })
      .fontColor($r('sys.color.font_primary'))
      .onSubmit(() => {
        if ((this.searchValue !== '' && this.searchValue.trim() === '')) {
          //弹出提示
          promptAction.showToast({ message: '请输入搜索内容' })
        } else if (this.searchValue === '' && this.defaultSearchValue !== '') {
          this.searchValue = this.defaultSearchValue;
        }
        this.homeViewVM.getSearchResultList(this.searchValue, index)
        this.homeViewVM.searchChange(this.searchValue, true, index)
        this.isSearchCommit = true
      })
      .defaultFocus(true)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
      .width('85%')
      .maxLength(20)
  }

  @Builder
  historySearch() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('历史搜索')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
        if (!this.isEdit) {
          Row({ space: 5 }) {
            Image($r('app.media.clear')).width(16).height(16)
            Text('删除')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
          }
          .onClick(() => {
            this.isEdit = true;

          })
        } else {
          Row() {
            Text('全部删除')
              .fontSize(14)
              .onClick(() => {
                this.deleteAll();
              });
            Divider()
              .height(16)
              .vertical(true)
              .width(1)
              .backgroundColor($r('sys.color.black'))
              .margin({ left: CommonConstants.SPACE_S, right: CommonConstants.SPACE_S });

            Text('完成')
              .fontSize(14)
              .onClick(() => {
                this.updateList?.(this.tempHistoryList);
                this.isEdit = false;
                this.homeViewVM.searchHistory.historyList = this.tempHistoryList;
              });
          };
        }
      }.visibility(this.homeViewVM.searchHistory.historyList.length <= 0 ? Visibility.None : Visibility.Visible)

      Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        ForEach(this.tempHistoryList, (item: string) => {
          this.historyItemBuilder(item);
        }, (item: string, index: number) => item)
      }
      .margin({ top: 12, bottom: 12 })
    }
    .padding({ left: 16, right: 16 })
    .margin({ top: 16 })
    .visibility(this.homeViewVM.searchHistory.historyList.length <= 0 ? Visibility.None : Visibility.Visible)
  }

  @Builder
  hotSearch() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('猜你想搜')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
        Row({ space: 5 }) {
          Image($r('app.media.flush')).width(16).height(16)
        }
        .onClick(() => {
          this.homeViewVM.searchHistory.getRandomSixSimple()
        })
      }

    }
    .padding({ left: 16, right: 16 })
    .margin({ top: 16 })
  }

  @Builder
  searchResultListBuilder(searchValue: string, index: number) {
    TabComp({
      tabBar: MY_TAB_BAR_HOME,
      index: index,
      contentUi: (index: number) => {
        this.tabContentBuilder(index, searchValue);
      },
    }).visibility(this.isSearchCommit ? Visibility.Visible : Visibility.None)

  }

  @Builder
  searchListBuilder() {
    List({ space: 21 }) {
      ListItem() {
        Column() {
          Image($r('app.media.search_no_result')).width(120).height(120)
          Text('暂无搜索结果')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }
      }
      .visibility(this.homeViewVM.searchStoreResultList.length <= 0 ? Visibility.Visible : Visibility.None)
      .width('100%')
      .height('100%')

      ForEach(this.homeViewVM.searchStoreResultList, (item: RequestStoreListData) => {
        ForEach(item.articles, (value: StoreResponse) => {
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
                sourceString: value.name,
                textFontWeight: FontWeight.Medium,
                maxLines: 1,
                highLightColor: $r('app.color.app_theme'),
                overflow: TextOverflow.Ellipsis,
              })
                .flexGrow(1)
            }
          }
          .onClick(() => {
            this.searchValue = value.name
            this.homeViewVM.getSearchResultList(this.searchValue, this.index)
            //保存历史记录
            this.homeViewVM.searchChange(this.searchValue, true, this.index)
            this.controller.stopEditing()
            this.isSearchCommit = true
          })
          .visibility(this.homeViewVM.searchStoreResultList.length <= 0 ? Visibility.None : Visibility.Visible)
        })
      }, (item: StoreResponse, index: number) => JSON.stringify(item))
    }
    .visibility(this.isSearchCommit ? Visibility.None : Visibility.Visible)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({ left: 16, right: 16 })
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .cachedCount(1)
  }

  @Builder
  hotSearchResult() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        ForEach(this.homeViewVM.searchHistory.hotSearchListLimit, (item: string) => {
          Row() {
            Text(item)
              .fontSize(14)
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
            this.homeViewVM.getSearchResultList(this.searchValue, this.index)
            //保存历史记录
            this.homeViewVM.searchChange(this.searchValue, true, this.index)
            this.controller.stopEditing()
            this.isSearchCommit = true
          })
          .margin({ right: 12, bottom: 12 })
          .borderRadius(14)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
        }, (item: string, index: number) => item)
      }
      .margin({ top: 12, bottom: 12 })
    }.padding({ left: 16, right: 16 })
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        rightPartBuilder: () => {
          this.searchBuilder(this.index)
        },
      })
      Column() {
        if (this.searchValue.trim() !== '') {
          this.searchListBuilder()
          this.searchResultListBuilder(this.searchValue.trim(), this.index)
        } else {
          this.historySearch()
          this.hotSearch()
          this.hotSearchResult()
        }
      }
      .layoutWeight(1)
    }
    .padding({ bottom: this.homeViewVM.windowModel.windowBottomPadding })
    .hideTitleBar(true)
    .onReady((context) => {
      let searchParam = context.pathInfo.param as SearchParam
      if (searchParam) {
        this.index = searchParam.index
        this.defaultSearchValue =
          searchParam.searchValue ? searchParam.searchValue : this.homeViewVM.searchHistory.hotSearchListLimit[0];
      }
    })
  }

  @Builder
  tabContentBuilder(index: number, searchValue: string) {
    ProductWaterFlow({
      bgColor: Color.Transparent,
      changeByThreshold: 0,
      scoreThreshold: this.homeViewVM.scoreThreshold,
      salesThreshold: this.homeViewVM.salesThreshold,
      address: this.homeViewVM.settingInfo.address,
      showInitLoading: true,
      categoryId: index === 0 ? undefined : this.storeEnumIndex[index-1].toString(),
      deliveryTimeThreshold: this.homeViewVM.deliveryTimeThreshold,
      requestType: RequestType.BY_WORDS,
      keywords: searchValue,
      customColumnTemplate: '1fr 1fr',
      handleProductClick: (id) => {
        RouterUtils.pushPathByName(RouterMap.STORE_PAGE, id)
      },
      handleBack: () => {
        this.scroller.scrollEdge(Edge.Top);
      },
    })
      .align(Alignment.Top)
      .padding({ top: 8, left: 12, right: 12 })
  }

  @Builder
  historyItemBuilder(item: string) {
    if (this.isEdit) {
      Row() {
        Row() {
          Text(item)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Image($r('app.media.ic_close'))
            .fillColor($r('app.color.app_yellow'))
            .width(16)
            .height(16)
            .margin({ left: CommonConstants.SPACE_XS })
            .onClick(() => {
              this.tempHistoryList = this.tempHistoryList.filter((it) => it !== item);
            });

        }
      }
      .backgroundColor(CommonConstants.BACKGROUND_COLOR_GREY_2)
      .padding(CommonConstants.SPACE_S)
      .borderRadius(CommonConstants.BORDER_RADIUS_CAPSULE)
      .borderRadius(14)
      .padding({
        left: 12,
        right: 12,
        top: 4,
        bottom: 4,
      })
      .margin({ right: 12, bottom: 12 })
    } else {
      Row() {
        Row() {
          Text(item)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

        }
      }
      .backgroundColor(CommonConstants.BACKGROUND_COLOR_GREY_2)
      .padding(CommonConstants.SPACE_S)
      .borderRadius(CommonConstants.BORDER_RADIUS_CAPSULE)
      .borderRadius(14)
      .padding({
        left: 12,
        right: 12,
        top: 4,
        bottom: 4,
      })
      .margin({ right: 12, bottom: 12 })

      .onClick(() => {
        this.searchValue = item
        this.homeViewVM.getSearchResultList(this.searchValue, this.index)
        this.controller.stopEditing()
        this.isSearchCommit = true
        if (this.isEdit) {
          return;
        }
        this.handleClickItem?.(item);
      });
    }
  }

  deleteAll() {
    let uiContext = this.getUIContext();
    let promptAction: PromptAction = uiContext.getPromptAction();
    try {
      promptAction.showDialog({
        message: '确定要清空所有搜索历史吗？',
        buttons: [
          {
            text: '取消',
            color: CommonConstants.FONT_COLOR_LEVEL2,
          },
          {
            text: '删除',
            color: $r('app.color.app_theme'),
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
          this.homeViewVM.clearHistory()
        }
      });
    } catch (error) {
      Logger.error(TAG, 'open dialog failed. error:' + JSON.stringify(error));
    }
  }
}
