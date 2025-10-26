import {
  CommonUrl,
  Constants,
  Goods,
  GoodsSpec,
  GoodsSpecInfo,
  GoodsSpecVal,
  HttpRequest,
  MyCarModel,
  PackageSpec,
  WindowModel,
} from 'common';
import { Decimal } from '@kit.ArkTS';
import { AppStorageV2, promptAction } from '@kit.ArkUI';

@Builder
export function SpecSheetBuilder(item: Goods, close: (selectSpec?: GoodsSpecInfo) => void, sheetHeight: number = 500,
  isPkg: boolean = false, specInfoOri?: GoodsSpecInfo) {
  SpecSheet({
    goods: item,
    sheetHeight,
    isPkg,
    specInfoOri,
    close: (selectSpec?: GoodsSpecInfo) => {
      close(selectSpec)
    },
  })
}

@ComponentV2
struct SpecSheet {
  @Local myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Param @Require goods: Goods;
  @Param sheetHeight: number = 500;
  @Param isPkg: boolean = false;
  @Param specInfoOri?: GoodsSpecInfo = undefined;
  @Local goodsSpecList: Array<GoodsSpec> = [];
  @Local selectSpecInfo?: GoodsSpecInfo = undefined;
  @Local goodsSinglePrice: number = 0;
  @Local sumPrice: string = '0';
  @Local goodsNum: number = 1;
  @Local selectSpecArr: Array<PackageSpec> = [];
  @Event close: (selectSpecArr?: GoodsSpecInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.sumPrice = this.goods?.money ?? '0';
    HttpRequest.getGoodsInfo(this.goods.id).then((resp: Goods) => {
      this.goodsSpecList = resp.spec ?? [];
      this.selectSpecArr = this.goodsSpecList.map((item: GoodsSpec) => {
        let specValId = item.specValId
        if (this.specInfoOri) {
          specValId =
            this.specInfoOri.combination?.find((pkgSpec: PackageSpec) => item.specId === pkgSpec.specId)?.specValId ??
            item.specValId
        }
        let goodsSpec = item.specVal.find((spec: GoodsSpecVal) => specValId === spec.specValId);
        let result: PackageSpec = {
          specId: item.specId,
          specValId: goodsSpec?.specValId ?? item.specVal[0].specValId,
          specName: goodsSpec?.specValName ?? item.specVal[0].specValName,
          specNum: Number(goodsSpec?.specValNum ?? 0),
        };
        return result;
      });
      this.getGoodsSpecInfo()
    });
  }

  getGoodsSpecInfo() {
    HttpRequest.getGoodsSpec(this.goods.id, this.selectSpecArr).then((resp) => {
      this.selectSpecInfo = resp;
      this.goodsSinglePrice = Number(resp.money);
      this.sumPrice = new Decimal(this.goodsSinglePrice).mul(this.goodsNum).toString();
    });
  }

  build() {
    Stack() {
      Column() {
        Column() {
          Row() {
            Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.goods.logo}`).width(80).height(80).borderRadius(8);
            Column() {
              Column() {
                Text(this.goods.name)
                  .fontSize($r('sys.float.Subtitle_L'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .lineHeight(20);
                Text() {
                  Span($r('app.string.selected'));
                  Span(this.selectSpecArr.map(spec => spec.specName).join(' | '));
                }
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
                .margin({ top: 2 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              }.alignItems(HorizontalAlign.Start)

              Text() {
                Span($r('app.string.currency_symbol'))
                  .fontSize($r('sys.float.Caption_M'))
                  .fontColor('#61860B')
                Span(`${Number(this.sumPrice)}`)
                  .fontSize($r('sys.float.Subtitle_L'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#61860B')
              }
            }.alignItems(HorizontalAlign.Start).margin({ left: 8 }).justifyContent(FlexAlign.SpaceBetween).height(80)
          }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Start)

          List() {
            ForEach(this.goodsSpecList, (goodsSpec: GoodsSpec, index: number) => {
              ListItem() {
                Row() {
                  Text(goodsSpec.specName)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .width(60)
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(goodsSpec.specVal, (goodSpecInfo: GoodsSpecVal) => {
                      Row() {
                        Text(goodSpecInfo.specValName)
                          .fontSize($r('sys.float.Caption_L'))
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.selectSpecArr[index].specName === goodSpecInfo.specValName ?
                          $r('sys.color.font_on_primary') :
                          $r('sys.color.font_primary'))
                      }
                      .padding({
                        left: 12,
                        right: 12,
                        top: 4,
                        bottom: 4,
                      })
                      .margin({ right: 8, bottom: 8 })
                      .backgroundColor(this.selectSpecArr[index].specName === goodSpecInfo.specValName ?
                        '#61860B' : $r('sys.color.comp_background_tertiary'))
                      .borderRadius(12)
                      .onClick(() => {
                        let pkgSpec: PackageSpec = {
                          specId: goodsSpec.specId,
                          specLogo: this.goods.logo,
                          specValId: goodSpecInfo.specValId,
                          specName: goodSpecInfo.specValName,
                          specNum: Number(goodSpecInfo.specValNum),
                        };
                        this.selectSpecArr[index] = pkgSpec;
                        this.getGoodsSpecInfo()
                      });
                    }, (goodSpecInfo: GoodsSpecVal) => goodSpecInfo.specValId);
                  }.margin({ left: 12 })
                }
              }
            }, (goodsSpec: GoodsSpec) => goodsSpec.specId);
          }
          .align(Alignment.Center)
          .contentStartOffset(12)
          .contentEndOffset(12)
          .height(this.isPkg ? 110 : 156)
          .margin({ top: 28 })
          .scrollBar(BarState.Off);
        }.height(276)

        if (!this.isPkg) {
          Column() {
            Row() {
              Text($r('app.string.good_number'))
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))

              Row() {
                Image($r('app.media.ic_subtract')).width(24).onClick(() => {
                  if (this.goodsNum > 1) {
                    this.goodsNum = this.goodsNum - 1
                    this.sumPrice = new Decimal(this.goodsSinglePrice).mul(this.goodsNum).toString();
                  }
                });
                Text(this.goodsNum.toString())
                  .fontSize($r('sys.float.Body_L'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 12, right: 12 })
                Image($r('app.media.ic_add_car')).width(24).onClick(() => {
                  this.goodsNum = this.goodsNum + 1
                  this.sumPrice = new Decimal(this.goodsSinglePrice).mul(this.goodsNum).toString();
                });
              }
            }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

            Button($r('app.string.add_car'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
              .width(Constants.FULL_SIZE)
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .backgroundColor('#486602')
              .onClick(() => {
                if (!this.selectSpecInfo) {
                  console.info(`add car empty.`);
                  return;
                }
                HttpRequest.addCarSpec(this.selectSpecInfo, this.goods.id, this.goodsNum).then((res: string) => {
                  promptAction.showToast({ message: $r('app.string.add_success') });
                  this.goodsNum = 1;
                  if (!this.myCarModel.carCheck.includes(res)) {
                    this.myCarModel.carCheck.push(res)
                  }
                  this.close()
                });
              })
              .margin({ top: 35 })
          }
        }
      }
      .width(Constants.FULL_SIZE)
      .borderRadius(12)
      .backgroundColor($r('sys.color.background_primary'))
      .padding({
        top: 32,
        left: 12,
        right: 12,
        bottom: 30,
      })
      .margin({ bottom: this.windowModel.getWindowBottomHeight() })

      Column() {
        Row() {
          Text() {
            Span($r('app.string.selected'));
            Span(this.selectSpecArr.map(spec => spec.specName).join(' | '));
          }
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .padding({ top: 8, bottom: 12 })
        .margin({ left: 10 })
        .width(Constants.FULL_SIZE)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })

        Row({ space: 16 }) {
          Button($r('app.string.revert_select'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor('#486602')
            .backgroundColor($r('sys.color.background_primary'))
            .width(148)
            .height(40)
            .border({ width: 1, color: $r('app.color.fontMainColor') })
            .onClick(() => {
              this.selectSpecArr = this.goodsSpecList.map((item: GoodsSpec) => {
                let goodsSpec = item.specVal.find((spec: GoodsSpecVal) => item.specValId === spec.specValId);
                let result: PackageSpec = {
                  specId: item?.specId ?? this.goodsSpecList[0].specId,
                  specValId: goodsSpec?.specValId ?? item.specVal[0].specValId,
                  specName: goodsSpec?.name ?? item.specVal[0].specValName,
                  specNum: Number(goodsSpec?.specValNum ?? 0),
                };
                return result;
              })
              this.getGoodsSpecInfo()
            })
          Button($r('app.string.confirm_select'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .width(148)
            .height(40)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('#486602')
            .onClick(() => {
              if (!this.selectSpecInfo) {
                console.error(`select spec empty.`);
                return;
              }
              this.close(this.selectSpecInfo)
            })
        }.justifyContent(FlexAlign.Center).padding(8)
      }
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_primary'))
      .shadow({
        radius: 30,
        color: '#33000000',
        offsetX: 0,
        offsetY: 10,
      })
      .visibility(this.isPkg ? Visibility.Visible : Visibility.None)
      .padding({ bottom: this.windowModel.getWindowBottomHeight() })
    }.width(Constants.FULL_SIZE)
    .alignContent(this.isPkg ? Alignment.Bottom : Alignment.Top)
  }
}