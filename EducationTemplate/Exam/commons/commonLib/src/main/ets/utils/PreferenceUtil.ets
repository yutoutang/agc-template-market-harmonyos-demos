import { preferences } from '@kit.ArkData';
import { Logger } from './Logger';
import { GlobalContextUtils } from './ContextUtils';

export class PreferConstant {
  // 题目笔记
  static readonly TOPIC_NOTES: string = 'TOPIC_NOTES';
  // 错题记录
  static readonly ERROR_RECORDS: string = 'ERROR_RECORDS';
  // 收藏记录
  static readonly EXAM_PREFER_COLLECT: string = 'EXAM_PREFER_COLLECT';
  //意见反馈记录
  static readonly FEEDBACK_RECORD: string = 'FEEDBACK_RECORD';
  //首次进入启动页隐私协议状态
  static readonly FIRST_LAUNCH: string = 'FirstLaunch';
  // 深色模式
  static readonly COLOR_MODE: string = 'Color_Mode';
}

export class PreferenceUtil {
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map()
  private dataPreferences: preferences.Preferences | null = null

  private constructor(context: Context, fileName: string) {
    try {
      preferences.removePreferencesFromCacheSync(context, fileName)
      this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName })
      Logger.info(`PreferenceUtil: ${fileName} init: ${this.dataPreferences != null}`)
    } catch (e) {
      Logger.error(`PreferenceUtil error :  ${JSON.stringify(e)}`)
    }
  }

  public static getInstance(fileName: string = 'default') {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      return PreferenceUtil.preferenceRecord.get(fileName)!!
    }
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(GlobalContextUtils.globalContext, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil)
    return preferenceUtil
  }

  public put(key: string, value: preferences.ValueType) {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
    }
    try {
      this.dataPreferences?.putSync(key, value)
      this.dataPreferences?.flush()
      Logger.info(`PreferenceUtil: put: ${key} = ${JSON.stringify(value)}`)
    } catch (e) {
      Logger.info(`PreferenceUtil: put error: ${JSON.stringify(e)}`)
    }
  }

  public get(key: string, defaultValue?: preferences.ValueType) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue)
      Logger.info(`PreferenceUtil: get: ${key} = ${JSON.stringify(data)}`)
      return data
    } catch (e) {
      Logger.info(`PreferenceUtil: get error: ${JSON.stringify(e)}`)
      return defaultValue
    }
  }

  public hasSync(key: string): boolean {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
      return false
    }
    try {
      return this.dataPreferences?.hasSync(key)
    } catch (e) {
      Logger.error(`PreferenceUtil: hasSync error: ${JSON.stringify(e)}`)
    }
    return false;
  }

  public getAllSync(): object | null {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
      return null
    }
    try {
      return this.dataPreferences.getAllSync()
    } catch (e) {
      Logger.error(`PreferenceUtil: getAllSync error: ${JSON.stringify(e)}`)
    }
    return null
  }

  public delete(key: string) {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
      return;
    }
    try {
      // 删除
      this.dataPreferences?.deleteSync(key)
      this.dataPreferences?.flush()
      Logger.info('testTag', '删除Preferences[${key} = ${value}]成功');
    } catch (e) {
      Logger.info('testTag', '删除Preferences[${key} = ${value}]失败' + JSON.stringify(e));
    }
  }

  isClean(): boolean {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
      return true
    }
    let arr: [] = [];
    try {
      let value = this.dataPreferences.getAllSync()
      if (value) {
        arr = Object.values(value) as [];
      }
      if (arr.length === 0) {
        return true
      }
    } catch (e) {
      Logger.info(`PreferenceUtil: isClean error ${JSON.stringify(e)} `)
    }
    return false
  }

  clear() {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
      return;
    }
    try {
      this.dataPreferences.clearSync()
      this.dataPreferences?.flush()
    } catch (e) {
      Logger.info('testTag', 'clear失败' + JSON.stringify(e));
    }
  }
}

