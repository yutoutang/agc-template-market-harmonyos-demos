import { pasteboard } from '@kit.BasicServicesKit';
import { FileBaseInfo } from 'cloud_file_base';
import { ShareDetailRowViewInfoViewModel } from '../viewmodel/ShareDetailRowViewInfoViewModel';

/**
 * @usage 分享详情页信息行视图：用于展示可修改的有效期或常规信息条目，支持触发变更动作。
 * @layout 行内布局：左侧标题与内容，右侧操作按钮（如“修改”），中间可配合分割线作为分组呈现。
 * @constraints 依赖 ShareDetailRowViewInfoViewModel 获取当前展示文案；与 UIContext 协作显示弹窗或 Toast；无循环依赖。
 * @isGen false
 * @fileType component
 * @zhName 分享信息行视图组件
 * @subPage false
 * @component RowView
 * @modifiable 操作按钮文案、布局与样式可定制；变更逻辑可扩展（如弹窗类型、选项范围）。
 * @image 使用分享/设置相关图标资源（如 share_* 或 setting_*）。
 */
@ComponentV2
export struct RowView {
  @Param @Require fileInfo: FileBaseInfo
  @Param @Require shareExtureInfoVM: ShareDetailRowViewInfoViewModel
  @Event shareAction: () => void = () => {
  }
  @Param change: boolean = false
  @Local isSetUseFullTime: boolean = false
  @Param subTitle: string = ''
  @Param title: string = ''

  build() {
    Row() {
      Column({ space: 3 }) {
        Text(this.subTitle)

          .font({ size: $r('sys.float.Body_S'), })
          .height(13)
          .fontColor($r('sys.color.font_tertiary'))
          .textAlign(TextAlign.Center)

        Text(this.shareExtureInfoVM.usefullTime ? this.shareExtureInfoVM.usefullTime : this.title)
          .height(18)
          .fontColor('#B2000000')
          .textAlign(TextAlign.Center)
          .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('修改')
        .textAlign(TextAlign.End)
        .font({
          size: $r('sys.float.Body_M'),
        })
        .fontColor('#FF2FAFFF')
        .height(15)
        .onClick(() => {
          this.shareAction()
        })
    }
    .height(60)
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }
}

export async function copyPastBoard(curContext: UIContext, curText: string, tipString: string) {
  let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, curText);
  // 获取系统剪贴板
  let systemPasteboard = pasteboard.getSystemPasteboard();
  // 将数据写入剪贴板
  await systemPasteboard.setData(data);
  showToast(curContext, tipString)
}

function showToast(uiContext: UIContext, message: string) {
  uiContext.getPromptAction().showToast({
    backgroundColor: '#CC202C3B',
    bottom: 136 + 24,
    backgroundBlurStyle: BlurStyle.NONE,
    message: message,
    duration: 2000,
    textColor: $r('sys.color.font_on_primary')
  })
}