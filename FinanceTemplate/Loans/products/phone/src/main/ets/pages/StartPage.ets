import { CommonConstants, PreferenceUtils, RouterMap, RouterUtils } from 'lib_common';
import { agreePrivacyKey } from '../common/Constants';
/**
 * 非首次打开首屏页
 */
@Builder
export function StartPageBuilder() {
  StartPage()
}

@ComponentV2
struct StartPage {
  // todo: 自行调整是否支持开屏广告
  @Local isShowAd: boolean = false;

  isAgreePrivacy() {
    return PreferenceUtils.getInstance().get(agreePrivacyKey) as boolean;
  }

  aboutToAppear(): void {
    setTimeout(() => {
      if (this.isAgreePrivacy()) {
        const targetPage = this.isShowAd ? RouterMap.SPLASH_PAGE : RouterMap.INDEX_PAGE;
        RouterUtils.replacePathByName(targetPage);
      } else {
        // 未同意 跳转到同意隐私协议页面
        RouterUtils.replacePathByName(RouterMap.SAFE_PAGE);
      }
    }, 500)
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Image($r('app.media.start_icon'))
            .width(116)
            .height(116)
            .draggable(false)
            .margin({ top: 215, bottom: 258 })
          Text('贷款模板')
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.app_theme'))
            .height(32)
          Text('资金周转不求人')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(92, 121, 217, 0.8)')
            .height(21)
        }
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .backgroundImage($r('app.media.ic_start_background'))
        .backgroundImageSize({ width: '100%', height: '100%' })
      }
    }
    .hideTitleBar(true)
  }
}
