import { RecipesTable } from '../types/Types';

export class CommonConstants {
  // 域名
  public static readonly BASE_URL = '';
  // 全屏宽度
  public static readonly FULL_WIDTH = '100%';
  // 全屏高度
  public static readonly FULL_HEIGHT = '100%';
  // 首选项key
  public static readonly PRIVACY_POLICY_KEY = 'privacy policy';
  // 跳转搜索页前置页面
  public static readonly CLASSIFICATION_PAGE = 'ClassificationPage';
  // rdb开关，默认开启rdb(false 走接口)
  public static readonly RDB_FLAG = true;
  //Recipes表配置.
  static readonly RECIPES_TABLE: RecipesTable = {
    tableName: 'recipesTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS recipesTable(id INTEGER, title TEXT, description TEXT, category TEXT, cookingTime INTEGER, difficulty TEXT, ' +
      'authorId INTEGER, author TEXT, authorAvatar TEXT, thumbnail TEXT, views INTEGER, likes INTEGER, isCollected INTEGER)',
    columns: ['id', 'title', 'description', 'category', 'cookingTime', 'difficulty', 'authorId', 'author', 'authorAvatar', 'thumbnail', 'views', 'likes', 'isCollected'],
  };
  // 搜索历史首选项key
  public static readonly SEARCH_KEYS = 'searchKeys';
}
