import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { BreakpointModel, getMedia, RouterMap, UserInfo } from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { LoginPageBuilder } from './LoginPage'
import { UserItem } from '../comp/UserItem'
import { BuildMyOrderPage } from '../pages/MyOrderPage'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { Constants } from 'common'
import { BuildMyBankCardPage } from '../pages/MyBankCardPage'
import { AddressManagerPageBuilder } from '../pages/AddressManagerPage'

@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local mineArr: MineItem[] = [
    new MineItem('我的订单', $r('app.media.icon_feedback'), wrapBuilder(BuildMyOrderPage),
      RouterMap.MY_ORDER_PAGE),
    new MineItem('地址管理', $r('app.media.icon_message2'), wrapBuilder(AddressManagerPageBuilder),
      RouterMap.MESSAGE_CENTER_PAGE),
    new MineItem('我的银行卡', $r('app.media.icon_feedback'), wrapBuilder(BuildMyBankCardPage),
      RouterMap.FEEDBACK_PAGE),
    new MineItem('设置', $r('app.media.icon_Setting'), wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE),
  ]

  aboutToAppear(): void {

  }

  @Builder
  perMine() {
    Row() {
      Image(this.userInfo.isLogin ?
        (this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '') ? this.userInfo.avatarUrl :
        $r('app.media.path2x') :
      $r('app.media.person'))
        .borderRadius(40)
        .width(48)
        .aspectRatio(1)

      Row() {
        Column() {
          Text(this.userInfo?.isLogin ? this.userInfo?.nickName : '点击登录')
            .height(24)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 16, bottom: 2 })

          if (this.userInfo?.isLogin) {
            Text(`ID：${this.userInfo?.id.toString().padStart(7, '0')}`)
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ left: 16 })
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        Image($r('app.media.iconRight'))
          .width(18)
          .aspectRatio(1)
          .margin({ right: 2 })
      }
      .layoutWeight(1)
    }
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
      } else {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PERSONAL_CENTER_PAGE,
          builder: wrapBuilder(EditPersonalCenterBuilder)
        })
      }
    })
    .width('100%')
    .height(72)
    .padding(12)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
  }

  // 用户的头像+昵称+ID
  @Builder
  mineInfo() {
    Row() {
      // 头像
      Image(this.userInfo.isLogin ?
        (this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '') ? this.userInfo.avatarUrl :
        $r('app.media.path2x') :
      $r('app.media.person'))
        .borderRadius(38)
        .width(76)
        .height(76)

      // 昵称+ID
      Column() {
        Row() {
          Text(this.userInfo?.isLogin ? this.userInfo?.nickName : '点击登录')
            .height(24)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('rgba(51, 51, 51, 1)')

        }.justifyContent(FlexAlign.Start)

        if (this.userInfo?.isLogin) {
          Text(`ID：${this.userInfo?.id.toString().padStart(7, '0')}`)
            .height(19)
            .fontSize(14)
            .fontColor('rgba(90, 96, 108, 1)')
            .margin({ top: 4 })
        }

      }
      .height('100%')
      .margin({ left: 16 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (!this.userInfo?.isLogin) {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.LOGIN_PAGE,
            builder: wrapBuilder(LoginPageBuilder)
          })
        } else {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PERSONAL_CENTER_PAGE,
            builder: wrapBuilder(EditPersonalCenterBuilder)
          })
        }
      })
    }
    .width('100%')
    .height(76)
    .justifyContent(FlexAlign.Start)
    .margin({ top: 20 })
  }

  // 个人信息
  @Builder
  personInfo() {
    Row() {
      Row() {
        Text('个人信息')
          .height(21)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 1)')
          .margin({ left: 16 })
          .fontWeight(FontWeight.Normal)

        Image($r('app.media.ic_right_enter')).width(13).height(25).margin({ right: 16 })
      }
      .height('100%')
      .layoutWeight(1)
      .backgroundColor('rgba(255, 255, 255, 1)')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius(16)
    }.width('100%').height(56).margin({ top: 40, bottom: 16 })
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
      } else {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PERSONAL_CENTER_PAGE,
          builder: wrapBuilder(EditPersonalCenterBuilder)
        })
      }
    })
  }

  build() {
    Scroll() {
      Column() {
        // 用户信息
        this.mineInfo()

        // 个人信息
        this.personInfo()

        // 菜单项
        OuterFrameCard() {
          List() {
            ForEach(this.mineArr, (item: MineItem, index: number) => {
              UserItem({
                title: item.titleName,
                image: item.icon,
                url: item.url,
                isLine: !(index === this.mineArr.length - 1),
                messageNum: item.messageNum
              })
                .onClick(() => {
                  // 设置多个点击
                  if (this.userInfo?.isLogin && item.url) {
                    phoneRouterControl.jumpPage({
                      pageName: item.url,
                      param: item.params,
                      builder: item.builder
                    })
                  } else {
                    if (item.url && item.url === RouterMap.SET_UP_PAGE) {
                      // 设置页面不登录也可进入
                      phoneRouterControl.jumpPage({
                        pageName: item.url,
                        param: item.params,
                        builder: item.builder
                      })
                    } else {
                      // 非设置页面需要登录
                      phoneRouterControl.jumpPage({
                        pageName: RouterMap.LOGIN_PAGE,
                        builder: wrapBuilder(LoginPageBuilder)
                      })
                    }
                  }
                })
            }, (item: MineItem) => JSON.stringify(item))
          }
          .width('100%')
          .height('auto')
          .lanes(1)
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .divider({
            strokeWidth: 0.5,
            color: 'rgba(0, 0, 0, 0.05)',
          })
          .padding({
            left: 4,
            right: 4,
            top: 4,
            bottom: 4,
          })
        }
      }
    }
    .align(Alignment.TopStart)
    .backgroundImage(getMedia('app.media.profile_background'))
    .backgroundImageSize(ImageSize.FILL)
    .backgroundColor('#f2f3f5')
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: Constants.PADDING_7XL
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}

