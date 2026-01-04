import { Constants } from '../commons/Constants';
import { ImageInfo, ImageInfos } from '../commons/ImageInfo';
import { OnWallpaperDetailsListener } from '../commons/OnWallpaperDetailsListener';

@ComponentV2
export struct NewWallpaperDetail {
  currentIndex: number = 0;
  currentTime: string = '09:00';
  currentDate: string = '9月01日 星期一';
  startX: number = 0;
  startY: number = 0;
  isSwiping: boolean = false;
  @Local collectText: string = '已收藏'
  @Local collectIcon: Resource = $r('app.media.ic_collect')
  @Local downIcon: Resource = $r('app.media.ic_download')
  @Local setIcon: Resource = $r('app.media.id_Settings')
  @Local isUIVisible: boolean = true;
  @Local isPreviewing: boolean = false;
  @Local currentImageInfo?: ImageInfo;
  @Local keywordList: string[] = []; // 存储处理后的关键词数组
  @Param @Require imageInfos: ImageInfos;
  @Param @Require listener: OnWallpaperDetailsListener;
  @Param @Require audio: boolean;
  private controller: VideoController = new VideoController();

  aboutToAppear(): void {
    for (let i = 0; i < this.imageInfos.list.length; i++) {
      let tempImageInfo = this.imageInfos.list[i]

      if (tempImageInfo.url === this.imageInfos.url) {
        this.currentIndex = i;
        this.currentImageInfo = this.imageInfos.list[i];
        this.currentImageInfo.like = this.listener.isFavorite(this.currentImageInfo);
        this.collectIcon = this.currentImageInfo.like ? $r('app.media.ic_collect_t') : $r('app.media.ic_collect')
        this.downIcon = this.currentImageInfo.isVideo ? $r('app.media.ic_download_vip') : $r('app.media.ic_download')
        this.setIcon = this.currentImageInfo.isVideo ? $r('app.media.id_Settings_vip') : $r('app.media.id_Settings')
        this.collectText = this.currentImageInfo.like ? '取消收藏' : '收藏'
        // 预处理关键词数据
        this.processKeywords(this.currentImageInfo);
      }
    }
  }

  // 关键词方法
  private processKeywords(imageInfo: ImageInfo): void {
    this.keywordList = []; // 清空之前的关键词

    if (imageInfo.keywords) {
      // 逗号分割关键词
      if (typeof imageInfo.keywords === 'string' && imageInfo.keywords.includes(',')) {
        const keywords = imageInfo.keywords.split(',');
        keywords.forEach((keyword: string) => {
          if (keyword.trim()) {
            this.keywordList.push(keyword.trim()); // 去掉 # 符号
          }
        });
      }
      // 单个字符关键词
      else if (typeof imageInfo.keywords === 'string' && imageInfo.keywords.trim()) {
        this.keywordList.push(imageInfo.keywords.trim()); // 去掉 # 符号
      }
      // 关键词已经是数组
      else if (Array.isArray(imageInfo.keywords)) {
        imageInfo.keywords.forEach((keyword: string) => {
          if (keyword.trim()) {
            // 包含#，去掉否则直接使用
            const cleanKeyword = keyword.startsWith('#') ? keyword.substring(1) : keyword;
            this.keywordList.push(cleanKeyword.trim());
          }
        });
      }
    }

    //使用默认标签
    if (this.keywordList.length === 0) {
      this.keywordList = ['#国风', '#二次元'];
    }
  }

  private updateCurrentTime(): void {
    const now = new Date();
    this.currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    this.currentDate =
      `${now.getMonth() + 1}/${now.getDate()} 周${['日', '一', '二', '三', '四', '五', '六'][now.getDay()]}`;
  }

  handleTouch(event: TouchEvent): void {
    const touch = event.touches[0];

    switch (event.type) {
      case TouchType.Down:
        this.startX = touch.x;
        this.startY = touch.y;
        this.isSwiping = false;
        break;

      case TouchType.Move:
        if (Math.abs(touch.x - this.startX) > 10) {
          this.isSwiping = true;
        }
        break;

      case TouchType.Up:
        const deltaX = touch.x - this.startX;
        const deltaY = touch.y - this.startY;

        if (this.isSwiping && Math.abs(deltaX) > 50 && Math.abs(deltaX) > Math.abs(deltaY)) {
          if (deltaX > 0) {
            this.slideSwitch(true)
          } else {
            this.slideSwitch(false)
          }
        } else {
          if (this.isPreviewing) {
            this.isPreviewing = !this.isPreviewing
          } else {
            this.isUIVisible = !this.isUIVisible;
          }
        }

        this.isSwiping = false;
        break;
    }
  }

  private slideSwitch(right: boolean): void {
    this.controller.pause()
    if (right) {
      if (this.currentIndex === 0) {
        this.currentIndex = this.imageInfos.list.length - 1;
      } else {
        this.currentIndex--;
      }
    } else {
      if (this.currentIndex === this.imageInfos.list.length - 1) {
        this.currentIndex = 0;
      } else {
        this.currentIndex++;
      }
    }
    this.currentImageInfo = this.imageInfos.list[this.currentIndex];
    this.currentImageInfo.like = this.listener.isFavorite(this.currentImageInfo);
    this.collectIcon = this.currentImageInfo.like ? $r('app.media.ic_collect_t') : $r('app.media.ic_collect')
    this.downIcon = this.currentImageInfo.isVideo ? $r('app.media.ic_download_vip') : $r('app.media.ic_download')
    this.setIcon = this.currentImageInfo.isVideo ? $r('app.media.id_Settings_vip') : $r('app.media.id_Settings')
    this.collectText = this.currentImageInfo.like ? '取消收藏' : '收藏'
    this.processKeywords(this.currentImageInfo); // 切换图片时重新处理关键词
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        // 主要内容区域
        this.buildMainContent()

        // 顶部操作栏
        this.buildTopBar()

        // 预览模式叠加层
        this.buildPreviewOverlay()
        // 作者信息模块
        this.buildAuthorInfo()

      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BACKGROUND_COLOR)
  }

  @Builder
  buildMainContent() {
    LoadingProgress()
      .size({ width: 72, height: 72 })
      .layoutWeight(1);

    Column() {
      Stack({ alignContent: Alignment.Top }) {
        if (this.currentImageInfo?.isVideo) {
          Video({
            src: this.currentImageInfo.src?.includes('http') ? this.currentImageInfo.src :
              $rawfile(this.currentImageInfo.src),
            previewUri: this.currentImageInfo.url,
            controller: this.controller
          })
            .width('100%')
            .height('100%')
            .controls(false)
            .muted(!this.audio)
            .loop(true)
            .onPrepared(() => {
              this.controller.start();
            })
        } else {
          Image(this.currentImageInfo?.url)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
        }
        Row()
          .width('100%')
          .height(150)
          .linearGradient({
            colors: [
              ['rgba(255,255,255,0.4)', 0.0],
              ['rgba(255,255,255,0.0)', 1.0]
            ]
          })
      }
    }
    .onTouch((event: TouchEvent) => this.handleTouch(event));
  }

  @Builder
  buildTopBar() {
    if (this.isUIVisible && !this.isPreviewing) {
      Row() {
        Image($r('app.media.ic_back'))
          .width(40)
          .aspectRatio(1)
          .margin({ left: 16 })
          .onClick(() => {
            this.listener.onBack();
          });
        Blank()
          .layoutWeight(1)
        Row() {
          Image($r('app.media.ic_heat_value'))
            .width(28)
            .aspectRatio(1)
            .margin({ right: 4 })
          Text(this.currentImageInfo?.hotValue?.toString() || '0')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
        }
        .padding({
          left: 6,
          right: 12
        })
        .backgroundColor('#33000000')
        .borderRadius(30)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .height(40)
        .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .position({ x: 0, y: 40 })
    }
  }

  // 壁纸详情展示作者名称等...
  @Builder
  buildAuthorInfo() {
    if (this.isUIVisible && !this.isPreviewing) {
      Column() {
        Stack() {
          Row()
            .width('100%')
            .height(148)
            .linearGradient({
              colors: [
                ['rgba(0,0,0,0.0)', 0.0],
                ['rgba(0,0,0,0.4)', 1.0]
              ]
            })
          Column() {
            Row() {
              Image(this.currentImageInfo?.userAvatar)
                .width(32)
                .aspectRatio(1)
                .borderRadius(20)
                .objectFit(ImageFit.Cover)
                .margin({ right: 12 })

              Column() {
                Text(this.currentImageInfo?.userName || '未知作者')
                  .fontSize(16)
                  .fontColor('#fff')
              }
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
            }
            .width('100%').padding({ left: 16, right: 16 })
            .margin({ bottom: 12 })

            Row() {
              Row() {
                // 分类标签
                Text(this.currentImageInfo?.type || '二次元')
                  .fontSize(14)
                  .height(28)
                  .fontColor('#fff')
                  .constraintSize({
                    minWidth: 72
                  })
                  .padding({
                    left: 8,
                    right: 8
                  })
                  .textAlign(TextAlign.Center)
                  .margin({ right: 8 })
                  .backgroundColor('#33000000')
                  .borderRadius(15)

                // 动态关键词标签
                ForEach(this.keywordList, (keyword: string) => {
                  Text(keyword)
                    .fontSize(14)
                    .fontColor('#fff')
                    .margin({
                      left: 8,
                      right: 8
                    })
                }, (keyword: string) => keyword)
              }

              if (this.currentImageInfo?.isVideo) {
                Row() {
                  Image($r('app.media.ic_live'))
                    .objectFit(ImageFit.Cover)
                    .width(16)
                    .height(16).margin({ left: 2 })

                  Text('动态壁纸')
                    .fontSize(14)
                    .fontColor('#fff')
                }.backgroundColor('rgba(0, 0, 0, 0.2)').borderRadius(15).padding({ left: 8, right: 8 }).height(28)
              }
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .margin({
              bottom: -50
            })
          }
        }
      }
      .margin({
        bottom: 90
      })
      .opacity(this.isUIVisible ? 1 : 0)

      this.buildBottomBar()

    }
  }

  @Builder
  buildPreviewOverlay() {
    if (this.isPreviewing) {
      Stack() {
        Column() {
          Text(this.currentTime).height(98)
            .fontSize(84)
            .fontColor(Constants.FONT_COLOR_WHITE);
          Text(this.currentDate).height(28)
            .fontSize(24)
            .fontColor(Constants.FONT_COLOR_WHITE)
        }
        .height('100%').margin({ top: 124 })

        Row() {
          Image($r('app.media.icon_flashlight'))
            .width(40)
            .height(40)
            .borderRadius(20)
            .objectFit(ImageFit.Cover)
            .align(Alignment.BottomStart)
            .margin(24)

          Image($r('app.media.icon_camera'))
            .width(40)
            .height(40)
            .borderRadius(20)
            .objectFit(ImageFit.Cover)
            .align(Alignment.BottomStart)
            .margin(24)
        }.justifyContent(FlexAlign.SpaceBetween).width('100%').height('100%').alignItems(VerticalAlign.Bottom)
      }.onTouch((event: TouchEvent) => this.handleTouch(event));
    }
  }

  @Builder
  buildBottomBar() {
    if (this.isUIVisible && !this.isPreviewing) {
      Row() {
        Column() {
          Image(this.collectIcon)
            .width(24)
            .height(24)
          Text(this.collectText)
            .fontSize(12)
            .margin({ top: 4 })
            .fontColor('#000000');
        }
        .layoutWeight(1)
        .onClick(() => {
          if (this.currentImageInfo !== undefined && this.listener.onFavorite(this.currentImageInfo)) {
            this.currentImageInfo.like = !this.currentImageInfo.like;
            this.collectIcon = this.currentImageInfo.like ? $r('app.media.ic_collect_t') : $r('app.media.ic_collect')
            this.collectText = this.currentImageInfo.like ? '取消收藏' : '收藏'
          }
        })

        this.buildActionButton(
          $r('app.media.ic_preview'),
          '预览',
          '#000000',
          () => {
            this.isPreviewing = !this.isPreviewing;
            this.updateCurrentTime()
            this.listener.onPreview(this.isPreviewing);
          }
        )

        Column() {
          SaveButton({
            icon: SaveIconStyle.FULL_FILLED,
            text: SaveDescription.DOWNLOAD,
          })
            .layoutDirection(SecurityComponentLayoutDirection.VERTICAL)
            .iconColor('#000000')
            .iconSize(22)
            .textIconSpace(6)
            .fontColor('#000000')
            .fontSize(12)
            .fontWeight(FontWeight.Normal)
            .backgroundColor('rgba(255, 255, 255, 0)')
            .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
              if (result === SaveButtonOnClickResult.SUCCESS) {
                if (this.currentImageInfo) {
                  this.listener.onDownload(this.currentImageInfo);
                }
              } else {
                this.getUIContext().getPromptAction().showToast({ message: '设置权限失败！' });
              }
            })
        }
        .layoutWeight(1)

        Column() {
          Image(this.setIcon)
            .width(24)
            .height(24)
            .fillColor('#000000');
          Text('设为壁纸')
            .fontSize(12)
            .margin({ top: 4 })
            .fontColor('#000000');
        }
        .layoutWeight(1)
        .onClick(() => {
          if (this.currentImageInfo !== undefined) {
            this.listener.onSetWallpaper(this.currentImageInfo);
          }
        })
      }
      .width('100%')
      .height(90)
      .padding({ left: 20, right: 20, bottom: 25 })
      .backgroundColor('rgba(255, 255, 255, 1)')
      .alignItems(VerticalAlign.Center)
      .opacity(this.isUIVisible ? 1 : 0)
      .animation({ duration: 300, curve: Curve.EaseInOut });
    }
  }

  @Builder
  buildActionButton(icon: Resource, text: string, color: string, onClick: () => void) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(color);
      Text(text)
        .fontSize(12)
        .margin({ top: 4 })
        .fontColor(color);
    }
    .layoutWeight(1)
    .onClick(onClick)
  }
}