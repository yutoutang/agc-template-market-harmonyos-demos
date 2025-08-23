import { ComponentInfo } from '../utils/Utils';

export interface ImagePreviewParam {
  imageList: (string | Resource)[];
  active: number;
}

export interface imageSize {
  width: number;
  height: number;
}

export interface ImageSizeType {
  width: number;
  height: number;
  scale: number;
  offsetX: number;
  offsetY: number;
  offsetStartX: number;
  offsetStartY: number;
  dragOffsetX: number;
  dragOffsetY: number;
  isVideo: boolean;
}

interface ProgressState {
  index: number,
  value: number,
  ifLoad: boolean
}


@Component
struct ImageViewerComponent {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State progressState: ProgressState[] = [{
    index: 0,
    value: 0,
    ifLoad: false,
  }, {
    index: 1,
    value: 0,
    ifLoad: false,
  }, {
    index: 2,
    value: 0,
    ifLoad: false,
  }, {
    index: 3,
    value: 0,
    ifLoad: false,
  }, {
    index: 4,
    value: 0,
    ifLoad: false,
  }, {
    index: 5,
    value: 0,
    ifLoad: false,
  }];
  private imageListSize: imageSize[] = [];
  private defaultScale: number = 1;
  private gradientColor: LinearGradient = new LinearGradient([{ color: Color.Yellow, offset: 0.5 },
    { color: Color.Orange, offset: 1.0 }]);
  controller: VideoController = new VideoController();
  @Consume('pageStack') pageStack: NavPathStack;
  @State imageList: (string | Resource)[] = [];
  @State active: number = 0;
  @State indexChange: number = 0;
  @State offSetIndexY: number = 0;
  @State containerHeight: number = 0;
  @State containerWidth: number = 0;
  @State disabledSwipe: boolean = false;
  @State isInitially: boolean = true;
  @State isFull: boolean = false;
  @State progressValue: number = 50;
  @State isPlay: boolean = true;
  @State loading: boolean = true;
  @State activeImage: ImageSizeType = {
    width: 0,
    height: 0,
    scale: 1,
    offsetX: 0,
    offsetY: 0,
    offsetStartX: 0,
    offsetStartY: 0,
    dragOffsetX: 0,
    dragOffsetY: 0,
    isVideo: false,
  };
  @State componentInfo: ComponentInfo = {
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    width: 0,
    height: 0,
  };

  build() {
    NavDestination() {
      Stack() {
        Swiper() {
          ForEach(this.imageList, (item: ResourceStr, i: number) => {
            if (typeof item === 'string') {
              Image(item)
                .id('imageheight')
                .width(`calc(100% * ${this.activeImage.scale})`)
                .height(`calc(100% * ${this.activeImage.scale})`)
                .objectFit(ImageFit.Contain)
                .draggable(false)
                .scale(this.active === i ? { x: this.activeImage.scale, y: this.activeImage.scale } : null)
                .offset(this.active === i ? { x: this.activeImage.offsetX, y: this.activeImage.offsetY } : null)
                .onComplete(e => {
                  this.loading = false;
                  if (e?.loadingStatus) {
                    this.imageListSize[i] = {
                      width: px2vp(Number(e.contentWidth)),
                      height: px2vp(Number(e.contentHeight)),
                    };
                    this.activeImage.isVideo = false;
                    if (this.active === i) {
                      this.activeImage.width = this.imageListSize[i].width;
                      this.activeImage.height = this.imageListSize[i].height;
                      this.activeImage.isVideo = false;
                    }
                  }
                });

            }
          }, (item: ResourceStr) => JSON.stringify(item));
        }
        .onChange((e) => {
          this.indexChange = e;
        })
        .width('100%')
        .height('100%')
        .index(this.active)
        .backgroundColor('#FFFFFF')
        .indicator(false)
        .parallelGesture(
          GestureGroup(GestureMode.Exclusive,
            PinchGesture({ fingers: 2, distance: 1 })
              .onActionStart((e) => {
                this.defaultScale = this.activeImage.scale;
              })
              .onActionUpdate((e) => {
                let scale = e.scale * this.defaultScale;
                if (scale <= 4 && scale >= 1) {
                  this.activeImage.offsetX = this.activeImage.offsetX / (this.activeImage.scale - 1) * (scale - 1) || 0;
                  this.activeImage.offsetY = this.activeImage.offsetY / (this.activeImage.scale - 1) * (scale - 1) || 0;
                  this.activeImage.scale = scale;
                }
                this.disabledSwipe = this.activeImage.scale > 1;
              })
              .onActionEnd((e) => {
                this.disabledSwipe = this.activeImage.scale > 1;
              })
              .onActionCancel(() => {
                this.disabledSwipe = this.activeImage.scale > 1;
              }),

            PanGesture()
              .onActionStart(e => {
                this.activeImage.dragOffsetX = e.fingerList[0].globalX;
                this.activeImage.dragOffsetY = e.fingerList[0].globalY;
              })
              .onActionUpdate((e) => {
                if (this.activeImage.scale === 1) {
                  return;
                }
                let offsetX = e.fingerList[0].globalX - this.activeImage.dragOffsetX +
                this.activeImage.offsetStartX;
                let offsetY = e.fingerList[0].globalY - this.activeImage.dragOffsetY +
                this.activeImage.offsetStartY;

                if (this.activeImage.width * this.activeImage.scale > this.containerWidth &&
                  (this.activeImage.width * this.activeImage.scale - this.containerWidth) / 2 >=
                  Math.abs(offsetX)) {
                  this.activeImage.offsetX = offsetX;
                }
                if (this.activeImage.height * this.activeImage.scale >
                this.containerHeight &&
                  (this.activeImage.height * this.activeImage.scale - this.containerHeight) / 2 >=
                  Math.abs(offsetY)) {
                  this.activeImage.offsetY = offsetY;
                }
                if ((this.activeImage.width * this.activeImage.scale - this.containerWidth) / 2 < Math.abs(offsetX)) {
                  this.disabledSwipe = false;
                }
              })
              .onActionEnd((e) => {
                this.activeImage.offsetStartX = this.activeImage.offsetX;
                this.activeImage.offsetStartY = this.activeImage.offsetY;
              })
              .onActionCancel(() => {
                this.activeImage.offsetStartX = this.activeImage.offsetX;
                this.activeImage.offsetStartY = this.activeImage.offsetY;
              }),

            PanGesture({ fingers: 1, direction: PanDirection.Down, distance: 2 })
              .onActionStart(e => {
                if (this.activeImage.scale === 1) {
                  this.isInitially = true;
                } else {
                  this.isInitially = false;
                }
              })
              .onActionUpdate((e) => {
                if (this.isInitially) {
                  if (e.offsetY - this.offSetIndexY > 1) {
                    this.offSetIndexY = e.offsetY;
                    this.activeImage.scale = this.activeImage.scale * 0.98;
                  }
                }

              })
              .onActionEnd(() => {
                if (this.isInitially) {
                  this.activeImage.scale = 1;
                  this.pageStack?.pop();
                }

              }),

            TapGesture({ count: 2 })
              .onAction((e) => {
                if (this.activeImage.scale === 1) {
                  this.activeImage.offsetX = 2 * (this.activeImage.width / 2 - e.fingerList[0].globalX);

                  this.activeImage.scale = 2 * this.activeImage.scale;
                  if (this.activeImage.offsetX < -this.activeImage.width / 2) {
                    this.activeImage.offsetX = -this.activeImage.width / 2;
                  }
                  if (this.activeImage.offsetX > this.activeImage.width / 2) {
                    this.activeImage.offsetX = this.activeImage.width / 2;
                  }


                } else {
                  this.activeImage.offsetX = 0;
                  this.activeImage.offsetY = 0;
                  this.activeImage.scale = 1;
                }
              }),
          ),
        )
        .disableSwipe(this.disabledSwipe)
        .onAnimationEnd((index) => {
          if (index !== this.active) {
            this.activeImage = {
              width: 0,
              height: 0,
              scale: 1,
              offsetX: 0,
              offsetY: 0,
              offsetStartX: 0,
              offsetStartY: 0,
              dragOffsetX: 0,
              dragOffsetY: 0,
              isVideo: typeof this.imageList[index] !== 'string',
            };
          }
          this.active = index;
          this.disabledSwipe = this.activeImage.scale > 1;
          if (!this.activeImage.isVideo) {
            this.activeImage.width = this.imageListSize[index].width;
            this.activeImage.height = this.imageListSize[index].height;
          }

        })
        .itemSpace(50)
        .onAreaChange((_, n) => {
          this.containerWidth = Number(n.width);
          this.containerHeight = Number(n.height);
        });

        if (this.loading) {
          Column() {
            LoadingProgress().width(70);
          }.backgroundColor($r('sys.color.white')).width('100%').height('100%').justifyContent(FlexAlign.Center);
        }
      };

    }
    .onWillShow(() => {
      this.pageStack.getParamByIndex(0);
      this.indexChange = this.active;
    })
    // .hideTitleBar(true)
    .title('')
    .padding({ top: px2vp(this.topRectHeight) })
    .onReady((ctx: NavDestinationContext) => {
      try {
        const myParams = ctx?.pathInfo?.param as ImagePreviewParam;
        if (myParams) {
          this.imageList = myParams.imageList;
        }
      } catch (e) {
        console.log('e', JSON.stringify(e));
      }
    });
  }
}


@Builder
export function ImagePreviewBuilder() {
  ImageViewerComponent();
}