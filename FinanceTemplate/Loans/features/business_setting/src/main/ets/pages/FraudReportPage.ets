import {
  CommonConstants,
  DoneConfirmDialog,
  RouterMap,
  RouterUtils,
  WindowModel
} from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { ImagePreview, PreviewVerticalAlign } from 'module_imagepreview';
import { Constants } from '../constants/Constants';
import { FraudReportInfo, fraudReportList } from '../types/Types';
import { FraudReportViewModel } from '../viewmodels/FraudReportVM';
import { AppStorageV2, promptAction } from '@kit.ArkUI';

@Builder
export function FraudReportPageBuilder() {
  FraudReportPage()
}

@ComponentV2
struct FraudReportPage {
  @Local vm: FraudReportViewModel = new FraudReportViewModel();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '诈骗举报',
      })
      Scroll() {
        Column({ space: CommonConstants.SPACE_L }) {
          this.FraudReportType()
          this.ReportDescription()
          this.imageInfo()
          Blank().layoutWeight(1)
          this.submit()
        }
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          top: CommonConstants.SPACE_M,
        })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
      .padding({ bottom: this.windowModel.windowBottomPadding })
    }
    .hideTitleBar(true)
    .backgroundColor('#FFF1F3F5')
    .onReady(() => {
      fraudReportList.forEach(item => {
        item.isSelect = false
      })
    })
  }

  @Builder
  FraudReportType() {
    Column({ space: CommonConstants.SPACE_L }) {
      Text('举报类型')
        .textAlign(TextAlign.Start)
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .lineHeight(21)
        .fontColor($r('sys.color.font_primary'))
      Row() {
        ForEach(fraudReportList, (item: FraudReportInfo, index: number) => {
          Text(item.title)
            .fontSize(12)
            .lineHeight(16)
            .fontColor(item.isSelect ? Color.White : '#E6000000')
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textAlign(TextAlign.Center) // 限制最多显示1行
            .padding({
              left: 8,
              right: 8,
              top: 5,
              bottom: 5,
            })
            .backgroundColor(item.isSelect ? '#FF317AF7' : '#0D000000')
            .onClick(() => {
              fraudReportList[index].isSelect = !fraudReportList[index].isSelect;
            })
            .borderRadius(21)
            .width(72)
            .height(28)
        }, (item: FraudReportInfo, index: number) => JSON.stringify(item.isSelect) + index)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .width('100%')
  }

  @Builder
  ReportDescription() {
    Column({ space: CommonConstants.SPACE_L }) {
      Row() {
        Text('举报描述（必填）')
          .textAlign(TextAlign.Start)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .lineHeight(21)
          .fontColor($r('sys.color.font_primary'))

        Text(this.vm.reportDescription.length + '/100')
          .fontSize(14)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 10, right: 10 })

      TextArea({
        placeholder: '请详细描述举报内容',
        text: this.vm.reportDescription
      })
        .placeholderColor($r('sys.color.font_secondary'))
        .maxLength(100)
        .maxLines(5)
        .onChange((value: string) => {
          this.vm.reportDescription = value;
        })
        .backgroundColor(Color.Transparent)
        .height(140)
        .borderRadius(10)
        .padding({
          left: 10,
          right: 10,
          top: Constants.PADDING_S,
          bottom: Constants.PADDING_S,
        })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding(Constants.PADDING_L)
    .borderRadius(Constants.RADIUS_16)
  }

  @Builder
  imageInfo() {
    Column({ space: CommonConstants.SPACE_L }) {
      Row() {
        Text('上传凭证（选填）')
          .textAlign(TextAlign.Start)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .lineHeight(21)
          .fontColor($r('sys.color.font_primary'))
        Text(`${this.vm.imgArr.length}/${Constants.MAX_IMG_COUNT}`)
          .fontSize(14)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 10, right: 10 })

      Grid() {
        if (this.vm.imgArr.length < Constants.MAX_IMG_COUNT) {
          GridItem() {
            this.uploadBox()
          }
        }

        ForEach(this.vm.imgArr, (v: string, index: number) => {
          GridItem() {
            this.imageBox(v, index)
          }
        }, (v: string) => v)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(12)
      .rowsGap(8)
      .maxCount(Constants.MAX_IMG_COUNT)
      .constraintSize({ maxHeight: '50%' })
      .scrollBar(BarState.Off)

    }
    .padding({
      left: Constants.PADDING_PAGE,
      right: Constants.PADDING_PAGE,
      bottom: Constants.PADDING_L,
    })
    .margin({
      top: Constants.PADDING_M,
    })
    .backgroundColor('#FFFFFF')
    .padding(Constants.PADDING_L)
    .borderRadius(Constants.RADIUS_16)
  }

  @Builder
  submit() {
    // 提交举报按钮（位于页面底部）
    Text('提交')
      .backgroundColor('#317AF7')
      .fontColor(Color.White)
      .fontSize(16)
      .lineHeight(19)
      .width('100%')
      .height(40)
      .padding({ top: 10, bottom: 10 })
      .textAlign(TextAlign.Center)
      .borderRadius(20)
      .onClick(() => {
        let isSelectAny = fraudReportList.some(item => item.isSelect)
        if (!isSelectAny) {
          promptAction.showToast({ message: '请至少选择一种举报类型' });
          return
        }
        if (!this.vm.reportDescription.trim()) {
          promptAction.showToast({ message: '请完善信息' });
          return
        }
        DoneConfirmDialog.show({
          primaryTitle: '',
          content: '举报已提交\n我们将尽快核查处理',
          priBtnV: '知道了',
          confirm: () => {
            RouterUtils.pop(RouterMap.CONTACT_PAGE)
          },
        })
      })
  }

  @Builder
  imageBox(v: string, index: number) {
    Stack() {
      Image(v)
        .width(Constants.FULL_PERCENT)
        .aspectRatio(1)
      Image($r('app.media.ic_close'))
        .width(Constants.ICON_WIDTH)
        .aspectRatio(1)
        .draggable(false)
        .borderRadius(16)
        .margin({
          top: Constants.SPACE_8,
          right: Constants.SPACE_8,
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
  uploadBox() {
    Column({ space: 4 }) {
      Image($r('app.media.ic_plus_two'))
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
      this.vm.selectPhoto();
    })
  }
}
