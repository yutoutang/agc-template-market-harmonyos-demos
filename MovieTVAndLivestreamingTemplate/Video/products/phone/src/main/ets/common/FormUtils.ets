import { preferences } from '@kit.ArkData';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { Logger } from 'lib_common';

const TAG = '[FormUtils]';

/**
 * 服务卡片工具类
 */
export class FormUtils {
  private static readonly fileName: string = 'form_id_file';
  private static readonly formIdKey: string = 'form_id_key';
  private static readonly formIdEventName: string = 'form_id_event_name';
  public static isSubscribed: boolean = false;

  /**
   * 创建卡片
   * @param formId
   * @param cxt
   */
  public static async addFormId(formId: string, cxt: Context) {
    const list = FormUtils.getFormIds(cxt);
    if (!list.some((id) => id === formId)) {
      list.push(formId);
      const store = FormUtils.getStore(cxt);
      store.putSync(FormUtils.formIdKey, list);
      await store.flush();
    }
  }

  /**
   * 删除卡片
   * @param formId
   * @param cxt
   */
  public static async delFormId(formId: string, cxt: Context) {
    const list = FormUtils.getFormIds(cxt);
    const index = list.findIndex((id) => id === formId);
    if (index !== -1) {
      list.splice(index, 1);
      const store = FormUtils.getStore(cxt);
      store.putSync(FormUtils.formIdKey, list);
      await store.flush();
    }
  }

  /**
   * 发布卡片创建/删除事件
   * @param formId
   * @param isDelete
   */
  public static publishFormId(formId: string, isDelete: boolean) {
    commonEventManager.publish(
      FormUtils.formIdEventName,
      { data: formId, parameters: { isDelete } },
      (err: BusinessError) => {
        if (err) {
          Logger.error(TAG, 'Failed to publish form_id_event_name, error: ' + JSON.stringify(err));
        } else {
          Logger.info(TAG, 'Succeeded in publish form_id_event_name.');
        }
      },
    );
  }

  /**
   * 订阅卡片创建/删除事件
   * @param ctx
   */
  public static async subscribeFormId(ctx: Context, source?: string) {
    Logger.info('subscribeFormId source:' + source)
    FormUtils.isSubscribed = true;
    let subscriber: commonEventManager.CommonEventSubscriber | undefined = undefined;
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: [FormUtils.formIdEventName],
      publisherPermission: '',
    };
    commonEventManager.createSubscriber(subscribeInfo, (err1, data1) => {
      if (data1) {
        subscriber = data1;
        commonEventManager.subscribe(subscriber, async (err2, data2) => {
          if (data2) {
            if (data2.parameters?.isDelete) {
              FormUtils.delFormId(data2.data as string, ctx);
            } else {
              FormUtils.addFormId(data2.data as string, ctx);
            }
            Logger.info(TAG, 'Succeeded in creating subscribeFormId.');
          }
        });
      }
    });
  }

  /**
   * 获取卡片id列表
   * @param ctx
   * @returns
   */
  public static getFormIds(ctx: Context) {
    const store = FormUtils.getStore(ctx);
    return store.getSync(FormUtils.formIdKey, []) as string[];
  }

  /**
   * 获取持久化
   * @param ctx
   * @returns
   */
  private static getStore(ctx: Context) {
    return preferences.getPreferencesSync(ctx, { name: FormUtils.fileName });
  }
}