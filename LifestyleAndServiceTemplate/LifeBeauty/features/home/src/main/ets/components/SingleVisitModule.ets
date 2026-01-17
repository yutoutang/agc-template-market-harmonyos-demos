import { CommonUtils, getSingleVisitCardList, ISingleVisitCard, RouterMap, RouterModule } from 'foundation'

@ComponentV2
export struct SingleVisit {
  @Require @Param cardInfo: ISingleVisitCard;

  build() {
    Column() {
      Column({ space: 4 }) {
        Text(this.cardInfo.title).fontColor($r('app.color.single_card')).fontSize(14).fontWeight(500)
        Text() {
          Span('￥' + CommonUtils.handleCash(this.cardInfo.vipPrice)).fontSize(14)
          Span(`/${this.cardInfo.availableNum}次`).fontSize(12)
        }
        .fontColor($r('app.color.single_card'))
        .fontWeight(500)
        .textAlign(TextAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        top: 12,
        bottom: 8,
        left: 12,
        right: 12,
      })
      .borderRadius({ topLeft: 8, topRight: 8 })

      Text('单次仅￥' + CommonUtils.handleCash(this.cardInfo.vipPrice / this.cardInfo.availableNum))
        .fontSize(10)
        .fontColor($r('app.color.single_card'))
        .fontWeight(500)
        .width('100%')
        .height(20)
        .padding({ left: 12 })
        .backgroundColor(Color.White)
        .opacity(0.5)
        .borderRadius({ bottomLeft: 8, bottomRight: 8 })
    }
    .width('100%')
    .backgroundImage($r('app.media.home_single_card_bg'))
    .backgroundImageSize(ImageSize.FILL)
    .borderRadius(8)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.SINGLE_CARD_DETAIL, param: this.cardInfo });
    })

  }
}

@ComponentV2
export struct SingleVisitList {
  @Local list: ISingleVisitCard[] = [];

  aboutToAppear(): void {
    getSingleVisitCardList().then((resp) => {
      this.list = resp;
    })
  }

  build() {
    Column({ space: 10 }) {
      Text('超值次卡').fontSize(18).fontWeight(700).alignSelf(ItemAlign.Start)
      List({space: 10}) {
        ForEach(this.list, (item: ISingleVisitCard) => {
          ListItem() {
            SingleVisit({ cardInfo: item })
          }
          .width(148)
        }, (v: ISingleVisitCard) => JSON.stringify(v))
      }
      .width('100%')
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .padding({left: 12, right: 12, bottom: 12, top: 24})
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}