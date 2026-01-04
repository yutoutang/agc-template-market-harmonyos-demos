import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class PreferenceUtil {
  // 所有运动记录key
  static readonly ALL_RECORD_DATA_KEY = 'all_record_data';
  // 首次安装app
  static readonly RESTART_APP_SIGN = 'restart_app_sign';
  // 是否需要开启运动相关权限
  static readonly OPEN_SPORT_PERMISSION = 'open_sport_permission';
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map();
  private dataPreferences: preferences.Preferences | null = null;

  private constructor(context: Context, fileName: string) {
    try {
      preferences.removePreferencesFromCacheSync(context, fileName);
      this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName });
    } catch (error) {
      hilog.error(0x0000, 'PreferenceUtil', 'constructor error');
    }
  }

  public static getInstance(context?: Context, fileName: string = 'default') {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      return PreferenceUtil.preferenceRecord.get(fileName)!!;
    }
    let ctx = context || getContext();
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(ctx, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil);
    return preferenceUtil;
  }

  public put(key: string, value: Object | string | boolean) {
    if (!this.dataPreferences) {
    }
    try {
      this.dataPreferences?.putSync(key, value);
      this.dataPreferences?.flush();
    } catch (e) {
    }
  }

  public get(key: string, defaultValue?: Object | string | boolean) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue);
      return data;
    } catch (e) {
      return defaultValue;
    }
  }
}