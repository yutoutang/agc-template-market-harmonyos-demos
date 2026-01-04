import { preferences } from '@kit.ArkData';

const MSG_COLLECT: string = 'MsgCollect';

export class CollectDataManager {
  private static instance: CollectDataManager;
  private dataManager: preferences.Preferences | null = null;

  private constructor() {
    try {
      preferences.removePreferencesFromCacheSync(getContext(), 'default');
      this.dataManager = preferences.getPreferencesSync(getContext(), { name: 'default' });
    } catch (error) {
    }
  }

  public static getInstance() {
    if (!CollectDataManager.instance) {
      CollectDataManager.instance = new CollectDataManager();
    }
    return CollectDataManager.instance;
  }

  public setCollectData(value: string) {
    if (!this.dataManager) {
    }
    try {
      this.dataManager?.putSync(MSG_COLLECT, value);
      this.dataManager?.flush();
    } catch (e) {
    }
  }

  public getCollectData(defaultValue?: string) {
    try {
      let data = this.dataManager?.getSync(MSG_COLLECT, defaultValue);
      return data;
    } catch (e) {
      return defaultValue;
    }
  }
}