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

import { call } from '@kit.TelephonyKit';
import { display, window, AppStorageV2 } from '@kit.ArkUI';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction, CustomContentDialog } from '@kit.ArkUI';
import common from '@ohos.app.ability.common';
import { TopBar, MyScrollModifier } from 'commonlib'
import { UpdateContentCard } from '../views/UpdateVersionContentCard';
import { VersionModel } from '../models/MessageModel';

@ComponentV2
export struct AboutPage {
  // 版本检测
  @Local versionInfo: VersionModel = AppStorageV2.connect(VersionModel, () => new VersionModel())!
  @Local updateProgress: number = 0
  @Local appId: string = 'AppID'
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  // 高度
  @Local contentHeight: number = 0;
  uiContext: UIContext = this.getUIContext()
  // 窗口状态
  @Local windowStatusType: number = 0;
  updateVersionDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.updateVersionDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.later_update'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
        },
        {
          value: $r('app.string.immediate_update'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            const want: Want = {
              uri: `store://appgallery.huawei.com/app/detail?id=${this.appId}`
            };
            const context = getContext(this) as common.UIAbilityContext;
            context.startAbility(want).then(() => {
              //拉起成功
            }).catch(() => {
              // 拉起失败
            });
          }
        }
      ],
    }),
    alignment: DialogAlignment.Center
  });

  // 拨打电话弹窗
  phoneDialog() {
    this.getUIContext().showAlertDialog({
      message: '900800',
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: $r('sys.color.font_primary'),
          action: () => {
          }
        },
        {
          value: $r('app.string.play_call'),
          fontColor: $r('sys.color.warning'),
          action: () => {
            call.makeCall('900800',
              (err: BusinessError) => {
                if (err) {
                  console.error(`makeCall fail, err->${JSON.stringify(err)}`);
                } else {
                  console.log(`makeCall success`);
                }
              });
          }
        }
      ]
    })
  }

  aboutToAppear(): void {
    window.getLastWindow(getContext(), (_err, data: window.Window) => {
      // 获取窗口属性
      let properties = data.getWindowProperties();
      let rect = properties.windowRect;
      if (this.uiContext.px2vp(rect.height) <= 680) {
        this.windowStatusType = 5
      }
      let topHeight = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height;
      this.contentHeight = this.uiContext.px2vp(display.getDefaultDisplaySync().height - topHeight -
        0);

    })
  }

  build() {
    Column() {
      // 顶部导航
      TopBar({ title: $r('app.string.about') })
      Scroll() {
        Column() {
          Column() {
            Image($r('app.media.about_app_icon'))
              .width($r('app.float.vp_72'))
              .height($r('app.float.vp_72'))
              .borderRadius(16)
              .objectFit(ImageFit.Contain)
            Text('课堂模板')
              .width('100%')
              .height($r('app.float.vp_21'))
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Center)
          }
          .padding({ top: $r('app.float.vp_62') })
          .margin({ bottom: $r('app.float.vp_62') })

          // 版本信息
          this.aboutCardView()
          Blank()
          //底部
          this.copyrightCardView()
        }
        .width('100%')
        .height($r('app.float.vp_700'))
      }
      .attributeModifier(this.scrollModifier)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })

  }

  @Builder
  updateVersionDialogBuilder() {
    UpdateContentCard()
  }

  /**
   * 底部版权
   */
  @Builder
  copyrightCardView() {
    Column() {
      Text('XXXX备xxxxxxxx号-xxxx')
        .fontColor($r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')
      Text('xxxx 版权所有 © xxxx-xxxx')
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .width('100%')
      Text('技术支持：xxxxxxxx')
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
    .width('100%')

    .padding({ bottom: $r('app.float.vp_20') })
  }

  /**
   * 版本信息卡片
   */
  @Builder
  aboutCardView() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('版本信息')
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Medium)
              .height($r('app.float.vp_21'))
              .textAlign(TextAlign.Start)
            if (!this.versionInfo.isLatestVersion) {
              Image($r('app.media.red_dot'))
                .width($r('app.float.vp_6'))
                .height($r('app.float.vp_6'))
                .objectFit(ImageFit.Contain)
                .margin({ left: $r('app.float.vp_4') })
            }
          }
          .justifyContent(FlexAlign.Start)

          Text('10.15.1')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .height($r('app.float.vp_19'))
            .textAlign(TextAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        Row() {
          Blank()
          Text(this.versionInfo.isLatestVersion ? '检查更新' : '待更新')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
          Image($r('app.media.icon_right'))
            .width($r('app.float.vp_12'))
            .height($r('app.float.vp_24'))
            .margin({ left: $r('app.float.vp_4') })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        // 版本检测
        if (this.versionInfo.isLatestVersion) {
          promptAction.showToast({ message: $r('app.string.already_latest_version') })
        } else {
          this.updateVersionDialogController.open()
        }
      })

      Row() {
        Column() {
          Text('客服电话')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .height($r('app.float.vp_21'))
            .textAlign(TextAlign.Start)
          Text('900800')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .height($r('app.float.vp_19'))
            .textAlign(TextAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ top: $r('app.float.vp_21') })
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.phoneDialog()
      })
    }
    .width('100%')
    .height($r('app.float.vp_128'))
    .backgroundColor($r('sys.color.background_primary'))
    .padding({
      left: $r('app.float.vp_12'),
      right: $r('app.float.vp_12'),
      top: $r('app.float.vp_12'),
      bottom: $r('app.float.vp_12')
    })
    .borderRadius(16)
  }
}

@Builder
export function AboutPageBuilder() {
  AboutPage()
}