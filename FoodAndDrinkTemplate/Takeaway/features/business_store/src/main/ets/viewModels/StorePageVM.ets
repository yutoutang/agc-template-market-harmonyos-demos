import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import {
  GoodsServiceApi,
  GoodsTypeResp,
  MustGoodsController,
  MyCar,
  MyCarModel,
  StoreModel,
  StoreServiceApi,
  SubmitOrderItem
} from 'lib_takeaway_api';
import { StoreResponse } from 'lib_takeaway_api/src/main/ets/params/response/StoreResponse';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { LoginSheetUtils } from 'lib_account';
import { CommentApis } from 'module_store_comments';

@ObservedV2
export class StorePageViewModel extends BaseViewModel {
  // 店铺id
  @Trace storeId: string = '';
  // 店铺信息
  @Trace storeInfo: StoreResponse | undefined = undefined
  // 关注列表
  @Trace followStoreList: StoreModel[] = [];
  // 是否关注
  @Trace isFollow: boolean = false;
  @Trace showCarList: boolean = false;
  // tabIndex
  @Trace currentIndex: number = 0;
  // 必选商品index
  @Trace goodsMustIndex: number = 0;
  // 评论总数
  @Trace commentTotal: number = 0;
  // 评论总数处理
  @Trace commentTotalStr: string = '';
  // 店铺原始商品
  @Trace originGoodsList: GoodsTypeResp[] = []
  // 店铺展示商品
  @Trace displayGoodsList: GoodsTypeResp[] = []
  tabController: TabsController = new TabsController();
  titleItemScroller: Scroller = new Scroller();
  goodsScroller: Scroller = new Scroller();
  // 我的购物车
  @Trace myCar: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!;
  @Trace storeCar: MyCar = AppStorageV2.connect(MyCar, () => new MyCar())!;
  mustGoodsCtrl: MustGoodsController = new MustGoodsController();

  updateStoreCar() {
    this.storeCar = this.myCar.myCar.find((item: MyCar) => item.storeId === this.storeId) || new MyCar()
  }

  /**
   * 查询我的关注
   */
  queryFollowStore() {
    const tempFollowStoreList: StoreModel[] = [];
    StoreServiceApi.queryMyFollows().forEach(followStore => {
      tempFollowStoreList.push(new StoreModel(followStore))
      if (followStore.id === this.storeId) {
        this.isFollow = true
      }
    })
    this.followStoreList = tempFollowStoreList
  }

  /**
   * 查询店铺信息
   */
  queryStoreInfo(storeId: string) {
    this.storeId = storeId
    this.storeInfo = StoreServiceApi.queryStoreByStoreId(storeId)
    if (this.userInfoModel.isLogin) {
      this.queryFollowStore()
    } else {
      this.isFollow = false
      this.followStoreList = []
    }
  }

  initStore(storeId: string) {
    // 查询店铺信息
    this.queryStoreInfo(storeId)
    // 查询评价总数
    this.commentTotal = CommentApis.getCommentTotal(storeId)
    this.convertCommentTotalStr(this.commentTotal)
    // 查询商品
    let goods = GoodsServiceApi.queryStoreGoodsList(storeId)
    this.originGoodsList = JSON.parse(JSON.stringify(goods))
    this.displayGoodsList = JSON.parse(JSON.stringify(goods))
    // 查询购物车
    if (this.userInfoModel.isLogin) {
      this.myCar = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!;
      this.myCar.storeIdNow = storeId
      this.storeCar = this.myCar.myCar.find((item: MyCar) => item.storeId === this.storeId) || new MyCar()
    } else {
      this.storeCar = new MyCar()
    }
    // 查询是否选中必选品
    this.mustGoodsCtrl = new MustGoodsController()
    this.storeCar.goodsList.forEach(carGoodsItem => {
      if (carGoodsItem.isMust) {
        this.mustGoodsCtrl.addIsMust(carGoodsItem.num)
      }
    })
    // 查询必选商品索引和必选商品数量
    for (let i = 0; i < this.originGoodsList.length; i++) {
      this.originGoodsList[i].goods.forEach(goodsItem => {
        if (goodsItem.isMust === 1) {
          this.mustGoodsCtrl.changeShopIsMustGoods()
          this.goodsMustIndex = i
        }
      })
    }
  }

  /**
   * 店铺点击关注
   */
  clickFollow() {
    if (this.userInfoModel.isLogin) {
      if (this.isFollow) {
        this.cancelFollowStore(this.storeId)
        promptAction.showToast({ message: '已取消关注' });
      } else {
        this.followStore(this.storeId)
        promptAction.showToast({ message: '已成功关注' });
      }
    } else {
      LoginSheetUtils.open()
    }
  }

  /**
   * 关注
   * @param storeId
   */
  followStore(storeId: string) {
    StoreServiceApi.addFollow(storeId)
    this.isFollow = true
  }

  convertCommentTotalStr(commentTotal: number) {
    if (commentTotal > 0) {
      this.commentTotalStr = commentTotal + '+'
    } else {
      this.commentTotalStr = ''
    }
  }

  /**
   * 取消关注
   * @param storeId
   */
  cancelFollowStore(storeId: string) {
    StoreServiceApi.cancelFollow(storeId)
    this.isFollow = false
  }

  /**
   * 切换tab
   * @param index
   */
  public async changeTab(index: number) {
    this.currentIndex = index;
  }

  /**
   * 返回
   */
  public customBack() {
    this.isFollow = false
    this.myCar.storeIdNow = ''
    this.showCarList = false
    RouterUtils.pop(1)
  }

  public cleanStoreCar() {
    this.storeCar = new MyCar()
  }

  goMustGoods = () => {
    if (this.mustGoodsCtrl.isNeedMustGoods && this.goodsMustIndex >= 0) {
      // 搜索占据第一个索引，这里需要给index+1
      this.goodsScroller.scrollToIndex(this.goodsMustIndex + 1);
    }
  }

  submitClick(onPop: Callback<PopInfo>) {
    if (this.storeCar && this.storeCar?.num > 0) {
      if (this.mustGoodsCtrl.isNeedMustGoods) {
        this.mustGoodsCtrl.clickSubmit()
        this.goMustGoods()
        promptAction.showToast({ message: '请选择必选品' })
      } else {
        this.showCarList = false
        this.mustGoodsCtrl.clickSubmit()
        if (this.storeInfo) {
          let submitParam: SubmitOrderItem = {
            storeInfo: this.storeInfo,
            carGoodsList: this.storeCar.goodsList
          }
          RouterUtils.pushPathByName(RouterMap.ORDER_SUBMIT, submitParam, onPop)
        }
      }
    }
  }
}