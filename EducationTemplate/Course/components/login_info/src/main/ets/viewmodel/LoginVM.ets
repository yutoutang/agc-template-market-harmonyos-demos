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

import { common } from '@kit.AbilityKit';
import * as wxOpenSdk from '@tencent/wechat_open_sdk';
import { ExtraInfo } from '../model/Index';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class LoginVM {
  private static _instance: LoginVM;
  /**
   * 登录成功回调
   */
  loginFinished: (flag: boolean, unionId?: string) => void = () => {
  };

  public static get instance() {
    if (!LoginVM._instance) {
      LoginVM._instance = new LoginVM();
    }
    return LoginVM._instance;
  }

  async wxLogin(extraInfo: ExtraInfo) {
    let wxApi = wxOpenSdk.WXAPIFactory.createWXAPI(extraInfo.appId)
    let req = new wxOpenSdk.SendAuthReq;
    req.isOption1 = false;
    req.nonAutomatic = true;
    req.scope = extraInfo.scope;
    req.state = extraInfo.state;
    req.transaction = extraInfo.transaction;
    let finished = await wxApi.sendReq(getContext(this) as common.UIAbilityContext, req);
    if (!finished) {
      promptAction.showToast({ message: '暂无法拉起微信', duration: 1000 });
    }
  }
}
