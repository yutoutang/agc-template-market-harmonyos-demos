import { NewsEnum } from '../constants/NewsEnum';
import { RouterMap } from '../constants/RouterMap';
import { RouterParams } from '../models/RouterParams';
import { RouterUtils } from './RouterUtils';

export class RouterToNews {
  /**
   * 根据id跳转新闻详情页
   * @param {id} 组件id
   * @param {formType} 跳转来源
   * @param {scrollOffset}
   * */
  static routerToNewsById(id: string, formType?: string) {
    let routerParams = {
      'newsId': id,
      'formType': formType,
    } as Record<string, string | number>;
    RouterUtils.pushPathByName(RouterMap.ARTICLE_FEED_DETAILS, routerParams);
  }
  /**
   * 跳转新闻详情页
   * @param {routerParams} 跳转参数，携带一镜到底参数longTakeTransitionParam
   * */
  static pushToNewsDetails<T>(routerParams: RouterParams<T>) {
    /**
     * routerParams携带cardInfo需要携带整个数据跳转到详情页
     * routerParams携带id需要通过id跳转到详情页
     * routerParams.type或者routerParams.surfaceUrl存在则需要跳转到视频详情页
     * */
    if (routerParams.type === NewsEnum.Video || routerParams.surfaceUrl) {
      RouterUtils.pushPathByName(RouterMap.VIDEO_DETAIL_PAGE, routerParams)
      return
    }
    if (routerParams.cardData) {
      RouterUtils.pushPathByName(RouterMap.ARTICLE_FEED_DETAILS, routerParams)
      return
    }
    RouterToNews.routerToNewsById(routerParams.newsId as string, '');
  }
}
