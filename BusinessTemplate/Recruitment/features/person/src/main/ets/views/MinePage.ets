import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { BarVM, BreakpointModel, getMedia, JobApplicationData, RouterMap, TabItem, UserInfo } from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { UserItem } from '../comp/UserItem'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { JobApplicationPageBuilder } from './JobApplicationPage'
import { ResumeAttachmentPageBuilder } from './ResumeAttachmentPage'
import { LoginPageBuilder, ProtocolRouterParams } from 'aggregated_login'
import { ResumePageBuilder } from 'resume'
import { JobIntentionsPageBuilder } from 'job_intention'

/**
 * @usage: 个人中心主页面，提供用户信息管理和个人设置功能。包含用户信息展示、求职经历统计、在线简历、附件简历、求职意向等功能入口。
 * 主要数据结构包括UserInfo（用户信息）、MineItem（菜单项模型）、JobApplicationData（求职申请数据）。包含if逻辑判断用户登录状态和
 * 求职数据显示。
 * @layout: 页面采用Scroll+Column垂直布局，顶部为"我的"标题，下方依次为用户信息卡片、求职经历统计tab、常用功能区域和常用服务列表。
 * 用户信息卡片采用横向布局（Row），左侧头像右侧用户信息和编辑入口。常用功能采用横向排列的图标+文字形式。常用服务使用List组件垂直排列。
 * @constraints: 登录相关不可删除
 * @domain: 招聘求职
 * @isGen: true
 * @fileType: page
 * @zhName: 个人中心主页面
 * @subPage: LoginPage,SetUpPage,EditPersonalCenterPage,JobApplicationPage,ResumeAttachmentPage,ResumePage,
 * JobIntentionsPage
 * @component: OuterFrameCard,UserItem
 * @image: screenshot/person.jpg
 */

@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local jobAppData: JobApplicationData = AppStorageV2.connect(JobApplicationData, () => new JobApplicationData())!;
  @Local commonFunctionList: MineItem[] = [
    new MineItem('在线简历', $r('app.media.ic_online_resume'), wrapBuilder(ResumePageBuilder),
      RouterMap.RESUME_PAGE),
    new MineItem('附件简历', $r('app.media.ic_resume_attachment'), wrapBuilder(ResumeAttachmentPageBuilder),
      RouterMap.RESUME_ATTACHMENT_PAGE),
    new MineItem('求职意向', $r('app.media.ic_career_objective'), wrapBuilder(JobIntentionsPageBuilder),
      RouterMap.JOB_INTENTION_PAGE)
  ];
  @Local mineArr: MineItem[] = [
    new MineItem('设置', $r('app.media.icon_Setting'), wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE),
  ]

  aboutToAppear(): void {
    this.jobAppData.updateData()
  }

  @Builder
  perMine() {
    Row() {
      Image(this.userInfo.isLogin ?
        (this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '') ? $r('app.media.' + this.userInfo.avatarUrl) :
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
            Row() {

              Text('在线简历')
                .fontSize(12)
                .fontWeight(400)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 16 })
              Image($r('app.media.ic_edit'))
                .width(16)
                .height(16)
                .margin({ left: 4 })
                .onClick(() => {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.RESUME_PAGE,
                    builder: wrapBuilder(ResumePageBuilder)
                  })
                })
            }
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

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Text('我的')
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .height(36)
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        Column() {
          this.perMine()
          // tab分类
          Row() {
            ForEach(this.jobAppData.tabList, (item: TabItem, index: number) => {
              Column() {
                Text(item.num.toString()).fontSize(16).fontColor('#E5000000')
                Text(item.text).fontSize(12).fontColor('#99000000')
              }
              .onClick(() => {
                if (!this.userInfo?.isLogin) {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.LOGIN_PAGE,
                    builder: wrapBuilder(LoginPageBuilder)
                  })
                } else {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.JOP_APPLICATION_PAGE,
                    param: {
                      content: index.toString(),
                      isSheet: false,
                    } as ProtocolRouterParams,
                    builder: wrapBuilder(JobApplicationPageBuilder)
                  })
                }

              })
            }, (item: TabItem) => JSON.stringify(item))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ top: 8, left: 10, right: 10 })
        }
        .padding(12)
        .backgroundColor($r('sys.color.background_primary'))
        .borderRadius(16)

        // 常用功能
        Column() {
          Row() {
            Text('常用功能').fontSize(12).fontColor('#E5000000')
          }.width('100%')

          Row() {
            ForEach(this.commonFunctionList, (item: MineItem) => {
              Column() {
                Image(item.icon).width(36).height(36)
                Text(item.titleName).fontSize(12).fontColor('#E5000000').margin({ top: 8 })
              }.margin({ right: 25 })
              .onClick(() => {
                if (!this.userInfo?.isLogin) {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.LOGIN_PAGE,
                    builder: wrapBuilder(LoginPageBuilder)
                  })
                } else {
                  if (item.url) {
                    phoneRouterControl.jumpPage({
                      pageName: item.url,
                      param: item.params,
                      builder: item.builder,
                      onPop: () => {
                        phoneRouterControl.popLastPage()
                      }
                    })
                  }
                }

              })
            }, (item: MineItem) => JSON.stringify(item))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding({ left: 10, top: 10 })
        }
        .padding(16)
        .backgroundColor($r('sys.color.background_primary'))
        .borderRadius(16)

        Text('常用服务')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .lineHeight(24)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 12, bottom: 4 })
          .width('100%')

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
        }
      }
    }
    .align(Alignment.TopStart)
    .backgroundImage(getMedia('app.media.profile_background'))
    .backgroundImageSize(ImageSize.FILL)
    .backgroundColor('#f2f3f5')
    .padding({
      top: BarVM.instance.staBarH,
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}