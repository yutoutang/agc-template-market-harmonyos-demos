import { AccountUtil, WindowUtil, Logger } from 'commonlib';
import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct EmptyPage {
  aboutToAppear(): void {
    WindowUtil.initWindowUtil();
    AccountUtil.silentLogin().then(() => {
      if (AccountUtil.getAccountInfo().openID) {
        Logger.info('登录成功！');
      } else {
        Logger.info('请先登录华为账号~');
      }
    }).catch(() => {
      Logger.info('华为账号登录失败，请检查工程签名配置~');
    });
    //  为优化体验不做隐匿登录失败拦截
    router.replaceUrl({
      url: 'pages/MainEntry',
    });

  }

  build() {
    RelativeContainer() {

    }
    .height('100%')
    .width('100%');
  }
}