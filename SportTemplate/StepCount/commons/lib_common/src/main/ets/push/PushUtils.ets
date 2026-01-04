import { pushService } from '@kit.PushKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import { PushModel } from './Model';
import { RandomUtils } from '../utils/RamdomUtils';

export class PushUtils {
  /**
   * 获取push推送token
   **/
  public static async getTokenSyn(): Promise<string> {
    try {
      const pushToken = await pushService.getToken();
      return pushToken;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.error('get token', 'Get push token catch error: %{public}d %{public}s');
      return '';
    }
  }


  /**
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushMessageParams(articleList: ESObject): PushModel {
    const randomIndex = Math.floor(RandomUtils.getRandom(1) * articleList.length);
    return {
      'payload': {
        'notification': {
          'category': 'MARKETING',
          'title': '计步模板',
          'image': articleList[randomIndex].postImgList?.[0]?.picVideoUrl,
          'body': articleList[randomIndex].title,
          'clickAction': {
            'actionType': 0,
            'data': {
              'articleInfo': {
                'articleId': articleList[randomIndex].id,
                'authorId': articleList[randomIndex].authorId,
                'type': articleList[randomIndex].type,
              },
            },
          },
          'notifyId': 0,
          'badge': { 'addNum': 1 },
        },
      },
      target: {
        'token': [AppStorage.get('pushToken') ?? ''],
      },
      pushOptions: {
        'testMessage': true,
      },
    }
  }
}