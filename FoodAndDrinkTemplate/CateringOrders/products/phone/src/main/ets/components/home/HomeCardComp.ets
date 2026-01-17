import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import {
  Constants,
  getDistanceWithLocation,
  getFmtDistWithLocation,
  GridRowColSetting,
  PermissionUtil,
  RouterMap,
  RouterModule,
  StoreInfoModel,
  TabBarType,
  UserInfoModel,
} from 'common/Index';
import * as API from '../../api/Index';

@ComponentV2
export struct HomeCardComp {
  @Consumer('currentIndex') currentIndex: number = 0
  @Param breakpoint: string = '';
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  build() {
    Row({ space: 12 }) {
      Column() {
        Column({ space: 4 }) {
          Text($r('app.string.scan'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text($r('app.string.scan_desc')).fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.font_tertiary'))
        }
        .width(Constants.FULL_SIZE)
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 12, left: 12 })
        .constraintSize({ maxWidth: Constants.FULL_SIZE })

        Image($r('app.media.bg_scan')).width(158).height(133).objectFit(ImageFit.Fill)
      }
      .cardStyle()
      .layoutWeight(1)
      .height(208)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.scanCode()
      })

      Column({ space: 12 }) {
        Column() {
          Stack() {
            Column({ space: 4 }) {
              Text($r('app.string.preorder'))
                .fontSize($r('sys.float.Subtitle_L'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
              Text($r('app.string.preorder_desc'))
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_tertiary'))
            }
            .width(Constants.FULL_SIZE)
            .height(Constants.FULL_SIZE)
            .alignItems(HorizontalAlign.Start)
            .margin({ top: 12, left: 12 })
            .constraintSize({ maxWidth: Constants.FULL_SIZE, maxHeight: Constants.FULL_SIZE })

            Image($r('app.media.bg_preorder')).width(97).height(56)
          }.alignContent(Alignment.BottomEnd).height(Constants.FULL_SIZE)
        }.cardStyle().height(98).onClick(() => {
          if (!this.userInfoModel.isRelative) {
            promptAction.showToast({ message: '请先关联账号~' })
            return
          }
          RouterModule.push(RouterMap.BOOK_PAGE)
        })

        Column() {
          Stack() {
            Column({ space: 4 }) {
              Text($r('app.string.queue'))
                .fontSize($r('sys.float.Subtitle_L'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
              Text($r('app.string.queue_desc'))
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_tertiary'))
            }
            .width(Constants.FULL_SIZE)
            .height(Constants.FULL_SIZE)
            .alignItems(HorizontalAlign.Start)
            .margin({ top: 12, left: 12 })
            .constraintSize({ maxWidth: Constants.FULL_SIZE, maxHeight: Constants.FULL_SIZE })

            Image($r('app.media.bg_queue')).width(97).height(56)
          }.alignContent(Alignment.BottomEnd).height(Constants.FULL_SIZE)
        }.cardStyle().height(98).onClick(() => {
          if (!this.userInfoModel.isRelative) {
            promptAction.showToast({ message: '请先关联账号~' })
            return
          }
          RouterModule.push(RouterMap.QUEUE_PAGE)
        })
      }.layoutWeight(1)
    }.margin({
      left: GridRowColSetting.getPageMargin(this.breakpoint),
      right: GridRowColSetting.getPageMargin(this.breakpoint),
    })
  }

  scanCode() { // 定义扫码参数options
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL], enableMultiMode: true, enableAlbum: true,
    };
    try { // 可调用getHostContext接口获取当前页面关联的Context
      scanBarcode.startScanForResult(this.getUIContext().getHostContext(), options)
        .then((result: scanBarcode.ScanResult) => { // 解析码值结果跳转应用服务页
          UtilLog.info(`Succeeded in getting ScanResult by promise with options, result is ${JSON.stringify(result)}`);
          let scanInfo: Record<string, string> = JSON.parse(result.originalValue || '{}')
          if (!scanInfo.storeId || !scanInfo.tableId) {
            promptAction.showToast({ message: '非店铺二维码~' })
            UtilLog.error(`Failed to get ScanResult result. scanInfo:${result}`);
            return
          }
          this.storeModel.storeId = scanInfo.storeId
          API.getStoreInfo(this.storeModel.storeId).then(res => {
            this.storeModel.storeInfo = res
            PermissionUtil.getLocation().then(location => {
              this.storeModel.storeInfo.distance = getDistanceWithLocation(location, res.coordinates);
              this.storeModel.storeInfo.distanceStr = getFmtDistWithLocation(location, res.coordinates);
            })
            this.currentIndex = TabBarType.ORDER
          }).catch(() => {
            promptAction.showToast({ message: '店铺不存在~' })
            UtilLog.error(`Failed to get ScanResult result. storeId:${this.storeModel.storeId}`);
          })

          let table = this.storeModel.tableList.find(item => item.id === scanInfo.tableId)
          if (table) {
            this.storeModel.tableId = scanInfo.tableId
            this.storeModel.tableInfo = this.storeModel.tableList.find(item => item.id === this.storeModel.tableId)!;
          } else {
            promptAction.showToast({ message: '店铺桌号不存在，请重新选择~' })

          }
        })
        .catch((error: BusinessError) => {
          promptAction.showToast({ message: '二维码解析失败~' })
          UtilLog.error(`Failed to get ScanResult by promise with options. Code:${error.code}, message: ${error.message}`);
        });
    } catch (error) {
      promptAction.showToast({ message: '二维码解析失败~' })
      UtilLog.error(`Failed to start the scanning service. Code:${error.code}, message: ${error.message}`);
    }
  }

  @Styles
  cardStyle(){
    .borderRadius(20).backgroundColor($r('sys.color.background_primary')).clip(true)
  }
}
