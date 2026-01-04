import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, RouterUtils, WindowModel } from 'lib_common';

/**
 * 通用页面标题栏
 */
@ComponentV2
export struct NavHeaderBar {
  @Param title: ResourceStr = '';
  @Param bgColor: ResourceColor = '#00000000';
  @Param subTitle: ResourceStr = '';
  @BuilderParam rightPartBuilder: () => void;
  @Param showBackBtn: boolean = false;
  @Param backImg: ResourceStr = $r('app.media.ic_back');
  @Param isSubTitle: boolean = true;
  // 自定义返回事件
  @Event onBack: () => void = () => {
    RouterUtils.pop()
  };
  @BuilderParam titleBindMenu?: CustomBuilder
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Consumer() isCommentInModalDialog: boolean = false

  build() {
    Column() {
      Row() {
        // 显示返回按钮：主动设置或者二级标题
        if (this.showBackBtn || this.isSubTitle) {
          Image(this.backImg)
            .draggable(false)
            .width($r('app.float.head_icon_width'))
            .borderRadius(CommonConstants.HALF_PERCENT)
            .aspectRatio(1)
            .margin({ right: CommonConstants.SPACE_S })
            .stateStyles({
              pressed: { .backgroundColor($r('sys.color.interactive_pressed'))
              },
              normal: { .backgroundColor(Color.Transparent)
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
                .fontWeight(FontWeight.Bold)
                .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
                .fontColor($r('sys.color.font_primary'))
                .bindMenu(this.titleBindMenu)
            } else {
              Text(this.title)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
                .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
            }
          }
          if (this.subTitle) {
            Text(this.subTitle)
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Subtitle_S'))
          }
        }
        .alignItems(HorizontalAlign.Start)

        if (this.rightPartBuilder) {
          this.rightPartBuilder()
        }
      }
      .height($r('app.float.nav_header_height'))
      .width(CommonConstants.FULL_PERCENT)
    }
    .padding({
      right: CommonConstants.PADDING_PAGE,
      left: CommonConstants.PADDING_PAGE,
      top: this.isCommentInModalDialog ? CommonConstants.PADDING_S : this.windowModel.windowTopPadding,
    })
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(this.bgColor)
  }
}