import { StoreInfo } from '../models/Index'

@ComponentV2
export struct SelectStoreComp {
  @Param @Require storeInfo: StoreInfo
  @Param isSelect: boolean = false
  STORE_MAKING_PROCESS_MAX = 15
  @Event navigateStoreCb: (coordinates: string, address: string) => void = () => {
  }
  @Event callTelCb: (callTelSheet: boolean, tel: string) => void = () => {
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text(this.storeInfo.name)
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: 180 })
          if (this.storeInfo.canTakeaways) {
            Text($r('app.string.can_takeaways'))
              .fontSize(10)
              .fontColor($r('sys.color.font_on_primary'))
              .height(20)
              .padding({ left: 9, right: 9 })
              .backgroundColor('#86AD2B')
              .borderRadius(10)
              .margin({ left: 4 })
          }
        }.layoutWeight(1)

        Row() {
          Image($r('app.media.ic_public_position')).width(12)
          Text(this.storeInfo.distanceStr).fontSize(10).fontColor($r('sys.color.font_secondary')).margin({ left: 8 })
        }.margin({ left: 8 })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Row() {
        if (this.storeInfo.makingNum) {
          Progress({
            value: this.storeInfo.makingNum,
            total: this.STORE_MAKING_PROCESS_MAX,
            type: ProgressType.Linear,
          })
            .width(72)
            .height(24)
            .color('#486602')
            .borderRadius(6)
            .padding({top:10,bottom:10})
            .margin({ left: 4, right: 4 })
          Row() {
            Text($r('app.string.wait_num_pre')).fontColor($r('sys.color.black')).fontSize(8)
            Text(this.storeInfo.makingNum.toString()).fontColor('#86AD2B').fontSize(8).margin({ left: 4, right: 4 })
            Text($r('app.string.wait_num_post')).fontColor($r('sys.color.black')).fontSize(8)
          }.height(20)
        } else {
          Text($r('app.string.make_now')).fontSize(8).fontColor('#86AD2B')
        }
      }.width('100%').margin({ top: 6 }).height(20)

      Row() {
        Text(this.storeInfo.address).fontSize(10).fontColor($r('sys.color.font_secondary')).maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.margin({ top: 6 }).constraintSize({ maxWidth: 200 })

      Row() {
        Row() {
          Image($r('app.media.ic_clock_grey')).width(12)
          Text($r('app.string.store_open_time'))
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: 8 })
          Text(`${this.storeInfo.time1} - ${this.storeInfo.time2}`)
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
        }

        Row() {
          Image($r('app.media.ic_navigation')).width(24).onClick(() => {
            this.navigateStoreCb(this.storeInfo.coordinates, this.storeInfo.address)
          })
          Image($r('app.media.ic_telephone')).width(24).margin({ left: 24 }).onClick(() => {
            this.callTelCb(true, this.storeInfo.tel)
          })
        }
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 4 })

    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(12)
    .border(this.isSelect ? { width: 1, color: '#86AD2B' } : { width: 0 })
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8,
    })
  }
}