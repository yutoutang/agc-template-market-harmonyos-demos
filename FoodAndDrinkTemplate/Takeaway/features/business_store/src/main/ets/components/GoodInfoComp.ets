import { AppStorageV2, MeasureText, promptAction } from '@kit.ArkUI';
import { CommonConstants } from 'lib_common';
import {
  CarGoodsInfo,
  Goods,
  GoodsServiceApi,
  GoodsSpecResp,
  MyCar,
  MyCarModel,
  MyCartServiceApi,
  PackageSpec,
  SpecCatalogResp,
  SpecItemResp,
  StoreServiceApi
} from 'lib_takeaway_api';
import { CommonUrl, Constants, GoodsSpecEnum } from '../common/Constants';
import { StorePageViewModel } from '../viewModels/StorePageVM';
import { Decimal } from '@kit.ArkTS';
import { LoginSheetUtils } from 'lib_account';

// 子列表
@ComponentV2
export struct GoodInfoComp {
  @Local myCar: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!;
  @Consumer() storeCar: MyCar = AppStorageV2.connect(MyCar, () => new MyCar())!;
  @Require @Param vm: StorePageViewModel
  @Param @Require item: Goods = new Goods();
  @Local carGoodsInfo: CarGoodsInfo = new CarGoodsInfo();
  @Local goodNum: string = '1';
  @Local goodSpecList: SpecCatalogResp[] = [];
  @Local sumPrice: number = this.item.money ?? 0;
  @Local selectSpecArr: PackageSpec[] = [];
  @Local selectSpecInfo?: GoodsSpecResp = undefined;
  @Local goodSinglePrice: number = 0;
  @Local specSheetFlag: boolean = false;
  @Local showGoodContent: boolean = true;
  @Local goodTextWidth: number = 0;
  @Local carGoodsNum: number = 0;

  aboutToAppear(): void {
    let carGoodsInfo = this.storeCar.goodsList?.find((item: CarGoodsInfo) => item.goodsId === this.item.id)!;
    if (carGoodsInfo) {
      this.carGoodsInfo = carGoodsInfo
      this.carGoodsInfo.num = carGoodsInfo.num
      this.carGoodsNum = carGoodsInfo.num
    } else {
      this.carGoodsInfo.num = 0
      this.carGoodsNum = 0
    }
  }

  @Monitor('storeCar.num')
  myCarChange(monitor: IMonitor) {
    let carGoodsInfo = this.storeCar.goodsList?.find((item: CarGoodsInfo) => item.goodsId === this.item.id)!;
    if (carGoodsInfo) {
      this.carGoodsInfo = carGoodsInfo
      this.carGoodsInfo.num = carGoodsInfo.num
      this.carGoodsNum = carGoodsInfo.num
    } else {
      this.carGoodsInfo.num = 0
      this.carGoodsNum = 0
    }
  }

  goodChange() {
    let nameWidth: number = MeasureText.measureText({
      textContent: this.item.name,
      fontSize: '14px',
    });
    if (nameWidth > this.goodTextWidth) {
      this.showGoodContent = false;
    } else {
      this.showGoodContent = true;
    }
  }

  build() {
    Row() {
      // 基础URL拼接返回的imageURL地址
      Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.item?.logo}`).width(70).height(70).borderRadius(6)
      Column() {
        Column() {
          Text(this.item?.name)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          if (this.showGoodContent) {
            Text(this.item?.content)
              .fontSize($r('sys.float.Caption_M'))
              .lineHeight(14)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 2 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
          Text(Number(this.item?.sales) > 100 ? $r('app.string.sales_more') :
          $r('app.string.month_sale', this.item?.sales))
            .fontSize($r('sys.float.Caption_M'))
            .lineHeight(14)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 2 });
        }.alignItems(HorizontalAlign.Start)

        Row() {
          Row() {
            Text() {
              Span($r('app.string.currency_symbol'))
                .fontSize(10)
                .fontWeight(400)
                .fontColor($r('app.color.orange_yellow'))
              Span(`${Number(this.item?.money)}`)
                .fontSize(15)
                .fontWeight(600)
                .fontColor($r('app.color.orange_yellow'))
            };

            if (this.item.specType === GoodsSpecEnum.PACKAGE_TYPE) {
              Text($r('app.string.discount', this.item.discount))
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.multi_color_09'))
                .padding({
                  left: 4,
                  right: 4,
                  top: 2,
                  bottom: 2,
                })
                .borderWidth(1)
                .borderColor($r('sys.color.multi_color_09'))
                .borderRadius(4)
                .margin({ left: 4 });
              Text($r('app.string.currency_symbol_post_params', this.item?.money2))
                .fontSize($r('sys.float.Caption_S'))
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(14)
                .margin({ left: 4 })
                .decoration({
                  type: TextDecorationType.LineThrough,
                  color: $r('sys.color.font_secondary'),
                });
            }

          };

          if (this.item?.specType === GoodsSpecEnum.NORMAL) {
            Row() {
              Image($r('app.media.ic_subtract'))
                .width(20)
                .height(20)
                .onClick(() => {
                  if (this.vm.userInfoModel.isLogin) {
                    if (this.carGoodsNum && this.carGoodsNum > 0) {
                      MyCartServiceApi.subMyCar(this.vm.storeId, this.carGoodsInfo.id)
                      if (this.item.isMust === 1) {
                        // 必选
                        this.vm.mustGoodsCtrl.subIsMust()
                      }
                      this.storeCar = this.vm.myCar.myCar.find((item) =>
                      item.storeId === this.vm.storeId) || new MyCar()
                      this.vm.storeCar = this.vm.myCar.myCar.find((item) =>
                      item.storeId === this.vm.storeId) || new MyCar()
                      promptAction.showToast({ message: '减少成功！' });
                      // }
                    }
                  } else {
                    LoginSheetUtils.open()
                  }
                })
                .visibility(this.carGoodsNum && this.carGoodsNum > 0 ? Visibility.Visible :
                Visibility.Hidden);
              Text(this.carGoodsNum.toString())
                .margin({ left: 8, right: 8 })
                .fontSize(12)
                .fontColor('#909399')
                .fontWeight(400)
                .visibility(this.carGoodsNum && this.carGoodsNum > 0 ? Visibility.Visible :
                Visibility.Hidden);
              Image($r('app.media.ic_add_car'))
                .width(20)
                .height(20)
                .onClick(() => {
                  if (this.vm.userInfoModel.isLogin) {
                    if (this.carGoodsInfo.num >= 10) {
                      promptAction.showToast({ message: '已达最大限购数量' });
                      return
                    }
                    let flag = StoreServiceApi.addCar(this.vm.storeId, this.vm.storeInfo, this.item)
                    if (flag === 1) {
                      // this.carGoodsInfo.num++
                      if (this.item.isMust === 1) {
                        // 必选
                        this.vm.mustGoodsCtrl.addIsMust()
                      }
                      this.storeCar =
                        this.vm.myCar.myCar.find((item) => item.storeId === this.vm.storeId) || new MyCar()
                      this.vm.storeCar =
                        this.vm.myCar.myCar.find((item) => item.storeId === this.vm.storeId) || new MyCar()
                      promptAction.showToast({ message: '添加成功！' });
                    }
                  } else {
                    LoginSheetUtils.open()
                  }
                });
            }.padding({ right: 8 });

          } else {
            Row() {
              Text(this.item?.specType === GoodsSpecEnum.PACKAGE_TYPE ? '选套餐' : '选规格')
                .fontSize(10)
                .fontColor('#FFFFFF')
                .width(46)
                .height(18)
                .textAlign(TextAlign.Center)
            }
            .margin({
              right: 8
            })
            .borderRadius(4)
            .backgroundColor($r('app.color.app_theme'))
            .onClick(() => {
              if (this.item?.specType === GoodsSpecEnum.PACKAGE_TYPE) {
                return;
              }
              this.getGoodsInfo(this.item.id)
            });
          }
        }
        .margin({ top: 3 })
        .width(CommonConstants.FULL_PERCENT)
        .height(22)
        .justifyContent(FlexAlign.SpaceBetween);

      }
      .layoutWeight(1)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: 5.5, top: 1, bottom: 1 })
      .alignItems(HorizontalAlign.Start)
      .onAreaChange((oldValue, newValue) => {
        if (newValue.width && oldValue.width !== newValue.width) {
          this.goodTextWidth = Number(newValue.width);
          this.goodChange();
        }
      });
    }
    .alignItems(VerticalAlign.Top)
    .width(CommonConstants.FULL_PERCENT)
    .height(72)
    .backgroundColor(this.item.isMust === Constants.GOODS_MUST && this.vm.mustGoodsCtrl.showMustGoods ? '#0FF9A01E' :
      '#FFFFFF')
    .justifyContent(FlexAlign.SpaceBetween)
    .bindSheet($$this.specSheetFlag, this.specSheet(() => {
      this.specSheetFlag = false
    }), {
      height: 440,
      preferType: SheetType.CENTER,
      blurStyle: BlurStyle.Thick,
      showClose: false,
    });
  }

  @Builder
  specSheet(close: () => void) {
    Column() {
      Row()
        .width(48)
        .height(4)
        .backgroundColor($r('sys.color.mask_fourth'))
        .borderRadius(2)
        .margin({ top: 8, bottom: 16 })
      Row() {
        Text(this.item.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'))
          .textAlign(TextAlign.Start)
      }
      .padding({
        left: 16,
        right: 16,
      })
      .height(56)
      .width(CommonConstants.FULL_PERCENT)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      Column() {
        ForEach(this.goodSpecList, (goodSpec: SpecCatalogResp, index: number) => {
          Column() {
            Text(goodSpec.specName)
              .fontSize(14)
              .fontWeight(500)
              .fontColor('#909399')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(goodSpec.specVal, (item: SpecItemResp) => {
                Row() {
                  Text(item.specValName)
                    .fontSize(12)
                    .fontWeight(400)
                    .fontColor(this.selectSpecArr[index].specName === item.specValName ?
                    $r('app.color.app_theme') : '#999999')
                }
                .height(28)
                .padding({
                  left: 12,
                  right: 12,
                  top: 4,
                  bottom: 4,
                })
                .borderColor(this.selectSpecArr[index].specName === item.specValName ? $r('app.color.app_theme') :
                  '#D8D8D8')
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.selectSpecArr[index].specName === item.specValName ?
                  '#FEF3DE' : '#D8D8D8')
                .borderRadius(4)
                .onClick(() => {
                  let pkgSpec: PackageSpec = {
                    specName: item.specValName,
                    specNum: Number(item.specValNum),
                  };
                  this.selectSpecArr[index] = pkgSpec;
                  this.getGoodSpec(this.item.id, this.selectSpecArr)
                });
              }, (item: SpecItemResp, index: number) => JSON.stringify(item));
            }.margin({ top: 12 })

          }.alignItems(HorizontalAlign.Start).margin({ top: 20 });
        }, (goodSpec: SpecCatalogResp) => goodSpec.specId);

      }
      .padding({
        left: 16,
      })
      .layoutWeight(1)
      .width(CommonConstants.FULL_PERCENT)

      Row() {
        Text() {
          Span($r('app.string.currency_symbol'))
            .fontSize(14)
            .fontWeight(500)
            .fontColor('#121212')
          Span(`${Number(this.goodSinglePrice)}`)
            .fontSize(22)
            .fontWeight(500)
            .fontColor('#121212')
        }

        Button('加入购物车')
          .height(40)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .linearGradient(
            { angle: 90, colors: [[$r('app.color.app_theme'), 0], [$r('app.color.orange_yellow'), 1]] }
          )
          .onClick(() => {
            if (this.vm.userInfoModel.isLogin) {
              if (this.selectSpecInfo) {
                // 校验
                let existingGoods = this.storeCar.goodsList?.find((carGoods) =>
                carGoods.goodsId === this.item.id &&
                  carGoods.spec === this.selectSpecInfo?.spec
                )
                let existingGoodsNum = existingGoods ? existingGoods.num : 0;
                if (existingGoodsNum >= 10) {
                  promptAction.showToast({ message: '已达最大限购数量' });
                  return;
                }
                let flag = StoreServiceApi.addCar(this.vm.storeId, this.vm.storeInfo, this.item, this.selectSpecInfo)
                if (flag === 1) {
                  this.specSheetFlag = false
                  this.storeCar = this.vm.myCar.myCar.find((item) => item.storeId === this.vm.storeId) || new MyCar()
                  this.vm.storeCar = this.vm.myCar.myCar.find((item) => item.storeId === this.vm.storeId) || new MyCar()
                  promptAction.showToast({ message: '添加成功！' });
                }
              }
            } else {
              LoginSheetUtils.open()
            }
          })
      }
      .border({
        width: {
          top: 0.5
        },
        color: '#EBEBEB'
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .height(54)
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      })
    }
    .padding({
      bottom: 10
    })

  }

  getGoodsInfo(goodsId: string) {
    const goodsInfo = GoodsServiceApi.queryGoodsInfoById(goodsId)
    this.goodSpecList = goodsInfo?.spec ?? [];
    this.selectSpecArr = this.goodSpecList.map((item: SpecCatalogResp) => {
      let goodSpec = item.specVal.find((spec: SpecItemResp) => item.specValId === spec.specValId);
      let result: PackageSpec = {
        specName: goodSpec?.specValName ?? item.specVal[0].specValName,
        specNum: Number(goodSpec?.specValNum ?? 0),
      };
      return result;
    });
    const goodsSpecInfo = GoodsServiceApi.queryGoodsSpecInfo(goodsId, this.selectSpecArr)
    this.selectSpecInfo = goodsSpecInfo;
    this.goodSinglePrice = Number(goodsSpecInfo.money);
    this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toNumber();
    this.goodNum = '1'
    this.specSheetFlag = true;
  }

  getGoodSpec(goodsId: string = '', selectSpecArr: PackageSpec[]) {
    const goodsSpecInfo = GoodsServiceApi.queryGoodsSpecInfo(goodsId, this.selectSpecArr)
    this.selectSpecInfo = goodsSpecInfo;
    this.goodSinglePrice = Number(goodsSpecInfo.money);
    this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toNumber();
  }
}