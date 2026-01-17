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

import { loginComponentManager } from '@kit.AccountKit';

@CustomDialog
export struct AgreementDialog {
  logTag: string = 'AgreementDialog';
  domainId: number = 0x0000;
  dialogController?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };
  clickHyperlinkText: (tag: string) => void = () => {
  };
  privacyText: loginComponentManager.PrivacyText[] = [];

  build() {
    Column() {
      // 标题
      this.titleBuilder()
      // 内容
      this.contentBuilder()
      // 操作按钮
      this.actionButtonBuilder()
    }
    .padding({
      left: 16,
      right: 16
    })
  }

  /**
   * 操作按钮
   */
  @Builder
  actionButtonBuilder() {
    Flex({
      direction: FlexDirection.Row
    }) {
      Button('取消',
        { type: ButtonType.Capsule, stateEffect: true })
        .id('loginPanel_agreement_cancel_btn')
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.ohos_id_text_size_button1'))
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .backgroundColor(Color.Transparent)
        .fontWeight(FontWeight.Medium)
        .focusable(true)
        .focusOnTouch(true)
        .constraintSize({ minHeight: 40, maxWidth: 400 })
        .width('50%')
        .onClick(() => {
          this.cancel();
        })
      Button('同意并登录',
        { type: ButtonType.Capsule, stateEffect: true })
        .id('loginPanel_agreement_dialog_huawei_id_login_btn')
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#4B5CC4')
        .fontSize($r('sys.float.ohos_id_text_size_button1'))
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .fontWeight(FontWeight.Medium)
        .focusable(true)
        .focusOnTouch(true)
        .constraintSize({ minHeight: 40, maxWidth: 400 })
        .width('50%')
        .onClick(() => {
          this.confirm();
        })
    }
    .margin({
      top: 8,
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      bottom: 16
    })
  }

  /**
   * 内容
   */
  @Builder
  contentBuilder() {
    Row() {
      Text() {
        ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
          if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
            Span(item?.text)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Regular)
          } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
            Span(item?.text)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor('#4B5CC4')
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .fontWeight(FontWeight.Medium)
              .focusable(true)
              .focusOnTouch(true)
              .onClick(() => {
                // 应用需要根据item.tag实现协议页面的跳转逻辑
                if (item.tag) {
                  this.clickHyperlinkText(item.tag)
                }
              })
          }
        }, (item: loginComponentManager.PrivacyText) => item.text.toString())
      }
      .width('100%')
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(10)
      .textAlign(TextAlign.Start)
      .focusable(true)
      .focusOnTouch(true)
      .padding({ left: 24, right: 24 })
    }.width('100%')
  }

  /**
   * 标题
   */
  @Builder
  titleBuilder() {
    Row() {
      Text('用户协议与隐私条款')
        .id('loginPanel_agreement_dialog_privacy_title')
        .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
        .minFontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(2)
    }
    .alignItems(VerticalAlign.Center)
    .constraintSize({ minHeight: 56, maxWidth: 400 })
    .margin({
      left: $r('sys.float.ohos_id_max_padding_start'),
      right: $r('sys.float.ohos_id_max_padding_start')
    })
  }
}
