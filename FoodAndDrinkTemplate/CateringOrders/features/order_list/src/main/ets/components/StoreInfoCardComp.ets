import { CommonUrl, Constants, HwMapModel, RouterMap, RouterModule, StoreInfoModel } from 'common/Index';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { callTelSheetBuilder } from 'base_ui';

/*
 * 购买商品列表
 * */
@ComponentV2
export struct StoreInfoCard {
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local tel: string = ''
  @Local callTelSheet: boolean = false

  aboutToAppear(): void {
    this.tel = this.storeModel.storeInfo?.tel ?? ''
  }

  build() {
    Row() {
      Row() {
        Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeModel.storeInfo.logo}`).width(40).height(40)
        Column() {
          Text(`${this.storeModel.storeInfo.name}`)
            .fontSize(18)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${this.storeModel.storeInfo.address}`)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(400)
            .margin({ top: 5 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 8 })
      }.layoutWeight(1)

      Text() {
        ImageSpan($r('app.media.phone_icon')).width(24).height(24).margin({ right: 12 }).onClick(() => {
          // 拨打商家电话
          this.callTelSheet = true
        })
        ImageSpan($r('app.media.position_icon')).width(24).height(24).onClick(() => {
          let coordinates = this.storeModel.storeInfo?.coordinates?.split(',')
          if (coordinates?.length === 2) {
            let latitude: number = Number(coordinates[0])
            let longitude: number = Number(coordinates[1])
            RouterModule.push(RouterMap.HW_MAP_PAGE, { latitude, longitude } as HwMapModel)
          } else {
            promptAction.showToast({ message: $r('app.string.store_address_error') })
          }
        })
      }.margin({ left: 8 })
      .bindSheet($$this.callTelSheet, callTelSheetBuilder(this.tel, () => {
        this.callTelSheet = false
      }), {
        height: 309,
        blurStyle: BlurStyle.Thick,
        showClose: false,
      });
    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
  }
}