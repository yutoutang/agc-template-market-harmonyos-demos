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

import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { RouterTable } from '../model/RouterTable';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {

  onCreate(): void {
    // 初始化路由表
    RouterTable.routerInit();
  }

  onDestroy(): void {
    UtilLog.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    UtilLog.info(TAG, 'Ability onWindowStageCreate');
    try {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          UtilLog.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        UtilLog.info(TAG, 'Succeeded in loading the content.');
      });
    }catch (e) {
      UtilLog.info(TAG, 'Ability onWindowStageCreate error');
    }
  }

  onWindowStageDestroy(): void {
    UtilLog.info(TAG, 'onWindowStageDestroy.');
  }

  onForeground(): void {
    UtilLog.info(TAG, 'Ability onForeground.');
  }

  onBackground(): void {
    UtilLog.info(TAG, 'Ability onBackground.');
  }

};