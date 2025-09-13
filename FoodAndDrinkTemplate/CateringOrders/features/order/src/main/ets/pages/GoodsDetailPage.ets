import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { MustGoodsController } from '../models/MustGoodsController';
import { GoodsResp, GoodsSpecResp, PackageSpecResp, SpecCatalogResp, SpecItemResp } from 'network';
import * as API from '../api/Index';
import { Goods } from '../models/Index';
import { Constants, NavHeaderBar, PackageSpec, RouterMap, RouterModule, WindowModel } from 'common';
import { goodsInfoMapper } from '../mapper/Index';
import { GoodsDetail } from 'goods_detail';

@Builder
export function GoodsDetailPageBuilder() {
  GoodsDetailPage()
}

@ComponentV2
struct GoodsDetailPage {
  @Consumer('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController = new MustGoodsController();
  @Local goodsInfo: Goods = new Goods();
  @Local goodSpecList: Array<SpecCatalogResp> = [];
  @Local selectSpecArr: Array<PackageSpecResp> = [];
  @Local selectSpecInfo?: GoodsSpecResp = undefined;
  @Local goodSinglePrice: number = 0;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  private goodsId: string = '';

  aboutToAppear(): void {
    this.getParams();
    API.getGoodInfo(this.goodsId).then((resp: GoodsResp) => {
      this.goodsInfo = goodsInfoMapper(resp);
      if (resp.spec?.length && resp.spec?.length > 0) {
        this.goodSpecList = resp.spec ?? [];
        this.selectSpecArr = this.goodSpecList.map((item: SpecCatalogResp) => {
          let goodSpec = item.specVal.find((spec: SpecItemResp) => item.specValId === spec.specValId);
          let result: PackageSpec =
            { specName: goodSpec?.specValName || '', specNum: Number(goodSpec?.specValNum ?? 1) };
          return result;
        });

        API.getGoodSpec(this.goodsInfo?.id, this.selectSpecArr).then((res) => {
          this.selectSpecInfo = res;
          this.goodSinglePrice = Number(res.money);
        });

      } else {
        this.goodSinglePrice = Number(resp.money);
      }

    });
  }

  getParams() {
    let params = RouterModule.getNavParam<Record<string, string>>(RouterMap.GOODS_DETAIL_PAGE);
    if (params) {
      this.goodsId = params.goodsId;
    }
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: $r('app.string.good_details'), hasBgColor: false })
          .backgroundImage($r('app.media.background'))
          .backgroundImageSize(ImageSize.Cover);
        GoodsDetail({
          goodsInfo: this.goodsInfo,
          goodSpecList: this.goodSpecList,
          goodSinglePrice: this.goodSinglePrice,
          selectSpecArr: this.selectSpecArr,
          clickAddCarCb: (goodNum: number) => {
            this.clickAddCar(goodNum)
          },
          getSelectSpec: (item: SpecItemResp, index: number) => {
            this.getSelectSpec(item, index)
          },
        }).layoutWeight(1)

      }.margin({ bottom: this.windowModel.getWindowBottomHeight() });

    }.hideTitleBar(true);
  }

  getSelectSpec(item: SpecItemResp, index: number) {
    let pkgSpec: PackageSpecResp = {
      specName: item.specValName,
      specNum: Number(item.specValNum),
    };
    this.selectSpecArr[index] = pkgSpec;
    API.getGoodSpec(this.goodsInfo?.id, this.selectSpecArr).then((resp) => {
      this.selectSpecInfo = resp;
      this.goodSinglePrice = Number(resp.money);
    });
  }

  clickAddCar(goodNum: number) {
    if (this.goodSpecList.length) {
      if (!this.selectSpecInfo) {
        console.error(`add car selectSpecInfo empty.`);
        return;
      }
      API.addCarSpec(this.selectSpecInfo, this.goodsInfo?.id ?? '', Number(goodNum)).then(() => {
        promptAction.showToast({ message: $r('app.string.add_success') });
        if (this.goodsInfo?.isMust === Constants.GOODS_MUST) {
          this.mustGoodsCtrl.addIsMust(Number(goodNum));
        }
        RouterModule.pop();
      }).catch(() => {
        promptAction.showToast({ message: $r('app.string.add_failed') });
      });
    } else {
      if (this.goodsInfo) {
        API.addCar(this.goodsInfo, Number(goodNum)).then(() => {
          promptAction.showToast({ message: $r('app.string.add_success') });
          if (this.goodsInfo?.isMust === Constants.GOODS_MUST) {
            this.mustGoodsCtrl.addIsMust(Number(goodNum));
          }
          RouterModule.pop();
        }).catch(() => {
          promptAction.showToast({ message: $r('app.string.add_failed') });
        });
      } else {
        console.error(`add car goodInfo empty.`);
      }

    }
  }
}
