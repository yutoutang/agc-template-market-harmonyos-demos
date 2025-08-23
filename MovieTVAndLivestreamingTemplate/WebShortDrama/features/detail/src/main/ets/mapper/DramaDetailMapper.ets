import { ShortDramaDetailItemVM } from '../viewmodels/ShortDramaDetailItemVM';
import { EpisodeInfo } from '@agctemplate/server';
import { DetailVideoData } from '../models/DetailVideoData';

export function mapEpisodeInfo(episodeInfo: EpisodeInfo): DetailVideoData {
  let shortDramaDetailItemVM: ShortDramaDetailItemVM = new ShortDramaDetailItemVM()
  shortDramaDetailItemVM.url = episodeInfo?.url || ''
  shortDramaDetailItemVM.dramaInfo.id = episodeInfo?.dramaId || ''
  shortDramaDetailItemVM.dramaInfo.description = episodeInfo?.desc || ''
  shortDramaDetailItemVM.likeCount = episodeInfo?.socialInfo?.likeCount || ''
  shortDramaDetailItemVM.favoriteCount = episodeInfo?.socialInfo?.favoriteCount || ''
  shortDramaDetailItemVM.shareCount = episodeInfo?.socialInfo?.shareCount || ''
  shortDramaDetailItemVM.commentCount = episodeInfo?.socialInfo?.commentCount || ''
  shortDramaDetailItemVM.currentSerial = episodeInfo?.id || 0
  shortDramaDetailItemVM.dramaInfo.totalCount = episodeInfo?.totalCount || 0
  let videoPlayData: DetailVideoData = new DetailVideoData(shortDramaDetailItemVM)
  return videoPlayData;
}
