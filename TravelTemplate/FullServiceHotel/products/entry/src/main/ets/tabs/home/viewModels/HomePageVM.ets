import {
  AccountUtil,
  AppStorageMap,
  FormatUtil,
  Logger,
  MemberInfo,
  RouterMap,
  RouterModule,
} from 'commonlib';
import { https, StructureDetailItem } from 'network';
import { ServiceLink, TemplateStructureType } from '../commons/Constants';
import { BannerItem, ProductItem, ProductItemResp, PublicNoticeItem, ServiceItem } from '../commons/Types';

const TAG = '[HomePageVM]';

@ObservedV2
export class HomePageVM {
  // banner
  @Trace bannerList: ResourceStr[] = [];
  // 滚动公告
  @Trace publicNoticeList: PublicNoticeItem[] = [];
  // 会员信息
  @Trace vipMemberInfo: MemberInfo | undefined = undefined;
  // 两图列表
  @Trace twoPicsService: ServiceItem[] = [];
  // 三图列表
  @Trace threePicsService: ServiceItem[] = [];
  // icon列表
  @Trace iconServiceList: ServiceItem[] = [];
  // 商城广告图
  @Trace productAd: ResourceStr = '';
  // 商城列表
  @Trace productList: ProductItem[] = [];
  private static _instance: HomePageVM;

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  public async initData() {
    await this.getTenantInfo();
    this.handleHomePageConfig();
    this.getPublicNoticeList();
  }

  public async getTenantInfo() {
    let tenantId: number | undefined = AppStorage.get(AppStorageMap.TENANT_ID);
    if (!tenantId) {
      const res = await https.getTenantInfo();
      if (res.code === 0) {
        tenantId = res.data.tenantId;
        AppStorage.setOrCreate(AppStorageMap.TENANT_ID, tenantId);
      }
    }
  }

  public async handleHomePageConfig() {
    let structureDetails: StructureDetailItem[] | undefined = AppStorage.get(AppStorageMap.STRUCTURE_CACHE);
    if (!structureDetails) {
      const res = await https.getTenantConfig();
      if (res.code !== 0) {
        Logger.error(TAG, 'get tenant config failed');
        return;
      }
      structureDetails = res.data;
    }

    structureDetails.forEach((item: StructureDetailItem) => {
      switch (item.templateStructureType) {
        case TemplateStructureType.CAROUSEL:
          this.getBannerList(item.info);
          break;
        case TemplateStructureType.PICS_2:
          this.getTwoPicService(item.info);
          break;
        case TemplateStructureType.PICS_3:
          this.getThreePicService(item.info);
          break;
        case TemplateStructureType.ICONS:
          this.getIconService(item.info);
          break;
        case TemplateStructureType.MALL_PIC:
          this.getMallPic(item.info);
          break;
        case TemplateStructureType.MALL_LIST:
          this.getMallList(item.info);
          break;
        default:
          break;
      }
    });
  }

  public getBannerList(info: string) {
    const imgSrcs: BannerItem[] = JSON.parse(info);
    this.bannerList = imgSrcs.map((item) => FormatUtil.getImgResource(item.image as string));
  }

  public async getPublicNoticeList() {
    https.getNoticeList().then((res) => {
      if (res.code === 0) {
        res.data.forEach((item) => {
          const noticeItem: PublicNoticeItem = {
            title: item.noticeTitle,
            noticeId: item.noticeId,
            date: item.publishTime,
          };
          this.publicNoticeList.push(noticeItem);
        });
      }
    });
  }

  public getVipMemberInfo() {
    const userInfo = AccountUtil.getUserInfo();
    if (userInfo.memberInfo) {
      this.vipMemberInfo = userInfo.memberInfo;
    }
  }

  public getTwoPicService(info: string) {
    const itemList: ServiceItem[] = JSON.parse(info);
    this.twoPicsService = itemList.map((item) => {
      return {
        link: item.link,
        image: FormatUtil.getImgResource(item.image),
        title: item.title,
      } as ServiceItem;
    });
  }

  public getThreePicService(info: string) {
    const itemList: ServiceItem[] = JSON.parse(info);
    this.threePicsService = itemList.map((item) => {
      return {
        link: item.link,
        image: FormatUtil.getImgResource(item.image),
        title: item.title,
      } as ServiceItem;
    });
  }

  public getIconService(info: string) {
    const itemList: ServiceItem[] = JSON.parse(info);
    this.iconServiceList = itemList.map((item) => {
      return {
        link: item.link,
        image: FormatUtil.getImgResource(item.image),
        title: item.title,
      } as ServiceItem;
    });
  }

  public getMallPic(info: string) {
    const infoList: ServiceItem = JSON.parse(info);
    this.productAd = FormatUtil.getImgResource(infoList.image);
  }

  public getMallList(info: string) {
    const itemList: ProductItemResp[] = JSON.parse(info);
    itemList.forEach((item) => {
      const product: ProductItem = {
        label: item.text,
        image: FormatUtil.getImgResource(item.image),
        id: item.id,
        discountedPrice: item.price,
        originalPrice: item.oldPrice,
        monthlySales: item.monthlySales,
      };
      this.productList.push(product);
    });
  }

  private jumpToNext<T = undefined>(service: RouterMap, params?: T) {
    try {
      if (params) {
        RouterModule.push({
          url: service,
          param: params,
        });
      } else {
        RouterModule.push({
          url: service,
        });
      }
    } catch (err) {
      Logger.error(TAG, 'jump to next page failed::' + JSON.stringify(err));
    }
  }

  public jumpToPublicNoticePage(index: number) {
    const noticeId: number = this.publicNoticeList[index].noticeId;
    this.jumpToNext<number>(RouterMap.HOME_PUBLIC_NOTICE, noticeId);
  }

  public jumpToServicePage(link: string) {
    switch (link) {
      case ServiceLink.HOTEL_ROOM:
        this.jumpToNext(RouterMap.HOTEL_LIST);
        break;
      case ServiceLink.CATERING:
        this.jumpToNext(RouterMap.RESTAURANT_LIST);
        break;
      case ServiceLink.BALLROOM:
        this.jumpToNext(RouterMap.BANQUET_HOTEL_LIST);
        break;
      case ServiceLink.ORDERS:
        this.jumpToNext(RouterMap.ORDER_LIST);
        break;
      case ServiceLink.COMMENTS:
        this.jumpToNext(RouterMap.COMMENT_LIST);
        break;
      case ServiceLink.LOCATION:
        this.jumpToNext(RouterMap.COMMON_LOCATION);
        break;
      case ServiceLink.INTRODUCTION:
        this.jumpToNext(RouterMap.COMMON_INTRODUCTION);
        break;
      default:
        break;
    }
  }
}
