import { queryRecipeHistoryList } from 'network';
import { historyListMapper } from '../mapper/Index';
import { RecipeItem } from '../types/Index';
import { common } from '@kit.AbilityKit';
import { RdbManager, recipesData, CommonConstants, GlobalContextUtils } from 'commonlib';

@ObservedV2
export class BrowsingHistoryVM {
  private static _instance: BrowsingHistoryVM;
  @Trace history: RecipeItem[] = [];
  private context: common.UIAbilityContext = GlobalContextUtils.globalUIAbilityContext;
  private rdbManager: RdbManager = new RdbManager(this.context);

  async queryRecipeHistory() {
    // rdb查询
    if (CommonConstants.RDB_FLAG) {
      await this.rdbManager.initDatabase(this.context);
      const result: recipesData[] = await this.rdbManager.query('', true);
      this.history = historyListMapper(result);
    } else {
      // 接口查询
      const res = await queryRecipeHistoryList();
      this.history = historyListMapper(res.data);
    }
  }

  public static get instance() {
    if (!BrowsingHistoryVM._instance) {
      BrowsingHistoryVM._instance = new BrowsingHistoryVM();
    }
    return BrowsingHistoryVM._instance;
  }
}
