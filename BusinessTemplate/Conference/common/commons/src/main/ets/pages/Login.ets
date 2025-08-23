import { seminarContactsGet } from '../api/serviceLogin'
import { MyConfig } from '../constants/MyConfig';
import { UserInfoDetail } from '../viewModel/UserModel';
import { Phone } from '../view/Phone'

// 跳转页面登录入口函数
@Builder
export function LoginBuilder() {
  Login()
}

@Component
export struct Login {
  @Consume('pageStack') pageStack: NavPathStack
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageLink('mainTabIndex') currentTabIndex: number = 0;
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  isHasFrom: string = ''

  loginSuccess() {
    seminarContactsGet({
      token: this.token,
    }).then((res) => {
      this.userInfo = res.data as UserInfoDetail;
      if (this.isHasFrom === 'ticket') {
        this.isHasFrom = ''
        this.pageStack.pushPath({
          name: 'Ticket'
        })
        return
      }
      this.pageStack.pop()
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Image(`${MyConfig.URL}/project/hdc/2025/static/images/login_banner.png`).width(288).margin({ bottom: 64, top: 93 })
          Column({ space: 20 }) {

            Stack() {
              Button('关联华为账号')
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize($r('sys.float.Body_M'))
                .width('100%')
                .height(40)
                .borderRadius(19)
                .backgroundColor('#fff')
                .backgroundImage(`${MyConfig.URL}agenda3%2Flogin_btn.png?token=47298f95-1a54-4097-9cef-aa5d78e7c16f`)
                .backgroundImageSize(ImageSize.FILL)
              Phone({
                cWidth: '100%',
                cHeight: 40,
                callback: () => {
                  this.loginSuccess()
                }
              })
            }


            Button('稍后处理')
              .fontColor($r('sys.color.font_tertiary'))
              .fontSize($r('sys.float.Body_M'))
              .width('100%')
              .height(40)
              .borderRadius(19)
              .backgroundColor('#fff')
              .border({
                color: '#979797',
                width: 1
              })
              .onClick(() => {
                this.pageStack.pop()
                if (this.isHasFrom === 'ticket' || this.isHasFrom === 'code') {
                  this.currentTabIndex = 0
                  return
                }
                this.currentTabIndex = 3
              })
            Text() {
              Span('* ').fontColor('#FF0000')
              Span('请使用您报名时使用的手机号')
            }.fontColor('#999').fontSize('12fp')
          }.width(298)
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .padding({ bottom: px2vp(this.bottomRectHeight) })
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Image(`${MyConfig.URL}/project/hdc/2025/static/images/login_bg_left.png`).width(126).position({ bottom: 0, left: 0 })
      Image(`${MyConfig.URL}/project/hdc/2025/static/images/login_bg_right.png`).width(101).position({ bottom: 0, right: 0 })
    }
    .onReady((ctx: NavDestinationContext) => {
      try {
        const myParams = ctx?.pathInfo?.param as Record<string, string>;
        if (myParams) {
          this.isHasFrom = myParams.from
        }
      } catch (e) {
        console.log('e', JSON.stringify(e))
      }
    })
    .onBackPressed(() => {
      this.pageStack.pop()
      this.currentTabIndex = 0
      return true
    })
    //别删除 这个是从卡片进来 登录后 去门票 再返回 要回到首页或者 我的
    .onShown(() => {
      if (this.token) {
        this.pageStack.pop()
      }
    })
    .padding({ top: px2vp(this.topRectHeight) })
  }
}