import { pushService } from '@kit.PushKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '../utils/LogUtil';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
import { PushModel } from './Model';
import { StringUtil } from '../utils/StringUtil'

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
      LogUtil.error('get token', 'Get push token catch error: %{public}d %{public}s');
      return '';
    }
  }

  /**
   * 本地使用push rest api mock云端推送
   **/
  public static async pushMessage(articleInfo: ESObject, context:Context) {
    /*
     * 这里的Authorization需要开发者自行获取，详情见readme
     * todo
     * 将AppScope/resources/rawfile/data.json 里的push_url中XXXX换成projectId
     * */
    const url = StringUtil.getProtocolUrl('push_url', context)
    axios.post(url,PushUtils.pushMessageParams(articleInfo), {
        headers: {
          'Content-Type': 'application/json',
          'push-type': 0,
          'Authorization': 'Bearer ',   // bearer 后拼接鉴权令牌，生成过程见readme中的文档
        },
      })
      .then((resp: AxiosResponse) => {
        LogUtil.info('push success', JSON.stringify(resp))
      })
      .catch((err: AxiosError) => {
        LogUtil.info('push err' + err)
      })
  }

  /**
   * 本地使用mock 随机云端推送
   **/
  public static async randomPushMessage(articleInfo: ESObject, context:Context) {
    PushUtils.pushMessage(articleInfo, context)
  }

  /**
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushMessageParams(articleInfo: ESObject): PushModel {
    return {
      'payload': {
        'notification': {
          'category': 'MARKETING',
          'title': '儿童教育模板',
          'image': articleInfo?.picVideoUrl,
          'body': articleInfo?.title,
          'clickAction': {
            'actionType': 0,
            'id':articleInfo?.id,
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