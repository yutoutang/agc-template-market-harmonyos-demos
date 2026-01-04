import { AppStorageV2 } from '@kit.ArkUI';
import { LineCommonConstants } from '../common/LineCommonConstants';
import { LineLogger } from '../common/LineLogger';
import { LineWindowModel } from '../models/LineWindowModel';

/**
 * 通用页面标题栏
 */
@ComponentV2
export struct NavHeaderBar {
  @Param title: ResourceStr = '';
  @Param showBackBtn: boolean = false;
  @Param bgColor: ResourceColor = '#FFFFFF';
  @Param fontColor: ResourceColor = $r('sys.color.font_primary');
  @Param backImg: ResourceStr = $r('app.media.ic_back');
  @Param isSubTitle: boolean = true;
  @BuilderParam rightPartBuilder: () => void;
  @Local windowModel: LineWindowModel = AppStorageV2.connect(LineWindowModel, () => new LineWindowModel())!;
  @Consumer() isCommentInModalDialog: boolean = false
  // 自定义返回事件
  @Event onBack: () => void = () => {
    LineLogger.info('onBack Event')
  }

  build() {
    Column() {
      Row() {
        // 显示返回按钮：主动设置或者二级标题
        if (this.showBackBtn || this.isSubTitle) {
          Image(this.backImg)
            .width($r('app.float.head_icon_width'))
            .aspectRatio(1)
            .draggable(false)
            .margin({ right: LineCommonConstants.SPACE_S })
            .borderRadius(LineCommonConstants.HALF_PERCENT)
            .stateStyles({
              normal: { .backgroundColor(Color.Transparent)
              },
              pressed: { .backgroundColor($r('sys.color.interactive_pressed'))
              },
            })
            .onClick(() => {
              this.onBack();
            })
        }
        if (this.title) {
          Text(this.title)
            .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
            .fontColor(this.fontColor)
        }
        if (this.rightPartBuilder) {
          this.rightPartBuilder()
        }
      }
      .height($r('app.float.nav_header_height'))
      .width(LineCommonConstants.FULL_PERCENT)
    }
    .margin({
      top: this.isCommentInModalDialog ? LineCommonConstants.PADDING_S : this.windowModel.windowTopPadding,
    })
    .padding({
      left: LineCommonConstants.PADDING_PAGE,
      right: LineCommonConstants.PADDING_PAGE,
    })
    .width(LineCommonConstants.FULL_PERCENT)
  }
}