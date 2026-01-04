import { ImagePreview, PreviewVerticalAlign } from 'module_imagepreview';
import { NavHeaderBar } from '../components/NavHeaderBar';
import { FeedbackConstants } from '../common/FeedbackConstants';
import { SubmitVM } from '../viewmodels/SubmitVM';

@Builder
export function SubmitPageBuilder() {
  SubmitPage()
}

@ComponentV2
export struct SubmitPage {
  @Provider() stack: NavPathStack = new NavPathStack();
  @Local vm: SubmitVM = new SubmitVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: '反馈问题' })

        Scroll() {
          Column({ space: 16 }) {
            this.textInfo()
            this.imageInfo()
            this.contactInfo()
          }.padding({ left: 16, right: 16 })
          .width(FeedbackConstants.FULL_PERCENT)
          .height(FeedbackConstants.FULL_PERCENT)
        }
        .width(FeedbackConstants.FULL_PERCENT)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)

        this.btnInfo()
      }
    }.backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .padding({
      bottom: this.vm.feedbackModel.windowBottomPadding,
    })
    .onReady((context) => {
      this.stack = context.pathStack;
      this.vm.stack = this.stack;
    })
  }

  @Builder
  textInfo() {
    Column() {
      Row() {
        Text('问题描述（必填）')
          .fontColor(Color.Black)
          .fontSize(16)
      }.width('100%')

      TextArea({
        placeholder: '请详细描述您的问题',
        text: $$this.vm.body,
      })
        .fontSize(16 * this.vm.feedbackModel.fontSizeRatio)
        .placeholderColor($r('sys.color.font_tertiary'))
        .placeholderFont({ size: 16 * this.vm.feedbackModel.fontSizeRatio })
        .backgroundColor(Color.Transparent)
        .maxLength(100)
        .showCounter(true)
        .height(140)
        .borderRadius(0)
        .padding({
          left: 0,
          right: 0,
          top: FeedbackConstants.PADDING_S,
          bottom: FeedbackConstants.PADDING_S,
        })
    }
    .padding({
      left: FeedbackConstants.PADDING_PAGE,
      right: FeedbackConstants.PADDING_PAGE,
      top: FeedbackConstants.PADDING_L,
    }).backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  imageInfo() {
    Column() {
      Row() {
        Text('问题截图（选填）')
          .fontColor(Color.Black)
          .fontSize(16)

        Blank()

        Text(`${this.vm.imgArr.length}/${FeedbackConstants.MAX_IMG_COUNT}`)
          .fontSize(12)
          .fontColor('#66000000')
          .margin({ top: FeedbackConstants.PADDING_M })
      }.width('100%')
      .alignItems(VerticalAlign.Center)

      Grid() {
        if (this.vm.imgArr.length < FeedbackConstants.MAX_IMG_COUNT) {
          GridItem() {
            this.uploadBox()
          }
        }

        ForEach(this.vm.imgArr, (v: string, index: number) => {
          GridItem() {
            this.imageBox(v, index)
          }
        }, (v: string, index: number) => v)
      }
      .margin({ top: 12 })
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(12)
      .rowsGap(8)
      .maxCount(FeedbackConstants.MAX_IMG_COUNT)
      .constraintSize({ maxHeight: '50%' })
      .scrollBar(BarState.Off)
    }
    .padding({
      left: FeedbackConstants.PADDING_PAGE,
      top: FeedbackConstants.PADDING_PAGE,
      right: FeedbackConstants.PADDING_PAGE,
      bottom: FeedbackConstants.PADDING_L,
    })
    .margin({
      top: FeedbackConstants.PADDING_M,
    }).backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  contactInfo() {
    Column() {
      Text('联系方式（选填）')
        .fontSize(16 * this.vm.feedbackModel.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
      Stack() {
        TextInput({
          text: $$this.vm.contactPhone,
          placeholder: '请填写联系手机',
        })
          .type(InputType.PhoneNumber)
          .width(FeedbackConstants.FULL_PERCENT)
          .height(FeedbackConstants.TEXT_INPUT_HEIGHT)
          .padding(0)
          .fontSize(16 * this.vm.feedbackModel.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: 14 * this.vm.feedbackModel.fontSizeRatio })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(0)
          .borderWidth({ bottom: 0.5 })
          .borderColor($r('sys.color.comp_divider'))
          .maxLength(11)
        Image($r('app.media.ic_public_close_circle'))
          .width(FeedbackConstants.ICON_WIDTH)
          .draggable(false)
          .visibility(this.vm.contactPhone ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.vm.contactPhone = '';
          })
      }
      .alignContent(Alignment.End)

    }.backgroundColor(Color.White)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: FeedbackConstants.PADDING_PAGE,
      right: FeedbackConstants.PADDING_PAGE,
      top: FeedbackConstants.PADDING_L,
    })
  }

  @Builder
  btnInfo() {
    Column() {
      Button() {
        Row({ space: 4 }) {
          LoadingProgress()
            .width(24)
            .aspectRatio(1)
            .color($r('sys.color.icon_on_primary'))
            .visibility(this.vm.loading ? Visibility.Visible : Visibility.None)
          Text(this.vm.loading ? '正在提交反馈...' : '提交反馈')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
        }
      }
      .backgroundColor('#FC7A17')
      .width(FeedbackConstants.FULL_PERCENT)
      .height(FeedbackConstants.BTN_HEIGHT)
      .enabled(!this.vm.loading)
      .onClick(() => {
        this.vm.submit();
      })
    }
    .padding({
      top: FeedbackConstants.PADDING_S,
      bottom: FeedbackConstants.PADDING_S,
      left: FeedbackConstants.PADDING_PAGE,
      right: FeedbackConstants.PADDING_PAGE,
    })
  }

  @Builder
  uploadBox() {
    Column({ space: 4 }) {
      Image($r('app.media.ic_plus2'))
        .width(FeedbackConstants.ICON_WIDTH)
        .aspectRatio(1)
        .draggable(false)
        .fillColor($r('sys.color.icon_secondary'))
    }
    .width(FeedbackConstants.FULL_PERCENT)
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(async () => {
      this.vm.selectPhoto();
    })
  }

  @Builder
  imageBox(v: string, index: number) {
    Stack() {
      Image(v)
        .width(FeedbackConstants.FULL_PERCENT)
        .aspectRatio(1)
      Image($r('app.media.ic_public_close_circle'))
        .width(FeedbackConstants.ICON_WIDTH)
        .aspectRatio(1)
        .draggable(false)
        .borderRadius(16)
        .margin({
          top: FeedbackConstants.SPACE_8,
          right: FeedbackConstants.SPACE_8,
        })
        .onClick(() => {
          this.vm.imgArr.splice(index, 1);
        })
    }
    .borderRadius(16)
    .alignContent(Alignment.TopEnd)
    .clip(true)
    .onClick(() => {
      ImagePreview.show(this.vm.imgArr, {
        startIndex: index,
        showIndex: true,
        loop: false,
        isBasicMode: true,
        indexPosition: PreviewVerticalAlign.Top,
      })
    })
  }

  @Builder
  customDivider() {
    Row().width(FeedbackConstants.FULL_PERCENT).height(8).backgroundColor($r('sys.color.background_secondary'))
  }
}