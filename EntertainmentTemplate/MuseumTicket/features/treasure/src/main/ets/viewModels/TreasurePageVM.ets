import { RouterMap, RouterModule } from 'commonlib';
import { TreasureItem, https, CloudUrl } from 'network';
import { SwiperItem } from 'module_page_swiper';


const TAG = '[TreasurePageVM]';


@ObservedV2
export class TreasurePageVM {
  @Trace intCount: number = 0;
  @Trace treasureInfo: TreasureItem[] = [];
  // 默认展示的项
  @Trace defaultIndex: number = 0;
  @Trace swiperData: SwiperItem[] = [];
  @Trace isScale: boolean = false;
  @Trace cloudUrl: CloudUrl = new CloudUrl();
  private static _instance: TreasurePageVM;

  public static get instance() {
    if (!TreasurePageVM._instance) {
      TreasurePageVM._instance = new TreasurePageVM();
    }
    return TreasurePageVM._instance;
  }

  public async getCloudUrl() {
    const res = await https.getCloudUrl();
    if (res.code === 0) {
      this.cloudUrl = res.data;
    }
  }

  public handleSwiperData() {
    this.swiperData = this.treasureInfo.map((item) => {
      const obj: SwiperItem = {
        img: item.bg,
        name: item.name,
        age: item.age,
        introduction: item.introduction,
      };
      return obj;
    });
  }

  public getDefaultIndex() {
    const param: Record<string, number> | undefined = RouterModule.getNavParam({ url: RouterMap.TREASURE_PAGE });
    if (param) {
      this.defaultIndex = param.defaultIndex;
    } else {
      this.defaultIndex = 0;
    }
  }

  public async getTreasureInfo() {
    const res = await https.getTreasureInfo();
    if (res.code === 0) {
      this.treasureInfo = res.data;
      this.handleSwiperData();
    }
  }
}
