/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { application, common, contextConstant } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import { AppStorageV2, window } from '@kit.ArkUI';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { SetupItem } from '../viewModel/setUpModel';
import { RouterMap, RouterModule } from 'router_module';
import { Logger, PreferConstant, PreferenceUtil } from 'commonlib';
import { Header } from '../components/Header';
import { UserInfo } from 'login_info';

enum AlertType {
  // 清除缓存弹框
  clean = 1,
  // 退出登录弹框
  loginOut,

}

@ComponentV2
struct SetupComponent {
  @Param @Require setupItem: SetupItem;

  build() {
    Row() {
      Text(this.setupItem.msg)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular);
      Row() {
        if (this.setupItem.cache) {
          Text(this.setupItem.cache)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .margin({ right: 4 });
        }
        Image(this.setupItem.icon).height($r('app.float.vp_24')).width($r('app.float.vp_24'));
      };
    }
    .padding(12)
    .margin({ bottom: 12 })
    .borderRadius($r('app.float.vp_16'))
    .padding($r('app.float.vp_12'))
    .margin({ bottom: $r('app.float.vp_12') })
    .borderRadius($r('app.float.vp_16'))
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center);
  }
}

@ComponentV2
export struct SetUpPage {
  @Local bottomHeight: number = 0;
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local setupList: SetupItem[] = [
    new SetupItem('个人信息', $r('app.media.iconRight'), '', RouterMap.PERSONAL_CENTER_PAGE),
    new SetupItem('意见反馈', $r('app.media.iconRight'), '', RouterMap.FEEDBACK_PAGE),
    new SetupItem('反馈记录', $r('app.media.iconRight'), '', RouterMap.FEEDBACK_RECORD_PAGE),
    new SetupItem('隐私协议', $r('app.media.iconRight'), '', 'PrivacyStatementPage'),
    new SetupItem('关于', $r('app.media.iconRight'), '', RouterMap.ABOUT_PAGE),
    new SetupItem('清除缓存', $r('app.media.iconRight'), '0.0M', ''),
  ];

  aboutToAppear(): void {
    this.getClearSize();
    try {
      window.getLastWindow(getContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      });
    }catch (e) {
    }
  }

  build() {
    Column() {
      Header({ title: '设置' });
      Column() {
        Column() {
          ForEach(this.setupList, (item: SetupItem) => {
            SetupComponent({ setupItem: item })
              .onClick(() => {
                if (item.msg === '清除缓存') {
                  this.showAlert(AlertType.clean);
                } else if (item.msg === '个人信息') {
                  if (item.url && this.logoUser.isLogin) {
                    RouterModule.push({ url: item.url });
                  } else {
                    RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: false });
                  }
                } else {
                  if (item.url) {
                    RouterModule.push({ url: item.url });
                  }
                }
              });
          }, (item: SetupItem, index: number) => item.msg + index);
        };

        Button('退出登录')
          .borderRadius(20)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#4c5dc4')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .width(312)
          .height(40)
          .padding({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') })
          .onClick(() => {
            if (this.logoUser.isLogin) {
              this.showAlert(AlertType.loginOut);
            } else {
              this.getUIContext().getPromptAction().showToast({ message: '您还未登录', duration: 2000 });
            }
            try {
              emitter.emit('MinePageShown');
            }catch (e) {
            }
          });
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
      .padding({
        left: $r('app.float.vp_16'),
        right: $r('app.float.vp_16'),
        top: $r('app.float.vp_12'),
        bottom: this.bottomHeight
      })
      .backgroundColor($r('sys.color.comp_background_gray'));
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start);
  }

  getClearSize() {
    try {
      storageStatistics.getCurrentBundleStats((error: BusinessError, bundleStats: storageStatistics.BundleStats) => {
        if (error) {
          Logger.error('getCurrentBundleStats failed with error:' + error.code);
        } else {
          Logger.info('getCurrentBundleStats successfully:' + bundleStats);
          this.setupList.forEach(async (eme) => {
            // 模拟缓存cache
            if (eme.msg === '清除缓存') {
              let isClean = PreferenceUtil.getInstance().isClean() &&
              PreferenceUtil.getInstance(PreferConstant.TOPIC_NOTES).isClean();
              if (isClean) {
                eme.cache = 0 + 'KB';
              } else {
                eme.cache = (bundleStats.dataSize / 1024).toFixed(2) + 'KB';
              }
            }
          });
        }
      });
    }catch (e) {
    }
  }

  showAlert(type: AlertType) {
    this.getUIContext().showAlertDialog({
      message: type === AlertType.clean ? '请确认是否清除缓存' : '确定要退出登录吗',
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: '确定',
          action: () => {
            if (type === AlertType.clean) {
              this.clean();
            } else {
              this.loginOut();
            }
          }
        }
      ]
    });
  }

  async clean() {
    try {
      let paths: Array<string> = [];
      let moduleContext: common.Context;
      let context = getContext();
      moduleContext = await application.createModuleContext(getContext(), 'entry');
      paths.push(moduleContext.cacheDir);
      paths.push(context.cacheDir);
      paths.push(moduleContext.preferencesDir);
      paths.push(context.preferencesDir);
      moduleContext.area = contextConstant.AreaMode.EL1;
      context.area = contextConstant.AreaMode.EL1;
      paths.push(moduleContext.cacheDir);
      paths.push(context.cacheDir);
      paths.push(moduleContext.preferencesDir);
      paths.push(context.preferencesDir);
      PreferenceUtil.getInstance().clear();
      PreferenceUtil.getInstance(PreferConstant.TOPIC_NOTES).clear();

      for (let i = 0; i < paths.length; i++) {
        let path = paths[i];
        fileIo.listFile(path).then((filenames) => {
          for (let i = 0; i < filenames.length; i++) {
            let dirPath = path + '/' + filenames[i];
            // 判断是否为文件夹
            let isDirectory: boolean = false;
            try {
              isDirectory = fileIo.statSync(dirPath).isDirectory();
            } catch (e) {
            }
            if (isDirectory) {
              fileIo.unlinkSync(dirPath);
            } else {
              fileIo.unlink(dirPath).then(() => {
                Logger.info('remove file succeed');
              }).catch((err: Error) => {
                Logger.error('remove file failed with error message: ' + err.message);
              });
            }
          }
        });
      }
      this.getClearSize();
    } catch (e) {
    }
  }

  loginOut() {
    this.logoUser.isLogin = false;
    this.getUIContext().getPromptAction().showToast({ message: '退出成功', duration: 2000 });
    RouterModule.pop();
  }
}

@Builder
export function SetUpPageBuilder() {
  SetUpPage();
}
