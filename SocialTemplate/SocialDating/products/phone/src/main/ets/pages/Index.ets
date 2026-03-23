import { TabItem, tabItems } from '../model/TabItem';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BasicUserInfo, GetUserResponse, UserInfo, Constants,MockService } from 'commons';
import { Home, Personal } from 'composite';
import { FeedListPage } from 'feed';
import UserService from 'user/src/main/ets/service/UserService';
import Logger from 'commons/src/main/ets/utils/Logger';
import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  @Local currentPageIndex: number = 0;
  @Local currentUser: BasicUserInfo | null = null;
  @Local vm: IndexVM = new IndexVM();
  @Provider('pageStack') pageStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack) {
      if (this.currentUser != null) {
        this.buildPageTitle()
        Column() {
          Tabs({ barPosition: BarPosition.End, index: this.currentPageIndex }) {
            TabContent() {
              Home({ index: this.currentPageIndex })
            }.tabBar(this.buildTabBar(tabItems[Constants.PAGE_INDEX_HOME], Constants.PAGE_INDEX_HOME))

            TabContent() {
              FeedListPage({ index: this.currentPageIndex })
            }.tabBar(this.buildTabBar(tabItems[Constants.PAGE_INDEX_FEED], Constants.PAGE_INDEX_FEED))

            TabContent() {
              Personal({ index: this.currentPageIndex })
            }.tabBar(this.buildTabBar(tabItems[Constants.PAGE_INDEX_PERSONAL], Constants.PAGE_INDEX_PERSONAL))
          }
          .backgroundColor(Color.White)
          .barHeight('auto')
          .barWidth('100%')
          .scrollable(false)
          .vertical(false)
          .onChange((index) => {
            this.currentPageIndex = index
          })
        }
        .height('95%')
        .padding({ bottom: 10 })
        .backgroundColor(Color.White)
      }
    }
    .backgroundColor($r('app.color.page_background_color'))
    .hideTitleBar(true)
    .hideToolBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildPageTitle() {
    Row() {
      if (this.currentPageIndex === Constants.PAGE_INDEX_HOME) {
        this.buildPageTitleText(tabItems[Constants.PAGE_INDEX_HOME].title)
      } else if (this.currentPageIndex === Constants.PAGE_INDEX_FEED) {
        this.buildPageTitleText(tabItems[Constants.PAGE_INDEX_FEED].title)
      } else {
        this.buildPageTitleText(tabItems[Constants.PAGE_INDEX_PERSONAL].title)
      }
    }
    .width('92%')
    .height(56)
    .justifyContent(FlexAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildPageTitleText(pageTitle: string) {
    Text(pageTitle)
      .fontColor($r('app.color.text_font_color_black'))
      .fontSize(24)
      .fontWeight(FontWeight.Medium)
      .fontFamily(Constants.HARMONY_HEITI)
      .height(56)
  }

  @Builder
  buildTabBar(button: TabItem, tabIndex: number) {
    Column() {
      Image(this.currentPageIndex === tabIndex ? button.selectedImage : button.img)
        .objectFit(ImageFit.Contain)
        .width(24)
        .height(24)
        .margin({ top: 6 })
      Text(button.title)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(this.currentPageIndex === tabIndex ? button.selectedTitleColor :
        $r('app.color.text_font_color_gray'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(50)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      this.currentPageIndex = tabIndex;
    })
  }

  aboutToAppear(): void {
    MockService.init(this.getUIContext());
    this.vm.contextModel.setUIContext('phone', this.getUIContext());
    this.silentLogin();
  }

  private silentLogin() {
    let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    loginRequest.forceLogin = false;
    let controller = new authentication.AuthenticationController();
    controller.executeRequest(loginRequest).then((data) => {
      let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
      let authCode = loginWithHuaweiIDResponse.data?.authorizationCode;
      let unionId = loginWithHuaweiIDResponse.data?.unionID;
      Logger.info('silent login success, unionId=' + unionId);
      AppStorage.setOrCreate(Constants.UNION_ID, unionId);
      this.getUserInfo(unionId);
    }).catch((error: BusinessError) => {
      Logger.error(0x0000, 'testTag', 'silentLogin failed, error: %{public}s', JSON.stringify(error));
      // 为了不阻塞模板体验，不做失败拦截
      this.getUserInfo('');
    })
  }

  getUserInfo(unionId: string | undefined) {
    Logger.debug('getUserInfo, unionId=' + unionId);
    UserService.getUserFullInfoByUnionId(unionId).then((data: GetUserResponse | null) => {
      AppStorage.setOrCreate(Constants.FIRST_LOGIN_FLAG, false);
      if (data === null || data.userFullInfo == null || data.userFullInfo.userInfo == null) {
        this.pageStack.pushPathByName('UserRegister', null, (popInfo: PopInfo) => {
          this.currentUser = popInfo.result as BasicUserInfo;
        });
      } else {
        this.currentUser = UserInfo.toBasicUserInfo(data.userFullInfo.userInfo);
        AppStorage.setOrCreate(Constants.CURRENT_USER_BASIC, this.currentUser);
        Logger.debug('-----currentUser set to  appStorage=' + JSON.stringify(this.currentUser))
      }
    })
  }
}
