import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { TValueType } from '../constant/Constants';
import { GlobalContext } from '../common/GlobalContext';

export class PreferenceUtil {
  private dataPreferences: preferences.Preferences | null = null;
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map();

  private constructor(context: Context, fileName: string) {
    try {
      preferences.removePreferencesFromCacheSync(context, fileName);
      this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName });
    } catch (error) {
    }
  }

  public static getInstance(context?: Context, fileName: string = 'default') {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      return PreferenceUtil.preferenceRecord.get(fileName)!!;
    }
    let ctx = context || GlobalContext.getUIAbilityContext() as common.UIAbilityContext;
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(ctx, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil);
    return preferenceUtil;
  }

  public put(key: string, value: TValueType) {
    if (!this.dataPreferences) {
    }
    try {
      this.dataPreferences?.putSync(key, value);
      this.dataPreferences?.flush();
    } catch (e) {
    }
  }

  public putToArray(key: string, value: string) {
    if (!this.dataPreferences) {
    }
    let array: Array<string> = this.get(key) as Array<string> || [];
    if (array.indexOf(value) !== -1) {
      return;
    }
    array.push(value);
    this.put(key, array);
  }

  public get(key: string, defaultValue?: TValueType) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue);
      return data;
    } catch (e) {
      return defaultValue;
    }
  }

  public removeFromArray(key: string, value: string) {
    if (!this.dataPreferences) {
    }
    let array: Array<string> = this.get(key) as Array<string> || [];
    array.splice(array.indexOf(value), 1);
    this.put(key, array);
  }

  /**
   * 清空缓存
   * @param preferenceName
   * @returns
   */
  public clear() {
    if (!this.dataPreferences) {
    }

    this.dataPreferences?.clearSync();
    return this.dataPreferences?.flush() //此处一定要flush，要不然不能永久序列化到本地
  }

  /**
   * 删除缓存值
   * @param key
   * @returns
   */
  public delete(key: string) {
    if (!this.dataPreferences) {
    }

    this.dataPreferences?.deleteSync(key);
    return this.dataPreferences?.flush() //此处一定要flush，要不然不能永久序列化到本地
  }

  /**
   * 检查缓存的Preferences实例中是否包含名为给定Key的存储键值对
   * @param key
   * @returns
   */
  public has(key: string) {
    if (!this.dataPreferences) {
    }

    return this.dataPreferences?.hasSync(key);
  }
}