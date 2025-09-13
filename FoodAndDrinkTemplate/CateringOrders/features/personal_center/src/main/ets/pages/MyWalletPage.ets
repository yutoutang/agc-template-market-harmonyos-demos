import {
  NavHeaderBar,
  RechargeTier,
  RouterMap,
  RouterModule,
  StoreInfoModel,
  UserInfoModel,
  WindowModel,
} from 'common/Index';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import * as API from '../api/Index';
import { paySheetBuilder } from 'base_ui';
import { common } from '@kit.AbilityKit';
import { MyWallet } from 'my_wallet';

@Builder
export function MyWalletPageBuilder() {
  MyWalletPage()
}

@ComponentV2
struct MyWalletPage {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!
  @Local userInfoModel: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!
  @Local selectTier: RechargeTier = new RechargeTier()
  @Local showPaySheet: boolean = false
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  @Computed
  get rechargeTierList() {
    return this.storeModel.storeInfo.rechargeTier.filter(item => item.type === 1)
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: '我的钱包' })
      MyWallet({
        wallet: this.userInfoModel.userInfo.wallet,
        rechargeTierList: this.rechargeTierList,
        selectTier: this.selectTier,
        goRechargeCb: (): void => RouterModule.push(RouterMap.RECHARGE_RECORD_PAGE),
        changeSelectCb: (selectTier: RechargeTier) => {
          this.selectTier = selectTier
        },
        goWalletTermsCb: () => {
          RouterModule.push(RouterMap.WALLET_TERMS_PAGE)
        },
        goPayCb: () => {
          this.showPaySheet = true
        },
      })
        .layoutWeight(1)
        .backgroundColor($r('sys.color.background_secondary'))
        .padding({
          top: 12,
          bottom: 16 + this.windowModel.getWindowBottomHeight(),
          left: 16,
          right: 16,
        })
        .bindSheet(this.showPaySheet, paySheetBuilder(this.selectTier.payMoney, (flag: boolean) => {
          if (flag) {
            this.payRechargeMoney()
          }
          this.showPaySheet = false
        }), {
          height: 397,
          blurStyle: BlurStyle.Thick,
          showClose: false,
        })

    }.hideTitleBar(true)
  }

  payRechargeMoney() {
    // 拉华为支付
    API.purchase(this.context).then(() => {
      API.rechargeMoney(this.selectTier.id).then((res) => {
        promptAction.showToast({ message: '充值成功' })
        RouterModule.pop(res)
      })
    }).catch(() => {
      promptAction.showToast({ message: '充值失败~' })
    })
  }
}
