import { KeyboardAvoidMode, window } from '@kit.ArkUI';
import { ImagePreview, PreviewVerticalAlign } from 'module_imagepreview';
import {
  Constants,
  DEFAULT_IMAGE_PARAM,
  DEFAULT_VIDEO_PARAM,
  PostImgVideoItem,
  UploadType,
  MediaParams,
  GRID_ROW_OPTIONS,
  COL_SPAN,
  COL_OFFSET,
} from '../constants/Constants';
import { MediaUtils } from '../utils/MediaUtils';
import { FileUtils } from '../utils/FileUtils';
import { getPageMargin } from '../utils/Common';

@ComponentV2
export struct PublishPostComp {
  // 字体大小比例
  @Param fontRatio: number = 1;
  // 图片参数
  @Param imageParams: MediaParams = DEFAULT_IMAGE_PARAM;
  // 视频参数
  @Param videoParams: MediaParams = DEFAULT_VIDEO_PARAM;
  // 图文变化的回调
  @Event onChange: (body: string, mediaList: PostImgVideoItem[]) => void = () => {
  };
  @Event onHideNewsTab: (isHide: boolean) => void = () => {
  }
  // 是否是新闻发表页
  @Param isArticlePost: boolean = false
  @Local body: string = '';
  @Local imgList: PostImgVideoItem[] = [];
  @Local videoList: PostImgVideoItem[] = [];
  @Local columnsNum: number = 3;
  @Local breakpoint: string = 'sm';

  @Monitor('body', 'imgList.length', 'videoList.length')
  onContentChange(monitor: IMonitor) {
    this.onChange(this.body, [...this.imgList, ...this.videoList]);
  }

  aboutToAppear(): void {
    window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', this.onKeyBoardCB);
    })
  }

  build() {
    Column() {
      GridRow(GRID_ROW_OPTIONS) {
        GridCol({
          span: COL_SPAN,
          offset: COL_OFFSET,
        }) {
          Scroll() {
            Column() {
              this.textArea()
              this.mediaArea()
            }
            .width(Constants.FULL_PERCENT)
            .alignItems(HorizontalAlign.Start)
          }
          .width(Constants.FULL_PERCENT)
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
      }
      .layoutWeight(1)
      .padding({
        left: getPageMargin(this.breakpoint),
        right: getPageMargin(this.breakpoint),
      })
      .onBreakpointChange((bp: string) => {
        this.breakpoint = bp;
        if (bp === 'sm') {
          this.columnsNum = 3;
        } else {
          this.columnsNum = 6;
        }
      })

      this.actionBar()
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .onAppear(() => {
      this.handleKeyBoard();
    })
    .onDisAppear(() => {
      this.cancelHandleKeyBoard()
    })
  }

  @Builder
  textArea() {
    TextArea({
      placeholder: '畅所欲言，发表你的想法',
      text: $$this.body,
    })
      .fontSize(16 * this.fontRatio)
      .placeholderColor($r('sys.color.font_tertiary'))
      .placeholderFont({ size: 16 * this.fontRatio })
      .backgroundColor(Color.Transparent)
      .maxLength(Constants.MAX_BODY_WORD_LIMIT)
      .height(Constants.MAX_TEXTAREA_HEIGHT)
      .padding(0)
      .borderRadius(0)
  }

  @Builder
  mediaArea() {
    Column({ space: Constants.SPACE_8 }) {
      Grid() {
        if (this.showUploadBox) {
          GridItem() {
            this.uploadBox()
          }
        }

        ForEach(this.imgList, (v: PostImgVideoItem, index: number) => {
          GridItem() {
            this.imageBox(v.picVideoUrl, index)
          }
        }, (v: PostImgVideoItem) => v.picVideoUrl)

        ForEach(this.videoList, (v: PostImgVideoItem, index: number) => {
          GridItem() {
            this.videoBox(v.surfaceUrl, index)
          }
        }, (v: PostImgVideoItem) => v.picVideoUrl)
      }
      .columnsTemplate(this.getColumnsTemplate)
      .columnsGap(12)
      .rowsGap(8)
      .maxCount(this.getMaxCount)
      .scrollBar(BarState.Off)

      Text(this.isImageType ? `图片格式jpg/png，最多支持上传${this.imageParams.maxLimit}张图片` :
        `视频大小不超过${this.videoParams.maxSize ?? DEFAULT_VIDEO_PARAM.maxSize}MB，且一次只可上传一个视频`)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_tertiary'))
        .visibility((this.imgList.length || this.videoList.length) > 0 ? Visibility.Visible : Visibility.Hidden)
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 16, bottom: 16 })
  }

  @Builder
  actionBar() {
    Row() {
      Image($r('app.media.ic_public_camera'))
        .width(Constants.ICON_WIDTH)
        .height(Constants.ICON_WIDTH)
        .draggable(false)
        .fillColor($r('sys.color.font_primary'))
        .onClick(() => {
          this.uploadImage();
        })
      Image($r('app.media.ic_public_recorder'))
        .width(Constants.ICON_WIDTH)
        .height(Constants.ICON_WIDTH)
        .draggable(false)
        .fillColor($r('sys.color.font_primary'))
        .margin({ left: Constants.PADDING_16 })
        .onClick(() => {
          this.uploadVideo();
        })
      Blank()
      Text(`${this.body.length}/${Constants.MAX_BODY_WORD_LIMIT}`)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.ACTION_BAR_HEIGHT)
    .padding({
      left: getPageMargin(this.breakpoint),
      right: getPageMargin(this.breakpoint),
    })
    .shadow({
      offsetY: -2,
      radius: 4,
      color: '#F2F2F2',
    })
  }

  @Builder
  uploadBox() {
    Column({ space: 4 }) {
      Image($r('app.media.ic_plus2'))
        .width(Constants.ICON_WIDTH)
        .aspectRatio(1)
        .draggable(false)
        .fillColor($r('sys.color.icon_secondary'))
    }
    .width(Constants.FULL_PERCENT)
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(async () => {
      this.plusBtnClick();
    })
  }

  @Builder
  imageBox(v: string, index: number) {
    Stack() {
      Image(v)
        .width(Constants.FULL_PERCENT)
        .aspectRatio(1)
        .draggable(false)
      Image($r('app.media.ic_public_close_circle'))
        .width(Constants.ICON_WIDTH)
        .aspectRatio(1)
        .draggable(false)
        .borderRadius(16)
        .margin({
          top: Constants.SPACE_8,
          right: Constants.SPACE_8,
        })
        .onClick(() => {
          this.imgList.splice(index, 1);
        })
    }
    .borderRadius(16)
    .alignContent(Alignment.TopEnd)
    .clip(true)
    .onClick(() => {
      ImagePreview.show(this.imgList.map(v => v.picVideoUrl), {
        startIndex: index,
        showIndex: true,
        loop: false,
        isBasicMode: true,
        indexPosition: PreviewVerticalAlign.Top,
      })
    })
  }

  @Builder
  videoBox(v: string, index: number) {
    Stack() {
      Stack() {
        Image(v)
          .width(Constants.FULL_PERCENT)
          .aspectRatio(1)
          .draggable(false)
        Row()
          .width(Constants.FULL_PERCENT)
          .aspectRatio(1)
          .backgroundColor($r('sys.color.mask_fourth'))
        Image($r('app.media.ic_public_close_circle'))
          .width(Constants.ICON_WIDTH)
          .aspectRatio(1)
          .draggable(false)
          .borderRadius(16)
          .margin({
            top: Constants.SPACE_8,
            right: Constants.SPACE_8,
          })
          .onClick(() => {
            this.videoList.splice(index, 1);
          })
      }
      .alignContent(Alignment.TopEnd)

      Image($r('app.media.ic_video_flag'))
        .width(Constants.ICON_WIDTH)
        .draggable(false)
    }
    .alignContent(Alignment.Center)
    .borderRadius(16)
    .clip(true)
  }

  uploadImage() {
    if (this.videoList.length) {
      this.getUIContext().getPromptAction().showToast({
        message: '图片与视频一次只可上传一种',
        bottom: this.toastMarginBottom,
      });
      return;
    }
    if (this.imgList.length >= this.imageParams.maxLimit) {
      this.getUIContext().getPromptAction().showToast({
        message: '已添加的图片数量已达上限',
        bottom: this.toastMarginBottom,
      });
      return;
    }
    this.plusBtnClick(UploadType.Image);
  }

  uploadVideo() {
    if (this.imgList.length) {
      this.getUIContext().getPromptAction().showToast({
        message: '图片与视频一次只可上传一种',
        bottom: this.toastMarginBottom,
      });
      return;
    }
    if (this.videoList.length >= this.videoParams.maxLimit) {
      this.getUIContext().getPromptAction().showToast({
        message: '已添加的视频数量已达上限',
        bottom: this.toastMarginBottom,
      });
      return;
    }
    this.plusBtnClick(UploadType.Video);
  }

  async plusBtnClick(type?: UploadType) {
    let isUploadImage = true;
    if (type && type === UploadType.Image) {
      isUploadImage = true;
    } else if (type && type === UploadType.Video) {
      isUploadImage = false;
    } else {
      isUploadImage = this.isImageType;
    }
    let params = isUploadImage ? this.imageParams : this.videoParams;
    let list = isUploadImage ? this.imgList : this.videoList;

    const uriList = await MediaUtils.selectMedia({
      type: params.type,
      maxLimit: params.maxLimit - list.length,
      maxSize: params.maxSize,
    });
    uriList.forEach(async (v: string) => {
      const item = new PostImgVideoItem();
      item.picVideoUrl = FileUtils.handleUri(v, isUploadImage ? 'png' : 'mp4');
      if (!isUploadImage) {
        const thumbnail = await MediaUtils.getVideoThumbnail(v);
        item.surfaceUrl = await FileUtils.writePixelMap(thumbnail);
      }
      list.push(item);
    })
  }

  handleKeyBoard() {
    // 键盘避让设置为压缩模式
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  onKeyBoardCB: (height: number) => void = (height: number) => {
    animateTo({
      duration: 200,
      curve: Curve.EaseInOut,
    }, () => {
      if (!height) {
        this.onHideNewsTab(false)
      } else {
        this.onHideNewsTab(true)
      }
    });
  };

  cancelHandleKeyBoard() {
    // 键盘避让还原成上抬模式
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }

  @Computed
  get toastMarginBottom() {
    return 40;
  }

  @Computed
  get getMaxCount() {
    return Math.max(this.imageParams.maxLimit, this.videoParams.maxLimit) + 1;
  }

  @Computed
  get getColumnsTemplate() {
    return Array(this.columnsNum).fill('1fr').join(' ');
  }

  @Computed
  get isImageType() {
    return this.imgList.length > 0;
  }

  @Computed
  get showUploadBox() {
    if (this.imgList.length && this.imgList.length < this.imageParams.maxLimit) {
      return true;
    }
    if (this.videoList.length && this.videoList.length < this.videoParams.maxLimit) {
      return true;
    }
    return false;
  }
}