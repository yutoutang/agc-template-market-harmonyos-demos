import { BarVM, GlobalContext, PreferenceConstant, PreferenceUtil, RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PrivacyAgreementPageBuilder } from 'person';
import { IndexVM } from '../viewmodels/IndexVM';
import { HomePageBuilder } from './HomePage';
import { HomeModel } from '../viewmodels/HomeModel';

@Entry
@ComponentV2
struct Index {
  pageStack: NavPathStack = new NavPathStack()
  vm: IndexVM = new IndexVM();
  homeModel: HomeModel = HomeModel.instance;
  @Local isHomePage: boolean = true;
  @Local topPageName: string = '';
  private intervalId: number = -1;

  @Builder
  pageStackMap(name: string, _param: string) {
    phoneRouterControl.getPageBuilder(name)?.builder(_param)
  }

  // 需要显示白色状态栏的二级页面列表
  private readonly WHITE_STATUS_BAR_PAGES = [
    RouterMap.TEMPLATE_RESUME_PREVIEW_PAGE,
    RouterMap.RESUME_PAGE,
    RouterMap.RESUME_QUALIFICATION_CERTIFICATE_PAGE,
    RouterMap.RESUME_POSITION_SELECT_PAGE,
    RouterMap.RESUME_ROLE_SELECT_PAGE,
    RouterMap.RESUME_INDUSTRY_SELECT_PAGE,
    RouterMap.RESUME_WORK_DESCRIPTION_PAGE,
    RouterMap.RESUME_PROJECT_DESCRIPTION_PAGE,
    RouterMap.RESUME_VOCATIONAL_SKILL_PAGE,
    RouterMap.RESUME_SELF_EVALUATION_PAGE,
    RouterMap.SEARCH_PAGE,
    RouterMap.RESUME_CITY_SELECT_PAGE
  ]

  private getNavigationBgColor(): string | Resource {
    // 优先使用reactive变量，确保UI刷新
    const currentTopName = this.topPageName

    // 检查是否是需要白色背景的特定二级页面
    if (this.WHITE_STATUS_BAR_PAGES.includes(currentTopName)) {
      return '#FFFFFF'
    }

    // 特殊处理：个人信息页强制灰色
    if (currentTopName === RouterMap.RESUME_PERSONAL_INFO_PAGE) {
      return $r('sys.color.background_secondary')
    }

    // 主页判断：
    // 如果不在主页 (isHomePage为false 且 当前页面不是MainPage)，则显示灰色
    if (!this.isHomePage && currentTopName !== 'MainPage') {
      return $r('sys.color.background_secondary')
    }

    // 直接读取homeModel.curIndex
    const realTabIndex = this.homeModel.curIndex
    // 前两个tab（模板和简历）显示白色背景，我的tab显示灰色
    const color = (realTabIndex === 0 || realTabIndex === 1) ? '#FFFFFF' : $r('sys.color.background_secondary')
    return color
  }

  private getBottomBarColor(): string | Resource {
    // 白名单页面保持白色底栏
    if (this.WHITE_STATUS_BAR_PAGES.includes(this.topPageName)) {
      return '#FFFFFF'
    }
    // 我的简历和我的收藏页面使用白色底栏
    if (this.topPageName === RouterMap.MY_RESUME_PAGE ||
      this.topPageName === RouterMap.MY_FAVORITES_PAGE) {
      return '#FFFFFF'
    }
    // 隐私授权页面使用白色底栏
    if (this.topPageName === RouterMap.PRIVACY_AGREEMENT_PAGE) {
      return '#FFFFFF'
    }
    // 前两个Tab页（以及默认情况）改为灰色底栏
    return $r('sys.color.background_secondary')
  }

  private updateNavigationState() {
    // 更新是否在主页状态 (栈深度为1说明在主页)
    const stackSize = this.pageStack.size()
    const isHome = stackSize <= 1
    if (this.isHomePage !== isHome) {
      this.isHomePage = isHome
    }

    // 更新栈顶页面名称
    const pathNames = this.pageStack.getAllPathName()
    const topName = pathNames.length > 0 ? pathNames[pathNames.length - 1] : ''
    if (this.topPageName !== topName) {
      this.topPageName = topName
    }
  }

  private startTabIndexMonitor() {
    // 立即执行一次更新
    this.updateNavigationState()

    // 使用定时器作为兜底方案，确保状态同步
    this.intervalId = setInterval(() => {
      this.updateNavigationState()
    }, 100)
  }

  aboutToAppear() {
    phoneRouterControl.createRouter(this.pageStack)

    // 设置页面栈监听器，监听页面变化
    this.pageStack.setInterception({
      willShow: (from, to, operation, isAnimated) => {
        // 页面即将显示时，立即更新导航状态
        this.updateNavigationState()
      }
    })

    this.startTabIndexMonitor()
    this.vm.registerBreakpointListener(this.getUIContext());
    this.vm.displayOrientationListener();
    let isFirstLaunch = PreferenceUtil.getInstance(GlobalContext.getUIAbilityContext())
      .get(PreferenceConstant.FIRST_LAUNCH, true) as boolean
    if (isFirstLaunch) {
      //隐私政策
      phoneRouterControl.jumpPage({
        pageName: RouterMap.PRIVACY_AGREEMENT_PAGE,
        builder: wrapBuilder(PrivacyAgreementPageBuilder),
        onPop: (popInfo: PopInfo) => {
          phoneRouterControl.replacePage({
            pageName: RouterMap.MAIN_PAGE,
            builder: wrapBuilder(HomePageBuilder)
          })
        }
      })
      return;
    }
    phoneRouterControl.replacePage({
      pageName: RouterMap.MAIN_PAGE,
      builder: wrapBuilder(HomePageBuilder)
    })
  }

  aboutToDisappear(): void {
    this.vm.unregisterBreakpointListener();
    // 清理定时器，防止内存泄漏
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId);
      this.intervalId = -1;
    }
  }

  build() {
    Column() {
      Navigation(this.pageStack) {
      }
      .hideNavBar(true)
      .hideToolBar(true)
      .hideTitleBar(true)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
      .navDestination(this.pageStackMap)
      .id(phoneRouterControl.defaultRouteName)
      .backgroundColor(Color.Transparent)
      .layoutWeight(1)
      .padding({
        top: BarVM.instance.staBarH
      })

      // 底部安全区域
      Column()
        .width('100%')
        .height(BarVM.instance.aiBarH)
        .backgroundColor(this.getBottomBarColor())
    }
    .backgroundColor(this.getNavigationBgColor())
  }
}
