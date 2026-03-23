import { BaseViewModel, PreferenceUtils, RouterMap, RouterUtils } from 'lib_common';
import { skipGuide } from '../common/Constants';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class GuidePageVM extends BaseViewModel {
  currentPageIndex: number = 0;

  backBtnClick() {
    this.currentPageIndex--;
    RouterUtils.pop();
  }

  skipBtnClick() {
    PreferenceUtils.getInstance().put(skipGuide, true);
    RouterUtils.clearStack();
    RouterUtils.pushPathByName(RouterMap.INDEX_PAGE);
  }

  skipGuide() {
    PreferenceUtils.getInstance().put(skipGuide, true);
    RouterUtils.replacePathByName(RouterMap.INDEX_PAGE);
  }

  saveAge(context: common.UIAbilityContext, age: string) {
    const pref = preferences.getPreferencesSync(context, { name: 'prefData' });
    pref.putSync('userAge', age); // 同步写入内存
    pref.flushSync(); // 持久化到磁盘（建议在onBackground调用）
  }

  saveGender(context: common.UIAbilityContext, gender: string) {
    const pref = preferences.getPreferencesSync(context, { name: 'prefData' });
    pref.putSync('userGender', gender); // 同步写入内存
    pref.flushSync(); // 持久化到磁盘（建议在onBackground调用）
  }

  saveBody(context: common.UIAbilityContext, body: string[]) {
    const pref = preferences.getPreferencesSync(context, { name: 'prefData' });
    pref.putSync('userBody', body); // 同步写入内存
    pref.flushSync(); // 持久化到磁盘（建议在onBackground调用）
    AppStorage.setOrCreate<string[]>('userBody', body);
  }

  savePurpose(context: common.UIAbilityContext, purpose: string[]) {
    const pref = preferences.getPreferencesSync(context, { name: 'prefData' });
    pref.putSync('userPurpose', purpose); // 同步写入内存
    pref.flushSync(); // 持久化到磁盘（建议在onBackground调用）
  }

  saveHeight(context: common.UIAbilityContext, height: string) {
    const pref = preferences.getPreferencesSync(context, { name: 'prefData' });
    pref.putSync('userHeight', height); // 同步写入内存
    pref.flushSync(); // 持久化到磁盘（建议在onBackground调用）
  }

  saveWeight(context: common.UIAbilityContext, weight: string) {
    const pref = preferences.getPreferencesSync(context, { name: 'prefData' });
    pref.putSync('userWeight', weight); // 同步写入内存
    pref.flushSync(); // 持久化到磁盘（建议在onBackground调用）
  }

  saveTargetWeight(target: string) {
    AppStorage.setOrCreate<string>('userTargetWeight', target);
  }
}
