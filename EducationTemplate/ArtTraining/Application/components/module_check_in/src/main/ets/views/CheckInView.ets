import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, CommonButton, ContainerColumn } from 'module_ui_base';
import { CheckInDataModel } from '../commons/Models';
import { MediaPreviewSheet } from '../components/MediaPreviewSheet';
import { PickerPreviewItem, PickerResourceType, PickerUtil } from '../utils/PickerUtil';

@ComponentV2
export struct CheckInView {
  @Param
  title: string = '任务详情';
  @Param
  maxResourceNumber: number = 9;
  @Param
  bgColor: ResourceColor = $r('app.color.system_color_background_auxiliary');
  @Param
  textLimit: number = 200;
  @BuilderParam
  customDesc: () => void = this.emptyBuilder;
  @Event
  handleSubmit: (data: CheckInDataModel) => void;
  @Local
  textDetail: string = ''
  @Local
  pickerUtil: PickerUtil = new PickerUtil(this.getUIContext(), this.maxResourceNumber);
  @Local
  showPreview: boolean = false;
  @Local
  previewItem: PickerPreviewItem | undefined = undefined;
  @Local
  curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  @Computed
  get previewGridHeight() {
    const rowNum = Math.ceil(this.pickerUtil.mediaPreviewList.length / 3);
    return rowNum * 118;
  }

  @Computed
  get previewGridTemplate(){
    if(this.curBreakpoint.value === BreakpointTypeEnum.MD){
      return '1fr 1fr 1fr 1fr 1fr'
    }
    return '1fr 1fr 1fr'
  }

  aboutToAppear(): void {
    BreakpointSystem.register(this.getUIContext())
  }

  aboutToDisappear(): void {
    this.pickerUtil.clearResource();
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // 打卡任务描述
          this.taskDescBuilder();
          // 文字输入框
          this.checkInInputBuilder();
          // 媒体内容选择
          this.mediaPreviewBuilder();
        }
      }
      .align(Alignment.Top)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .padding($r('app.string.space_l'));

      this.bottomButtonBuilder();
    }
    .layoutWeight(1)

    .backgroundColor(this.bgColor);
  }

  @Builder
  taskDescBuilder() {
    ContainerColumn({ title: this.title }) {
      this.customDesc?.();
    };
  }

  @Builder
  checkInInputBuilder() {
    ContainerColumn() {
      TextArea({
        placeholder: '请输入打卡内容',
        text: this.textDetail,
      })
        .placeholderFont({ size: $r('app.string.font_size_14') })
        .placeholderColor($r('app.color.font_color_level3'))
        .height(150)
        .maxLength(this.textLimit)
        .borderRadius($r('app.string.border_radius_8'))
        .showCounter(true)
        .fontSize($r('app.string.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .backgroundColor($r('app.color.system_color_background_grey_level2'))
        .onChange((value: string) => {
          this.textDetail = value;
        });

      Row() {
        this.filePickButtonBuilder($r('app.media.ic_camera'), PickerResourceType.IMAGE);
        this.filePickButtonBuilder($r('app.media.ic_video'), PickerResourceType.VIDEO);
      }
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.SpaceAround)
      .margin({
        top: $r('app.string.space_xl'),
        bottom: $r('app.string.space_xs'),
      });
    };
  }

  @Builder
  bottomButtonBuilder() {
    Row() {
      CommonButton({
        fullWidth: true,
        title: '提交打卡',
        handleClick: () => {
          const checkInData: CheckInDataModel = new CheckInDataModel()
          checkInData.textDetail = this.textDetail
          this.pickerUtil.mediaPreviewList.forEach((item) => {
            switch (item.type) {
              case PickerResourceType.IMAGE:
                checkInData.pictureDetail.push(item.uri);
                break;
              case PickerResourceType.VIDEO:
                checkInData.videoDetail.push(item.uri);
                break;
              case PickerResourceType.AUDIO:
                checkInData.audioDetail.push(item.uri);
                break;
              default:
                break;
            }
          });
          this.handleSubmit?.(checkInData);
        },
      });
    }
    .width($r('app.string.size_percent_full'))
    .padding($r('app.string.space_s'))
    .backgroundColor($r('app.color.system_color_background_white'))
  }

  @Builder
  filePickButtonBuilder(src: ResourceStr, type: PickerResourceType) {
    Image(src)
      .width(24)
      .height(24)
      .onClick(() => {
        this.pickerUtil.selectResource(type);
      });
  }

  @Builder
  mediaPreviewBuilder() {
    Grid() {
      ForEach(this.pickerUtil.mediaPreviewList, (item: PickerPreviewItem, index: number) => {
        GridItem() {
          this.mediaItemBuilder(item, index);
        }
        .width(96)
        .height(96)
        .onClick(() => {
          this.previewItem = item;
          this.showPreview = true;
        });
      }, (item: PickerPreviewItem, index: number) => index + JSON.stringify(item.uri));
    }
    .columnsTemplate(this.previewGridTemplate)
    .columnsGap(8)
    .rowsGap(8)
    .margin({ top: $r('app.string.space_m') })
    .height(this.previewGridHeight)
    .bindSheet($$this.showPreview, this.fullScreenPreviewBuilder(), {
      showClose: false,
      preferType:SheetType.CENTER,
    });

  }

  @Builder
  mediaItemBuilder(item: PickerPreviewItem, index: number) {
    Row() {
      Image($r('app.media.ic_delete_circle'))
        .width(16)
        .height(16)
        .zIndex(9)
        .position({ right: 8, top: 8 })
        .onClick(() => {
          this.pickerUtil.deleteItem(index);
        });

      if (item.type === PickerResourceType.IMAGE) {
        Image(item.uri);
      } else {
        Stack({ alignContent: Alignment.Center }) {
          Image(item.type === PickerResourceType.VIDEO ?
          $r('app.media.ic_record_video') :
          $r('app.media.ic_record_audio'))
            .width(24);
        }
        .width($r('app.string.size_percent_full'))
        .height($r('app.string.size_percent_full'))
        .backgroundColor($r('app.color.system_color_background_grey_level1'));
      }
    }
    .width(96)
    .height(96)
    .borderRadius($r('app.string.border_radius_16'))
    .clip(true);
  }

  @Builder
  fullScreenPreviewBuilder() {
    MediaPreviewSheet({
      previewItem: this.previewItem,
      clickBackButton: () => {
        this.showPreview = false;
        this.previewItem = undefined;
      },
    });
  }

  @Builder
  emptyBuilder() {
  }
}