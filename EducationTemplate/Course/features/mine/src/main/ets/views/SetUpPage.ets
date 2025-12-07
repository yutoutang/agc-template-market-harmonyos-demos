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
import { fileIo, storageStatistics } from '@kit.CoreFileKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  RouterMap,
  RouterModule,
  TopBar,
  UserInfo,
  MyScrollModifier,
  PreferenceUtil,
  PreferConstant,
  Logger
} from 'commonlib'
import { PlayerVM, ResolutionSheet } from 'recorded_player';
import { AboutAndVersion } from '../views/AboutAndVersion';
import { VersionModel } from '../models/MessageModel';


@ComponentV2
export struct SetUpPage {
  @Local bottomHeight: number = 0;
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()

  aboutToAppear(): void {
    window.getLastWindow(getContext(), (_err, data) => {
      const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.bottomHeight = avoidAreaBottom.bottomRect.height;
    })
  }

  build() {
    Column() {
      Column() {
        TopBar({ title: $r('app.string.setting') })
        Scroll() {
          Column() {
            setItem()
            // 视频设置
            setVideoItem()
            // 版本检测+关于我们
            AboutAndVersion()
          }
          .alignItems(HorizontalAlign.Start)
        }
        .attributeModifier(this.scrollModifier)
      }.alignItems(HorizontalAlign.Start)

      this.logOutButton()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_50') })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  logOutButton() {
    Column() {
      Button($r('app.string.log_out'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(20)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height($r('app.float.vp_40'))
        .padding({ top: $r('app.float.vp_9'), bottom: $r('app.float.vp_9') })
        .onClick(() => {
          if (this.loginUser.isLogin) {
            this.loginUser.isLogin = false
            this.getUIContext().getPromptAction().showToast({ message: '退出成功', duration: 2000 });
            RouterModule.pop()
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '您还未登录', duration: 2000 });
          }
        })
    }
  }
}

//个人信息+隐私设置
@ComponentV2
struct setItem {
  build() {
    Column() {
      Row() {
        Text($r('app.string.personal_info'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Blank()
        Image($r('app.media.icon_right'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_24'))
      }
      .width('100%')
      .height($r('app.float.vp_48'))
      .onClick(() => {
        // 跳转个人信息页面
        RouterModule.push({ url: RouterMap.PERSONAL_INFO_PAGE })
      })

      Divider().color($r('sys.color.comp_divider'))
      Row() {
        Text($r('app.string.privacy_setting'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Blank()
        Image($r('app.media.icon_right'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_24'))
      }
      .width('100%')
      .height($r('app.float.vp_48'))
      .onClick(() => {
        // 跳转隐私设置
        RouterModule.push({ url: RouterMap.PRIVACY_SET_PAGE })
      })
    }
    .width('100%')
    .height('auto')
    .margin({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_14') })
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
    .borderRadius(16)
  }
}

//视频播放设置
@ComponentV2
struct setVideoItem {
  @Local playerVM: PlayerVM = PlayerVM.instance;
  // 清晰度
  @Local isShowDefinitionSheet: boolean = false;
  @Local cacheSize: string = '0';

  build() {
    Column() {
      this.videoBackendBuilder()
      this.videoClarityBuilder()
      Divider().color($r('sys.color.comp_divider'))
      this.clearCacheBuilder()
    }
    .width('100%')
    .height('auto')
    .margin({ bottom: $r('app.float.vp_14') })
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
    .borderRadius(16)
  }

  /**
   * 视频后台播放
   */
  @Builder
  videoBackendBuilder() {
    Row() {
      Text($r('app.string.video_backend'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: this.playerVM.autoStartEnabled })
        .onChange((isOn: boolean) => {
          this.playerVM.autoStartEnabled = isOn
        })
    }
    .width('100%')
    .height($r('app.float.vp_48'))
  }

  /**
   * 视频播放速度
   */
  @Builder
  videoPlayBackSpeedBuilder() {
    Row() {
      Text($r('app.string.video_play_Speed'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Blank()
      Text('1.25x')
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
      Image($r('app.media.icon_right'))
        .width($r('app.float.vp_12'))
        .height($r('app.float.vp_24'))
        .margin({ left: $r('app.float.vp_4') })
    }
    .width('100%')
    .height($r('app.float.vp_48'))
    .onClick(() => {
      // todo 视频播放速度
    })
  }

  /**
   * 视频默认清晰度
   */
  @Builder
  videoClarityBuilder() {
    Row() {
      Text($r('app.string.video_clarity'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Blank()
      Text(this.playerVM.resolution)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
      Image($r('app.media.icon_right'))
        .width($r('app.float.vp_12'))
        .height($r('app.float.vp_24'))
        .margin({ left: $r('app.float.vp_4') })
      Row()
        .bindSheet(this.isShowDefinitionSheet, this.DefinitionBuilder(), {
          // 半模态高度
          height: 350,
          dragBar: true, // 是否显示控制条
          backgroundColor: Color.White,
          showClose: true, // 是否显示关闭图标
          preferType:SheetType.CENTER,
          shouldDismiss: ((sheetDismiss: SheetDismiss) => {
            sheetDismiss.dismiss();
            this.isShowDefinitionSheet = false
          })
        })
    }
    .width('100%')
    .height($r('app.float.vp_48'))
    .onClick(() => {
      this.isShowDefinitionSheet = true
    })
  }

  @Builder
  DefinitionBuilder() {
    Column() {
      ResolutionSheet({
        defaultResolution: this.playerVM.resolution,
        onChangeResolution: (selectResolution: string) => {
          this.playerVM.resolution = selectResolution
          this.getUIContext().getPromptAction().showToast({ message: `已切换${selectResolution}` })
        }
      })
        .width('90%')
        .height(350)
    }
    .width('100%')
    .height(350)
  }

  /**
   * 清除缓存
   */
  @Builder
  clearCacheBuilder() {
    Row() {
      Text($r('app.string.clear_cache'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Blank()
      Text(this.cacheSize)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
      Image($r('app.media.icon_right'))
        .width($r('app.float.vp_12'))
        .height($r('app.float.vp_24'))
        .margin({ left: $r('app.float.vp_4') })
    }
    .width('100%')
    .height($r('app.float.vp_48'))
    .onClick(() => {
      this.showAlert()
    })
  }

  aboutToAppear(): void {
    this.getClearSize()
  }

  getClearSize() {
    storageStatistics.getCurrentBundleStats((error: BusinessError, bundleStats: storageStatistics.BundleStats) => {
      if (error) {
        Logger.error('getCurrentBundleStats failed with error:' + JSON.stringify(error));
      } else {
        Logger.info('getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
        let isClean = PreferenceUtil.getInstance().isClear()
        if (isClean) {
          this.cacheSize = 0 + 'KB'
        } else {
          this.cacheSize = (bundleStats.dataSize / 1024).toFixed(2) + 'KB'
        }
      }
    });
  }

  showAlert() {
    this.getUIContext().showAlertDialog({
      message: '请确认是否清除缓存',
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
            this.clean()
          }
        }
      ]
    })
  }

  async clean() {
    let paths: Array<string> = []
    let moduleContext: common.Context;
    let context = getContext()
    moduleContext = await application.createModuleContext(getContext(), 'entry');
    paths.push(moduleContext.cacheDir)
    paths.push(context.cacheDir)
    paths.push(moduleContext.preferencesDir)
    paths.push(context.preferencesDir)
    moduleContext.area = contextConstant.AreaMode.EL1;
    context.area = contextConstant.AreaMode.EL1;
    paths.push(moduleContext.cacheDir)
    paths.push(context.cacheDir)
    paths.push(moduleContext.preferencesDir)
    paths.push(context.preferencesDir)
    PreferenceUtil.getInstance().clear()
    for (let i = 0; i < paths.length; i++) {
      let path = paths[i]
      fileIo.listFile(path).then((filenames) => {
        for (let i = 0; i < filenames.length; i++) {
          let dirPath = path + '/' + filenames[i];
          // 判断是否为文件夹
          let isDirectory: boolean = false;
          try {
            isDirectory = fileIo.statSync(dirPath).isDirectory();
          } catch (e) {
            Logger.error(JSON.stringify(e));
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
      })
    }
    this.getClearSize()
  }
}


@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}