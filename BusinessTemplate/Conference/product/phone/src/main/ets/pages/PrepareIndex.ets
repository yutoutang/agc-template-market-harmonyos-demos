import { Home } from 'home';
import { Agenda, AgendaDetailParam } from 'agenda';
import { My } from 'my';
import { getMyTag, isSigned, MyConfig, UserInfoDetail } from 'commons';
import TagListDialog from '../view/TagListDialog';
import { JumpUtil } from '../utils/jump';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';


@Builder
export function PrepareIndexBuilder() {
  PrepareIndex()
}

@Component
struct PrepareIndex {
  @Consume('pageStack') pageStack: NavPathStack
  @StorageProp('token') token: string = '';
  @StorageLink('firstEnter') firstEnter: boolean = true;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  @State isActivePage: string = 'home';
  @State timeStr: number = 0;
  @StorageLink('mainTabIndex') currentTabIndex: number = 0;
  @Provide('agendaParams') agendaParams: number = 0;
  @StorageLink('isShowTagDialog') isShowTagDialog: string = '';
  @State tagDialogSetInterVal: number = 0
  @StorageLink('isAgree') isAgree: boolean = false;
  @StorageLink('nfcT') nfcT: string = '';
  @StorageLink('nfcP') nfcP: string = '';
  @StorageLink('agendaDetailId') agendaDetailId: string = '';
  @StorageLink('is401') @Watch('handleIs401') is401: number = 0;
  tagDialogController: CustomDialogController | null = new CustomDialogController({
    builder: TagListDialog(),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
  })
  @State selectTag: string = ''

  aboutToAppear() {
    this.silentLogin();
    this.showSignDialog();
    this.showTagDialogFun()
  }

  // Silent sign-in.
  silentLogin() {
    // Execute the sign-in request.
    try {
      // Create a sign-in request and set parameters.
      const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      /*
       * false: If the user has not signed in to the HUAWEI ID,
       * the HUAWEI ID sign-in screen will not be displayed. Instead, error code 1001502001 will be returned.
       * */
      loginRequest.forceLogin = false;
      // Used to prevent cross-site request forgery. You are advised to assign a value to state as follows:
      loginRequest.state = util.generateRandomUUID();
      // Execute the sign-in request.
      const controller = new authentication.AuthenticationController();
      controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
        const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
        const state = loginWithHuaweiIDResponse.state;
        if (state && loginRequest.state !== state) {
          // hilog.error(domainId, logTag, `Failed to login. The state is different, response state: ${state}`);
          return;
        }
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
        const code = loginWithHuaweiIDCredential.authorizationCode;
        const idToken = loginWithHuaweiIDCredential.idToken;
        const openID = loginWithHuaweiIDCredential.openID;
        const unionID = loginWithHuaweiIDCredential.unionID;
      }).catch((error: BusinessError) => {
        // dealAllError(error);
      })
    } catch (error) {
      // this.dealAllError(error);
    }
  }

  showSignDialog() {
    if (!this.isAgree) {
      this.getSign().then((res) => {
        if (!res) {
          this.pageStack.pushPath({
            name: 'PrivacyDialog',
            param: null,
            onPop: (popInfo: PopInfo) => {
              if (popInfo.result === 'success') {
              }
            }
          })
        }
      })
    }
  }

  getSign() {
    return isSigned({
      token: this.token,
    }).then(res => {
      if (res.data.isSign === 1) {
        this.isAgree = true;
      } else {
        this.isAgree = false;
      }
      return Promise.resolve(res.data.isSign === 1);
    }).catch(() => {
      return Promise.resolve(false);
    });
  }

  handleIs401(){
    if (this.is401) {
      this.currentTabIndex=0
      this.pageStack.popToName('PrepareIndex', true)
      this.is401 = 0
    }
  }

  getContactTag() {
    if (this.token) {
      return getMyTag({
        token: this.token,
      }).then((res) => {
        this.selectTag = res.data
      })
    }
    return Promise.resolve()
  }

  isHasSigned() {
    if (this.token) {
      return isSigned({
        token: this.token,
      }).then(res => {
        let isSign = res.data.isSign
        if (isSign === 1) {
          this.isAgree = true
        }
      })
    }
    return Promise.resolve()
  }

  async showTagDialogFun() {
    if (this.isShowTagDialog === '') {
      await this.getContactTag()
      await this.isHasSigned()
    }
    if (this.token && this.isAgree && this.selectTag === '') {
      if (this.isShowTagDialog === '') {
        this.tagDialogSetInterVal && clearInterval(this.tagDialogSetInterVal)
        this.tagDialogSetInterVal = setTimeout(() => {
          if (this.tagDialogController !== null) {
            this.isShowTagDialog = 'showEd'
            this.tagDialogController.open()
          }
        }, 2500)
      } else {
        this.tagDialogSetInterVal && clearInterval(this.tagDialogSetInterVal)
      }
    }
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: BarPosition.End,
        index: $$this.currentTabIndex,
      }) {
        TabContent() {
          Home()
        }

        .tabBar(this.tabBuilder('首页', 0, MyConfig.URL +
          'upload%2FhomeActive.svg?token=5a5947b8-7b6b-4318-a2a1-91adf2646384',
          MyConfig.URL + 'upload%2Fhome.svg?token=401eda6e-7087-462d-85fc-762c858abd67'))

        TabContent() {
          Agenda()
        }

        .tabBar(this.tabBuilder('议程', 1, MyConfig.URL +
          'upload%2FagendaActive.svg?token=0414e7a4-30f8-4ed3-b29d-ffd01eb6b49e',
          MyConfig.URL + 'upload%2Fagenda.svg?token=8742759a-91f8-4399-aead-9e55cf4ac610'))

        TabContent() {
          My()
        }

        .tabBar(this.tabBuilder('我的', 2, MyConfig.URL +
          'upload%2FmyActive.svg?token=c840c91f-e48f-4bf8-9eb9-64195450bef4',
        MyConfig.URL + 'upload%2Fmy.svg?token=cf76eb38-9643-4f45-ae9b-18faca70b340'))
      }
      .scrollable(false)
      .animationDuration(0)
      .onChange((index: number) => {
        getContext().eventHub.emit('switchTab', index);
        if (index === 3 && this.firstEnter && !this.token) {
          this.firstEnter = false
          this.pageStack.pushPath({
            name: 'Login',
          })
        }
        if (index === 0 || index === 1) {
          this.showTagDialogFun()
        }else{
          this.tagDialogSetInterVal && clearInterval(this.tagDialogSetInterVal)
        }
      })
      .barOverlap(false)
      .padding({ bottom: px2vp(this.bottomRectHeight) })
    }
    .hideTitleBar(true)
    .onShown(() => {
      getContext().eventHub.emit('onShown', this.currentTabIndex);
    })
    .onReady((ctx: NavDestinationContext) => {
      try {
        const myParams = ctx?.pathInfo?.param as Record<string, string>;
        if (myParams) {
          if (myParams.from) {
            if (myParams.from === 'isToAgendaDetail') {
              this.pageStack.pushPath({
                name: 'AgendaDetail',
                param: new AgendaDetailParam(this.agendaDetailId)
              })
              return
            }
            let ju = new JumpUtil(this.token, this.userInfo, this.pageStack)
            ju.handleJump(myParams.from)
          }
        }
      } catch (e) {
        console.log('e', JSON.stringify(e))
      }
    })
  }

  @Builder
  tabBuilder(title: string, targetIndex: number, selectImg: ResourceStr, normalImg: ResourceStr) {
    Column() {
      Image(this.currentTabIndex === targetIndex ? selectImg : normalImg)
        .width(30)
        .height(30)
        .objectFit(ImageFit.Contain)
      Text(title)
        .fontColor(this.currentTabIndex === targetIndex ? '#2A2F46' : '#802a2f46')
        .fontSize(12)
        .lineHeight(18)
        .fontWeight(this.currentTabIndex === targetIndex ? 700 : 400)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}