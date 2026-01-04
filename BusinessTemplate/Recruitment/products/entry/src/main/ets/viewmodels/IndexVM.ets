import { display } from '@kit.ArkUI';
import {
  BaseViewModel, BreakpointUtils, KickedDialog, KickedDialogModel, RouterMap,
} from 'common';
import { common } from '@kit.AbilityKit';
import { CMChatFactory } from 'instant_messaging';
import { BusinessError } from '@kit.BasicServicesKit';
import { phoneRouterControl } from 'oh_router';
import { LoginPageBuilder } from 'aggregated_login';

@ObservedV2
export class IndexVM extends BaseViewModel {
  breakpoint: BreakpointUtils | null = null;

  constructor() {
    super();
    this.addSdkListener();
  }

  // 监听设备屏幕方向改变
  displayOrientationListener() {
    try {
      this.displayModel.isFoldable = display.isFoldable();
      display.on('change', (type: number) => {
        let displayClass = display.getDisplayByIdSync(type);
        // 横屏
        let landscapeType = [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED]
        this.displayModel.isLandscape = landscapeType.includes(displayClass.orientation);
      })
    } catch (err) {
    }
  }

  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }

  async initSdk(context: common.Context | undefined) {
    let applicationContext = context as common.ApplicationContext;
    let initResult = CMChatFactory.instance.initSDK(applicationContext, 1600116626);
    if (initResult && CMChatFactory.instance.getLoginStatus() === 3) {
      if (this.userInfo.isLogin) {
        await CMChatFactory.instance.login(this.userInfo.id, this.userInfo.userSig ?? '')
          .then(() => {
          }).catch((err: BusinessError) => {
            this.kickedDialog();
          })
      }
    }
  }

  addSdkListener() {
    CMChatFactory.instance.addSDKListener({
      onKickedOffline: () => {
        this.kickedDialog();
      }
    });
  }

  private kickedDialog() {
    let dialogVM = new KickedDialogModel();
    dialogVM.title = `你的账号在其他设备登录，其重新登录`;
    dialogVM.onValueConfirmClick = async (_model: Object) => {
      this.userInfo.isLogin = false;
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder),
        onPop: (_popInfo: PopInfo) => {
          let mainBuilder = phoneRouterControl.getPageBuilder(RouterMap.MAIN_PAGE);
          phoneRouterControl.replacePage({
            pageName: RouterMap.MAIN_PAGE,
            builder: mainBuilder
          });
        }
      })
    };
    dialogVM.onValueConcelClick = async (_model: Object) => {
      this.userInfo.isLogin = false;
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder),
        onPop: (_popInfo: PopInfo) => {
          let mainBuilder = phoneRouterControl.getPageBuilder(RouterMap.MAIN_PAGE);
          phoneRouterControl.replacePage({
            pageName: RouterMap.MAIN_PAGE,
            builder: mainBuilder
          });
        }
      })
    }
    KickedDialog.ShowPopup(dialogVM);
  }
}

