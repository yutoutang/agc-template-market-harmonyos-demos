/**
 * 搜索组件
 * 用于模板搜索页面,支持搜索历史、搜索结果展示、关键词高亮等功能
 */

import { SearchController } from '../viewsmodel/SearchModel'
import { TemplateCard } from '../viewsmodel/TemplateModel'
import { phoneRouterControl } from 'oh_router'
import { GlobalContext } from 'common';

interface TextSegment {
  text: string
  matched: boolean
}

@ComponentV2
export struct SearchComponent {
  private searchController: SearchController = SearchController.instance;
  @Param @Require appPathStack: NavPathStack;
  @Local searchCondition: string = '';
  @BuilderParam historySearchBuilder: VoidCallback;
  @BuilderParam searchResultBuilder: VoidCallback;
  @Param @Require getSearchResult: VoidCallback;
  @Local textWidth: number = 0;

  private getHighlightSegments(full: string, keyword: string): Array<TextSegment> {
    if (!keyword) {
      return [{ text: full, matched: false }]
    }
    const parts: Array<string> = full.split(keyword)
    const segments: Array<TextSegment> = []
    for (let i = 0; i < parts.length; i++) {
      if (parts[i]) {
        segments.push({ text: parts[i], matched: false })
      }
      if (i < parts.length - 1) {
        segments.push({ text: keyword, matched: true })
      }
    }
    return segments
  }

  @Monitor('searchController.searchCondition')
  searchConditionMonitor(monitor: IMonitor) {
    this.searchCondition = monitor.value()?.now as string;
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(40)
          .onClick(() => {
            this.searchController.isShowResult = false;
            this.appPathStack.pop();
          });
        Blank();
        Search({
          placeholder: '请输入搜索内容',
          value: $$this.searchCondition,
        })
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .layoutWeight(1)
          .margin({
            left: '4%',
            right: '4%',
          })
          .onChange((searchCondition: string) => {
            this.searchController.searchCondition = searchCondition;
            if (searchCondition === '') {
              this.searchController.isShowResult = false;
              this.searchController.suggestions = [];
              return;
            }
            this.searchController.updateSuggestions(searchCondition);
          })
          .onSubmit((searchCondition: string) => {
            if (searchCondition === undefined || searchCondition === '') {
              GlobalContext.getUIContext().getPromptAction().showToast({
                message: '请输入搜索内容',
                duration: 1000,
              });
              return;
            }

            this.searchController.updateHistorySearch(searchCondition);
            this.searchController.searchCondition = searchCondition;
            this.getSearchResult();
            if (this.searchController.resultList.length > 0) {
              // 搜索成功，清除搜索条件后返回
              this.searchController.searchCondition = '';
              this.searchController.isShowResult = false;
              phoneRouterControl.popPage();
            }
          });

        Blank();
        Text('搜索')
          .fontSize($r('sys.float.Body_M'))
          .fontColor('#0A59F7')
          .onClick(() => {
            if (this.searchCondition === undefined ||
              this.searchCondition === '') {
              GlobalContext.getUIContext().getPromptAction().showToast({
                message: '请输入搜索内容',
                duration: 1000,
              });
              return;
            }
            this.searchController.isShowResult = true;
            this.searchController.searchCondition = this.searchCondition;
            this.searchController.updateHistorySearch(this.searchCondition);
            this.getSearchResult();
            if (this.searchController.resultList.length > 0) {
              // 搜索成功，清除搜索条件后返回
              this.searchController.searchCondition = '';
              this.searchController.isShowResult = false;
              phoneRouterControl.popPage();
            }
          });
      }
      .width('100%');

      if (!this.searchController.isShowResult) {
        if (this.searchController.searchCondition !== '') {
          Column({ space: 0 }) {
            ForEach(this.searchController.suggestions, (item: TemplateCard, index: number) => {
              Column() {
                Row() {
                  Text() {
                    ForEach(
                      this.getHighlightSegments(item.name, this.searchController.searchCondition),
                      (seg: TextSegment) => {
                        Span(seg.text)
                          .fontSize(14)
                          .fontColor(seg.matched ? '#0A59F7' : '#99000000')
                      },
                      (seg: TextSegment) => JSON.stringify(seg.text + seg.matched)
                    )
                  }
                }
                .width('100%')
                .padding({ left: 5 })
                .height(50)
                .onClick(() => {
                  this.searchController.searchFromSuggestion(item.name);
                  this.getSearchResult();
                  if (this.searchController.resultList.length > 0) {
                    // 搜索成功，清除搜索条件后返回
                    this.searchController.searchCondition = '';
                    this.searchController.isShowResult = false;
                    phoneRouterControl.popPage();
                  }
                })

                if (index < this.searchController.suggestions.length - 1) {
                  Divider()
                    .strokeWidth('1px')
                }
              }
            }, (item: TemplateCard) => JSON.stringify(item.name));
          }
          .padding({ top: 10 });
        } else {
          Column({ space: 30 }) {
            this.historySearchBuilder();
          }
          .padding({
            top: 20,
          });
        }
      } else {
        this.searchResultBuilder();
      }
    }
    .width('100%')
    .height('100%');
  }
}
