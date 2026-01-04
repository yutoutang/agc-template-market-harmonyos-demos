/**
 * @fileType: common
 * @zhName: 手机导航路径拦截器
 */
import { PhoneRouterManager } from './PhoneRouterManager'

/**
 * 拦截路由，例如分屏为左右两屏
 */
export class PhoneNavPathIntercept {
  router: PhoneRouterManager
  /**
   * 监听页面跳转
   */
  navigationInterception: NavigationInterception = {
    willShow: (from: NavDestinationContext | NavBar, to: NavDestinationContext | NavBar): void => {
    },
    didShow: (from: NavDestinationContext | NavBar, to: NavDestinationContext | NavBar, operation: NavigationOperation,
      isAnimated: boolean): void => {
    },
    modeChange: (mode: NavigationMode): void => {
    }
  }

  constructor(routerName: string, router: PhoneRouterManager) {
    this.router = router
  }
}