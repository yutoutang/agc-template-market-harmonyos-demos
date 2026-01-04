/**
 * 模板搜索页面
 * 提供模板搜索功能,支持搜索历史记录和搜索结果展示
 */

import { SearchComponent } from '../comp/SearchComponent';
import { SearchController } from '../viewsmodel/SearchModel'
import { TemplateCard } from '../viewsmodel/TemplateModel';
import { phoneRouterControl } from 'oh_router'
import { RouterMap } from 'common'
import { TemplateModel } from '../viewsmodel/TemplateModel'
import { TemplateDetailPageBuilder } from './TemplateDetailPage'
import { promptAction } from '@kit.ArkUI';

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@Entry
@ComponentV2
struct SearchPage {
  @Provider('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private searchController: SearchController = SearchController.instance;
  @Local searchKey: string = '';
  @Local textWidth: number = 0;
  @Local isDelete: boolean = false;

  build() {
    NavDestination() {
      Column() {
        SearchComponent({
          appPathStack: this.appPathStack,
          historySearchBuilder: () => this.historySearch(),
          searchResultBuilder: () => this.searchResult(),
          getSearchResult: () => this.getSearchResult(),
        });
      }
      .width('100%')
      .height('100%')
      .margin({ top: 20 })
      .padding({
        left: '4%',
        right: '4%',
      });
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.appPathStack = ctx.pathStack;
      this.searchController.isShowResult = false;
      this.searchController.searchCondition = '';
      this.searchController.suggestions = [];
      this.searchController.resultList = [];
    })
  }

  @Builder
  historySearch() {
    Column() {
      Row() {
        Text('历史搜索').fontSize(16).fontColor('#919191');

        Blank();

        Row() {
          if (this.isDelete) {
            Row(){
              Image($r('app.media.ic_trash'))
                .width(14)
                .height(14)
                .margin({ right: 4 })
                .objectFit(ImageFit.Contain)
              Text('全部删除')
                .fontSize(14)
                .fontColor($r('sys.color.font_tertiary'))
            }
            .onClick(() => {
              promptAction.showDialog({
                message: '确定要清空所有搜索历史吗？',
                buttons: [
                  { text: '取消', color: $r('sys.color.font_tertiary') },
                  { text: '删除', color: '#FF0000' }
                ]
              }).then((result) => {
                if (result.index === 1) {
                  this.searchController.historySearch = [];
                  this.isDelete = false
                }
              })
            });

            Text('完成')
              .fontSize(14)
              .margin({
                left: 6
              })
              .onClick(() => {
                this.isDelete = false
              })
          } else {
            Row() {
              Image($r('app.media.ic_trash'))
                .width(14)
                .height(14)
                .margin({ right: 8 })
                .objectFit(ImageFit.Contain)
              Text('删除')
                .fontSize(14)
                .fontColor('#919191')
            }
            .onClick(() => {
              this.isDelete = true
            })
          }
        }
        .alignItems(VerticalAlign.Center)

      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.searchController.historySearch, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize(14)
                .fontColor('#99000000')
                .constraintSize({ minWidth: 36 })
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              if (this.isDelete) {
                Text('x')
                  .fontSize(18)
                  .fontColor('#99000000')
                  .margin({
                    left: 4
                  })
                  .offset({
                    bottom: 2
                  })
              }
            }
            .backgroundColor('#e5e7e9')
            .borderRadius(16)
            .height(30)
            .padding({
              left: 6,
              right: 6,
              top: 5,
              bottom: 5
            })
            .margin({
              top: 7,
              bottom: 7,
              right: 10,
            });
          }
          .onClick(() => {
            if (this.isDelete) {
              promptAction.showDialog({
                message: '确定删除该条记录吗？',
                buttons: [
                  { text: '取消', color: '#666666' },
                  { text: '删除', color: '#FF0000' }
                ]
              }).then((result) => {
                if (result.index === 1) {
                  this.searchController.deleteHistoryItem(index);
                }
              })

              return
            }
            this.searchController.searchCondition = item;
            this.searchController.isShowResult = true;
            this.searchController.updateHistorySearch(item);
            this.getSearchResult();
            if (this.searchController.resultList.length > 0) {
              // 搜索成功，清除搜索条件后返回
              this.searchController.searchCondition = '';
              this.searchController.isShowResult = false;
              phoneRouterControl.popPage();
            }
          });
        }, (item: string) => JSON.stringify(item));
      }
      .align(Alignment.Start)
      .layoutWeight(1);
    }
    .padding({
      bottom: px2vp(AppStorage.get('bottomRectHeight')),
    });
  }

  @Builder
  searchResult() {
    Column() {
      if (this.searchController.resultList.length === 0) {
        Image($r('app.media.ic_rays'))
          .width(40)
          .height(40)
          .margin({
            top: 120,
            bottom: 20
          })

        Text('暂时没有搜索到您要找的内容呢')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.40)')
      } else {
        Scroll() {
          Column() {
            Text('搜索结果')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .padding({
                top: 16,
                bottom: 16,
              });
            WaterFlow({ layoutMode: WaterFlowLayoutMode.SLIDING_WINDOW }) {
              ForEach(this.searchController.resultList, (item: TemplateCard, index: number) => {
                FlowItem() {
                  Stack() {
                    Row() {
                    }
                    .width('100%')
                    .height(226)
                    .backgroundColor(item.coverColor)
                    .borderRadius(8)
                    .border({ width: 1, color: '#E5E7E9' })

                    Text(item.name)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(226)
                  .align(Alignment.Center)
                }
                .onClick(() => {
                  TemplateModel.instance.selectedTemplate = item;
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.TEMPLATE_DETAIL_PAGE,
                    builder: wrapBuilder(TemplateDetailPageBuilder)
                  });
                })
              }, (item: TemplateCard) => JSON.stringify(item.name));
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(8)
            .columnsGap(16)
            .padding({ right: 16, left: 16 })
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          };
        }
        .scrollBar(BarState.Off);
      }

    }
    .layoutWeight(1);
  }

  getSearchResult() {
    this.searchController.search();
  }
}
