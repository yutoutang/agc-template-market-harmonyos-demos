import { BreakpointModel, BreakpointType } from 'commonlib';
import { LazyDataSource, TabItem } from 'featured_recipes';
import { queryRecipeList, RecipeBriefInfo } from 'network';
import { AppStorageV2 } from '@kit.ArkUI';

const TAG = '[HomePageVM]';

@ObservedV2
export class HomePageVM {
  @Trace bannerUrl: ResourceStr[] = [$r('app.media.banner1'), $r('app.media.banner2'),$r('app.media.banner_img1'), $r('app.media.banner_img2')];
  @Trace dishesList: LazyDataSource<RecipeBriefInfo> = new LazyDataSource();
  @Trace isRefreshing: boolean = false;
  @Trace isLoading: boolean = false;
  @Trace breakpoint: string = 'sm';
  @Trace tabList: TabItem[] = [
    {
      label: '家常菜',
      icon: $r('app.media.ic_home_dish'),
    },
    {
      label: '下饭菜',
      icon: $r('app.media.ic_meal_dish'),
    },
    {
      label: '快手菜',
      icon: $r('app.media.ic_fast'),
    },
    {
      label: '减脂餐',
      icon: $r('app.media.ic_fat'),
    },
    {
      label: '更多',
      icon: $r('app.media.ic_more'),
    },
  ];
  // 搜索框是否可见
  @Trace isSearchVisible: boolean = false
  @Trace totalCount = 75; //实际以接口为准
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 4,
    lg: 4,
    xl: 4,
  });
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  private static _instance: HomePageVM;

  public async getDishesList() {
    const res = await queryRecipeList()
    if (res.status === 200) {
      this.dishesList.pushArrayData(res.data)
    }
  }


  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  @Computed
  get gridCount() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }
}
