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

import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { RouterTable } from '../models/RouterTable';
import { Logger, WindowSize } from 'commonlib';
import { LoginVM, wXApi, wXEventHandler } from 'login_info';
import { aggregatedPaymentService } from 'aggregated_payment';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private mWindow!: window.Window;
  private vm: LoginVM = LoginVM.instance;

  onNewWant(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    this.handleWeChatCallIfNeed(want);
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化路由表
    RouterTable.routerInit();
    this.handleWeChatCallIfNeed(want);

    // 全局设置为浅色模式
    let applicationContext = this.context.getApplicationContext();
    applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    this.mWindow = windowStage.getMainWindowSync();
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
    // 设置屏幕方向为竖屏
  //  this.mWindow.setPreferredOrientation(window.Orientation.PORTRAIT);
    // 订阅窗口尺寸变化
    this.mWindow.on('windowSizeChange', (size: window.Size) => {
      let windowModel: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!;
      windowModel.screenHeight = size.height;
      windowModel.screenWidth = size.width;
    });

    // 安全区域变化时更新状态栏和导航栏高度
    this.mWindow.on('avoidAreaChange', (data) => {
      let windowModel: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!;
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        // 存储窗口内容规避的状态栏高度
        windowModel.statusHeight = data.area.topRect.height;
      } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        // 存储窗口内容规避的底部安全区高度
        windowModel.bottomHeight = data.area.bottomRect.height;
      }
    });

    this.mWindow.on('windowStatusChange', (windowStatusType) => {
      let windowModel: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!;
      windowModel.windowStatusType = windowStatusType;
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  private handleWeChatCallIfNeed(want: Want) {
    aggregatedPaymentService.handleWant(want); // 处理 Want 实例，接收可能存在的微信支付回调消息
    this.vm.loginFinished(false);
  }
};