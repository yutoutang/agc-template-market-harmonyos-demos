import { ValueType } from '@kit.ArkData';
import { AppStorageV2, uiObserver, window } from '@kit.ArkUI';
import {
  BreakpointModel,
  CommonConstants,
  GridRowColSetting,
  RouterMap,
  RouterUtils,
  WindowModel,
} from 'lib_common';
import { AvModel, AvSection, HomeServiceApi } from 'lib_news_api';
import { PiPWindowModel, VideoCard, VideoNetworkModel, VideoNetworkSetting } from 'module_swipeplayer';
import { VideoData } from '../model/VideoModel';
import { VideoVM } from '../viewmodel/VideoViewModel';
import { VideoPipViewModel } from '../viewmodel/VideoPipViewModel';
import { VideoAxisList } from '../components/VideoAxisList';
import { AvViewModel } from '../viewmodel/AvViewModel';


@Builder
export function VideoProgramDetailsBuilder() {
  VideoProgramDetails()
}

@ComponentV2
export struct VideoProgramDetails {
  @Local detailData: VideoData | undefined
  @Local videoDetails: AvModel | undefined
  @Local seek: number = 0
  @Local videoPipModel: VideoPipViewModel = new VideoPipViewModel()
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  @Local sectionIndex: number = -1
  @Local isHideSlide: boolean = true
  @Local videoId: string = ''
  videoVM: VideoVM = new VideoVM()
  avViewModel: AvViewModel = new AvViewModel()
  private landscapeListener = (info: uiObserver.NavDestinationInfo) => {
    this.pipWindowModel.navDestinationUpdateListeners.forEach((callback, key) => {
      if (key === 'landscapeListener') {
        callback(info)
      }
    })
  }

  @Monitor('sectionIndex')
  sectionIndexChange() {
    this.detailData = new VideoData(this.videoDetails!.section[this.sectionIndex])
  }

  // WindowStage生命周期变化的监听回调函数
  private windowStageEventCallback = (type: window.WindowStageEventType) => {
    const allPathStack = RouterUtils.getStack().getAllPathName()
    const lastPathName = allPathStack[allPathStack.length - 1];
    if (lastPathName === RouterMap.VIDEO_PROGRAM_DETAILS) {
      // 不展示画中画时，保持原有逻辑
      if (!this.videoVM.settingInfo.network.enableLivePiP) {
        if (type === window.WindowStageEventType.RESUMED || type === window.WindowStageEventType.SHOWN) {
          this.videoPipModel.getVideoCardPlayerController().play()
          this.pipWindowModel.isBackgroundPip = false;
        } else if (type === window.WindowStageEventType.PAUSED || type === window.WindowStageEventType.HIDDEN) {
          this.videoPipModel.getVideoCardPlayerController().pause()
          this.pipWindowModel.isBackgroundPip = true;
        }
      }
    }
  }

  aboutToAppear(): void {
    // 无感监听路由变化
    uiObserver.on('navDestinationUpdate', this.landscapeListener);
    this.videoPipModel.setContext(this.getUIContext().getHostContext() as Context)
    this.videoVM.windowStageModel.windowStageEventListeners.delete('VideoProgramDetails');
    this.videoVM.windowStageModel.windowStageEventListeners.set('VideoProgramDetails', (type) => {
      this.windowStageEventCallback(type)
    })
  }

  aboutToDisappear(): void {
    uiObserver.off('navDestinationUpdate', this.landscapeListener)
  }

  backIntercept() {
    this.videoPipModel.enableVideoPip(this.videoDetails!.id, false)
    RouterUtils.pop(this.videoDetails);
  }

  @Builder
  videoInfo() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.detailData?.title)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16 * this.videoVM.settingInfo.fontSizeRatio)
          .fontWeight(FontWeight.Medium)
        Text(this.detailData?.updateTime)
          .fontColor($r('sys.color.font_tertiary'))
          .fontSize(12 * this.videoVM.settingInfo.fontSizeRatio)
          .fontWeight(FontWeight.Regular)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row({ space: 12 }) {
          Image(this.videoDetails?.coverUrl)
            .width(40)
            .height(40)
            .borderRadius('50%')
            .clip(true)
          Text(this.videoDetails?.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(16 * this.videoVM.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Medium)
        }

        Button(this.videoDetails?.isFollow ? '已订阅' : '订阅')
          .fontColor(this.videoDetails?.isFollow ? $r('sys.color.font_emphasize') : $r('sys.color.font_on_primary'))
          .fontSize(14 * this.videoVM.settingInfo.fontSizeRatio)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.videoDetails?.isFollow ? $r('sys.color.comp_background_tertiary') : '#5C79D9')
          .width(72)
          .height(28)
          .padding(0)
          .onClick(() => {
            this.avViewModel.followOperation(this.videoDetails!)
          })

      }
    }
    .width('100%')
    .margin({ top: 8, bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ContentBuilder() {
    Column() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
        }) {
          Column() {
            Stack({ alignContent: Alignment.TopStart }) {
              Column() {
                if (this.videoDetails) {
                  VideoCard({
                    currentIndex: 0,
                    index: 0,
                    videoData: this.detailData,
                    isShown: true,
                    videoNetwork: this.videoVM.networkModel as VideoNetworkModel,
                    videoNetworkSetting: this.videoVM.settingInfo.network as VideoNetworkSetting,
                    currentBreakpoint: this.videoVM.breakPointModel.currentBreakpoint,
                    videoCardPlayerController: this.videoPipModel.getVideoCardPlayerController(),
                    isFromDetailCard: true,
                    canChangeSlide: true,
                    isHideSlide: this.isHideSlide,
                    pathStack: RouterUtils.getStack(),
                    fullScreenIcon: $r('sys.symbol.full_screen'),
                    isNeedMuteIcon: true,
                    isMute: this.videoVM.isMute,
                    onMute: (value) => {
                      this.videoVM.setMute(value)
                    },
                    playerStateCallback: (state: string, id: string) => {
                      if (id === this.detailData?.id && state === 'prepared') {
                        if (this.seek) {
                          this.videoPipModel.videoCardPlayerController.seek(this.seek)
                        }
                      }
                    },
                    xComponentReadyCallback: (controller: XComponentController) => {
                      this.videoPipModel.setMXComponentController(controller)
                      this.videoPipModel.handlePip()
                    },
                  })
                    .clip(true)
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(Color.Black)
              .height(this.videoVM.videoBoxHeight)
              .backgroundColor(Color.Black)

              Row({ space: CommonConstants.SPACE_S }) {
                Row({ space: 2 }) {
                  Button() {
                    SymbolGlyph($r('sys.symbol.chevron_backward'))
                      .fontColor([$r('sys.color.font_on_primary')])
                      .fontWeight(FontWeight.Normal)
                      .fontSize(24 * this.videoVM.settingInfo.fontSizeRatio)
                  }
                  .width(40)
                  .height(40)
                  .type(ButtonType.Circle)
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                  .accessibilityText('返回')
                  .onClick(() => {
                    this.backIntercept()
                  })
                }
                .padding({
                  left: 8,
                  top: 3,
                  right: 8,
                  bottom: 3,
                })
                .borderRadius(4)
              }
              .padding({ left: CommonConstants.PADDING_L, top: CommonConstants.PADDING_L })
            }
            .priorityGesture(
              GestureGroup(GestureMode.Exclusive,
                // 双击暂停或播放
                TapGesture({ count: 2 })
                  .onAction((event: GestureEvent) => {
                    if (!event) {
                      return
                    }
                    this.videoPipModel.getVideoCardPlayerController().switchPlayPause()
                  }),
              ),
            )
          }
        }

        GridCol({
          span: {
            sm: 8,
            md: 8,
            lg: 4,
            xl: 4,
          },
        }) {
          Column() {
            this.videoInfo()
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Text('往期节目')
                .fontColor($r('sys.color.font_primary'))
                .fontSize(18 * this.videoVM.settingInfo.fontSizeRatio)
                .fontWeight(FontWeight.Bold)
              Row() {
                Text('全部')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize(14 * this.videoVM.settingInfo.fontSizeRatio)
                  .fontWeight(FontWeight.Regular)
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontColor([$r('sys.color.font_secondary')])
                  .fontWeight(FontWeight.Normal)
                  .fontSize(14 * this.videoVM.settingInfo.fontSizeRatio)
              }
              .onClick(() => {
                this.videoPipModel.videoCardPlayerController.pause()
                let params: Record<string, ValueType> = {
                  'videoId': this.videoDetails!.id,
                  'sectionIndex': this.sectionIndex,
                }
                RouterUtils.pushPathByName(RouterMap.VIDEO_PROGRAM_HISTORY, params, (popInfo: PopInfo) => {
                  const result = popInfo.result as AvSection
                  this.videoPipModel.videoCardPlayerController.videoUrlChange(result.sectionUrl)
                  this.sectionIndex = this.videoDetails?.section.findIndex(val => val.id === result.id) ?? -1
                })
              })
            }
            .margin({ bottom: 8 })

            VideoAxisList({
              videoDetails: this.videoDetails,
              fontSizeRatio: this.videoVM.settingInfo.fontSizeRatio,
              isTvDetails: true,
              sectionIndex: this.sectionIndex!!,
              onVideoChange: (item: AvSection) => {
                this.videoPipModel.videoCardPlayerController.videoUrlChange(item.sectionUrl)
                this.isHideSlide = false
              },
            })
          }
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
    }
    .backgroundColor($r('sys.color.background_primary'))
  }

  build() {
    NavDestination() {
      this.ContentBuilder()
    }
    .hideTitleBar(true)
    .onReady((context) => {
      let params = context.pathStack.getParamByName('VideoProgramDetails')[0] as Record<string, ValueType>
      this.videoId = params.avId as string
      this.seek = params.seek as number
    })
    .onBackPressed(() => {
      this.backIntercept()
      return true
    })
    .padding({
      top: this.windowModel.windowTopPadding,
    })
    .onWillShow(() => {
      this.pipWindowModel.isBackPiP = false;
    })
    .onShown(async () => {
      const videoDetails = await HomeServiceApi.queryHomeTelevisionDetails(this.videoId) as AvModel
      this.videoDetails = new AvModel(videoDetails)
      this.detailData = new VideoData(this.videoDetails.section[0])
      this.videoPipModel.initVideoPip()
    })
    .onWillDisappear(() => {
      if (!this.videoVM.settingInfo.network.enableLivePiP) {
        this.videoPipModel.getVideoCardPlayerController().pause();
        this.pipWindowModel.pipController?.setAutoStartEnabled(false);
      }
      this.pipWindowModel.isBackPiP = true;
    })
  }
}