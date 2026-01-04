// 搜索页
import { SearchPageParams, SearchView } from 'lib_product_search';
import { RouterMap, RouterUtils } from 'lib_common';

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
export struct SearchPage {
  stack: NavPathStack = RouterUtils.getStack();
  @Provider('appPathStack') appPathStack: NavPathStack = RouterUtils.getStack();
  @Local initialKeyword: string = ''; // 初始搜索关键词
  @Local fromCarousel: boolean = false; // 标识是否来自轮播点击

  // 页面显示获取传递的参数
  aboutToAppear(): void {
    const params = RouterUtils.getParamByName<SearchPageParams>(RouterMap.SEARCH_PAGE);

    this.fromCarousel = params?.fromCarousel ?? false; // 设置标识
    this.initialKeyword = params?.initialKeyword ?? '';
  }

  build() {
    NavDestination() {
      SearchView({
        routerStack: this.stack,
        // 是否来自轮播点击的标识
        fromCarousel: this.fromCarousel,
        defaultSearch: this.initialKeyword, // 传递初始关键词
        handleSearch: (value) => {
          // TODO: 可以根据需要跳转到搜索结果页面
        },
      });
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.stack.pop();
      return true; // 阻止默认返回
    });
  }
}