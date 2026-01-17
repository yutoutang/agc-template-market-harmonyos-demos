import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit'
import { WindowUtil } from 'module_ui_base';
import { UtilLog } from '@hw-agconnect/util-log';
import { CommonConstants, LOG_TAG } from '../common/Constants';

@ObservedV2
export class ShareConfigModel {
  @Trace sheetType: SheetType = SheetType.BOTTOM;
  @Trace windowBottomPadding: number = 0;
  @Trace isLayoutFullScreen: boolean = false;

  @Computed
  get bottomPadding() {
    if (this.sheetType === SheetType.BOTTOM) {
      return this.windowBottomPadding;
    }
    return CommonConstants.PADDING_L;
  }

  private async _getLastWindow() {
    return window.getLastWindow(WindowUtil.context).then((win) => {
      return win
    }).catch((err: BusinessError) => {
      UtilLog.error(LOG_TAG, 'get last window failed. error: ' + JSON.stringify(err))
      return undefined
    })
  }

  /**
   * 主动获取底部避让区域高度
   */
  public queryWindowBottomPadding: () => void = () => {
    this._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      try {
        const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.windowBottomPadding = WindowUtil.px2vp(area.bottomRect.height);
      } catch (err) {
        UtilLog.error(LOG_TAG, 'get window avoid area failed. error: ' + JSON.stringify(err))
      }
    })
  }
  /**
   * 监听avoidAreaChange的回调函数
   * @param options
   */
  private setWindowBottomPadding: (options: window.AvoidAreaOptions) => void = (options: window.AvoidAreaOptions) => {
    if (options.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      this.windowBottomPadding = WindowUtil.px2vp(options.area.bottomRect.height)
    }
  }

  /**
   * 监听底部避让区域变化
   */
  public registerWindowBottomPadding() {
    this.queryWindowBottomPadding();
    this._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      currentWindow.on('avoidAreaChange', this.setWindowBottomPadding);
    })
  }

  /**
   * 取消监听底部避让区域变化
   */
  public unRegisterWindowBottomPadding() {
    this._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      currentWindow.off('avoidAreaChange', this.setWindowBottomPadding);
    })
  }

  /**
   * 还原应用窗口模式
   */
  public restoreWindowLayout() {
    this._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      currentWindow.setWindowLayoutFullScreen(this.isLayoutFullScreen).catch((err: BusinessError) => {
        UtilLog.error(LOG_TAG, 'set window layout full screen failed. error: ' + JSON.stringify(err))
      })
    })
  }
}
