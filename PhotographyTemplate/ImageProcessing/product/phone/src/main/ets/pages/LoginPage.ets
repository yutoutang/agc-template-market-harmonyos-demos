/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2, display } from '@kit.ArkUI';
import { RouterMap, RouterModule, UserInfo, WindowSize } from 'commonlib';
import { QuickLogin } from 'login_info';

@Builder
export function LoginPageBuilder() {
  LoginPage();
}

@ComponentV2
export struct LoginPage {
  // 半模态or全模态
  isBindContentCover: boolean = false;
  uiContext: UIContext = this.getUIContext();
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!;
  @Local contentHeight: number = 0;

  aboutToAppear(): void {
    this.contentHeight = this.uiContext.px2vp(display.getDefaultDisplaySync().height - this.windowSize.statusHeight -
    this.windowSize.bottomHeight);
    let temp = RouterModule.getNavParam({ url: RouterMap.LOGIN_PAGE });
    if (temp) {
      this.isBindContentCover = temp as boolean;
    }
  }

  build() {
    NavDestination() {
      Column() {
        QuickLogin({
          isBindContentCover: this.isBindContentCover,
          icon: $r('app.media.icon'),
          appName: '拍摄美化行业模板',
          loginBtnBgColor: $r('sys.color.multi_color_aux_01'),
          onAuthentication: () => {
            RouterModule.replace({ url: RouterMap.AUTHENTICATION_PAGE });
          },
          privacyPolicy: () => {
            RouterModule.replace({ url: RouterMap.PRIVACY_AGREEMENT_PAGE });
          },
          userService: () => {
            RouterModule.replace({ url: RouterMap.USER_AGREEMENT });
          },
          extraInfo: {
            appId: 'wxd5a474c******8fd17',
            scope: 'snsapi_userinfo,snsapi_friend,snsapi_message,snsapi_contact',
            transaction: 'test123',
            state: 'none',
          },
          // 模态消失回调
          shouldDismiss: () => {
            let paths: string[] = RouterModule.stack.getAllPathName();
            let isExit = paths.includes(RouterMap.LOGIN_PAGE);
            if (isExit) {
              RouterModule.pop();
            }
          },
          loginFinished: (flag: boolean) => {
            let prop: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())! as UserInfo;
            if (!prop.name) {
              prop.name = '华为用户';
            }
            prop.isLogin = true;
            prop.id = 0;
            prop.cellphone = '177******96';
            prop.address = 'xxx省xxx市';
            RouterModule.pop();
            if (flag) {
              this.getUIContext().getPromptAction().showToast({ message: '登陆成功', duration: 2000 });
            } else {
              this.getUIContext().getPromptAction().showToast({ message: 'mock登陆', duration: 2000 });
            }
          },
        });
      }
      .height('100%')
      .width('100%');
    }.mode(NavDestinationMode.DIALOG)
    .backgroundColor('rgba(0,0,0,0)')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);

  }
}