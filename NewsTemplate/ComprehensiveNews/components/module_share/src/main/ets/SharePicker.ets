import { ShareAppType } from './common/ShareEnum';
import { ShareViewData, ShareRecordData, ShareOptions, QQShareData } from './common/ShareParams';
import { PopViewUtils } from './utils/PopViewUtils';
import { WXShareUtils } from './utils/WXShareUtils';
import { shareViewBuilder } from './views/ShareView';

/**
 * 拉起分享面板的picker
 */
@ObservedV2
export class SharePicker {
  @Trace private data: ShareViewData = new ShareViewData();
  @Trace private sheetOptions: SheetOptions = {
    showClose: true,
    height: SheetSize.FIT_CONTENT,
    preferType: SheetType.CENTER,
    backgroundColor: $r('app.color.share_bg'),
    onTypeDidChange: (type: SheetType) => {
      this.data.sheetType = type;
    },
  };
  private wxShare: WXShareUtils = WXShareUtils.instance;
  private uiContext: UIContext | undefined = undefined;

  constructor(record: ShareRecordData) {
    this.data = new ShareViewData(record);
    this.data.setClose(this.close);
  }

  /**
   * 设置QQ互联分享签名
   * @param callback
   * @returns
   */
  public setSignQQShareDataCB(callback: (shareJson: string) => Promise<QQShareData>): SharePicker {
    this.data.extraInfo.signQQShareData = (shareJson: string) => {
      return callback(shareJson);
    };
    return this;
  }

  /**
   * 设置应用窗口模式
   * @param isLayoutFullScreen
   */
  public setWindowLayoutFullScreen(isLayoutFullScreen: boolean): SharePicker {
    this.data.extraInfo.isLayoutFullScreen = isLayoutFullScreen;
    return this;
  }

  /**
   * 拉起分享半模态弹窗
   * @param options
   */
  public show(uiContext: UIContext, options?: ShareOptions): void {
    this.uiContext = uiContext;

    if (options) {
      this.data.setShareOptions(options);
    }

    PopViewUtils.showSheet<ShareViewData>(uiContext, wrapBuilder(shareViewBuilder), this.sheetOptions, this.data);
  }

  /**
   * 关闭分享半模态弹窗
   */
  public close: () => void = () => {
    if (this.uiContext) {
      PopViewUtils.closeSheet(this.uiContext);
    }
  }

  /**
   * 分享到微信
   */
  public shareToWX(uiContext: UIContext): void {
    this.wxShare.registerOnWXRespCallback(uiContext, this.data);
    this.wxShare.shareWebpage(uiContext, this.data, ShareAppType.WECHAT_SESSION);
    setTimeout(() => {
      this.wxShare.unregisterOnWXRespCallback();
    }, 5000)
  }
}