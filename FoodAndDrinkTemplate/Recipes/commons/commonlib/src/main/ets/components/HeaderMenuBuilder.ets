import { RouterMap } from '../constants/CommonEnums'
import { AccountUtil } from '../utils/AccountUtil'
import { RouterModule } from '../utils/RouterModule'
import { promptAction } from '@kit.ArkUI'
import { GlobalContextUtils } from '../utils/ContextUtils'

@Builder
export function HeaderMenuBuilder() {
  Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
    Column() {
      Row() {
        Text('菜篮子').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
      }
      .height(48)
      .width('100%')
      .constraintSize({ maxWidth: '100%' })
    }
    .onClick(() => {
      if (AccountUtil.getUserInfo().isLogin) {
        RouterModule.push(RouterMap.SHOPPING_BASKET_PAGE);
      } else {
        GlobalContextUtils.showToast({ message: '未登录，请登录后重试！' });
        RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
      }
    })
  }.width(100).padding({ left: 16, right: 16 })
}