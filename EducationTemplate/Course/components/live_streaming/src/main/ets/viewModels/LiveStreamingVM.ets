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

import { PipManager } from '../tools/PipManager';

@ObservedV2
export class LiveStreamingVM {
  @Trace resolution: string = '1080P 原画（高帧率）';
  @Trace avatar: ResourceStr = '';
  @Trace name: string = '';
  @Trace streamUrl: string =
    'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4'
  public navId: string = 'courseNavId';
  private static _instance: LiveStreamingVM;

  public static get instance() {
    if (!LiveStreamingVM._instance) {
      LiveStreamingVM._instance = new LiveStreamingVM();
    }
    return LiveStreamingVM._instance;
  }

  startPip() {
    PipManager.getInstance().startPip();
  }

  stopPip() {
    PipManager.getInstance().stopPip();
  }
}