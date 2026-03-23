import { RouterMap, RouterModule } from 'commonlib';
import { SearchQuestionPage } from 'search_question';

@ComponentV2
export struct SearchInputPage {
  build() {
    Column() {
      SearchQuestionPage({
        search: (data) => {
          RouterModule.push({ url: RouterMap.SEARCH_PAGE, param: data })
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
export function SearchInputBuilder() {
  SearchInputPage();
}