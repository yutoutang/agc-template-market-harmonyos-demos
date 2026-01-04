import { preferences } from '@kit.ArkData';

export class PreferencesHelper {
  private static instance: PreferencesHelper;
  private static readonly ALBUM_PERMISSION_KEY: string = 'album_permission';
  private static readonly AUDIO_SWITCH_KEY: string = 'audio_switch';
  private static readonly PREFERENCES_NAME: string = 'wallpaper_prefs';

  private constructor() {
  }

  public static getInstance(): PreferencesHelper {
    if (!PreferencesHelper.instance) {
      PreferencesHelper.instance = new PreferencesHelper();
    }
    return PreferencesHelper.instance;
  }

  public checkAlbumPermission(context: Context): boolean {

    try {
      const prefs = preferences.getPreferencesSync(context, {
        name: PreferencesHelper.PREFERENCES_NAME
      });
      const favoritesStr = (prefs.getSync(PreferencesHelper.ALBUM_PERMISSION_KEY, false)) as boolean;
      return favoritesStr;

    } catch (error) {
      throw error instanceof Error ? error : new Error(`检查权限失败: ${String(error)}`);
    }
  }

  public saveAlbumPermission(context: Context): void {

    try {
      const prefs = preferences.getPreferencesSync(context, {
        name: PreferencesHelper.PREFERENCES_NAME
      });
      prefs.put(PreferencesHelper.ALBUM_PERMISSION_KEY, true);
      prefs.flush();
    } catch (error) {
      throw error instanceof Error ? error : new Error(`保存权限失败: ${String(error)}`);
    }
  }

  public checkAudioState(context: Context): boolean {
    try {
      const prefs = preferences.getPreferencesSync(context, {
        name: PreferencesHelper.PREFERENCES_NAME
      });
      const favoritesStr = (prefs.getSync(PreferencesHelper.AUDIO_SWITCH_KEY, true)) as boolean;
      return favoritesStr;

    } catch (error) {
      throw error instanceof Error ? error : new Error(`检查权限失败: ${String(error)}`);
    }
  }

  public saveAudioState(context: Context, state: boolean): void {

    try {
      const prefs = preferences.getPreferencesSync(context, {
        name: PreferencesHelper.PREFERENCES_NAME
      });
      prefs.put(PreferencesHelper.AUDIO_SWITCH_KEY, state);
      prefs.flush();
    } catch (error) {
    }
  }
}