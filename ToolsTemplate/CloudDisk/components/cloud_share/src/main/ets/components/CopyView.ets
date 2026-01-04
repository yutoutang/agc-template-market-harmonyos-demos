import { pasteboard } from '@kit.BasicServicesKit';
import { FileBaseInfo } from 'cloud_file_base';
import { ShareDetailRowViewInfoViewModel } from '../viewmodel/ShareDetailRowViewInfoViewModel';

/**
 * @usage 分享详情页复制提取码视图：展示提取码并提供复制到系统剪贴板的交互。
 * @layout 行内布局：左侧标题与提取码信息，右侧“复制”按钮；复制后展示 Toast 提示。
 * @constraints 依赖 pasteboard 系统剪贴板能力与 UIContext；与 ShareDetailRowViewInfoViewModel 协作以获取展示数据；无循环依赖。
 * @isGen false
 * @fileType component
 * @zhName 分享复制视图组件
 * @subPage false
 * @component CopyView
 * @modifiable 提示文案、按钮样式、布局间距与字体可定制；复制逻辑可扩展（如加密/校验）。
 * @image 使用分享相关图标资源（如 share_*）按主题配色展示。
 */
@ComponentV2
export struct CopyView {
  @Event shareAction: () => void = () => {
  }
  @Param @Require fileInfo: FileBaseInfo
  @Param @Require shareExtureInfoVM: ShareDetailRowViewInfoViewModel

  @Local isSetUseFullTime: boolean = false
  @Param subTitle: string = ''
  @Param title: string = ''
  @Param change: boolean = false

  build() {
    Row() {
      Column({ space: 3 }) {
        Text(this.subTitle)
          .font({
            size: $r('sys.float.Body_S'),
          })
          .height(13)
          .textAlign(TextAlign.Center)
          .fontColor($r('sys.color.font_tertiary'))

        Text(this.title)
          .textAlign(TextAlign.Center)
          .height(18)
          .fontColor('#B2000000')
          .font({
            size: $r('sys.float.Body_L'),
            weight: FontWeight.Medium
          })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('复制')
        .textAlign(TextAlign.End)
        .font({ size: $r('sys.float.Body_M'), })
        .height(15)
        .fontColor('#FF2FAFFF')
        .onClick(() => {
          copyPastBoard(this.getUIContext(), this.title, '提取码复制成功！')
        })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(60)
  }
}

export async function copyPastBoard(context: UIContext, content: string, tipString: string) {
  let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);
  // 获取系统剪贴板将数据写入
  let systemPasteboard = pasteboard.getSystemPasteboard();
  await systemPasteboard.setData(data);
  showToast(context, tipString)
}

function showToast(uiContext: UIContext, message: string) {
  uiContext.getPromptAction().showToast({
    textColor: $r('sys.color.font_on_primary'),
    message: message,
    duration: 2000,
    backgroundColor: '#CC202C3B',
    bottom: 136 + 24,
    backgroundBlurStyle: BlurStyle.NONE
  })
}