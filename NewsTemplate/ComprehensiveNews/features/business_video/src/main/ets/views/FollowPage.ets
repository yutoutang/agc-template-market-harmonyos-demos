import { PersistenceV2 } from '@kit.ArkUI';
import { RouterMap, RouterUtils, UserInfoModel } from 'lib_common';
import { TabPageType } from '../types/Index';
import { VideoSwiperPage } from './VideoSwiperPage';

@ComponentV2
export struct FollowPage {
  // tab页面的index
  @Param index: number = 0
  // 视频页里面的头部tabIndex
  @Param currentTabIndex: number = 0;

  userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  build() {
    Column() {
      if (this.userInfoModel.isLogin) {
        VideoSwiperPage({
          index: this.index,
          currentTabIndex: this.currentTabIndex,
          pageType: TabPageType.FOLLOW,
        })
      } else {
        this.logoutView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  logoutView() {
    Column({space: 20}) {
      Image($r('app.media.ic_follow_list'))
        .width(60)
        .height(55)

      Text('暂未登录，登录后查看关注内容')
        .fontSize(14)
        .fontColor('#bfbfbf')

      Button('登录', { type: ButtonType.Normal, stateEffect: true })
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_on_primary'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .backgroundColor('#505050')
        .width('33%')
        .onClick(() => {
          RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE);
        })
    }
  }
}