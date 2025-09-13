import {
  Constants,
  getDistanceWithLocation,
  getFmtDistWithLocation,
  MyCarModel,
  PermissionUtil,
  StoreInfoModel,
  StoreType,
  TabBarType,
  TableInfo,
} from 'common/Index';
import { TitleComp } from '../components/TitleComp';
import { MyCarListComp } from '../components/MyCarListComp';
import { MyCarComp } from '../components/MyCarComp';
import { MustGoodsController } from '../models/MustGoodsController';
import { CustomSelectSheetBuilder } from '../components/CustomSelectDialog';
import { OrderListComp } from '../components/OrderListComp';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessTimeDialog } from 'base_ui';
import { DishesTypeResp, HttpRequest } from 'network';
import * as API from '../api/Index';

@Builder
export function OrderPageBuilder() {
  OrderPage()
}

@ComponentV2
struct OrderPage {
  // 原始商品列表
  @Provider('dishesListOri') dishesListOri: Array<DishesTypeResp> = []
  // 展示的商品列表
  @Provider('dishesList') dishesList: Array<DishesTypeResp> = []
  @Consumer('currentIndex') currentIndex: number = 0
  @Consumer('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController = new MustGoodsController()
  @Local myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel) as MyCarModel
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local showCarList: boolean = false
  @Local tableSheetShow: boolean = false;
  @Local dinerSheetShow: boolean = false;
  businessHoursAM: string = ''
  businessHoursPM: string = ''
  businessController: CustomDialogController = new CustomDialogController({
    builder: BusinessTimeDialog({
      businessHoursAM: this.businessHoursAM,
      businessHoursPM: this.businessHoursPM,
    }),
    width: 296,
    height: 348,
  });

  @Monitor('currentIndex')
  currentIndexChange() {
    if (this.currentIndex === TabBarType.HOMEPAGE) {
      this.chooseRefresh()
    }
  }

  @Monitor('storeModel.storeId')
  getStoreInfo() {
    API.getStoreInfo(this.storeModel.storeId).then(res => {
      this.storeModel.storeInfo = res;
      PermissionUtil.getLocation().then(location => {
        this.storeModel.storeInfo.distance = getDistanceWithLocation(location, res.coordinates);
        this.storeModel.storeInfo.distanceStr = getFmtDistWithLocation(location, res.coordinates);
      })
      this.isShowRest()
    });
  }

  aboutToAppear() {
    this.getDishesList()
    this.getStoreInfo()
    HttpRequest.getMyCar()

    this.chooseRefresh()
  }

  build() {
    NavDestination() {
      Stack() {
        Column({ space: 12 }) {
          TitleComp()
          OrderListComp().layoutWeight(1)
        }
        .height(Constants.FULL_SIZE)
        .width(Constants.FULL_SIZE)
        .bindSheet($$this.tableSheetShow,
          CustomSelectSheetBuilder($r('app.string.pick_table'), this.storeModel.tableList.map((item) => {
            return item.typeName ?? '';
          }), (select: ResourceStr) => {
            this.confirmTable(select);
          }), {
            height: 408,
            blurStyle: BlurStyle.Thick,
            showClose: false,
          });

        MyCarListComp({
          close: () => {
            this.showCarList = false
          },
        }).visibility(this.showCarList ? Visibility.Visible : Visibility.Hidden)
        // 购物车
        MyCarComp({
          showCarList: this.showCarList, changeCarListShow: (flag: boolean) => {
            this.showCarList = flag
          },
        })
          .visibility(this.myCarModel.myCar.goodsList?.length ? Visibility.Visible : Visibility.Hidden)
      }.alignContent(Alignment.Bottom)
      .bindSheet($$this.dinerSheetShow,
        CustomSelectSheetBuilder($r('app.string.pick_dinner_num'), $r('app.strarray.diner_num'),
          (select: ResourceStr) => {
            this.confirmDiner(select);
          }), {
          height: 408,
          blurStyle: BlurStyle.Thick,
          showClose: false,
        });
    }
    .hideTitleBar(true)
  }

  getDishesList() {
    API.getDishesList().then(res => {
      this.dishesList = res
      this.dishesListOri = JSON.parse(JSON.stringify(res))
      this.dishesList.forEach(item => {
        item.goods.forEach(i => {
          if (i.isMust === Constants.GOODS_MUST) {
            this.mustGoodsCtrl.changeShopIsMustGoods()
          }
        })

      })
    })
  }

  chooseRefresh() {
    if (!this.storeModel.isRest) {
      if (this.storeModel.storeType === StoreType.SCAN_TYPE && !this.myCarModel.tableId) {
        this.myCarModel.tableInfo = new TableInfo()
        this.tableSheetShow = true
      } else if (!this.myCarModel.dinerNum && !this.dinerSheetShow) {
        this.dinerSheetShow = true
      }
    }
  }

  isShowRest() {
    if (this.storeModel.storeInfo.isRest === Constants.STORE_REST ||
      new Date().getTime() < this.getTimeByHour(this.storeModel.storeInfo.time1) ||
      new Date().getTime() > this.getTimeByHour(this.storeModel.storeInfo.time2)) {
      this.businessHoursAM = `AM ${this.storeModel.storeInfo?.time1}-${Constants.MID_DAY_TIME}`
      this.businessHoursPM = `PM ${Constants.MID_DAY_TIME}-${this.storeModel.storeInfo?.time2}`
      if (!this.storeModel.isRest) {
        this.businessController?.open();
      }
      this.storeModel.isRest = true
    } else {
      this.storeModel.isRest = false
    }
  }

  getTimeByHour(time: string = '') {
    let date = new Date(`${new Date().toLocaleDateString()} ${time}`)
    return date.getTime()
  }

  confirmTable(select: ResourceStr) {
    if (select) {
      let table = this.storeModel.tableList.find(item => item.tableName === select)
      this.myCarModel.tableId = table?.id ?? '1';
      this.myCarModel.tableInfo = this.storeModel.tableList.find(item => item.id === this.myCarModel.tableId)!;
    }
    this.tableSheetShow = false
    if (!this.myCarModel.dinerNum) {
      this.dinerSheetShow = true
    }
  }

  confirmDiner(select: ResourceStr) {
    if (select) {
      this.myCarModel.dinerNum = select;
    } else {
      this.myCarModel.dinerNum = this.myCarModel.dinerNum || `1人`;
    }
    this.dinerSheetShow = false
  }
}
