import { SwiperItem,PageSwiperController } from '../types/Index';

@ComponentV2
export struct PageSwiper {
  @Param swiperData: SwiperItem[] = [];
  @Param tips: string = '向右滑动查看其它珍品';
  @Param defaultIndex: number = 0;
  @Param sheetBg: ResourceStr = '';
  @Param @Once isShowTips: boolean = true;
  @Param bottomText: string = '点击查看详情';
  @Param pageSwiperController: PageSwiperController = new PageSwiperController();
  @BuilderParam customContent: () => void;
  @Local curIndex: number = 0;
  @Local isShow: boolean = false;
  // 是否图片缩小
  @Local isScale: boolean = false;
  @Event onBackgroundChange: (isScale: boolean,index:number) => void = () => {

  };
  // 放大背景图
  private zoom = () => {
    this.isScale = false;
    this.onBackgroundChange(this.isScale,this.curIndex);
  };
  // 缩小背景图
  private shrink = ()=>{
    this.isScale = true;
    this.onBackgroundChange(this.isScale,this.curIndex);
  }

  aboutToAppear(): void {
    this.curIndex = this.defaultIndex;
    this.pageSwiperController.zoom = this.zoom
    this.pageSwiperController.shrink = this.shrink
  }

  @Builder
  contentBuilder() {
    Column() {
      Text(`《${this.swiperData[this.curIndex].name}》`)
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor('#603C00')
        .margin({ bottom: 12 });
      Text('藏品信息')
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor('#603C00')
        .width('100%')
        .margin({ bottom: 6 });
      Text(`所属年代：${this.swiperData[this.curIndex].age ?? ''}`)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor('#603C00')
        .width('100%')
        .margin({ bottom: 16 });
      Text('藏品介绍')
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor('#603C00')
        .width('100%')
        .margin({ bottom: 4 });
      Text(this.swiperData[this.curIndex].introduction ?? '')
        .fontSize(14)
        .lineHeight(25)
        .fontColor('#000000')
        .textIndent(28);

    }
    .width('100%')
    .height('100%')
    .backgroundImage(this.sheetBg)
    .backgroundImageSize({ width: '100%', height: '100%' })
    .padding(16);
  }

  build() {
    Stack() {
      Swiper() {
        ForEach(this.swiperData, (item: SwiperItem, index) => {
          Stack() {
            Image(item.img)
              .width(this.isScale ? 242 : '100%')
              .height(this.isScale ? 284 : '100%')
              .expandSafeArea([this.isScale ? SafeAreaType.CUTOUT : SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
              .margin({ top: this.isScale ? 60 : 0 })
              .animation({
                duration: 800,
                curve: Curve.Linear,
              });
            if (!this.isScale) {
              Column({ space: 8 }) {
                Image($r('app.media.drawing_board'))
                  .width(24)
                  .height(24)
                  .margin({ top: 52 })
                  .alignSelf(ItemAlign.Start);
                Column({ space: 6 }) {
                  Text('《').commonTextExtend().rotate({ angle: 90 });
                  Text(item.name).commonTextExtend();
                  Text('《').commonTextExtend().rotate({ angle: -90 });
                }.layoutWeight(1).width('100%').alignItems(HorizontalAlign.Start);

                Column() {
                  if (this.customContent){
                    this.customContent()
                  }else {
                    Text('点击查看详情')
                      .fontColor('#D1B380')
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.Body_M'))
                      .onClick(() => {
                        this.isShow = true;
                        this.pageSwiperController.shrink()
                      });
                  }
                }
                .margin({ bottom: 49 });

              }.width('100%').height('100%').padding(16)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
            }


          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .width('100%')
          .height('100%')
          .alignContent(Alignment.Top);

        }, (item: SwiperItem) => item.name);
      }
      .width('100%')
      .height('100%')
      .indicator(false)
      .autoPlay(false)
      .interval(3000) // 停留时间
      .loop(false)
      .index(this.defaultIndex) // 默认展示的项
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .onChange((index) => {
        this.isShowTips = false;
        this.curIndex = index;
      });

      if (!this.isScale) {
        Row() {
          if (this.curIndex !== 0) {
            Image($r('app.media.page_arrow_left')).width(28).height(26);
          } else {
            Blank();
          }
          Row({ space: 4 }) {
            if (this.curIndex !== this.swiperData.length - 1 && this.isShowTips) {
              Text(this.tips).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.background_tertiary'));
            }
            if (this.curIndex !== this.swiperData.length - 1) {
              Image($r('app.media.page_arrow_right')).width(28).height(26);
            }

          };
        }.width('100%').padding({ left: 16, right: 16 }).justifyContent(FlexAlign.SpaceBetween);
      }
    }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor('#000000')
    .bindSheet($$this.isShow, this.contentBuilder, {
      height: 384,
      showClose: false,
      maskColor: 'rgba(0,0,0,0)',
      preferType: SheetType.BOTTOM,
      onWillDisappear: () => {
        this.isScale = false;
        this.pageSwiperController.zoom()
      },
    });

  }
}

@Extend(Text)
function commonTextExtend() {
  .fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Bold).fontColor($r('sys.color.background_primary')).width(16);
}


