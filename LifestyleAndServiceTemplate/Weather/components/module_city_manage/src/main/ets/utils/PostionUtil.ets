import { preferences } from '@kit.ArkData';
import { IPosition } from '../types/Types';

export class PositionUtl {
  private static readonly _fileName: string = 'weather_file';
  private static readonly _positionKey: string = 'weather_position_key';

  public static getPostionList() {
    const store = PositionUtl._getStore();
    return store.getSync(PositionUtl._positionKey, []) as IPosition[];
  }

  private static _getStore() {
    return preferences.getPreferencesSync(getContext(), { name: PositionUtl._fileName });
  }

  public static async add(postion: IPosition) {
    const list = PositionUtl.getPostionList();
    if (!list.some(item => postion.code === item.code)) {
      list.push(postion);
      const store = PositionUtl._getStore();
      store.putSync(PositionUtl._positionKey, list);
      await store.flush();
    }
  }

  public static async delete(code: string) {
    const list = PositionUtl.getPostionList();
    const index = list.findIndex(item => item.code === code);
    if (index !== -1) {
      list.splice(index, 1);
      const store = PositionUtl._getStore();
      store.putSync(PositionUtl._positionKey, list);
      await store.flush();
    }
  }

  public static async update(list: IPosition[]) {
    const store = PositionUtl._getStore();
    store.putSync(PositionUtl._positionKey, list);
    await store.flush();
  }
}