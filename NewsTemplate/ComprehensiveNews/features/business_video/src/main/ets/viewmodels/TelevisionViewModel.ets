import { AppStorageV2, uiObserver } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import {
  CardTvHeightSizeConstants,
  televisionHeightSize,
  televisionLanes,
  VideoData,
  VideoPipViewModel,
} from 'lib_av_details';
import { BaseViewModel } from 'lib_common';
import { AvModel, HomeServiceApi } from 'lib_news_api';
import { PiPWindowModel, VideoCardPlayerController } from 'module_swipeplayer';
import { VideoProgramSheet } from '../utils/VideoProgramSheet';

@ObservedV2
export class TelevisionViewModel extends BaseViewModel {
  @Trace televisionList: AvModel[] = []
  @Trace televisionExtraList: AvModel[] = []
  @Trace currentPage: number = 0;
  @Trace currentIndex: number = 10;
  @Trace televisionIndex: number = 0;
  context: UIContext
  @Trace sectionIndex: number = 0
  @Trace detailData: VideoData | undefined
  videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController();
  @Trace pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  @Trace videoPipModel: VideoPipViewModel = new VideoPipViewModel()
  @Trace isMute: boolean = true
  @Trace title: string = '猜你喜欢'
  @Trace loading: boolean = true
  @Trace isRefreshing: boolean = false
  private landscapeListener = (info: uiObserver.NavDestinationInfo) => {
    this.pipWindowModel.navDestinationUpdateListeners.forEach((callback, key) => {
      if (key === 'landscapeListener') {
        callback(info)
      }
    })
  }

  constructor(context: UIContext) {
    super()
    this.context = context
  }

  /*
   * 初始化电视数据
   * */
  public async requestTelevision() {
    this.loading = true
    // 无感监听路由变化
    emitter.on('stop_video_play', () => {
      this.videoCardPlayerController.pause()
    })
    uiObserver.on('navDestinationUpdate', this.landscapeListener);
    this.televisionList = await HomeServiceApi.queryTelevisionList(this.currentIndex, this.currentPage)
    this.loading = false
    this.detailData = new VideoData(this.televisionList[this.televisionIndex].section[this.sectionIndex])
  }

  /*
   * 初始化电视猜你喜欢数据
   * */
  public async requestTelevisionLike() {
    this.televisionExtraList = await HomeServiceApi.queryTelevisionLikes()
  }

  public getTitle() {
    return this.televisionList[this.televisionIndex]?.title
  }

  stopPip() {
    this.videoPipModel.stopPip()
  }

  public openProgram() {
    VideoProgramSheet.openProgram(this.televisionList[this.televisionIndex]?.id)
  }

  public setIndex(index: number, item: AvModel) {
    this.televisionIndex = index
    this.videoCardPlayerController.videoUrlChange(item.section[this.sectionIndex]?.sectionUrl)
  }

  public setMute(value: boolean) {
    this.isMute = value
  }

  destroyListener() {
    uiObserver.off('navDestinationUpdate', this.landscapeListener)
    emitter.off('stop_video_play')
  }

  public geVideoHeight() {
    return televisionHeightSize.getValue(this.breakPointModel.currentBreakpoint) ?? CardTvHeightSizeConstants.xlSize
  }

  /**
   * 获取猜您喜欢格栅
   * */
  public getTelevisionLanes() {
    return televisionLanes.getValue(this.breakPointModel.currentBreakpoint) ?? 2
  }

  public async refreshData() {
    this.isRefreshing = true
    this.televisionList = await HomeServiceApi.queryTelevisionList(this.currentIndex, this.currentPage)
    this.isRefreshing = false
  }


  @Computed
  get pagePaddingBottom() {
    if (this.tabModel.isTabVertical) {
      return this.windowModel.windowBottomPadding;
    }
    return 48;
  }
}