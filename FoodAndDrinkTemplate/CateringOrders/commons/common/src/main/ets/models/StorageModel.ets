import { OrderTypeEnum } from '../constants/Common';
import { Type, window } from '@kit.ArkUI';
import { getAnonymousTel } from '../utils/Utils';
import { MyCarResp, UserInfoResp } from 'network';

// 应用信息
export class AppInfoModel {
  packageName: string = '';
}

export class TableInfo {
  id: string = '';
  tableName: string = '';
  typeName: string = '';
  num: number = 0;
  status: number = 0;
}


export class Reduction {
  id: string = ''
  name: string = ''
  full: number = 0
  reduction: number = 0

  constructor(id: string = '', name: string = '', full: number = 0, reduction: number = 0) {
    this.id = id;
    this.name = name;
    this.full = full;
    this.reduction = reduction;
  }
}

export class RechargeTier {
  id: string = ''
  name: string = ''
  payMoney: number = 0
  realMoney: number = 0
  desc: string = ''
  type: number = 0
}

@ObservedV2
export class StoreInfo {
  id: string = ''
  @Trace name: string = ''
  address: string = ''
  // 营业开始时间
  @Trace time1: string = ''
  // 营业结束时间
  @Trace time2: string = ''
  @Trace tel: string = ''
  // 促销信息
  @Trace announcement: string = ''
  @Trace logo: string = ''
  // 位置坐标
  @Trace coordinates: string = ''
  // 营业执照
  @Trace businessLicense: string = ''
  // 食品经营许可证
  @Trace foodLicense: string = ''
  @Trace environment: Array<string> = []
  @Trace isRest: number = 0
  // 距离
  @Trace distance: number = 0
  @Trace distanceStr: string = ''
  // 新用户满减金额
  @Trace xyhMoney: number = 0
  // 备注口味：多个以;；分隔
  @Trace taste: string = ''
  @Type(Reduction)
  @Trace reductionList: Array<Reduction> = []
  rechargeTier: Array<RechargeTier> = []

  constructor(id: string = '', name: string = '', address: string = '', time1: string = '', time2: string = '',
    tel: string = '', announcement: string = '', logo: string = '', coordinates: string = '',
    businessLicense: string = '', foodLicense: string = '', environment: Array<string> = [], isRest: number = 0,
    xyhMoney: number = 0, taste: string = '', reductionList: Array<Reduction> = [],
    rechargeTier: Array<RechargeTier> = []) {
    this.id = id
    this.name = name
    this.address = address
    this.time1 = time1
    this.time2 = time2
    this.tel = tel
    this.announcement = announcement
    this.logo = logo
    this.coordinates = coordinates
    this.businessLicense = businessLicense
    this.foodLicense = foodLicense
    this.environment = environment
    this.isRest = isRest
    this.xyhMoney = xyhMoney
    this.taste = taste
    this.reductionList = reductionList
    this.rechargeTier = rechargeTier
  }
}

// 店铺信息
@ObservedV2
export class StoreInfoModel {
  @Trace storeId: string = '';
  @Trace tel: string = '';
  @Trace storeType: number = 2;
  @Trace orderType: number = OrderTypeEnum.PICK_SELF
  @Trace distance: number = 0
  @Trace isRest: boolean = false
  @Trace qrCodeFlag: boolean = false
  @Trace preloadFinished: boolean = false
  @Type(TableInfo)
  @Trace tableList: Array<TableInfo> = [];
  @Trace storeInfo: StoreInfo = new StoreInfo()
  @Type(StoreInfo)
  @Trace storeList: Array<StoreInfo> = []
}

// 用户头像持久化
@ObservedV2
export class WindowModel {
  @Trace windowTopHeight: number = 38.77;
  @Trace windowBottomHeight: number = 28;
  @Trace windowStage?: window.WindowStage = undefined;

  getWindowTopHeight() {
    return this.windowTopHeight || 38.77;
  }

  getWindowBottomHeight() {
    return this.windowBottomHeight || 28;
  }
}

@ObservedV2
export class FormCard {
  @Trace id: number = 0
  url: string = ''
  @Trace orderId: string = ''
  @Trace isOrderJump: boolean = false
}

// 购物车信息
@ObservedV2
export class MyCarModel {
  @Trace myCar: MyCar = new MyCar()
  @Trace tableId: string = ''
  @Trace dinerNum: ResourceStr = ''
  @Trace tableInfo: TableInfo = new TableInfo()
  @Trace preorderTime: string = '立即就餐'
  @Trace carCheck: Array<string> = []
}

export class MyCar {
  boxMoney: number = 0
  goodsList: Array<CarGoodsInfo> = []
  num: number = 0
  money: number = 0

  constructor(boxMoney: number = 0, goodsList: Array<CarGoodsInfo> = [], num: number = 0, money: number = 0) {
    this.boxMoney = boxMoney
    this.goodsList = goodsList
    this.num = num
    this.money = money
  }

  update(item: MyCarResp) {
    this.boxMoney = item.boxMoney
    this.goodsList = item.goodsList
    this.num = item.num
    this.money = item.money
  }
}

export class PackageSpec {
  specName: string = ''
  specNum: number = 0
}

@ObservedV2
export class CarGoodsInfo {
  id: string = ''
  goodsId: string = '';
  name: string = ''
  logo: string = ''
  @Trace num: number = 0
  specType: number = 0
  spec: string = ''
  combination: PackageSpec[] = []
  discount: string = ''
  money: number = 0
  money2: number = 0
  boxMoney: number = 0
  isMust: number = 0
}

@ObservedV2
export class UserInfo implements UserInfoResp {
  id: string = ''
  name: string = ''
  img: string = ''
  openId: string = ''
  unionId: string = ''
  storeId: string = ''
  @Trace totalScore: number = 0
  @Trace wallet: number = 0
  @Trace userTel: string = ''

  constructor(id: string = '', name: string = '', img: string = '', openId: string = '',
    storeId: string = '', totalScore: number = 0, wallet: number = 0, unionId: string = '') {
    this.id = id
    this.name = name
    this.img = img
    this.openId = openId
    this.storeId = storeId
    this.totalScore = totalScore
    this.wallet = wallet
    this.unionId = unionId
  }
}

@ObservedV2
export class UserInfoModel {
  @Trace userInfo: UserInfo = new UserInfo()
  @Trace authCode: string = ''
  @Trace isRelative: boolean = false

  getUserName(): ResourceStr {
    return this.isRelative ? this.userInfo.name : $r('app.string.no_relate')
  }

  getTotalScore(): number {
    return this.isRelative ? this.userInfo.totalScore : 0
  }

  getTel(): string {
    return getAnonymousTel(this.userInfo.userTel)
  }
}

// 用户头像持久化
@ObservedV2
export class UserIconModel {
  @Trace isSaved: boolean = false
  @Trace userIconPath: string = 'userImage.jpg'
}