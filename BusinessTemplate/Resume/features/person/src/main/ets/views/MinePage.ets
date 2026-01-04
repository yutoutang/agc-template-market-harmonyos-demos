/**
 * 我的页面
 * 展示用户个人信息和功能入口,包括我的简历、我的收藏、意见反馈、设置等
 */

import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { BreakpointModel, getMedia, RouterMap, TCLogger, UserInfo } from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { BuildFeedbackSubmitPage } from 'feedback'
import { LoginPageBuilder } from './LoginPage'
import { FavoritesPageBuilder } from './MyFavoritesPage'
import { UserItem } from '../comp/UserItem'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { MyResumePageBuilder } from './MyResumePage'

@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local mineTopArr: MineItem[] = [
    new MineItem('我的简历', wrapBuilder(MyResumePageBuilder),
      RouterMap.MY_RESUME_PAGE),
    new MineItem('我的收藏', wrapBuilder(FavoritesPageBuilder),
      RouterMap.MY_FAVORITES_PAGE),
  ]
  @Local mineBottomArr: MineItem[] = [
    new MineItem('意见反馈', wrapBuilder(BuildFeedbackSubmitPage),
      RouterMap.FEEDBACK_PAGE),
    new MineItem('设置', wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE),
  ]

  aboutToAppear(): void {
    TCLogger.info(this.logTag, 'aboutToAppear ' + JSON.stringify(this.userInfo));
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
            Text(`ID:${this.userInfo?.id.toString().padStart(7, '0')}`)
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

  @Builder
  buildMenuList(menuItems: MineItem[]) {
    List() {
      ForEach(menuItems, (item: MineItem, index: number) => {
        UserItem({
          title: item.titleName,
          url: item.url,
          isLine: !(index === menuItems.length - 1),
          messageNum: item.messageNum
        })
          .onClick(() => {
            // 设置多个点击
            if (this.userInfo?.isLogin && item.url) {
              phoneRouterControl.jumpPage({
                pageName: item.url,
                builder: item.builder
              })
            } else {
              if (item.url && item.url === RouterMap.SET_UP_PAGE) {
                // 设置页面不登录也可进入
                phoneRouterControl.jumpPage({
                  pageName: item.url,
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
      color: $r('sys.color.comp_divider'),
      startMargin: 12,
      endMargin: 12,
    })
    .padding({
      left: 4,
      right: 4,
      top: 4,
      bottom: 4,
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Text('我的')
            .size({ height: 32 })
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 12, bottom: 12 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        this.perMine()

        // 第一组:我的简历、我的收藏
        OuterFrameCard() {
          this.buildMenuList(this.mineTopArr)
        }

        // 第二组:意见反馈、设置
        OuterFrameCard() {
          this.buildMenuList(this.mineBottomArr)
        }
      }
    }
    .align(Alignment.TopStart)
    .backgroundImage(getMedia('app.media.profile_background'))
    .backgroundImageSize(ImageSize.FILL)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}

@Builder
export function MinePageBuilder() {
  MinePage()
}
