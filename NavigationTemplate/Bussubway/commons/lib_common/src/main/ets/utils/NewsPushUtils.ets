import { NewsEnum } from '../constants/NewsEnum';
import { RouterMap } from '../constants/RouterMap';
import { RouterParams } from '../models/RouterParams';
import { RouterUtils } from './RouterUtils';

export class RouterToNews {
  static routerToNewsById(id: string, formType?: string) {
    let routerParams = {
      'id': id,
      'formType': formType,
    } as Record<string, string>
    RouterUtils.pushPathByName(RouterMap.NEWSDETAIL_PAGE, routerParams);
  }

  static routerToNewsByDetails<T>(cardData: T, type?: string) {
    const params: RouterParams<T> = {
      cardData: cardData,
      formType: type,
    }
    RouterUtils.pushPathByName(RouterMap.NEWSDETAIL_PAGE, params);
  }

  static pushToNewsDetails(routerParams: Record<string, string | NewsEnum>) {
    RouterToNews.routerToNewsById(routerParams.newsId as string)
  }
}
