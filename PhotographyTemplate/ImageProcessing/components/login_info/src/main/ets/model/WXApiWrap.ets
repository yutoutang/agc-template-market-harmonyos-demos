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

import * as wxOpensdk from '@tencent/wechat_open_sdk';

export type OnWXReq = (req: wxOpensdk.BaseReq) => void;

export type OnWXResp = (resp: wxOpensdk.BaseResp) => void;

export const wXApi = wxOpensdk.WXAPIFactory.createWXAPI('wxd5a474c******8fd17')

class WXApiEventHandlerImpl implements wxOpensdk.WXApiEventHandler {
  private onReqCallbacks: Map<OnWXReq, OnWXReq> = new Map;
  private onRespCallbacks: Map<OnWXResp, OnWXResp> = new Map;

  registerOnWXReqCallback(on: OnWXReq) {
    this.onReqCallbacks.set(on, on);
  }

  unregisterOnWXReqCallback(on: OnWXReq) {
    this.onReqCallbacks.delete(on);
  }

  registerOnWXRespCallback(on: OnWXResp) {
    this.onRespCallbacks.set(on, on);
  }

  unregisterOnWXRespCallback(on: OnWXResp) {
    this.onRespCallbacks.delete(on);
  }

  onReq(req: wxOpensdk.BaseReq): void {
    this.onReqCallbacks.forEach((on) => {
      on(req);
    });
  }

  onResp(resp: wxOpensdk.BaseResp): void {
    this.onRespCallbacks.forEach((on) => {
      on(resp);
    });
  }
}

export const wXEventHandler = new WXApiEventHandlerImpl;

