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
import { BusinessError } from '@kit.BasicServicesKit';
import { PreferenceUtil, Logger } from 'commonlib'
@ComponentV2
export struct ClearCacheItem {
  @Local cacheSize: string = '0';

  aboutToAppear(): void {
    this.getClearSize()
  }

  getClearSize() {
    try {
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
    } catch (e) {
      console.error(`Failed to getCurrentBundleStats. error: ${JSON.stringify(e)}`)
    }
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
            this.cacheSize = '0KB'
          }
        }
      ]
    })
  }

  async clean() {
    let paths: Array<string> = []
    let moduleContext: common.Context;
    let context = AppStorage.get('context') as Context
    try {
      moduleContext = await application.createModuleContext(context, 'entry');
    } catch (e) {
      console.error(`Failed to createModuleContext. error: ${JSON.stringify(e)}`)
      return
    }
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

  build() {
    Column() {
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
        Image($r('app.media.forward'))
          .width(13)
          .height(13)
          .margin({ left: $r('app.float.vp_4') })
      }
      .width('100%')
      .onClick(() => {
        this.showAlert()
      })

    }
    .width('100%')
    .height('auto')
    .backgroundColor($r('sys.color.background_primary'))
  }

}