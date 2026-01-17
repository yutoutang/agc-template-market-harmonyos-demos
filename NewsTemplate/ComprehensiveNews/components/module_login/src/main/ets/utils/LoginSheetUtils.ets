import { Constants, LoginChannelType } from '../common/Constant';
import { Channel, LoginFailError, LoginSheetParams, PrivacyContent } from '../model/Index';
import { PopViewUtils } from './PopViewUtils';
import { LoginController, ApiController } from './Utils';

@Builder
function loginSheetBuilder(params: LoginInfoOptions) {
  loginSheet({ params })
}

@ComponentV2
export struct loginSheet {
  @Param params: LoginInfoOptions = new LoginInfoOptions();
  @Local sheetParams: LoginSheetParams = LoginSheetViewUtils.sheetParams;
  @Local sheetStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.sheetStack.pushPathByName('HuaweiLoginPage', this.params as LoginInfoOptions,
      undefined,
      true,
    );
  }

  build() {
    Navigation(this.sheetStack) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
    .height(this.sheetParams.height)
  }
}

@ObservedV2
export class LoginInfoOptions {
  @Trace uiContext: UIContext | undefined = undefined;
  @Trace routerModule?: NavPathStack = new NavPathStack()
  @Trace icon: ResourceStr = '';
  @Trace themeColor: ResourceColor = '#0A59F7';
  @Trace isSheet: boolean = true
  @Trace autoSheet: boolean = true
  @Trace isPersistence: boolean = false
  @Trace pagePadding: Padding = {};
  @Trace loginTypes: Channel[] = [];
  @Trace privacyContent: PrivacyContent[] = []
  @Trace apiController: ApiController = new ApiController(
    () => new Promise(() => {
    }), () => new Promise(() => {
  }), () => new Promise(() => {
  }),
  )
  @Trace loginController: LoginController = new LoginController();
  handleLoginFail: (loginChannelType: LoginChannelType, error: LoginFailError) => void = () => {
  }
  obtainVerifyCode: () => Promise<void> = () => new Promise(() => {
  });
}

/**
 * 统一登录半模态弹窗
 */
export class LoginSheetViewUtils {
  static sheetParams: LoginSheetParams = new LoginSheetParams();

  static open(params: LoginInfoOptions) {
    if (!params.uiContext) {
      return;
    }
    PopViewUtils.showSheet(params.uiContext, wrapBuilder(loginSheetBuilder), {
      showClose: true,
      height: Constants.DEFAULT_LOGIN_SHEET_HEIGHT,
      detents: [Constants.DEFAULT_LOGIN_SHEET_HEIGHT, SheetSize.LARGE],
      preferType: SheetType.CENTER,
      dragBar: true,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      onHeightDidChange: (height: number) => {
        if (params.uiContext) {
          LoginSheetViewUtils.sheetParams.height = params.uiContext.px2vp(height);
        }
      },
      onTypeDidChange: (type: SheetType) => {
        LoginSheetViewUtils.sheetParams.sheetType = type;
      },
    }, params);
  }

  static close() {
    PopViewUtils.closeSheet()
  }
}