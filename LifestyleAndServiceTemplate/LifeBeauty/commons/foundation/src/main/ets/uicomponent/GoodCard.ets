import { PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { CommonUtils } from '../utils/CommonUtils';
import { GetUserInfoResp, GoodInfo, SimpleGoodInfo } from '../model/Model';
import { RouterModule } from '../router/RouterModule';
import { LoginButtonType2 } from '../login/Login';
import { RouterMap } from '../constants/RouterMap';
import { OrderType } from '../constants/AppConstant';

@ComponentV2
export struct GoodCard {
  @Param goodInfo: GoodInfo = new GoodInfo();
  @Local bgH: number | undefined = 0;
  @Local userInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;

  @Computed
  get isBindPhone() {
    return Boolean(this.userInfo.mobile);
  }

  buildRouteParam() {
    const param = new SimpleGoodInfo();
    param.type = OrderType.GROUP;
    param.id = this.goodInfo.id;
    param.title = this.goodInfo.title;
    param.subTitle = this.goodInfo.subTitle;
    param.vipPrice = this.goodInfo.vipPrice;
    param.image = this.goodInfo.images[0] ?? '';
    param.price = this.goodInfo.price;
    return param;
  }

  jumpOrder() {
    const param = this.buildRouteParam();
    RouterModule.push({ url: RouterMap.SUBMIT_ORDER, param: param });
  }

  build() {
    Column() {
      Image(CommonUtils.handleImgUrl(this.goodInfo.images[0])).width(CommonConstants.FULL_PERCENT)

      Column({ space: 10 }) {
        Row() {
          Text(this.goodInfo.title)
            .fontSize(14)
            .width(CommonConstants.FULL_PERCENT)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
            .alignSelf(ItemAlign.Baseline)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(38)
        .alignItems(VerticalAlign.Top)

        Row({ space: 2 }) {
          Text('￥' + CommonUtils.handleCash(this.goodInfo.vipPrice))
            .fontSize(14)
            .fontWeight(500)
            .fontColor($r('sys.color.warning'))
          Text('￥' + CommonUtils.handleCash(this.goodInfo.price))
            .fontSize(10)
            .fontWeight(400)
            .fontColor($r('sys.color.font_tertiary'))
            .decoration({
              type: TextDecorationType.LineThrough,
              color: $r('sys.color.font_tertiary')
            })
          Blank()
          if (this.isBindPhone) {
            Button() {
              Text($r('app.string.good_card_purchase_btn'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(500)
                .fontColor($r('sys.color.font_on_primary'))
                .width(56)
                .height(20)
                .textAlign(TextAlign.Center)
            }
            .backgroundColor($r('app.color.common_theme_color'))
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            })
            .onClick(() => {
              this.jumpOrder();
            })
          } else {
            LoginButtonType2({
              onBind: () => {
                this.jumpOrder();
              },
            }).onClick(() => {
            })
          }
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .padding(8)
    }
    .clip(true)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(8)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: this.goodInfo });
    })
  }
}
