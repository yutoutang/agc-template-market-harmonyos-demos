import { AccountUtil, RouterMap, RouterModule, UserInfo, RdbManager, recipesData, CommonConstants } from 'commonlib';
import {
  deleteMyRecipe,
  getBloggerInfo,
  getMyNoticeList,
  Notice,
  queryCollectionList,
  queryMyRecipeList,
} from 'network';
import { recipeListMapper } from '../mapper/Index';
import { LazyDataSource, RecipeBriefInfo } from 'featured_recipes';
import { TabIndexEnum } from 'base_ui';
import { BloggerInfo } from 'personal_homepage';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

const TAG = '[MinePageVM]';

@ObservedV2
export class MinePageVM {
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  @Trace bloggerInfo: BloggerInfo = new BloggerInfo()
  @Trace recipeList: LazyDataSource<RecipeBriefInfo> = new LazyDataSource();
  @Trace authCode: string = '';
  @Trace showService: boolean = false;
  @Trace currentIndex: number = 1;
  @Trace noticeList: Notice[] = [];
  @Trace isToDelete: boolean = false;
  private static _instance: MinePageVM;
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private rdbManager: RdbManager = new RdbManager(this.context);
  @Trace recipes: Array<recipesData> = [];

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  @Monitor('userInfo.nickname', 'userInfo.avatar')
  changeUserInfo(monitor: IMonitor) {
    this.bloggerInfo.name = this.userInfo.isLogin ? this.userInfo.nickname : '去登录'
    this.bloggerInfo.avatar = this.formatAvatar(this.userInfo.avatar)
  }

  formatAvatar(avatar: string) {
    let newAvatar: ResourceStr
    if (avatar) {
      if (avatar.startsWith('file://')) {
        newAvatar = avatar
      } else {
        newAvatar = $r(`app.media.${avatar}`)
      }
    } else {
      newAvatar = $r('app.media.ic_avatar')
    }
    return newAvatar
  }

  init() {
    this.queryUserInfo()
    this.queryMyRecipeList()
    this.getMyNoticeList()
    this.queryCollection()
  }

  refreshMinePage() {
    this.queryMyRecipeList()
    this.getMyNoticeList()
    this.queryCollection()
  }

  getMyNoticeList() {
    if (!AccountUtil.getUserInfo().isLogin) {
      return
    }
    getMyNoticeList().then(res => {
      if (res.status === 200) {
        this.noticeList = res.data;
      }
    })
  }

  async queryMyRecipeList() {
    if (!AccountUtil.getUserInfo().isLogin) {
      return
    }
    this.recipeList.clear()
    const res = await queryMyRecipeList();
    if (this.currentIndex === TabIndexEnum.FIRST) {
      this.recipeList.pushArrayData(recipeListMapper(res.data));
    }
  }

  async queryCollection() {
    if (!AccountUtil.getUserInfo().isLogin) {
      return
    }
    this.recipeList.clear()

    // 接口查询或者rdb查询
    if (CommonConstants.RDB_FLAG) {
      // rdb 初始化rdb数据库
      await this.rdbManager.initDatabase(this.context);
      let result: recipesData[] = await this.rdbManager.query('', true);
      // 过滤收藏的
      result = result.filter(item => Boolean(item.isCollected))
      if (this.currentIndex === TabIndexEnum.SECOND) {
        this.recipeList.pushArrayData(recipeListMapper(result));
      }
    } else {
      //如果有接口，走接口查数据
      const res = await queryCollectionList();
      if (this.currentIndex === TabIndexEnum.SECOND) {
        this.recipeList.pushArrayData(recipeListMapper(res.data));
      }
    }
  }

  queryUserInfo() {
    if (!AccountUtil.getUserInfo().isLogin) {
      this.bloggerInfo.name = '去登录'
      this.bloggerInfo.avatar = $r('app.media.ic_avatar')
      return
    }
    getBloggerInfo(this.userInfo.id).then(res => {
      if (res.status === 200) {
        this.bloggerInfo.updateData(res.data.id, res.data.name, res.data.avatar, res.data.profile, res.data.sex,
          res.data.createdAccount, res.data.ipLocation, res.data.bloggerType, res.data.followers, res.data.fans,
          res.data.beFavorite, res.data.beFollowed, res.data.myRecipeList, res.data.collectRecipeList)
        if (this.userInfo.isLogin) {
          this.bloggerInfo.name = this.userInfo.nickname
          this.bloggerInfo.avatar = this.formatAvatar(this.userInfo.avatar)
        }
      }
    })
  }

  changeSideBar(flag: boolean) {
    RouterModule.push(RouterMap.SIDE_BAR_PAGE)
  }

  changeTabs(index: number) {
    this.currentIndex = index
    this.isToDelete = false
    if (index === TabIndexEnum.FIRST) {
      this.queryMyRecipeList()
    } else {
      this.queryCollection()
    }
  }

  login() {
    if (AccountUtil.getUserInfo().isLogin) {
      RouterModule.push(RouterMap.PERSON_INFO_PAGE);
    } else {
      RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
    }
  }

  changeLogin() {
    if (this.userInfo.isLogin) {
      this.init()
    } else {
      this.recipeList.clear()
      this.bloggerInfo.updateData(0, this.bloggerInfo.name, this.bloggerInfo.avatar)
      this.noticeList = this.noticeList.filter(() => false)
    }
  }

  async deleteMyRecipe(ids: number[]) {
    const res = await deleteMyRecipe(ids);
    if (res.status === 200) {
      this.queryMyRecipeList().then(() => {
        promptAction.showToast({ message: '删除成功！' });
        this.isToDelete = false
      });
    }
  }
}
