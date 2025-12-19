import { webview } from '@kit.ArkWeb';
import { SwiperContent, SwiperContentType, SwiperOption } from '../model/Index';
import { CommonUtils } from '../util/Utils';
import { AggregatedSwiperVM } from '../viewmodel/AggregatedSwiperVM';

@ComponentV2
export struct AggregatedSwiper {
  @Param @Require swiperOptions: SwiperOption[];
  @Local isShow: boolean = false;
  @Local durationTime: number = 0;
  @Local currentTime: number = 0;
  @Local isPlay: boolean = false;
  vm: AggregatedSwiperVM = AggregatedSwiperVM.instance;
  private indicatorController: IndicatorComponentController = new IndicatorComponentController();
  controller: VideoController = new VideoController();
  webViewController: webview.WebviewController = new webview.WebviewController();

  @Monitor('swiperOptions')
  swiperOptionsChange(monitor: IMonitor) {
    let options = monitor.value()?.now as SwiperOption[];
    this.vm.initOptions(options);
  }

  aboutToAppear(): void {
    if (this.swiperOptions.length) {
      this.vm.initOptions(this.swiperOptions);
    }
  }

  aboutToDisappear(): void {
    this.vm.swiperTypeIndex = 0;
  }

  @Builder
  content(item: SwiperContent) {
    if (item.type === SwiperContentType.IMAGE) {
      Image(CommonUtils.handleImgUrl(item.content, this.getUIContext().getHostContext()!))
        .objectFit(ImageFit.Cover)
        .width('100%');
    } else if (item.type === SwiperContentType.VIDEO) {
      Stack() {
        Image(CommonUtils.handleImgUrl(item?.preview ?? '', this.getUIContext().getHostContext()!))
          .objectFit(ImageFit.Cover)
          .width('100%');
        Image($r('app.media.play')).size({ width: 48, height: 48 });
      };
    } else {
      Stack() {
        Image(CommonUtils.handleImgUrl(item?.preview ?? '', this.getUIContext().getHostContext()!))
          .objectFit(ImageFit.Cover)
          .width('100%');
        Image($r('app.media.vr')).size({ width: 48, height: 48 });
      };
    }
  }

  @Builder
  contentBuilder(item: SwiperContent) {
    Column() {
      this.content(item);
    }.onClick(() => {
      this.isShow = !this.isShow;
    }).bindContentCover($$this.isShow, this.fullContentBuilder(this.vm.contents[this.vm.swiperAnimateIndex]), {
      modalTransition: ModalTransition.DEFAULT,
      onWillDismiss: ((action: DismissSheetAction) => {
        // 滑动不准情况的修正
        if (!this.vm.contents[this.vm.swiperAnimateIndex]) {
          this.vm.swiperAnimateIndex = 0;
          this.vm.contents = this.swiperOptions[this.vm.swiperTypeIndex].contents;
        }
        if (action.reason === DismissReason.PRESS_BACK) {
          this.isPlay = false;
          this.currentTime = 0;
          this.durationTime = 0;
          action.dismiss();
        }
      }),
    });
  }

  @Builder
  customVideoBuilder(item: SwiperContent) {
    Column() {
      Video({
        src: item.content,
        previewUri: CommonUtils.handleImgUrl(item.preview, this.getUIContext().getHostContext()!),
        controller: this.controller,
      })
        .objectFit(ImageFit.Contain)
        .autoPlay(true)
        .controls(false)
        .height('90%')
        .onStart(() => {
          this.isPlay = true;
        })
        .onPause(() => {
          this.isPlay = false;
        })
        .onFinish(() => {
          this.isPlay = false;
        })
        .onPrepared((event) => {
          if (event) {
            this.durationTime = event.duration;
          }
        })
        .onUpdate((event) => {
          if (event) {
            this.currentTime = event.time;
          }
        });

      Row() {
        Image(this.isPlay ? $r('app.media.pause') : $r('app.media.play'))
          .size({ width: 32, height: 32 })
          .onClick(() => {
            this.isPlay ? this.controller.pause() : this.controller.start();
            this.isPlay = !this.isPlay;
          });
        Slider({
          value: this.currentTime,
          min: 0,
          max: this.durationTime,
        })
          .onChange((value: number, mode: SliderChangeMode) => {
            this.controller.setCurrentTime(value);
          })
          .width('90%');
      }
      .opacity(0.8)
      .width('100%');
    };
  }

  @Builder
  fullContentBuilder(item: SwiperContent) {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        if (item?.type === SwiperContentType.IMAGE) {
          Image(CommonUtils.handleImgUrl(item.content, this.getUIContext().getHostContext()!))
            .width('100%')
            .objectFit(ImageFit.Contain);
        } else if (item?.type === SwiperContentType.VIDEO) {
          this.customVideoBuilder(item);
        } else if (item?.type === SwiperContentType.WEB) {
          Web({ src: item.content, controller: this.webViewController, incognitoMode: true })
            .geolocationAccess(false).height('calc(100% - 20vp)')
            .fileAccess(false);
        } else {
          Text('暂无可预览内容').fontSize(12).fontColor($r('sys.color.white'));
        }
      }
      .size({ height: '100%', width: '100%' })
      .backgroundColor($r('sys.color.black'))
      .justifyContent(FlexAlign.Center)
      .transition(TransitionEffect.translate({ y: '100%' }).animation({ duration: 300 }));

      Image($r('app.media.chevron_backward'))
        .size({ width: 24, height: 24 })
        .margin({ top: 28 })
        .onClick(() => {
          this.isShow = false;
        });
    };
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Swiper(this.vm.swiperController) {
          ForEach(this.vm.contents, (item: SwiperContent) => {
            this.contentBuilder(item);
          }, (item: SwiperContent) => item.content.toString());
        }
        .cachedCount(2)
        .index(0)
        .indicator(this.indicatorController)
        .itemSpace(0)
        .loop(false)
        .duration(1000)
        .curve(Curve.Ease)
        .effectMode(EdgeEffect.Spring)
        .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
          this.vm.handleSwiperEvent(index, targetIndex, extraInfo);
          this.vm.contents = this.swiperOptions[this.vm.swiperTypeIndex].contents;
        });

        Row() {
          Row({ space: 12 }) {
            if (this.vm.swiperTypes.length > 1) {
              ForEach(this.vm.swiperTypes, (item: string, index: number) => {
                Text(item)
                  .fontSize(8)
                  .fontWeight(500)
                  .padding({
                    left: 8,
                    right: 8,
                    top: 4,
                    bottom: 4,
                  })
                  .fontColor(this.vm.swiperTypeIndex === index ? $r('sys.color.black') : $r('sys.color.white'))
                  .backgroundColor(this.vm.swiperTypeIndex === index ? $r('sys.color.white') : Color.Transparent)
                  .borderRadius(16)
                  .onClick(() => {
                    this.vm.swiperTypeIndex = index;
                    this.vm.contents = this.swiperOptions[this.vm.swiperTypeIndex].contents;
                    this.vm.swiperController.changeIndex(0, SwiperAnimationMode.DEFAULT_ANIMATION);
                  });
              }, (item: string) => item);
            }
          }.padding(4).backgroundColor('rgba(0,0,0,0.40)').borderRadius(16);

          Row() {
            IndicatorComponent(this.indicatorController)
              .initialIndex(this.vm.swiperTypeIndex)
              .style(Indicator.digit()
                .fontColor($r('sys.color.white'))
                .selectedFontColor($r('sys.color.white'))
                .digitFont({ size: 8, weight: FontWeight.Medium })
                .selectedDigitFont({ size: 8, weight: FontWeight.Medium }))
              .vertical(true);
          }.height(24).backgroundColor('rgba(0,0,0,0.40)').borderRadius(16);
        }
        .padding({ left: 16, right: 16, bottom: 8 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      }.height(280);
    };
  }
}