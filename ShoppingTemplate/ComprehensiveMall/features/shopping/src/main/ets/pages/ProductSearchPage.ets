import { cache, RouterMap, routerStack } from 'lib_foundation';
import { SearchView } from 'module_product_search';

@Builder
export function buildProductSearchPage() {
  ProductSearchPage();
}

@ComponentV2
struct ProductSearchPage {
  build() {
    NavDestination() {
      SearchView({
        defaultSearch: cache.search.placeholder,
        routerStack: routerStack,
        handleSearch: (value) => {
          cache.search.lastSubmit = value;
          routerStack.pushPath({ name: RouterMap.PRODUCT_SEARCH_RESULTS }, false);
        },
      });
    }
    .hideTitleBar(true);
  }
}