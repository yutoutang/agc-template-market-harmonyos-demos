import { AbilityConstant, Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { PushUtils, PushActionParams } from '@ohos_agcit/driver_license_exam_commonlib'

const TAG = '[WantUtils]';

/**
 * 应用want处理工具类
 */
export class WantUtils {
  /**
   * 冷启动点击推送信息
   * @param want
   */
  public static async handlePushCall(want: Want) {
    let pushToken: string = await PushUtils.getTokenSyn();
    AppStorage.setOrCreate('pushToken', pushToken);
    const articleInfo = want.parameters?.articleInfo;
    AppStorage.setOrCreate('pushCardEntry', articleInfo);
  }

  /**
   * 热启动点击推送信息
   * @param want
   */
  public static handlePushWant(want: Want) {
    /*
    * 获取push卡片点击进入携带参数
    * */
    const articleInfo = want.parameters?.articleInfo as PushActionParams;
    if (articleInfo) {
      let articleId = articleInfo?.id;
      // 进行跳转
    }
  }
}