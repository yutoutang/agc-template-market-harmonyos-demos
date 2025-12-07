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

import { AppStorageV2 } from '@kit.ArkUI'
import { call } from '@kit.TelephonyKit'
import { common } from '@kit.AbilityKit'
import { MyScrollModifier, RouterMap, RouterModule, UserInfo } from 'commonlib'
import { FIRST_SERVICE_DATA, MENU_DATA, SECOND_SERVICE_DATA, ServiceModel } from '../models/ServiceModel'

@ComponentV2
export struct MinePage {
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  context = getContext(this) as common.UIAbilityContext

  build() {
    Column() {
      // 导航标题
      this.titleBuilder()
      Scroll() {
        Column({ space: 12 }) {
          // 用户登录信息
          this.userLoginBuilder()
          // 菜单栏
          this.menuBarBuilder()
          // 常用服务
          this.commonServicesBuilder()
        }
        .width('100%')
        .margin({ top: $r('app.float.vp_8') })
      }
      .attributeModifier(this.scrollModifier)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }

  /**
   * 常用服务
   */
  @Builder
  commonServicesBuilder() {
    Column() {
      Text($r('app.string.common_services'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .padding({ top: $r('app.float.vp_24'), bottom: $r('app.float.vp_8') })
      List() {
        ForEach(FIRST_SERVICE_DATA, (item: ServiceModel, index: number) => {
          ListItem() {
            Column() {
              ServiceItem({ serviceModel: item, loginUser: this.loginUser })
              Divider()
                .color($r('sys.color.comp_divider'))
                .visibility(index < FIRST_SERVICE_DATA.length - 1 ? Visibility.Visible : Visibility.None)
            }
          }

        }, (item: ServiceModel, index: number) => item.titleName.toString() + index)
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .width('100%')
      .height('auto')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('app.float.vp_16'))
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })

    List() {
      ForEach(SECOND_SERVICE_DATA, (item: ServiceModel, index: number) => {
        ListItem() {
          Column() {
            ServiceItem({ serviceModel: item, loginUser: this.loginUser })
            Divider()
              .color($r('sys.color.comp_divider'))
              .visibility(index < SECOND_SERVICE_DATA.length - 1 ? Visibility.Visible : Visibility.None)
          }
        }
      }, (item: ServiceModel, index: number) => item.titleName.toString() + index)
    }
    .width('100%')
    .height('auto')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('app.float.vp_16'))
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
  }

  /**
   * 导航标题
   */
  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.mine'))
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .height($r('app.float.vp_56'))
        .width('100%')
    }
  }

  /**
   * 用户登录信息
   */
  @Builder
  userLoginBuilder() {
    Row() {
      Image(this.loginUser.isLogin ?
        (this.loginUser.avatar && this.loginUser.avatar !== '') ? this.loginUser.avatar :
        $r('app.media.ic_user_default') :
      $r('app.media.icon_me_not_login_avatar'))
        .borderRadius($r('app.float.vp_40'))
        .width($r('app.float.vp_48'))
        .height($r('app.float.vp_48'))
      Row() {
        Column() {
          Text(this.loginUser.isLogin ? this.loginUser.name : $r('app.string.click_login'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: $r('app.float.vp_16') })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        Image($r('app.media.icon_right'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_24'))
          .visibility(this.loginUser.isLogin ? Visibility.Visible : Visibility.Hidden)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height($r('app.float.vp_72'))
    .padding($r('app.float.vp_12'))
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('app.float.vp_16'))
    .onClick(() => {
      if (this.loginUser.isLogin) {
        // 跳转个人信息页面
        RouterModule.push({ url: RouterMap.PERSONAL_INFO_PAGE })
      } else {
        RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: true })
      }
    })
  }

  /**
   * 菜单栏
   */
  @Builder
  menuBarBuilder() {
    Row() {
      ForEach(MENU_DATA, (item: ServiceModel) => {
        this.menuItemBuilder(item.titleName, item.icon, item.url)
      }, (item: ServiceModel) => JSON.stringify(item))
    }
    .width('100%')
    .height($r('app.float.vp_92'))
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('app.float.vp_16'))
  }

  /**
   * 菜单子项
   * @param titleName
   * @param icon
   * @param url
   */
  @Builder
  menuItemBuilder(titleName: Resource, icon?: ResourceStr, url?: string) {
    Column() {
      Image(icon)
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
      Text(titleName)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: $r('app.float.vp_4') })
    }
    .width('25%')
    .onClick(() => {
      if (this.loginUser.isLogin) {
        if (url) {
          RouterModule.push({ url: url })
        } else {
          // 获取资源字符串
          this.showToast(`点击跳转到${this.context.resourceManager.getStringSync(titleName)}页面`)
        }
      } else {
        RouterModule.push({ url: RouterMap.LOGIN_PAGE })
      }
    })
  }

  showToast(resource: string) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: resource,
        duration: 2000
      });
    } catch (error) {
      //在此处进行异常处理
    }
  }
}

@ComponentV2
struct ServiceItem {
  @Require @Param serviceModel: ServiceModel
  @Require @Param loginUser: UserInfo
  @Local isOpen: boolean = false
  context = getContext(this) as common.UIAbilityContext

  build() {
    Row() {
      Image(this.serviceModel.icon)
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
      Text(this.serviceModel.titleName)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('app.float.vp_16') })
      Blank()
      Image($r('app.media.icon_right'))
        .height($r('app.float.vp_24'))
        .width($r('app.float.vp_12'))
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .alignItems(VerticalAlign.Center)
    .bindSheet($$this.isOpen, this.buildMakeCallComponent(), {
      title: this.buildTitle(),
      height: $r('app.float.vp_265'),
      preferType:SheetType.CENTER,
    })
    .onClick(() => {
      if (this.loginUser.isLogin) {
        if (this.serviceModel.url) {
          RouterModule.push({ url: this.serviceModel.url })
        } else {
          let titleName: string = this.context.resourceManager.getStringSync(this.serviceModel.titleName)
          if (titleName === '联系客服') {
            this.isOpen = true
          } else {
            this.getUIContext().getPromptAction().showToast({
              message: `点击跳转到${this.context.resourceManager.getStringSync(this.serviceModel.titleName)}页面`,
              duration: 2000
            });
          }
        }

      } else {
        RouterModule.push({ url: RouterMap.LOGIN_PAGE })
      }
    })
  }

  /**
   * 联系客服
   */
  @Builder
  buildMakeCallComponent() {
    Column() {
      Column() {
        Text('0000-00000000')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_30'))
          .halfLeading(true)
        Button() {
          Row() {
            Image($r('app.media.play_call_icon'))
              .height($r('app.float.vp_14'))
              .objectFit(ImageFit.Contain)
              .margin({ right: $r('app.float.vp_5') })
            Text('一键拨号')
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
          }
        }
        .width('100%')
        .height($r('app.float.vp_45'))
        .type(ButtonType.Normal)
        .backgroundColor('#4c5dc4')
        .borderRadius($r('sys.float.corner_radius_level10'))
        .onClick(() => {
          if (canIUse('SystemCapability.Applications.Contacts')) {
            call.makeCall('0000-00000000');
          }
          this.isOpen = false;
        })

        Button() {
          Text($r('app.string.cancel'))
            .fontColor($r('sys.color.font_tertiary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height($r('app.float.vp_45'))
        .type(ButtonType.Normal)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius($r('sys.float.corner_radius_level10'))
        .onClick(() => this.isOpen = false)
      }
      .width('100%')
      .height($r('app.float.vp_170'))
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.vp_16'))
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      bottom: $r('app.float.vp_56'),
      top: $r('app.float.vp_8')
    })
  }

  @Builder
  buildTitle() {
    Text($r('app.string.online_customer_service'))
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Medium)
  }
}

@Builder
export function MinePageBuilder() {
  MinePage()
}
