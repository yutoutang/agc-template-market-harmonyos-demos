import { BaseViewModel } from 'lib_common';
import { CommentServiceApi, NewsResponse } from 'lib_news_api';
import { MakeObCommentServed, CommentInfo } from 'lib_news_feed_details';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';
import { TabNav } from '../models/VideoModel';

@ObservedV2
export class LivestreamDetailPageVM extends BaseViewModel {
  tabController: TabsController = new TabsController();
  tabNavs: TabNav[] = [
    new TabNav('introduction', '介绍', $r('app.color.color_tab_blue')),
    new TabNav('comment', '评论', $r('app.color.color_tab_blue')),
  ]
  @Trace livestreamInfo: NewsResponse = {} as NewsResponse;
  @Trace commentList: CommentInfo[] = [];
  // 当前tab下标
  @Trace currentTabIndex: number = 0;
  // 当前indicator的下标
  @Trace indicatorIndex: number = 0;

  async init() {
    let commentInfo = await CommentServiceApi.queryCommentList(this.livestreamInfo.id) as CommentInfo[]
    this.commentList = commentInfo?.map((value: CommentInfo) => {
      return new MakeObCommentServed(value)
    }) ?? [];
  }

  // 初始化一镜到底参数
  registerCustomTransition(longTakeSession: LongTakeAnimationProperties, context: NavDestinationContext) {
    let longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;
    let param = context.pathInfo?.param as Record<string, Object>;
    longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
    if (longTakeTransitionParam) {
      longTakeSession.init(context, longTakeTransitionParam, {
        pop: () => {
          context.pathStack.pop()
        },
      });
    }
  }

  handleAnimationStart(_index: number, targetIndex: number) {
    this.indicatorIndex = targetIndex;
  }
}