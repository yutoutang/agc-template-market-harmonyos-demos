import { AppStorageV2 } from '@kit.ArkUI';
import { ShortDramaDetailListVM, ContinueVideoData } from '../viewmodels/ShortDramaDetailListVM';
import { VideoDetailComponent as VideoDetailComponent } from '../components/VideoDetailMask';
import {
  AiBarHeight,
  AppStorageKeys,
  BreakPoint,
  BreakPointValue,
  StatusBarHeight,
  UserInfoModel
} from '@agctemplate/widgets';
import { VideoSwiper, PlayerLayoutSize, PlayController } from 'video_swiper';
import { NAV_PAGE_NAME } from '@agctemplate/resources';
import {
  appRouter,
  container,
  Logger,
  NavParams,
  PreferConstant,
  PreferenceUtil,
  WindowManager
} from '@agctemplate/utils';
import { DramaInfo, MyWatchRecordRes, RequestAPI } from '@agctemplate/server';
import { MyStorage } from '../models/SpeedData';
import { getDramaInfo } from '@agctemplate/server/src/main/ets/api/mock/mockData/mockDramaFactory';
import { emitter } from '@kit.BasicServicesKit';
import { CastListenerImpl } from '../listener/CastListenerImpl';
import { CastingLayer, CastService } from 'module_cast';
import { VideoData } from 'module_cast/src/main/ets/model/VideoData';
import { VideoDesLayer } from '../components/VideoDesLayer';
import { Params, PromptActionClass } from '../components/PromptActionClass';

const TAG: string = 'ShortVideo';


@ComponentV2
export struct ShortDramaDetailPage {
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  // 初始化当前视频的下标
  @Local currentVideoIndex: number = 0;
  // 首视频标志
  @Local firstFlag: boolean = true;
  // 当前播放视频的索引
  @Local isPageShow: boolean = false;
  @Local layoutSize: PlayerLayoutSize = new PlayerLayoutSize()
  @Local storage: MyStorage = MyStorage.instance();
  @Param @Require continueVideoData: ContinueVideoData;
  // 短视频数据
  @Local vm: ShortDramaDetailListVM = new ShortDramaDetailListVM;
  @Local playController: PlayController = new PlayController()
  @Local myWatchRecordRes: MyWatchRecordRes = new MyWatchRecordRes();
  @Local title: string = ''
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local bonus: number = this.userInfo.bonus
  castListener: CastListenerImpl = new CastListenerImpl(this.playController)

  @Monitor('playController.curentIndex',)
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      Logger.info(TAG, `${path} changed from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
      if (path === 'playController.curentIndex') {
        this.setAvMetaData()
      }
    });
  }

  setAvMetaData() {
    let videoPlayData = this.vm.data.getData(this.currentVideoIndex)
    if (!videoPlayData) {
      Logger.warn(TAG, 'can not set av metadata, cast will not effect')
      return
    }
    let videoData: VideoData = {
      url: videoPlayData.getUrl() as string,
      head: videoPlayData.getPic(),
      name: videoPlayData.getName() + ` 第${this.playController.curentIndex + 1}集`,
      index: this.currentVideoIndex
    }
    CastService.getInstance()
      .setAVMetadata(videoData, this.playController.getAVPlayer()?.duration || videoPlayData.getDuration())
  }

  getFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 5
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.vm.init(this.continueVideoData)
    }
    emitter.on(event, callback);
  }

  // 视频数据初始化
  async aboutToAppear() {
    this.getFavoriteEmitter()
    this.storage.selectSpeed =
      PreferenceUtil.getInstance(getContext()).get(PreferConstant.PLAY_SPEED_SETTINGS, '1.0x') as string
    this.playController.autoPlay = true

    await this.vm.init(this.continueVideoData)
    CastService.getInstance().registerSessionListener(this.castListener)
    this.currentVideoIndex = this.continueVideoData.currentIndex || 0
    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
    // 注册事件监听
    Logger.info(TAG, 'aboutToAppear')
    // 观看记录
    container.resolve(RequestAPI).getMyWatchRecord({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myWatchRecordRes = new MyWatchRecordRes(res.getBody());
    })
  }

  aboutToDisappear(): void {
    CastService.getInstance().unregisterSessionListener(this.castListener)
    this.storage.selectSpeed =
      PreferenceUtil.getInstance(getContext()).get(PreferConstant.PLAY_SPEED_SETTINGS, '1.0x') as string
    // 观看记录
    let isWatched: boolean = false
    this.myWatchRecordRes.myWatchRecord.forEach((item) => {
      if (item.id === this.vm.dramaInfo.id) {
        isWatched = true
      }
    })
    const drama = getDramaInfo(this.vm.dramaInfo.id)
    drama.curIndex = this.playController.curentIndex
    if (isWatched) {
      // container.resolve(RequestAPI).unsetMyWatchRecord(this.vm.dramaInfo.id)
      container.resolve(RequestAPI).setMyWatchRecord(drama)
    } else {
      container.resolve(RequestAPI).setMyWatchRecord(drama)
    }
  }

  build() {
    NavDestination() {
      if (this.vm.ready) {
        Stack({ alignContent: Alignment.Bottom }) {
          // 视频切换组件
          VideoSwiper({
            playController: this.playController,
            videoPlayDataSource: this.vm.data,
            contentBuilder: wrapBuilder(VideoDetailComponent),
            currentVideoIndex: this.currentVideoIndex,
            inPage: 'Detail'
          })
            .width('100%')
            .height('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
        .padding({
          bottom: this.currentBreakpoint.value === BreakPointValue.LG ? 0 : `${px2vp(this.aiBarHeight.value)}vp`
        })
      }
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (CastService.getInstance().isCasting) {
        this.onBack()
        return true
      }
      appRouter.back(true, {
        params: { id: this.vm.dramaInfo.id, curIndex: this.playController.curentIndex } as ParamsModel
      })
      return true
    })
  }

  onBack() {
    PromptActionClass.setParam(new Params('是否退出投屏？', [{
      content: '是', action: () => {
        PromptActionClass.closeDialog()
        CastService.getInstance().endCasting()
      }
    }, {
      content: '否', action: () => {
        PromptActionClass.closeDialog()
      }
    }
    ]));
    PromptActionClass.setOptions({ alignment: DialogAlignment.Center, maskColor: $r('sys.color.mask_fourth') });
    PromptActionClass.openDialog()
  }
}

@Builder
export function shortDramaDetailPageBuilder() {
  ShortDramaDetailPage({
    continueVideoData: {
      currentIndex: NavParams.getParams()?.currentIndex,
      playTime: NavParams.getParams()?.playTime,
      dramaInfo: NavParams.getParams()?.dramaInfo
    }
  });
}

export function jumpDetailPage(dramaInfo: DramaInfo, currentIndex?: number, playTime?: number,
  callback?: (popInfo: PopInfo) => void) {
  appRouter.push({
    builderName: NAV_PAGE_NAME.ShortDramaDetailPage.name,
    params: {
      dramaInfo: dramaInfo,
      currentIndex: currentIndex,
      playTime: playTime
    },
    popCallback: callback
  })
}

export interface ParamsModel {
  id: string
  curIndex: number
}