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
import { CustomContentDialog } from '@kit.ArkUI';
import { AppStorageV2 } from '@kit.ArkUI';
import { VersionModel } from '../model/VersionModel';
import { UpdateContentCard } from '../views/UpdateVersionContentCard';

@ComponentV2
export struct UpdateVersionItem {
  @Local isLatestVersion: boolean = false //版本检测
  @Local updateProgress: number = 0
  @Local versionInfo: VersionModel = AppStorageV2.connect(VersionModel, () => new VersionModel())!
  timerId?: number
  updateDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.updateDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.later_update'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            console.info('Callback when the button is clicked')
          }
        },
        {
          value: $r('app.string.immediate_update'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.progressDialogController.open()
            this.update()
          }
        }
      ],
    }),
    alignment: DialogAlignment.Center
  });
  progressDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.progressDialogBuilder();
      },
    }),
    alignment: DialogAlignment.Center
  });

  update() {
    this.timerId = setInterval(() => {
      if (this.updateProgress < 100) {
        this.updateProgress += 25
      } else {
        this.versionInfo.isLatestVersion = true
        this.progressDialogController.close()
      }
    }, 500)
  }

  stopUpdate() {
    clearInterval(this.timerId)
    this.progressDialogController.close()
    this.updateProgress = 0
  }

  build() {
    Column() {
      Row() {
        Text('检测版本')
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Blank()
        Image($r('app.media.forward'))
          .width(13)
          .height(13)
      }
      .width('100%')
      .onClick(() => {
        // 版本检测
        if (this.versionInfo.isLatestVersion) {
          const prompt = this.getUIContext().getPromptAction();
          prompt.showToast({
            message: $r('app.string.already_latest_version'),
            duration: 2000
          });
        } else {
          this.updateDialogController.open()
        }
      })

      Divider()
        .margin({ top: 13, bottom: 13 })
    }
    .width('100%')
    .height('auto')
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  updateDialogBuilder() {
    UpdateContentCard()
  }

  @Builder
  progressDialogBuilder() {
    Row() {
      Column({ space: 12 }) {
        Row() {
          Text('正在更新')
            .fontSize(14)
            .fontColor('#E5000000')
          Text(this.updateProgress + '%')
            .fontSize(14)
            .fontColor('#E5000000')
        }
        .width($r('app.float.vp_244'))
        .justifyContent(FlexAlign.SpaceBetween)

        Progress({ value: this.updateProgress, total: 100, type: ProgressType.Linear })
          .width($r('app.float.vp_244'))
      }
      .width($r('app.float.vp_244'))

      Image($r('app.media.ic_public_close_circle'))
        .width($r('app.float.vp_22'))
        .height($r('app.float.vp_22'))
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.stopUpdate()
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({
      left: $r('app.float.vp_4'),
      right: $r('app.float.vp_4')
    })
  }
}