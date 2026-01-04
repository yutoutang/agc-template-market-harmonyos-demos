import { BaseVideo, TabType } from '../database/VideoType';
import { VideoResponse } from '../params/response/VideoResponse';
import { CommentServiceApi } from './CommentService';
import { MockVideo } from './mockdata/MockVideo';

/**
 * 视频类
 */
export class VideoService {
  /**
   * 数据库字段转换成接口字段
   * @param item
   * @returns
   */
  public handleRawNews(item: BaseVideo): VideoResponse {
    const copyItem = JSON.parse(JSON.stringify(item)) as VideoResponse;
    copyItem.commentCount = CommentServiceApi.queryTotalCommentCount(item.videoId);
    copyItem.commentList = [];
    return copyItem;
  }


  /**
   * 获取相关视频
   * @returns
   */
  public getRandomVideoList(): VideoResponse[] {
    const newsVideoList = MockVideo.list.filter(v => v.category === '热播').map(v => this.handleRawNews(v))
    return newsVideoList
  }

  /**
   * 获取全部数据列表
   * @returns
   */
  public videoList(): VideoResponse[] {
    const newsVideoList = MockVideo.list.map(v => this.handleRawNews(v))
    return newsVideoList;
  }


  /**
   * 根据TabType获取轮播数据
   * @param tabType
   * @returns
   */
  public queryVideoSwiper(tabType: TabType | string): VideoResponse[] {
    const newsVideoList = MockVideo.list.filter((item: BaseVideo) => {
      return item.tabType === tabType;
    }).map(v => this.handleRawNews(v))
    return newsVideoList;
  }

  /**
   * 获取关键字搜索
   * @param keywords
   * @returns
   */
  public searchVideoList(keywords: string): VideoResponse[] {
    const newsVideoList = MockVideo.list.filter((item: BaseVideo) => {
      return item.title.includes(keywords);

    }).map(v => this.handleRawNews(v))
    return newsVideoList;
  }

  /**
   * 根据TabType & 类型
   * @param tabType
   * @param category
   * @returns
   */
  public queryVideoListByTabType(
    tabType: TabType,
    category: '热播' | '热搜' | '必看榜' | '小朋友爱看' | '亲子互动',
    page: number,
    pageSize: number
  ): VideoResponse[] {
    // 1. 筛选出符合 tabType 和 category 的全量数据
    const filteredList = MockVideo.list.filter((item: BaseVideo) => {
      return item.tabType === tabType && item.category === category;
    });

    // 2. 分页计算：根据 page 和 pageSize 截取数据
    // 计算起始索引（页码从1开始，需转换为数组下标）
    const startIndex = (page - 1) * pageSize;
    // 计算结束索引（不超过数组长度，避免越界）
    const endIndex = Math.min(startIndex + pageSize, filteredList.length);

    // 3. 截取分页数据并转换为 VideoResponse 类型
    const paginatedList = filteredList.slice(startIndex, endIndex).map(v => this.handleRawNews(v));

    return paginatedList;
  }

  /**
   * 根据TabType & 类型
   * @param tabType
   * @param category
   * @returns
   */
  public queryCategoryListByTabType(tabType: TabType | null,
    category: '热播' | '热搜' | '必看榜' | '小朋友爱看' | '亲子互动' | null,
    videoType: '战争' | '伦理' | '年代' | '爱情' | '喜剧' | null,
    country: '中国' | '美国' | '韩国' | '日本' | '英国' | null,
    createTime: '2025' | '2024' | '2023' | '2022' | '2021' | null): VideoResponse[] {

    const newsVideoList = MockVideo.list.filter((item: BaseVideo) => {

      return (tabType === TabType.ALL || item.tabType === tabType) &&
        (category === null || item.category === category) &&
        (videoType === null || item.videoType === videoType) &&
        (country === null || item.country === country) &&
        (createTime === null || item.createTime === createTime);
    }).map(v => this.handleRawNews(v))
    return newsVideoList
  }

  /**
   * 获取推荐视频
   * @param videoType
   * @returns
   */
  public queryRecommendVideo(videoInfo: VideoResponse): VideoResponse[] {
    const newsVideoList = MockVideo.list.filter((item: BaseVideo) => {
      return item.videoType === videoInfo.videoType && item.videoId !== videoInfo.videoId
    }).map(v => this.handleRawNews(v))
    return newsVideoList
  }

  /**
   * 获取视频详情
   * @param videoId
   * @returns
   */
  public queryVideoDetail(videoId: string): VideoResponse | undefined {
    const item = MockVideo.list.find((item: BaseVideo) => {
      return item.videoId === videoId
    })
    if (item) {
      return this.handleRawNews(item);
    }
    return undefined
  }

  /**
   * 根据标题获取视频全量信息
   * @param title
   * @returns
   */
  public getVideoByTitle(title: string): VideoResponse | undefined {
    const video = MockVideo.list.find(v => v.title === title)
    if (video) {
      return this.handleRawNews(video)
    }
    return undefined
  }

  /**
   * 视频（取消）点赞
   * @param videoId
   * @param isLike
   */
  public changeLike(videoId: string, isLike: boolean) {
    MockVideo.list.forEach((item: BaseVideo) => {
      if (item.videoId === videoId) {
        if (isLike) {
          item.likeCount++
        } else {
          item.likeCount--
        }
        item.isLiked = isLike
      }
    })
  }

  /**
   * 视频（取消）收藏
   * @param videoId
   * @param isMarked
   */
  public changeMark(videoId: string, isMarked: boolean) {
    MockVideo.list.forEach((item: BaseVideo) => {
      if (item.videoId === videoId) {
        item.isMarked = isMarked
      }
    })
  }

  /**
   * 批量取消点赞
   * @param videoId
   * @param isLike
   */
  public changeLikeIds(videoId: string[], isLike: boolean) {
    MockVideo.list.forEach((item: BaseVideo) => {
      if (videoId.includes(item.videoId)) {
        // 匹配成功：更新该视频的isLiked状态
        item.isLiked = isLike;
      }
    })
  }

  /**
   * 批量取消收藏
   * @param videoId
   * @param isMark
   */
  public changeMarkIds(videoId: string[], isMark: boolean) {
    MockVideo.list.forEach((item: BaseVideo) => {
      if (videoId.includes(item.videoId)) {
        // 匹配成功：更新该视频的isLiked状态
        item.isMarked = isMark;
      }
    })
  }

  /**
   * 获取点赞列表
   * @returns
   */
  public likeList(): VideoResponse[] {
    const newsVideoList = MockVideo.list.filter((item: BaseVideo) => {
      // 直接返回isLiked为true的条件
      return item.isLiked;

    }).map(v => this.handleRawNews(v))
    return newsVideoList;
  }

  /**
   * 获取收藏列表
   * @returns
   */
  public markList(): VideoResponse[] {
    const newsVideoList = MockVideo.list.filter((item: BaseVideo) => {
      return item.isMarked;
    }).map(v => this.handleRawNews(v))
    return newsVideoList;
  }

  /**
   * 记录当前视频播放的集数和时间
   * @param videoId
   * @param index
   * @param progress
   */
  public saveCurrentInfo(videoId: string, index: number, progress: number) {
    MockVideo.list.forEach((item: BaseVideo) => {
      if (item.videoId === videoId) {
        item.currentEpisode = index
        item.currentProgress = progress
      }
    })
  }
}

const instance = new VideoService();

export { instance as VideoServiceApi };