import { Want } from '@kit.AbilityKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { NewsEnum } from '../constants/NewsEnum';
import { RouterToNews } from './NewsPushUtils';
import { GlobalContextUtils } from './ContextUtils';
import { Logger } from './Logger';
import { RouterParams } from '../models/RouterParams';

export class NewsScan {
  static TAG: string = 'NewsScan'

  public scan() {
    // 定义扫码参数options
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true,
    };
    try {
      scanBarcode.startScanForResult(GlobalContextUtils.globalContext, options)
        .then((result: scanBarcode.ScanResult) => {
          // 识别网页链接场景
          if (result.originalValue.startsWith('http')) {
            this.startBrowsableAbility(result.originalValue);
            return;
          }
          // 解析码值结果跳转应用服务页
          let resultParams: Record<string, string | NewsEnum> = JSON.parse(result.originalValue)
          if (!resultParams?.newsId) {
            GlobalContextUtils.showToast({ message: '扫码错误，仅支持模板内文章、视频、动态海报生成的二维码' })
            return
          }
          let routerParams: RouterParams<null> = {
            'newsId': resultParams?.newsId,
            'type': resultParams?.type ?? NewsEnum.Article,
          } as Record<string, string>
          RouterToNews.pushToNewsDetails(routerParams)
        })
        .catch((error: BusinessError) => {
          let message: string = ''
          if (error.code === 1000500002) {
            // 用户取消扫码
            message = '取消扫码'
          } else {
            message = '扫码错误'
          }
          GlobalContextUtils.showToast({ message: message })
          Logger.error(NewsScan.TAG, '[Scan CPSample]',
            `Failed to get ScanResult by promise with options. Code:${error.code}, message: ${error.message}`);
        });
    } catch (error) {
      GlobalContextUtils.showToast({ message: '扫码错误' })
      Logger.error(NewsScan.TAG, '[Scan CPSample]',
        `Failed to start the scanning service. Code:${error.code}, message: ${error.message}`);
    }
  }

  startBrowsableAbility(url: string): void {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url,
      parameters: {
        'ohos.ability.params.showDefaultPicker': true,
      },
    };

    GlobalContextUtils.globalUIAbilityContext.startAbility(want)
      .then(() => {
        Logger.error(NewsScan.TAG, 'Start browsableAbility successfully.');
      })
      .catch((err: BusinessError) => {
        Logger.error(NewsScan.TAG, `Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      });
  }
}