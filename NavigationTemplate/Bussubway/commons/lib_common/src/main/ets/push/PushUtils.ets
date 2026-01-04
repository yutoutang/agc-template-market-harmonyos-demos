import { pushService } from '@kit.PushKit';
import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { notificationManager } from '@kit.NotificationKit';
import { Logger } from '../utils/Logger';
import { PushModel } from './Model';
import { newsInformation } from '../constants/HomeNewsMockData';
import { CustomRandomUtils } from '../utils/CustomRandomUtils';

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
   * 本地使用push rest api mock云端推送
   **/
  public static async pushMessage(articleList: ESObject) {
    /*
     * 这里的Authorization需要开发者自行获取，详情见readme
     * */
    axios.post('https://push-api.cloud.huawei.com/v3/388421841222475582/messages:send',
      PushUtils.pushMessageParams(articleList), {
        headers: {
          'Content-Type': 'application/json',
          'push-type': 0,
          'Authorization': 'Bearer ',
        },
      })
      .then((resp: AxiosResponse) => {
        Logger.info('push success', JSON.stringify(resp))
      })
      .catch((err: AxiosError) => {
        Logger.info('push err' + err)
      })
  }

  /**
   * 本地使用mock 随机云端推送
   **/
  public static async randomPushMessage(articleList: ESObject) {
    PushUtils.pushMessage(articleList)
  }


  /**
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushMessageParams(articleList: ESObject): PushModel {
    const randomIndex = CustomRandomUtils.getRandomIndex(articleList.length);
    return {
      'payload': {
        'notification': {
          'category': 'MARKETING',
          'title': '公交地铁模板',
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