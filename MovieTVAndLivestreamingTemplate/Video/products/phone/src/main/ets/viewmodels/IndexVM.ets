import { UIContext, uiObserver, window } from '@kit.ArkUI';
import { BaseViewModel, BreakpointUtils, Logger, RouterMap, RouterUtils, SystemBarOperation } from 'lib_common';
import { LoginSheetUtils } from 'lib_account';
import { REQUIRE_LOGIN_PAGE_LIST } from '../common/Constants';

const TAG = 'IndexVM';

@ObservedV2
export class IndexVM extends BaseViewModel {
  allowedCustomTransitionFromPageNames: string[] = ['IndexPage', 'VideoDetailPage'];
  allowedCustomTransitionToPageNames: string[] = ['LandscapeVideo'];
  breakpoint: BreakpointUtils | null = null;
  @Trace isPlayPage: boolean = false

  redirect() {
    RouterUtils.pushPathByName(RouterMap.START_PAGE);
  }

  setInterception() {
    RouterUtils.getStack().setInterception({
      willShow: (from: NavDestinationContext | NavBar, to: NavDestinationContext | NavBar,
        operation: NavigationOperation, animated: boolean) => {
        if (typeof to === 'string') {
          Logger.info(TAG, 'target page is navigation home page.');
          return;
        }
        let target: NavDestinationContext = to as NavDestinationContext;

        // 拦截依赖登录的页面
        if (!this.userInfoModel.isLogin && REQUIRE_LOGIN_PAGE_LIST.includes(target?.pathInfo?.name as RouterMap)) {
          target.pathStack.pop();
          LoginSheetUtils.open();
        }
      }
    })
  }

  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }


  isCustomTransitionEnabled(fromName: string, toName: string): boolean {
    if ((this.allowedCustomTransitionFromPageNames.includes(fromName) &&
    this.allowedCustomTransitionToPageNames.includes(toName)) ||
      (this.allowedCustomTransitionFromPageNames.includes(toName) &&
      this.allowedCustomTransitionToPageNames.includes(fromName))) {
      return true;
    }
    return false;
  }

  // 自定义转场动画
  customNavContentTransitionCallback(
    from: NavContentInfo,
    to: NavContentInfo,
    operation: NavigationOperation
  ): NavigationAnimatedTransition | undefined {
    if ((!from || !to) || (!from.name || !to.name)) {
      return undefined;
    }
    // 通过from和to的name对自定义转场路由进行管控
    if (!this.isCustomTransitionEnabled(from.name, to.name)) {
      return undefined;
    }
    // 构造customAnimation给系统侧调用，执行自定义转场动画
    let customAnimation: NavigationAnimatedTransition = {
      onTransitionEnd: (isSuccess: boolean) => {
        Logger.info(TAG, 'onTransitionEnd isSuccess：' + isSuccess)
      },
      timeout: 2000,
      transition: (transitionProxy: NavigationTransitionProxy) => {
        Logger.info(TAG, 'transition transitionProxy：' + JSON.stringify(transitionProxy))
      }
    };
    return customAnimation;
  }

  // 监听NavDestination组件的状态变化
  navDestinationListener() {
    // 无感监听路由变化
    uiObserver.on('navDestinationUpdate', (info: uiObserver.NavDestinationInfo) => {
      if (info.name === 'PlayPage' && info.state === uiObserver.NavDestinationState.ON_SHOWN) {
        SystemBarOperation.setWindowSystemBarProp({
          statusBarContentColor: '#ffffff',
        })
        this.isPlayPage = true
      }
      if (info.name === 'PlayPage' && info.state === uiObserver.NavDestinationState.ON_WILL_HIDE) {
        SystemBarOperation.setWindowSystemBarProp({
          statusBarContentColor: '#000000',
        })
        this.isPlayPage = false
      }
      this.navRouteModel.navDestinationUpdateListeners.forEach((callback) => {
        callback(info)
      })
    })
  }

  // 监听WindowStage生命周期变化
  windowStageEventListener() {
    let windowStage = AppStorage.get('windowStage') as window.WindowStage;
    windowStage.on('windowStageEvent', (type: window.WindowStageEventType) => {
      this.windowStageModel.windowStageEventListeners.forEach((callback) => {
        callback(type)
      })
    });
  }
}
