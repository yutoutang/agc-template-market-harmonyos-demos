/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the 'License');
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

import { AppStorageV2, window } from '@kit.ArkUI';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { UserInfo } from 'login_info';
import { Header } from '../components/Header';

@ComponentV2
export struct EditPersonalCenterPage {
  @Local textName: string = '';
  @Local isShowIcon: boolean = false;
  @Local isShowNickname: boolean = false;
  @Local keyboardHeight: number = 0;
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local imageUri: Array<string> = [];

  aboutToAppear(): void {
    window.getLastWindow(getContext(this)).then(currentWindow => {
      // 监视软键盘的弹出和收起
      currentWindow.on('avoidAreaChange', async data => {
        if (data.type !== window.AvoidAreaType.TYPE_KEYBOARD) {
          return;
        }
        this.keyboardHeight = px2vp(data.area.bottomRect.height);
      })
    })
  }

  build() {
    Column() {
      Header({ title: '个人信息' })
      Column() {
        // 头像
        this.avatarBuilder()
        Column() {
          // 昵称
          this.nickNameBuilder()
          Divider().color($r('sys.color.comp_divider'))
          // 手机号
          this.phoneNumberBuilder()
        }
        .backgroundColor(Color.White)
        .width('100%')
        .height(104)
        .borderRadius(16)
        .padding({
          left: $r('app.float.vp_12'),
          right: $r('app.float.vp_12'),
          top: $r('app.float.vp_4'),
          bottom: $r('app.float.vp_4')
        })
      }
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%')
  }

  /**
   * 手机号
   */
  @Builder
  phoneNumberBuilder() {
    Row() {
      Text('手机号')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Blank()
      Text(this.loginUser.cellphone)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
      Image($r('app.media.icon_right'))
        .width($r('app.float.vp_12'))
        .height($r('app.float.vp_24'))
        .margin({ left: $r('app.float.vp_4') })
    }
    .height($r('app.float.vp_48'))
    .width('100%')
  }

  /**
   * 昵称
   */
  @Builder
  nickNameBuilder() {
    Row() {
      Text('昵称')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Blank()
      Text(this.loginUser.name)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ right: $r('app.float.vp_4') })
      Image($r('app.media.icon_right'))
        .width($r('app.float.vp_12'))
        .height($r('app.float.vp_24'))
    }
    .width('100%')
    .height($r('app.float.vp_48'))
    .onClick(() => {
      this.isShowNickname = true;
    })
    .bindSheet($$this.isShowNickname, this.setNickNameBuilder(), {
      height: 744,
      backgroundColor: $r('sys.color.background_secondary'),
      showClose: false,
      maskColor: $r('sys.color.mask_fourth'),
    })
  }

  /**
   * 头像
   */
  @Builder
  avatarBuilder() {
    Row() {
      Text('头像')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Blank()
        .layoutWeight(1)
      Row({ space: 4 }) {
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
            label: '',
            styleOption: {
              styleConfig: new functionalButtonComponentManager.ButtonConfig()
                .type(ButtonType.Normal)
                .backgroundImage((this.loginUser.avatar && this.loginUser.avatar !== '') ? this.loginUser.avatar :
                $r('app.media.path2x'))
                .backgroundImageSize(ImageSize.Cover)
                .width(40)
                .height(40)
                .borderRadius(50)
                .backgroundColor('#E5E5E5'),
            },
          },
          controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err,
            data) => {
            if (err) {
              return;
            }
            if (data) {
              this.loginUser.avatar = data.avatarUri!
            }
          }),
        })
        Image($r('app.media.icon_right'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_24'))
          .draggable(false)
      }
      .accessibilityLevel('yes')
      .accessibilityText('切换头像')
    }
    .innerCard()
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
  }

  @Builder
  setNickNameBuilder() {
    Column() {
      Column() {
        Row() {
          Text('设置昵称')
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Image($r('app.media.close_btn'))
            .height($r('app.float.vp_40'))
            .width($r('app.float.vp_40'))
            .onClick(() => {
              this.isShowNickname = false
            })
        }
        .width('100%')
        .height($r('app.float.vp_56'))
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        TextInput({ placeholder: '请输入不超过12位的新昵称' })
          .width('100%')
          .height($r('app.float.vp_40'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .backgroundColor($r('sys.color.comp_background_primary'))
          .margin({ top: $r('app.float.vp_12') })
          .type(InputType.Normal)
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: { size: $r('app.float.vp_16'), color: $r('sys.color.icon_primary') }
          })
          .onChange((value: string) => {
            this.textName = value;
          })
      }

      Blank()
      Button('确定')
        .borderRadius(20)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.multi_color_01'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height($r('app.float.vp_40'))
        .padding({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') })
        .margin({ bottom: this.keyboardHeight ? $r('app.float.vp_300') : $r('app.float.vp_50') })
        .onClick(() => {
          if (this.textName.trim() !== '' && this.textName.length <= 12) {
            this.loginUser.name = this.textName
            this.showToast('昵称修改成功');
            this.isShowNickname = false
          } else if (this.textName.trim() === '') {
            this.showToast('您还未填写');
          } else {
            this.showToast('昵称禁止超过12位');
          }
        })
    }
    .height('100%')
    .padding({ top: $r('app.float.vp_8'), left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }

  showToast(message: ResourceStr) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
    }
  }
}

@Extend(Row)
function innerCard() {
  .width('100%')
  .height($r('app.float.vp_56'))
  .margin({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_12') })
  .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius($r('app.float.vp_16'))
  .justifyContent(FlexAlign.SpaceBetween)
}

@Builder
export function EditPersonalCenterBuilder() {
  EditPersonalCenterPage()
}

