/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { CustomShareParams, RouterModule } from 'lib_foundation';

const TAG = '[EntryAbility]';

// 系统的分享参数模型
interface ShareInfo {
  showShareMenu: boolean; // 当前页面是否允许分享，面板分享开关是否打开, 不填默认为不允许
  title?: string; // 系统分享面板标题，默认为元服务名称
  description?: string; // 系统分享面板简介，默认为元服务一句话描述
  previewUri?: string; // 分享图片缩略图，为本地文件uri，预留字段，不起作用
  parameters?: Object; // 开发者自定参数
  preview?: string; // 分享缩略图的base64编码，大小限制在32kb，太大会导致分享按钮置灰
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.setGlobalConfig({
      tag: 'HouseHoldService', // 指定日志标识
      domain: 0xff00, // 日志对应的领域标识
      open: true,
      showStack: false,
    })
    Logger.info(TAG, 'Ability onCreate');
    this.handleShare(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleShare(want);
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      this.setColorMode();
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }

  setColorMode() {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (error) {
      Logger.error(TAG, `Failed to set color mode. Code is ${error.code}, message is ${error.message}`);
    }
  }

  onShare(wantParams: Record<string, Object>) {
    // 指定页面支持分享按钮点击事件
    let currentName: string[] = RouterModule.getStack().getAllPathName();
    let showShareMenu = false;
    if (currentName.length && ['Main', 'GoodDetail'].includes(currentName[currentName.length - 1])) {
      showShareMenu = true;
    }
    const shareParams: ShareInfo = {
      showShareMenu: showShareMenu,
      title: '家政元服务分享',
      description: '家政元服务分享',
      parameters: {} as CustomShareParams,
    };
    // 分享方：从临时缓存中获取自定义参数来设置want
    const instance = AppStorageV2.connect(CustomShareParams, 'shareInstance', () => new CustomShareParams())!;
    if (instance.goodId) {
      const pageParams: CustomShareParams = {
        id: instance.id,
        pageName: instance.pageName,
        goodId: instance.goodId,
        goodName: instance.goodName,
      }
      shareParams.title = pageParams.goodName;
      shareParams.description = pageParams.goodName;
      shareParams.parameters = pageParams;
    }

    wantParams['atomicservice.param.key.shareInfo'] = shareParams;
  }


  handleShare(want: Want) {
    // 接收方：从want中获取自定义参数，用于后续实现页面的路由跳转
    const paramStr = want?.parameters?.custShareParam as string;
    const shareParams: CustomShareParams = JSON.parse(paramStr || '{}');
    const shareRouter: CustomShareParams = AppStorageV2.connect(CustomShareParams, 'handleShare', () => new CustomShareParams())!;
    shareRouter.id = new Date().getTime();
    shareRouter.pageName = '';
    shareRouter.goodId = '';
    if (shareParams?.goodId) {
      shareRouter.pageName = shareParams.pageName;
      shareRouter.goodId = shareParams.goodId;
    }
  }
}
