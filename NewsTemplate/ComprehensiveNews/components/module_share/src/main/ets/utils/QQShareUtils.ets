import { ShareResultType, ShareData } from '@tencent/qq-open-sdk';
import { QQShareContent, ShareViewData } from '../common/ShareParams';
import { ShareService } from '../ShareService';
import { showToast } from './ToastUtils';

/**
 * QQ分享
 */
export class QQShareUtils {
  private static _instance: QQShareUtils;
  private shareService = ShareService.instance;
  shareData: ShareData = new ShareData();

  /**
   * 获取实例
   * @returns
   */
  static get instance() {
    if (!QQShareUtils._instance) {
      QQShareUtils._instance = new QQShareUtils();
    }
    return QQShareUtils._instance;
  }

  /**
   * 分享到qq
   * @param data
   */
  public async share(uiContext: UIContext, data: ShareViewData) {
    if (!this.shareService.qqOpenApi.isQQInstalled()) {
      uiContext.showAlertDialog({ message: '请先安装QQ' })
      return;
    }
    const shareData: QQShareContent = {
      msg_style: 0,
      title: data.title,
      summary: '',
      brief: '',
      url: data.landingPageUrl,
      picture_url: data.coverUrl,
    };
    const signedShareData = await data.extraInfo.signQQShareData(JSON.stringify(shareData));
    let result = await this.shareService.qqOpenApi.share(2, signedShareData as ShareData);
    switch (result.resultType) {
      case ShareResultType.Success:
        showToast(uiContext, { message: '分享成功' });
        if (data.autoClose) {
          data.closeSheet();
        }
        break;
      case ShareResultType.Cancel:
        showToast(uiContext, { message: result.message ?? '分享取消' });
        break;
      case ShareResultType.Error:
        showToast(uiContext, { message: '分享失败: ' + result.message });
        break;
    }
  }
}
