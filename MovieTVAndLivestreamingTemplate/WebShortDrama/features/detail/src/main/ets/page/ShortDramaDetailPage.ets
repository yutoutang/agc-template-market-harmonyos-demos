import { AppStorageV2 } from '@kit.ArkUI';
import { ShortDramaDetailListVM, ContinueVideoData } from '../viewmodels/ShortDramaDetailListVM';
import { VideoDetailComponent as VideoDetailComponent } from '../components/VideoDetailMask';
import {
  AiBarHeight,
  AppStorageKeys,
  BreakPoint,
  BreakPointValue,
  StatusBarHeight
} from '@agctemplate/widgets';
import { VideoSwiper, PlayerLayoutSize, PlayController } from 'video_swiper';
import { NAV_PAGE_NAME } from '@agctemplate/resources';
import { appRouter, container, Logger, NavParams,
  PreferConstant,
  PreferenceUtil, WindowManager } from '@agctemplate/utils';
import { DramaInfo, MyWatchRecordRes, RequestAPI } from '@agctemplate/server';
import { MyStorage } from '../models/SpeedData';
import { getDramaInfo } from '@agctemplate/server/src/main/ets/api/mock/mockData/mockDramaFactory';
import { emitter } from '@kit.BasicServicesKit';

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
  playController: PlayController = new PlayController()
  @Local myWatchRecordRes: MyWatchRecordRes = new MyWatchRecordRes();

  listenBackPress() {

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
  aboutToAppear() {
    this.getFavoriteEmitter()
    this.storage.selectSpeed =
      PreferenceUtil.getInstance(getContext()).get(PreferConstant.PLAY_SPEED_SETTINGS, '1.0x') as string
    this.playController.autoPlay = true
    this.currentVideoIndex = this.continueVideoData.currentIndex || 0
    this.vm.init(this.continueVideoData)
    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
    // 注册事件监听
    this.listenBackPress();
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
      container.resolve(RequestAPI).unsetMyWatchRecord(this.vm.dramaInfo.id)
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
      appRouter.back(true, {
        params: { id: this.vm.dramaInfo.id, curIndex: this.playController.curentIndex } as ParamsModel
      })
      return true
    })
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