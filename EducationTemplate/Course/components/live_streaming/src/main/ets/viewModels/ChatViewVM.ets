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

import { ChatDataSource } from '../models/ChatDataSource';

@ObservedV2
export class ChatViewVM {
  @Trace isCharge: boolean = false;
  @Trace charge: number = 50;
  @Trace dataSource: ChatDataSource = new ChatDataSource();
  @Trace isShowTips = false;
  @Trace rowsNum: number = 2;
  @Trace notOpacity: number = 80;
  @Trace danMuSpeed: string = '适中';
  @Trace danMuSize: string = '适中';
  private static _instance: ChatViewVM;
  // 提交
  onSubmit: (content: string) => void = () => {
  };
  // 清屏
  onCleanScreen: () => void = () => {
  };
  setRowsNum: (set: number) => void = (set: number) => {
  };
  setNotOpacity: (set: number) => void = (set: number) => {
  };
  setDanMuSpeed: (set: string) => void = (set: string) => {
  };
  setDanMuSize: (set: string) => void = (set: string) => {
  };

  public static get instance() {
    if (!ChatViewVM._instance) {
      ChatViewVM._instance = new ChatViewVM();
    }
    return ChatViewVM._instance;
  }
}