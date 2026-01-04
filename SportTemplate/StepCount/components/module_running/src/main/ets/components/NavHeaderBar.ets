import { AppStorageV2 } from '@kit.ArkUI';
import { RunCommonConstants } from '../common/RunCommonConstants';
import { RunWindowModel } from '../models/RunWindowModel';

/**
 * 通用页面标题栏
 */
@ComponentV2
export struct NavHeaderBar {
  @Param title: ResourceStr = '';
  @Param subTitle: ResourceStr = '';
  @Param showBackBtn: boolean = false;
  @Param bgColor: ResourceColor = '#00000000';
  @Param backImg: ResourceStr = $r('app.media.ic_back');
  @Param isSubTitle: boolean = true;
  @BuilderParam rightPartBuilder: () => void;
  // 自定义返回事件
  @Event onBack?: () => void
  @Local windowModel: RunWindowModel = AppStorageV2.connect(RunWindowModel, () => new RunWindowModel())!;
  @Consumer() isCommentInModalDialog: boolean = false
  @BuilderParam titleBindMenu?: CustomBuilder

  build() {
    Column() {
      Row() {
        // 显示返回按钮：主动设置或者二级标题
        if (this.showBackBtn || this.isSubTitle) {
          Image(this.backImg)
            .width($r('app.float.head_icon_width'))
            .aspectRatio(1)
            .draggable(false)
            .margin({ right: RunCommonConstants.SPACE_S })
            .borderRadius(RunCommonConstants.HALF_PERCENT)
            .stateStyles({
              normal: { .backgroundColor(Color.Transparent)
              },
              pressed: { .backgroundColor($r('sys.color.interactive_pressed'))
              },
            })
            .onClick(() => {
              if (this.onBack) {
                this.onBack();
              }
            })
        }
        Column() {
          if (this.title) {
            if (this.titleBindMenu) {
              Text(this.title)
                .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
                .bindMenu(this.titleBindMenu)
            } else {
              Text(this.title)
                .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
                .fontColor($r('sys.color.font_primary'))
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
      .height($r('app.float.nav_header_height'))
      .width(RunCommonConstants.FULL_PERCENT)
    }
    .padding({
      left: RunCommonConstants.PADDING_PAGE,
      right: RunCommonConstants.PADDING_PAGE,
      top: this.isCommentInModalDialog ? RunCommonConstants.PADDING_S : this.windowModel.windowTopPadding,
    })
    .width(RunCommonConstants.FULL_PERCENT)
    .backgroundColor(this.bgColor)
  }
}