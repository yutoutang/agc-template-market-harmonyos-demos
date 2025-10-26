import { AppStorageV2, PiPWindow } from '@kit.ArkUI';
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
import { CastService } from 'module_cast';
import { VideoData } from 'module_cast/src/main/ets/model/VideoData';
import { Params, PromptActionClass } from '../components/PromptActionClass';
import { PipManager, PipVideoConfig } from 'module_pip';
import { MediaSource } from 'video_swiper/src/main/ets/constant/MediaSource';
import { DetailVideoData } from '../models/DetailVideoData';
import { JSON } from '@kit.ArkTS';

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
  @Local vm: ShortDramaDetailListVM = ShortDramaDetailListVM.instance;
  @Local playController: PlayController = new PlayController()
  @Local myWatchRecordRes: MyWatchRecordRes = new MyWatchRecordRes();
  @Local title: string = ''
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local bonus: number = this.userInfo.bonus
  isBackground: boolean = false
  enablePip: boolean = false
  restoredFromPip: boolean = false
  castListener: CastListenerImpl = new CastListenerImpl(this.playController)
  isStart: boolean = false
  pipSurfaceId: string = ''
  surfaceId?: string = ''
  private pipStateCallback: Function = (state: PiPWindow.PiPState) => {
    Logger.info(TAG, `pipStateChange: state ${state}`);
    if (state === PiPWindow.PiPState.ABOUT_TO_STOP) {
    }
    if (state === PiPWindow.PiPState.ABOUT_TO_START) {
    }
    if (state === PiPWindow.PiPState.ABOUT_TO_RESTORE) {
      this.restoredFromPip = true
    }
    if (state === PiPWindow.PiPState.ABOUT_TO_STOP) {
      Logger.info(TAG, 'pip stop')
      if (!this.restoredFromPip) {
        Logger.info(TAG, 'pip not restoredFromPip as stop')
        if (this.isBackground) {
          // during pip, click pip close
          this.playController.playIndex(PipManager.getInstance().getIndex())
          this.playController.pause()
        } else {
          // during pip, click app in launcher
          this.playController.playIndex(PipManager.getInstance().getIndex())
        }
      } else {
        // during pip, click pip restore
        Logger.info(TAG, 'pip playIndex')
        this.playController.playIndex(PipManager.getInstance().getIndex())
      }
      this.restoredFromPip = false
    }
  };

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
      index: this.currentVideoIndex,
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
    Logger.info(TAG, 'aboutToAppear')
    // 观看记录
    container.resolve(RequestAPI).getMyWatchRecord({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myWatchRecordRes = new MyWatchRecordRes(res.getBody());
    })
    this.enablePip = PreferenceUtil.getInstance(getContext())
      .get(PreferConstant.BACKGROUND_MINI_WINDOW_PLAYBACK, false) as boolean
    Logger.info(TAG, `enablePip:${this.enablePip}`)
    if (this.enablePip) {
      PipManager.getInstance().setAutoStart(true)
    }
    this.getFavoriteEmitter()
    this.storage.selectSpeed =
      PreferenceUtil.getInstance(getContext()).get(PreferConstant.PLAY_SPEED_SETTINGS, '1.0x') as string
    this.playController.autoPlay = true

    this.vm.deinit()
    await this.vm.init(this.continueVideoData)
    CastService.getInstance().registerSessionListener(this.castListener)
    this.currentVideoIndex = this.continueVideoData.currentIndex || 0

    Logger.info(TAG, `aboutToAppear continueVideoData:${JSON.stringify(this.continueVideoData)}}`)
    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
    PipManager.getInstance().registerLifecycleCallback(this.pipStateCallback);
    PipManager.getInstance().registerPipStateChangeListener();
    this.registerEmitter()
    let mediaSource: MediaSource[] = [];
    this.vm.data.videoList.map(item => {
      mediaSource.push(new MediaSource(item.getId(), item.getUrl() as string, item.isLocked()))
    })
    this.playController.setPlayList(mediaSource)
  }

  registerEmitter() {
    this.backEmitter()
    this.foreEmitter()
  }

  onForeground: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    this.isBackground = false
    Logger.info(TAG, `onForeground: ${JSON.stringify(eventData)}`);
    this.playController.play()
  }
  onBackground: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    Logger.info(TAG, `onBackground: ${JSON.stringify(eventData)}`);
    this.isBackground = true
    if (!this.enablePip) {
      this.playController.pause()
    }
  }

  backEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 1
    };
    emitter.on(event, this.onBackground);
  }

  foreEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 2
    };
    emitter.on(event, this.onForeground);
  }

  unEmitter() {
    Logger.info(TAG, 'on jump')
    emitter.off(1, this.onBackground)
    emitter.off(2, this.onForeground)
  }

  aboutToDisappear(): void {
    Logger.info(TAG, 'aboutToDisappear')
    this.unEmitter()
    PipManager.getInstance().setAutoStart(false)
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
    PipManager.getInstance().unregisterPipStateChangeListener();
    PipManager.getInstance().unRegisterLifecycleCallback(this.pipStateCallback);
    this.vm.deinit()
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
    .onWillShow(() => {
      if (this.vm.ready === false) {
        this.vm.init(this.continueVideoData)
      }
    })
    .onShown(() => {
      Logger.info(TAG, 'onShown')
      if (this.enablePip) {
        if (this.isStart) {
          Logger.info(TAG, 'pip stop')
          PipManager.getInstance().stopPip();
        } else {
          Logger.info(TAG, 'pip init')
          PipManager.getInstance().init(this.getUIContext().getHostContext() as Context);
          this.isStart = true
        }
      }
    })
    .onHidden(() => {
      if (!this.enablePip) {
        Logger.info(TAG, 'onHidden, no pip mode!')
        return
      }
      if ((this.vm.data.getData(this.currentVideoIndex) as DetailVideoData).isLocked()) {
        PipManager.getInstance().setAutoStart(false)
        Logger.info(TAG, 'onHidden, no locked pip mode!')
        return
      }
      PipManager.getInstance().setAutoStart(true)
      // 如果是能小窗播放，设置播放列表到小窗管理器中，小窗管理器内复用播放器实现无缝播放
      let pipConfig: PipVideoConfig = new PipVideoConfig()
      this.vm.data.videoList.map(item => {
        pipConfig.mediaSource.push(new MediaSource(item.getId(), item.getUrl() as string, item.isLocked()))
      })
      pipConfig.index = this.playController.curentIndex
      PipManager.getInstance().startPip(pipConfig)
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