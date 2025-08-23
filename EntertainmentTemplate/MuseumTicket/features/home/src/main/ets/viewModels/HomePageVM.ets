import { AccountUtil, FormatUtil, RouterMap, UserInfo } from 'commonlib';
import { CloudUrl, https, ParkTextResp, RecommendListItem, TreasureItem, GetIntroduceResp } from 'network';
import { ServerListItem } from '../types/Index';


const TAG = '[HomePageVM]';


@ObservedV2
export class HomePageVM {
  @Trace cloudUrl: CloudUrl = new CloudUrl();
  @Trace bannerUrl: string[] = [];
  // 主要服务
  @Trace serverList: ServerListItem[] = [{
    name: '讲解服务',
    value: '1',
    icon: $r('app.media.ic_main_server1'),
    url: RouterMap.EXPLAIN,
  },
    {
      name: '省博介绍',
      value: '2',
      icon: $r('app.media.ic_main_server2'),
      url: RouterMap.INTRODUCE,
    },
    {
      name: '场馆地图',
      value: '3',
      icon: $r('app.media.ic_main_server3'),
      url: RouterMap.MAP,
    },
    {
      name: '停车缴费',
      value: '4',
      icon: $r('app.media.ic_main_server4'),
      url: RouterMap.PARKING,
    },
  ];
  // 精彩推荐
  @Trace recommendList: RecommendListItem[] = [];
  // 用户信息
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  // 省博介绍
  @Trace introduceText: GetIntroduceResp | undefined = undefined;
  @Trace parkingText: ParkTextResp[] = [];
  @Trace treasureInfo: TreasureItem[] = [];
  private static _instance: HomePageVM;

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  public async initData() {
    this.getRecommendList();
    this.getBannerImg();
    this.getCloudUrl();
    this.getTreasureInfo();
  }

  public async getRecommendList() {
    https.getRecommendList().then(res => {
      if (res.code === 0) {
        res.data.forEach((item: RecommendListItem, index) => {
          const img = FormatUtil.getImgResource(item.img);
          this.recommendList.push({
            id: item.id,
            price: item.price,
            img: img,
            name: item.name,
            detail: item.detail,
          });
        });
      }
    });
  }

  public async getIntroduceText() {
    const res = await https.getIntroduceText();
    if (res.code === 0) {
      this.introduceText = res.data;
    }
  }

  public async getParkingText() {
    const res = await https.getParkingText();
    if (res.code === 0) {
      this.parkingText = res.data;
    }
  }

  public async getBannerImg() {
    const res = await https.getBannerImg({ pageType: 1 });
    if (res.code === 0) {
      this.bannerUrl = res.data as string[];
    }
  }

  public async getCloudUrl() {
    const res = await https.getCloudUrl();
    if (res.code === 0) {
      this.cloudUrl = res.data;
    }
  }

  //  获取馆藏珍品信
  public async getTreasureInfo() {
    const res = await https.getTreasureInfo();
    if (res.code === 0) {
      this.treasureInfo = res.data;
    }
  }
}
