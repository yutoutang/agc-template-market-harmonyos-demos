import { VideoSwiper, PlayController } from 'video_swiper';
import { DramaDesComponent } from '../components/DramaDes';
import { PlayErrorLayer } from '../components/PlayErrorLayer';
import { DramaListVM } from '../viewmodel/DramaListVM';
import { emitter } from '@kit.BasicServicesKit';
import { Logger } from '@agctemplate/utils';

const TAG = 'HomeMainPage'

@ComponentV2
export struct HomeMainPage {
  @Param @Require index: number;
  @Consumer('curTabIndex') curTabIndex: number = 0;
  @Local noFlash: boolean = true

  @Monitor('curTabIndex')
  onIndexChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      Logger.debug(TAG, `${path} change from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
      if (path === 'curTabIndex') {
        let curIndex = monitor.value(path)?.now as number
        if (this.index === curIndex) {
          this.playController.play();
        } else {
          this.playController.pause()
        }
      }
    })
  }

  @Local vm: DramaListVM = new DramaListVM()
  playController: PlayController = new PlayController()

  aboutToAppear(): void {
    Logger.info(TAG, 'main aboutToAppear')
    this.getDeleteEmitter()
    this.getDetailInfoFavoriteEmitter()
    this.getSideFavoriteEmitter()
    setTimeout(() => {
      this.noFlash = false;
    }, 1000);
    this.vm.init()
    this.playController.autoPlay = false
  }

  getDeleteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 6
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.vm.refresh()
    }
    emitter.on(event, callback);
  }

  getDetailInfoFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 5
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.vm.refresh()
    }
    emitter.on(event, callback);
  }

  getSideFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 7
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.vm.refresh()
    }
    emitter.on(event, callback);
  }

  build() {
    if (this.vm.ready) {
      Stack({ alignContent: Alignment.Bottom }) {
        // 视频切换组件
        VideoSwiper({
          playController: this.playController,
          videoPlayDataSource: this.vm.data,
          contentBuilder: wrapBuilder(DramaDesComponent),
          refresh: () => {
            this.vm.refresh()
          },
          loadMore: () => {
            this.vm.init()
          },
          inPage: 'Home'
        })
          .width('100%')
          .height('100%')
      }
      .padding({ top: '56vp' })
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    } else if (!this.noFlash) {
      PlayErrorLayer({ vm: this.vm })
    }
  }
}

@Builder
export function HomeMainPageBuilder(index: number) {
  HomeMainPage({
    index: index
  })
}