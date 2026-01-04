import { SearchComponent, SearchController } from 'search_box';
import {
  getMockPositionList,
  PositionCard,
  PositionInfo,
  getMockCompanyList,
  CompanyCard,
  CompanyInfo,
  RouterMap,
  BarVM
} from 'common';
import { phoneRouterControl } from 'oh_router';
import { ProtocolRouterParams } from 'aggregated_login';
import { PositionDetailPageBuilder } from './PositionDetailPage';
import { CompanyDetailPageBuilder } from './CompanyDetailPage';
import { promptAction } from '@kit.ArkUI';

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
struct SearchPage {
  @Provider('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private searchController: SearchController = SearchController.instance;
  @Local searchKey: string = '';
  @Local allPositions: PositionInfo[] = getMockPositionList();
  @Local filteredPositions: PositionInfo[] = [];
  @Local allCompanies: CompanyInfo[] = getMockCompanyList();
  @Local filteredCompanies: CompanyInfo[] = [];
  @Local selectedTab: number = 0;

  returnRoute() {
    phoneRouterControl.popPage();
  }

  getSearchResult() {
    const keyword = this.searchController.searchCondition.toLowerCase();
    this.filteredPositions = this.allPositions.filter(item =>
    item.jobTitle.toLowerCase().includes(keyword) ||
    item.companyName.toLowerCase().includes(keyword) ||
    item.location.toLowerCase().includes(keyword)
    );
    this.filteredCompanies = this.allCompanies.filter(item =>
    item.companyName.toLowerCase().includes(keyword) ||
    item.industry.toLowerCase().includes(keyword)
    );
  }

  build() {
    NavDestination() {
      Column() {
        SearchComponent({
          onClickBack: this.returnRoute,
          hotSearchBuilder: () => {
            this.hotSearch()
          },
          historySearchBuilder: () => {
            this.historySearch()
          },
          searchResultBuilder: () => {
            this.searchResult()
          },
          getSearchResult: () => {
            this.getSearchResult()
          },
        });
      }
      .width('100%')
      .height('100%')
      .margin({ top: 20 })
      .padding({
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
    }
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  hotSearch() {
  }

  @Builder
  historySearch() {
    Column() {
      Row() {
        Text('搜索历史').fontSize(16).fontColor('rgba(0,0,0,0.90)');

        Blank();

        Image($r('app.media.ic_trash'))
          .width(16)
          .height(16)
          .onClick(() => {
            try {
              promptAction.showDialog({
                message: '确定要清空所有搜索历史吗？',
                buttons: [
                  { text: '取消', color: '#666666' },
                  { text: '删除', color: '#FF0000' }
                ]
              }).then((result) => {
                if (result.index === 1) {
                  this.searchController.historySearch = [];
                }
              })
            } catch (error) {
            }
          });
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      List() {
        ForEach(this.searchController.historySearch, (item: string, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Image($r('app.media.icon_history'))
                  .width(16);

                Text(item)
                  .fontSize(14)
                  .fontColor('rgba(0,0,0,0.60)')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .padding({
                    left: '4%',
                  })
                  .width('82%');

                Blank();

                Row() {
                  SymbolGlyph($r('sys.symbol.xmark'))
                    .fontSize(16)
                    .fontColor(['rgba(0,0,0,0.60)'])
                    .onClick(() => {
                      try {
                        promptAction.showDialog({
                          message: '确定删除该条记录吗？',
                          buttons: [
                            { text: '取消', color: '#666666' },
                            { text: '删除', color: '#FF0000' }
                          ]
                        }).then((result) => {
                          if (result.index === 1) {
                            this.searchController.historySearch.splice(index, 1);
                          }
                        })
                      } catch (error) {
                      }
                    });
                }
                .width('10%')
                .justifyContent(FlexAlign.End);
              }
              .height(25)
              .width('100%')
              .margin({
                top: 7,
                bottom: 7,
              });
            }
            .onClick(() => {
              this.searchController.searchCondition = item;
              this.searchController.isShowResult = true;
              this.searchController.updateHistorySearch(item);
              this.getSearchResult();
            });
          };
        }, (item: string) => JSON.stringify(item));
      }
      .divider({
        strokeWidth: 1
      })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .layoutWeight(1);
    }
    .padding({
      left: '4%',
      right: '4%',
      bottom: px2vp(AppStorage.get('bottomRectHeight')),
    });
  }

  @Builder
  searchResult() {
    Column() {
      // Tab 切换
      Row() {
        Text('职位')
          .fontSize(16)
          .fontColor(this.selectedTab === 0 ? '#333333' : '#999999')
          .fontWeight(this.selectedTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .padding({ bottom: 12 })
          .border({
            width: { bottom: this.selectedTab === 0 ? 2 : 0 },
            color: '#5B6FFF'
          })
          .onClick(() => this.selectedTab = 0)

        Text('公司')
          .fontSize(16)
          .fontColor(this.selectedTab === 1 ? '#333333' : '#999999')
          .fontWeight(this.selectedTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .padding({ bottom: 12 })
          .border({
            width: { bottom: this.selectedTab === 1 ? 2 : 0 },
            color: '#5B6FFF'
          })
          .margin({ left: 32 })
          .onClick(() => this.selectedTab = 1)
      }
      .width('100%')
      .padding({ top: 16 })
      .backgroundColor('#fff')
      .padding({
        top: 20,
        left: '4%',
        right: '4%',
      })

      // 内容区域
      Row() {
        if (this.selectedTab === 0) {
          this.positionList()
        } else {
          this.companyList()
        }
      }.padding({
        left: '4%',
        right: '4%',
        bottom: 20
      })
      .margin({ top: 8 })
      .layoutWeight(1)
    }
    .layoutWeight(1)
    .width('100%')
    .backgroundColor('#FFF1F3F5')
  }

  @Builder
  positionList() {
    Column() {
      if (this.filteredPositions.length === 0) {
        Column() {
          Image($r('app.media.ic_no_search_result_found'))
            .width(120)
            .height(120)
            .margin({ top: 120 })

          Text('暂时没有搜索到您要找的内容呢')
            .fontSize(14)
            .fontColor('rgba(0,0,0,0.40)')
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        Column() {
          List({ space: 12 }) {
            ForEach(this.filteredPositions, (item: PositionInfo) => {
              ListItem() {
                PositionCard({ positionInfoData: item })
                  .onClick(() => {
                    phoneRouterControl.jumpPage({
                      pageName: RouterMap.POSITION_DETAIL_PAGE,
                      param: {
                        content: item.id,
                        isSheet: false,
                      } as ProtocolRouterParams,
                      builder: wrapBuilder(PositionDetailPageBuilder),
                    })
                  })
              }
            }, (item: PositionInfo) => item.id)
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  companyList() {
    Column() {
      if (this.filteredCompanies.length === 0) {
        Column() {
          Image($r('app.media.ic_no_search_result_found'))
            .width(120)
            .height(120)
            .margin({ top: 120 })

          Text('暂时没有搜索到您要找的内容呢')
            .fontSize(14)
            .fontColor('rgba(0,0,0,0.40)')
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        Column() {
          List({ space: 12 }) {
            ForEach(this.filteredCompanies, (item: CompanyInfo) => {
              ListItem() {
                CompanyCard({ companyInfoData: item })
                  .onClick(() => {
                    phoneRouterControl.jumpPage({
                      pageName: RouterMap.COMPANY_DETAIL_PAGE,
                      param: {
                        content: item.id,
                        isSheet: false,
                      } as ProtocolRouterParams,
                      builder: wrapBuilder(CompanyDetailPageBuilder),
                    })
                  })
              }
            }, (item: CompanyInfo) => item.id)
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}

