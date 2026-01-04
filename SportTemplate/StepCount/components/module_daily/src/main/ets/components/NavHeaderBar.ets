import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { DailyWindowModel } from '../models/DailyWindowModel';

/**
 * 通用页面标题栏
 */
@ComponentV2
export struct NavHeaderBar {
  @Param backImg?: ResourceStr = '';
  @Param title: ResourceStr = '';
  @Param showBackBtn: boolean = false;
  @Param subTitle: ResourceStr = '';
  @Param bgColor: ResourceColor = '#00000000';
  @Param isSubTitle: boolean = true;
  @BuilderParam rightPartBuilder: () => void;
  // 自定义返回事件
  @Event onBack: () => void = () => {
    // 默认返回事件，由外部传入路由栈处理
  };
  @Consumer() isCommentInModalDialog: boolean = false
  @Local windowModel: DailyWindowModel = AppStorageV2.connect(DailyWindowModel, () => new DailyWindowModel())!;
  @BuilderParam titleBindMenu?: CustomBuilder

  build() {
    Column() {
      Row() {
        // 显示返回按钮：主动设置或者二级标题
        if (this.showBackBtn || this.isSubTitle) {
          Image(this.backImg || $r('sys.media.ohos_ic_public_arrow_left'))
            .aspectRatio(1)
            .width(40)
            .draggable(false)
            .borderRadius(CommonConstants.HALF_PERCENT)
            .margin({ right: CommonConstants.SPACE_S })
            .stateStyles({
              pressed: {
                .backgroundColor($r('sys.color.interactive_pressed'))
              },
              normal: {
                .backgroundColor(Color.Transparent)
              },

            })
            .onClick(() => {
              this.onBack();
            })
        }
        Column() {
          if (this.title) {
            if (this.titleBindMenu) {
              Text(this.title)
                .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
                .bindMenu(this.titleBindMenu)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
            } else {
              Text(this.title)
                .fontColor($r('sys.color.font_primary'))
                .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
                .fontWeight(FontWeight.Bold)
            }
          }
          if (this.subTitle) {
            Text(this.subTitle)
              .fontSize($r('sys.float.Subtitle_S'))
              .fontColor($r('sys.color.font_secondary'))
          }
        }.alignItems(HorizontalAlign.Start)

        if (this.rightPartBuilder) {
          this.rightPartBuilder()
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(56)
    }
    .padding({
      left: CommonConstants.PADDING_PAGE,
      top: this.isCommentInModalDialog ? CommonConstants.PADDING_S : this.windowModel.windowTopPadding,
      right: CommonConstants.PADDING_PAGE,
    })
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(this.bgColor)
  }
}

