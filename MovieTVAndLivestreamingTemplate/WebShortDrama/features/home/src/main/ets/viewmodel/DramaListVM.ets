import { RequestAPI } from '@agctemplate/server';
import { DramaInfo } from '@agctemplate/server';
import { FeedDramaListRes } from '@agctemplate/server';
import { appRouter, BaseResponse, container, Logger } from '@agctemplate/utils';
import { PlayController, VideoPlayDataSource } from 'video_swiper';
import { mapDramaItem } from '../mapper/DramaInfoMapper';
import { AppStorageV2 } from '@kit.ArkUI';
import { NAV_PAGE_NAME } from '@agctemplate/resources';
import { ContinueModel } from '@agctemplate/widgets';

const TAG = 'DramaListVM'

@ObservedV2
export class DramaListVM {
  @Trace ready: boolean = false
  @Trace continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  data: VideoPlayDataSource = new VideoPlayDataSource()

  @Monitor('continueModel.id')
  onContinueSceneChange() {
    this.checkContinueScene();
  }

  async init() {
    try {
      let res: BaseResponse<FeedDramaListRes> = await container.resolve(RequestAPI).getFeedDramaList({
        pageSize: 1,
        pageNum: 20
      })
      let dramaListRes: FeedDramaListRes = new FeedDramaListRes(res.getBody());
      dramaListRes.feedDramaList?.map((dramaInfo: DramaInfo) => {
        this.data.pushData(mapDramaItem(dramaInfo));
      })
      this.ready = true
    } catch (e) {
      Logger.error(TAG, 'fetch dramaList failed')
    }
  }

  async refresh() {
    try {
      let res: BaseResponse<FeedDramaListRes> = await container.resolve(RequestAPI).getFeedDramaList({
        pageSize: 1,
        pageNum: 20
      })
      let dramaListRes: FeedDramaListRes = new FeedDramaListRes(res.getBody());
      this.data.replaceData(dramaListRes.feedDramaList?.map((dramaInfo: DramaInfo) => {
       return mapDramaItem(dramaInfo)
      }))
      this.ready = true
    } catch (e) {
      Logger.error(TAG, 'fetch dramaList failed')
    }
  }

  async checkContinueScene() {
    if (this.continueModel.id && this.continueModel.dramaId) {
      appRouter.push({
        builderName: NAV_PAGE_NAME.ShortDramaDetailPage.name,
        params: {
          currentIndex: this.continueModel.currentIndex,
          playTime: this.continueModel.playTime,
          dramaInfo: new DramaInfo({ id: this.continueModel.dramaId }),
        }
      })
      this.continueModel.id = 0;
    }
  }
}