import {
  BaseViewModel,
  CommonLoadingDialog,
  NewsEnum,
  RouterMap,
  RouterParams,
  RouterToNews,
  RouterUtils,
} from 'lib_common';
import { HomeServiceApi } from 'lib_news_api';
import { NewsPage, NewsArea, NewsSource } from 'module_digital_newspaper';

@ObservedV2
export class ENewsViewModel extends BaseViewModel {
  @Trace newspaperPages: NewsPage[] = [];
  @Trace newsSourceList: NewsSource[] = [];
  @Trace selectDate: Date = new Date();
  @Trace selectNewsSource: NewsSource = new NewsSource();
  public eNewsMap: Map<string, PixelMap> = new Map();

  queryRouteParams() {
    const map = RouterUtils.getParamByName(RouterMap.DIGITAL_NEWSPAPER) as Map<string, PixelMap>;
    if (map) {
      this.eNewsMap = map;
    }
  }

  queryNewsSourceList() {
    return HomeServiceApi.queryNewsSourceList().then((list) => {
      this.newsSourceList = list as NewsSource[];
      if (list.length) {
        this.selectNewsSource = list[0] as NewsSource;
      }
    })
  }

  queryNewspaperPages() {
    CommonLoadingDialog.show({
      loadColor: $r('sys.color.icon_on_primary'),
      textColor: $r('sys.color.font_on_primary'),
    });
    const sourceId = this.selectNewsSource.id;
    const publishDate = this.selectDate.getTime();
    HomeServiceApi.queryDigitalNewsList(sourceId, publishDate)
      .then((resp) => {
        const list = resp as NewsPage[];
        list.forEach(v => {
          const pixel = this.eNewsMap.get(v.newsImg);
          if (pixel) {
            v.preloadImg = pixel;
          }
        })
        this.newspaperPages = list;
      })
      .finally(() => {
        CommonLoadingDialog.close();
      })
  }

  onDateChange(date: Date) {
    this.selectDate = date;
    this.queryNewspaperPages();
  }

  onNewsSourceChange(source: NewsSource) {
    this.selectNewsSource = source;
    this.queryNewspaperPages();
  }

  jumpNewsDetail(area: NewsArea) {
    let routerParams: RouterParams<null> = {
      type: NewsEnum.Article,
      newsId: area.newsId,
    }
    RouterToNews.pushToNewsDetails(routerParams);
  }

  getNavStack() {
    return RouterUtils.getStack();
  }
}