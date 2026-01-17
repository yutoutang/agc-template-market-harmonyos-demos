import { SharePicker, ShareRecordData } from 'module_share';

/**
 * 分享工具类
 */
export class ShareUtils {
  private picker: SharePicker;

  constructor(shareData: ShareRecordData) {
    this.picker = new SharePicker(shareData);
  }

  shareToWX(uiContext: UIContext) {
    this.picker.shareToWX(uiContext);
  }
}
