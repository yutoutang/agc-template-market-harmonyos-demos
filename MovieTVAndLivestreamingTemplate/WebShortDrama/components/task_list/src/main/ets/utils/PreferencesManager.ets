import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

class PreferencesManager {
  private static instance: PreferencesManager
  private preferences: dataPreferences.Preferences | null = null
  private context: common.UIAbilityContext

  // 单例模式获取实例
  public static getInstance(context: common.UIAbilityContext): PreferencesManager {
    if (!PreferencesManager.instance) {
      PreferencesManager.instance = new PreferencesManager(context)
    }
    return PreferencesManager.instance
  }

  private constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  // 初始化Preferences
  public async initPreferences(preferencesName: string): Promise<void> {
    try {
      this.preferences = await dataPreferences.getPreferences(this.context, preferencesName)
      console.info(`Preferences [${preferencesName}] initialized`)
    } catch (err) {
      console.error(`Failed to init preferences. Code: ${err.code}, message: ${err.message}`)
    }
  }

  // 存储数据
  public async putData(key: string, value: dataPreferences.ValueType): Promise<boolean> {
    if (!this.preferences) {
      console.error('Preferences not initialized!')
      return false
    }
    try {
      await this.preferences.put(key, value)
      await this.preferences.flush()
      return true
    } catch (err) {
      console.error(`Save failed. Key:${key}, Code:${err.code}, Message:${err.message}`)
      return false
    }
  }

  // 读取数据
  public async getData<T extends dataPreferences.ValueType>(
    key: string,
    defaultValue: T
  ): Promise<T> {
    if (!this.preferences) {
      console.error('Preferences not initialized!')
      return defaultValue
    }
    try {
      const value = await this.preferences.get(key, defaultValue)
      return value as T
    } catch (err) {
      console.error(`Read failed. Key:${key}, Code:${err.code}, Message:${err.message}`)
      return defaultValue
    }
  }

  // 删除数据
  public async deleteData(key: string): Promise<boolean> {
    if (!this.preferences) {
      console.error('Preferences not initialized!')
      return false
    }
    try {
      await this.preferences.delete(key)
      await this.preferences.flush()
      return true
    } catch (err) {
      console.error(`Delete failed. Key:${key}, Code:${err.code}, Message:${err.message}`)
      return false
    }
  }
}

export default PreferencesManager