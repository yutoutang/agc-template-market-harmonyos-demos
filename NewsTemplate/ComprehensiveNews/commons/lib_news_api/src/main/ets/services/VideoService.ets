import { BaseNewsService, BaseNewsServiceApi } from './BaseNewsService';
import { NewsResponse } from '../params/response/NewsResponse';
import { MockVideo } from './mockdata/MockVideo';
import { BaseNews } from '../database/NewsType';
import { Utils } from '../utils/Utils';
import { MockPost } from './mockdata/MockPost';
import { NewsEnum } from '../constants/Constants';
import { PostImgList } from '../params/base/BaseModel';

/**
 * 新闻-视频类
 */
export class VideoService extends BaseNewsService {
  /**
   * 查询视频关注流
   * @returns
   */
  public queryVideoFollowList(followedUserIds: string[]): NewsResponse[] {
    const videos: NewsResponse[] = []
    followedUserIds.forEach((userId: string) => {
      const followedUserVideos = MockVideo.list
        .filter(v => v.authorId === userId)
        .map((video: BaseNews) => BaseNewsServiceApi.queryNews(video.id))
        .filter(v => Boolean(v)) as NewsResponse[];

      videos.push(...followedUserVideos)
    })
    return Utils.shuffleArray([...videos]);
  }

  /**
   * 查询视频流，如果有userId，查询对应用户的视频
   * 需要区分是纯视频还是发的动态中的视频
   * @returns
   */
  public queryVideoList(userId: string = '', type: number): NewsResponse[] {
    let list = MockVideo.list;
    if (userId) {
      if (type === NewsEnum.Video) {
        list = list.filter(v => v.authorId === userId)
      } else if (type === NewsEnum.Post) {
        const newsVideoList = MockPost.list.filter((item: BaseNews) => {
          const isVideo = item.postImgList?.some((postImgItem: PostImgList) => {
            return postImgItem.surfaceUrl && postImgItem.picVideoUrl
          });
          return isVideo
        })
        list = [...newsVideoList].filter(v => v.authorId === userId)
      }
    }
    const videos = list
      .map((video: BaseNews) => BaseNewsServiceApi.queryNews(video.id))
      .filter(v => Boolean(v)) as NewsResponse[];
    return Utils.shuffleArray([...videos]);
  }
  /**
   * 根据id查询详细信息
   * @returns
   */
  public queryVideoById(id: string): NewsResponse | undefined {
    return BaseNewsServiceApi.queryNews(id)
  }
}

const instance = new VideoService();

export { instance as VideoServiceApi };