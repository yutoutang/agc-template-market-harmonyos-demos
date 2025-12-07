import { AccountUtil, AppStorageMap, Logger, RdbManager, RouterMap, RouterModule, recipesData, CommonConstants } from 'commonlib';
import { addCollection, changeFollowers, queryRecipeDetail, RecipeBriefInfo, RecipeDetail, removeCollection } from 'network';
import { BasketList } from '../types/Index';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

const TAG = '[DishesVM]';

@ObservedV2
export class DishesVM {
  @Trace recipeDetail?: RecipeDetail = undefined
  @Trace basketList: BasketList =
    PersistenceV2.connect(BasketList, AppStorageMap.SHOPPING_BASKET, () => new BasketList())!;
  @Trace collection: boolean = false
  @Trace isFollower: boolean = false
  scroller: Scroller = new Scroller();
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private rdbManager: RdbManager = new RdbManager(this.context);

  async init() {
    let recipeRouter = RouterModule.getNavParam<RecipeDetail>(RouterMap.DISHES)
    await this.rdbManager.initDatabase(this.context);
    Logger.info('Dishes detail router params:', JSON.stringify(recipeRouter))
    queryRecipeDetail(recipeRouter?.id || 0).then(async res => {
      if (res.status === 200) {
        this.recipeDetail = res.data;
        // 查询rdb数据，判断是insert还是update
        const result: recipesData[] = await this.rdbManager.query(this.recipeDetail.title, false);
        if(!result.length) {
          let recipes: recipesData = {
            id: this.recipeDetail.id,
            title: this.recipeDetail.title,
            description:  this.recipeDetail.description,
            category:  this.recipeDetail.category,
            cookingTime:  this.recipeDetail.cookingTime,
            difficulty:  this.recipeDetail.difficulty,
            authorId:  this.recipeDetail.authorId,
            author:  this.recipeDetail.author,
            authorAvatar:  this.recipeDetail.authorAvatar,
            thumbnail:  this.recipeDetail.thumbnail,
            views:  this.recipeDetail.views,
            likes:  this.recipeDetail.likes,
            isCollected: 0
          }
          await this.rdbManager.insertData(recipes, 0);
        }
        let filterRecipes = result.filter((item) => item.id === res.data.id)[0];
        this.collection = Boolean(filterRecipes.isCollected) || false;
      }
    })
  }

  async addCollection() {
    if(CommonConstants.RDB_FLAG) {
      // rdb 处理
      if (this.recipeDetail) {
        let recipes:recipesData = JSON.parse(JSON.stringify(this.recipeDetail));
        await this.rdbManager.updateData(recipes, 1);
        this.collection = true
      }
    } else {
      //接口处理
      addCollection(this.recipeDetail?.id || 0).then(res => {
        if (res.status === 200) {
          this.collection = true
        }
      })
    }
  }

  async cancelCollection() {
    // rdb 处理
    if(CommonConstants.RDB_FLAG) {
      if (this.recipeDetail) {
        let recipes:recipesData = JSON.parse(JSON.stringify(this.recipeDetail));
        await this.rdbManager.updateData(recipes, 0);
        this.collection = false
      }
    } else {
      // 接口处理
      removeCollection(this.recipeDetail?.id || 0).then(res => {
        if (res.status === 200) {
          this.collection = false
        }
      })
    }
  }

  collectClick() {
    if (AccountUtil.getUserInfo().isLogin) {
      if (!this.collection) {
        this.addCollection();
      } else {
        this.cancelCollection();
      }
    } else {
      promptAction.showToast({ message: '未登录，请登录后重试！' });
      RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
    }
  }

  addBasket() {
    if (this.basketList.isInBasket(this.recipeDetail?.id ?? -1)) {
      return;
    }
    if (this.recipeDetail) {
      if (AccountUtil.getUserInfo().isLogin) {
        this.basketList.addBasket(this.recipeDetail);
        promptAction.showToast({ message: '添加成功~！' });
      } else {
        promptAction.showToast({ message: '未登录，请登录后重试！' });
        RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
      }
    }
  }

  collectCb() {
    if (AccountUtil.getUserInfo().isLogin) {
      if (!this.collection) {
        this.addCollection();
      } else {
        this.cancelCollection();
      }

    } else {
      promptAction.showToast({ message: '未登录，请登录后重试！' });
      RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
    }
  }

  changeFollower(isFollower: boolean) {
    if (!AccountUtil.getUserInfo().isLogin) {
      RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
      return
    }
    if (isFollower) {
      changeFollowers(Number(this.recipeDetail?.authorId), 1)
    } else {
      changeFollowers(Number(this.recipeDetail?.authorId), 2)
    }
    this.isFollower = isFollower
  }
}
