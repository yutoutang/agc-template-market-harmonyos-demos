import { RouterMap, RouterModule } from 'router_module';
import { SearchPage } from 'search';

@ComponentV2
export struct SearchIndexPage {
  @Local inputParam: string = ''
  @Local searchSourceData: string[] =
    ['2023初级会计-初级会计实务题库', '初级会计实务', '初级会计实务真题', '初级会计实务真题', '2024初级会计经济法冲刺']

  aboutToAppear(): void {
    this.inputParam = RouterModule.getNavParam({ url: RouterMap.SEARCH_PAGE }) as string
  }

  build() {
    Column() {
      SearchPage({
        mockSearchValue: this.inputParam.length > 0 ? this.inputParam : '',
        searchSourceData: this.searchSourceData,
        initParam: () => {
        },
        clickSearchItem: (data) => {
          RouterModule.push({ url: RouterMap.GOOD_COURSE_DETAIL_PAGE, param: data })
        },
        back: () => {
          RouterModule.pop()
        },
      })
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
export function SearchPageBuilder() {
  SearchIndexPage();
}