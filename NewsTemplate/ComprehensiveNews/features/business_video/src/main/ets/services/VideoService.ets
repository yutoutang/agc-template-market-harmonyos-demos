import { AuthorServiceApi, NewsResponse, VideoServiceApi } from 'lib_news_api';
import { VideoNewsData } from '../models/VideoModel';
import Decimal from '@arkts.math.Decimal';

export class VideoService {
  private static createVideoList(list: NewsResponse[]): VideoNewsData[] {
    let tempList: VideoNewsData[] = list.map((item: NewsResponse) => {
      return new VideoNewsData(item);
    })
    return tempList
  }

  // 查询关注的用户的视频列表
  public static async queryFollowedUserVideoList(authorId: string): Promise<VideoNewsData[]> {
    // 查询当前用户关注的用户
    const list = await AuthorServiceApi.queryWatchUsers(authorId);
    const followedUserIds = list.map((v) => v.authorId);
      // 查询关注用户发布的视频
    const followedUserVideos = await VideoServiceApi.queryVideoFollowList(followedUserIds);
    let videoList: VideoNewsData[] = VideoService.createVideoList(followedUserVideos);
    return [...videoList].sort(() => Number(Decimal.random()) - 0.5);
  }

  // 查询视频流，如果有userId，查询对应用户的视频。需要区分是纯视频还是发的动态中的视频
  public static async queryVideoList(authorId: string = '', type: number = 1): Promise<VideoNewsData[]> {
    let list = await VideoServiceApi.queryVideoList(authorId, type);
    let videoList: VideoNewsData[] = VideoService.createVideoList(list);
    return [...videoList].sort(() => Number(Decimal.random()) - 0.5);
  }

  // 根据id查询视频
  public static async queryVideoDataById(id: string = ''): Promise<VideoNewsData | undefined> {
    let data = await VideoServiceApi.queryVideoById(id);
    return data ? new VideoNewsData(data) : undefined
  }

  // 查询直播banner
  public static async queryLiveBannerList(): Promise<VideoNewsData[]> {
    let list = await VideoServiceApi.queryLiveVideoList();
    let liveVideoList: VideoNewsData[] = VideoService.createVideoList(list);
    return liveVideoList.sort(() => Number(Decimal.random()) - 0.5);
  }

  // 查询精彩回放数据
  public static async queryLiveHighlights(): Promise<VideoNewsData[]> {
    let list = await VideoServiceApi.queryHighlightVideoList();
    let videoList: VideoNewsData[] = VideoService.createVideoList(list);
    let liveMockList = [...videoList].slice(0, 8)
    return liveMockList.sort(() => Number(Decimal.random()) - 0.5);
  }
}