import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  BreakpointModel,
  BreakpointNameEnum,
  CommonUtils,
  getGroupList,
  GetUserInfoResp,
  IGroupInfo,
  LoginButtonType4,
  OrderType,
  RouterMap,
  RouterModule,
  SimpleGoodInfo,
} from 'foundation'

@ComponentV2
export struct GroupBuy {
  @Require @Param groupInfo: IGroupInfo;
  @Local userInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;

  buildRouteParam() {
    const param = new SimpleGoodInfo();
    param.type = OrderType.GROUP;
    param.id = this.groupInfo.id;
    param.title = this.groupInfo.title;
    param.subTitle = this.groupInfo.subTitle;
    param.vipPrice = this.groupInfo.vipPrice;
    param.image = this.groupInfo.images[0] ?? '';
    param.price = this.groupInfo.price;
    return param;
  }

  jumpOrder() {
    const param = this.buildRouteParam();
    RouterModule.push({ url: RouterMap.SUBMIT_ORDER, param: param });
  }

  build() {
    Row({ space: 12 }) {
      Image(CommonUtils.handleImgUrl(this.groupInfo.images[0])).width(86).aspectRatio(1).borderRadius(8)
      Column() {
        Text(this.groupInfo.title)
          .fontSize(14)
          .fontWeight(500)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          Text(this.groupInfo.subTitle ?? '款式任选·含卸甲').fontSize(12).fontColor($r('sys.color.font_secondary'))
          Blank()
          Text(`年售${this.groupInfo.soldNum}+`).fontSize(12).fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .margin({ top: 6 })

        Blank()
        Row() {
          Text('￥' + CommonUtils.handleCash(this.groupInfo.vipPrice))
            .fontSize(14)
            .fontColor($r('sys.color.warning'))
            .fontWeight(500)
          Text('￥' + CommonUtils.handleCash(this.groupInfo.price))
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .decoration({ type: TextDecorationType.LineThrough })
            .margin({ left: 4 })
          Blank()
          if (this.userInfo.mobile) {
            Button() {
              Text('购买')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(500)
                .width(56)
                .height(20)
                .fontColor($r('sys.color.font_on_primary'))
                .textAlign(TextAlign.Center)
            }
            .padding({
              top: 4,
              bottom: 4,
              left: 8,
              right: 8,
            })
            .backgroundColor($r('app.color.common_theme_color'))
            .onClick(() => {
              this.jumpOrder();
            })
          } else {
            LoginButtonType4({
              onBind: () => {
                this.jumpOrder();
              },
            })
              .onClick(() => {
              })
          }

        }
        .width('100%')
      }
      .height(86)
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.GROUP_DETAIL, param: this.groupInfo });
    })
  }
}

@ComponentV2
export struct GroupBuyList {
  @Local list: IGroupInfo[] = [];
  @Local allList: IGroupInfo[] = [];
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local isExpend: boolean = false;

  aboutToAppear(): void {
    getGroupList().then((resp) => {
      this.allList = resp;
      this.list = this.allList.slice(0, 2);
    })
  }

  @Computed
  get listLanes() {
    if (this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM) {
      return 1;
    }
    return 2;
  }

  build() {
    Column({ space: 10 }) {
      Text('团购').fontSize(18).fontWeight(500).alignSelf(ItemAlign.Start)
      List({ space: 24 }) {
        ForEach(this.list, (item: IGroupInfo) => {
          ListItem() {
            GroupBuy({ groupInfo: item })
          }
        }, (item: IGroupInfo) => JSON.stringify(item))
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .lanes(this.listLanes, 24)
      .divider({strokeWidth: 1, color: $r('sys.color.comp_divider'), startMargin: 98})

      if (this.allList.length > 2) {
        this.moreBtnBuilder()
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 24, bottom: 12})
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  @Builder
  moreBtnBuilder() {
    Button({type: ButtonType.Capsule, stateEffect: true}) {
      Row({space: 4}) {
        Text(this.isExpend ? '收起' : '更多')
          .fontSize(14)
          .fontWeight(500)
          .fontColor($r('sys.color.font_secondary'))
        SymbolGlyph($r('sys.symbol.chevron_down'))
          .fontSize(16)
          .fontColor([$r('sys.color.icon_secondary')])
          .rotate({ z: 1, angle: this.isExpend ? 180 : 0 })
          .animation({
            duration: 200,
            curve: Curve.EaseOut,
          })
      }
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .padding({left: 8, right: 8, top: 4, bottom: 4})
    .onClick(() => {
      this.isExpend = !this.isExpend
      this.list = this.isExpend ? this.allList : this.allList.slice(0, 2);
    })
  }
}