import { mapEpisodeInfo } from '../mapper/DramaDetailMapper';
import { VideoPlayDataSource } from 'video_swiper';
import { EpisodeInfo, DramaInfo, RequestAPI } from '@agctemplate/server';
import { DetailVideoData } from '../models/DetailVideoData';
import { BaseResponse, container, Logger } from '@agctemplate/utils';
import { EpisodeListRes } from '@agctemplate/server';
import { DramaSocialInfo } from './ShortDramaDetailItemVM';

const TAG = 'DetailListVM'

export interface ContinueVideoData {
  currentIndex?: number,
  playTime?: number,
  dramaInfo: DramaInfo
}

@ObservedV2
export class ShortDramaDetailListVM {
  @Trace ready: boolean = false
  // 短剧列表
  data: VideoPlayDataSource = new VideoPlayDataSource();
  private static _instance: ShortDramaDetailListVM;
  dramaInfo: DramaInfo = new DramaInfo('')
  playTime: number = 0

  public static get instance() {
    if (!ShortDramaDetailListVM._instance) {
      ShortDramaDetailListVM._instance = new ShortDramaDetailListVM();
    }
    return ShortDramaDetailListVM._instance;
  }

  async init(continueVideoData: ContinueVideoData) {
    Logger.info(TAG, 'init')
    try {
      this.data.videoList = []
      let res: BaseResponse<EpisodeListRes> =
        await container.resolve(RequestAPI).getEpisodeList(continueVideoData.dramaInfo.id)
      let dramaListRes: EpisodeListRes = res.getBody();
      this.dramaInfo = dramaListRes.dramaInfo
      let dramaSocialInfo: DramaSocialInfo =
        new DramaSocialInfo(this.dramaInfo.id, this.dramaInfo.isFavorite, this.dramaInfo.favoriteCount,
          this.dramaInfo.isLike, this.dramaInfo.likeCount)
      let count = 0
      dramaListRes.episodeList?.map((episodeInfo: EpisodeInfo) => {
        let videoData: DetailVideoData = mapEpisodeInfo(episodeInfo)
        if(count > 10){
          videoData.videoMask.isLocked = true
        }
        count++
        videoData.videoMask.dramaInfo = this.dramaInfo
        videoData.videoMask.dramaSocialInfo = dramaSocialInfo
        this.data.pushData(videoData);
      })
      this.ready = true
      Logger.info(TAG, 'fetch episodeList success')
    } catch (e) {
      Logger.error(TAG, 'fetch episodeList failed')
    }
    if (continueVideoData?.currentIndex && continueVideoData?.playTime && continueVideoData?.playTime > 0) {
      this.setContinuePlayTime(continueVideoData.currentIndex, continueVideoData.playTime)
    }
  }
  deinit(){
    Logger.info(TAG, 'deinit')
    this.data.videoList = []
    this.dramaInfo = new DramaInfo('')
    this.playTime = 0
    this.ready = false
  }
  private setContinuePlayTime(index: number, playTime: number) {
    (this.data.videoList[index] as DetailVideoData).videoMask.playTime = playTime
  }
}