/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common } from '@kit.AbilityKit'
import { emitter } from '@kit.BasicServicesKit';
import { MyScrollModifier, RouterMap, RouterModule, CourseItemComponent, UserInfo } from 'commonlib'
import { Course, CourseModel } from 'http';
import { HomeTop, SelectRoleItem } from '../components/HomeTop';
import { MENU_DATA, HomeMenuModel } from '../models/HomeMenuModel'
import { HomeVM } from '../viewModels/HomeVM';
import { LiveStreamingItem } from '../components/LiveStreamingItem';
import { AppStorageV2 } from '@kit.ArkUI';
import { LiveStreamingVM } from 'live_streaming';
import { PlayerVM } from 'recorded_player';

@ComponentV2
export struct HomePage {
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  @Local isShow: boolean = false;
  @Local roleStr: string = '一级建造师';
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local liveVM: LiveStreamingVM = LiveStreamingVM.instance;
  @Local playerVM: PlayerVM = PlayerVM.instance;
  context = getContext(this) as common.UIAbilityContext
  homeData: HomeVM = HomeVM.instance;

  aboutToAppear(): void {
    this.homeData.queryHomeHotCourseList()
    this.homeData.queryHomeHotLiveList()
    this.homeData.queryHomeHotTeacherList()
  }

  build() {
    Column() {
      //顶部
      HomeTop({
        type: this.roleStr,
        selectRole: () => { //角色切换
          this.isShow = true;
        }
      })
      Scroll() {
        Column() {
          // 轮播图
          this.swiperBannerBuilder()
          // 菜单栏
          this.homeMenuBarBuilder()

          if (this.homeData.popularLiveList.length > 0) {
            Column() {
              Column() {
                // 热门课程
                this.popularCourseBuilder()
              }
              .width('100%')
              .margin({ top: $r('app.float.vp_24') })

              Column() {
                // 热门直播
                this.popularLiveBuilder()
              }
              .width('100%')
              .margin({ top: $r('app.float.vp_24') })

              Column() {
                // 热门名师
                this.popularTeacherBuilder()
              }
              .width('100%')
              .margin({ top: $r('app.float.vp_24') })
            }
          } else {
            LoadingProgress()
              .width($r('app.float.vp_40'))
              .height($r('app.float.vp_40'))
              .margin({ top: $r('app.float.vp_20') })
          }
        }
        .width('100%')
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      }.attributeModifier(this.scrollModifier)
    }
    .height('100%')
    .width('100%')
    .bindSheet($$this.isShow, this.myRoleBuilder(), {
      height: SheetSize.LARGE,
      blurStyle: BlurStyle.Thick,
      showClose: true,
      preferType:SheetType.CENTER,
      title: { title: $r('app.string.please_select') },
      onWillDismiss: () => {
        this.isShow = false;
      }
    })
  }

  @Builder
  myRoleBuilder() {
    Column() {
      Column() {
        SelectRoleItem({
          changeRoleText: (roleText: string) => { //角色切换
            this.isShow = false;
            this.roleStr = roleText;
          }
        })
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK, {
        colorMode: ThemeColorMode.LIGHT,
        adaptiveColor: AdaptiveColor.DEFAULT,
        scale: 1.0
      })
      .borderRadius({
        topLeft: $r('app.float.vp_16'),
        topRight: $r('app.float.vp_16'),
      })
    }.width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }

  /**
   * 热门名师
   */
  @Builder
  popularTeacherBuilder() {
    Text($r('app.string.popular_teacher'))
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin({ bottom: $r('app.float.vp_16') })
    Column() {
      List() {
        ForEach(this.homeData.popularTeacherList, ((item: Course) => {
          ListItem() {
            // 课程列表子项
            CourseItemComponent({
              courseTitle: item.courseTitle,
              courseDuration: item.courseDuration,
              learnProgress: item.learnProgress,
              cover: item.cover,
              category: item.category,
              lecturer: item.lecturer,
              learnNumber: item.learnNumber
            }).onClick(() => {
              if (item.liveState !== 0) {
                this.playerVM.stopPip()
              }
              RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: item.id })
            })
          }
        }), (item: Course, index: number) => item.courseTitle + index)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .width('100%')
      .height('auto')
      .padding({ bottom: $r('app.float.vp_8') })
    }
    .width('100%')
    .height('auto')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12'), top: $r('app.float.vp_4') })
  }

  /**
   * 热门直播
   */
  @Builder
  popularLiveBuilder() {
    Text($r('app.string.popular_live_streaming'))
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin({ bottom: $r('app.float.vp_16') })
    Column() {
      Grid() {
        ForEach(this.homeData.popularLiveList, (info: Course, idx: number) => {
          GridItem() {
            LiveStreamingItem({ course: info })
          }
          .onClick(() => {
            if (this.loginUser.isLogin) {
              if (info.liveState === 1) {
                this.playerVM.stopPip()
                RouterModule.push({ url: RouterMap.LIVE_STREAMING_PAGE, param: info?.id })
              } else if (info.liveState === 2) {
                this.playerVM.stopPip()
                RouterModule.push({ url: RouterMap.LIVE_DETAIL_PAGE, param: info?.id })
              } else {
                this.liveVM.stopPip()
                let courseDetail =
                  this.homeData.courseData.courseList.find((course: CourseModel) => info?.id ===
                  course.id) as CourseModel
                courseDetail.catalogIndex = 0
                emitter.emit('changeCourseId', { data: { courseId: courseDetail.id } })
                RouterModule.push({ url: RouterMap.CHAPTER_DETAIL_PAGE, param: courseDetail })
              }
            } else {
              RouterModule.push({ url: RouterMap.LOGIN_PAGE })
            }
          })
        }, (item: Course) => {
          return item.id.toString()
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap($r('app.float.vp_8'))
      .rowsGap($r('app.float.vp_8'))
      .width('100%')
    }
  }

  /**
   * 热门课程
   */
  @Builder
  popularCourseBuilder() {
    Text($r('app.string.popular_course'))
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin({ bottom: $r('app.float.vp_16') })

    List() {
      ForEach(this.homeData.popularCourseList, ((item: Course) => {
        ListItem() {
          CourseItemComponent({
            courseTitle: item.courseTitle,
            courseDuration: item.courseDuration,
            learnProgress: item.learnProgress,
            cover: item.cover,
          })
        }
        .onClick(() => {
          RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: item.id })
        })
      }), (item: Course, index: number) => item.courseTitle + index)
    }
    .width('100%')
    .height('auto')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .padding($r('app.float.vp_12'))
  }

  getTimeFromSeconds(seconds: number): string {
    const hours = Math.floor(seconds / 3600); // 每小时3600秒
    const minutes = Math.floor((seconds % 3600) / 60); // 剩余秒数转换为分钟
    const remainingSeconds = Math.round(seconds % 60); // 剩余的秒数

    // 使用字符串模板和padStart来确保小时、分钟和秒都是两位数
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString()
      .padStart(2, '0')}`;
  }

  /**
   * 轮播图banner
   */
  @Builder
  swiperBannerBuilder() {
    Swiper() {
      Image($r('app.media.home_banner_image1'))
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Fill)
        .width('100%')
        .height($r('app.float.vp_184'))
        .draggable(false)
        .onClick(()=>{
          console.info('hello')
        })

      Image($r('app.media.home_banner_image1'))
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Fill)
        .width('100%')
        .height($r('app.float.vp_184'))
        .draggable(false)
    }
    .draggable(false)
    .loop(true)
    .autoPlay(true)
    .interval(2000)
    .margin({ top: $r('app.float.vp_12') })
    .borderRadius(16)
    .height($r('app.float.vp_184'))
    .width('100%')
  }

  /**
   * 菜单栏
   */
  @Builder
  homeMenuBarBuilder() {
    Row() {
      ForEach(MENU_DATA, (item: HomeMenuModel, index: number) => {
        this.drawMenuItemBuilder(index, item.titleName, item.icon, item.url)
      }, (item: HomeMenuModel) => JSON.stringify(item))
    }
    .width('100%')
    .height($r('app.float.vp_92'))
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .margin({ top: $r('app.float.vp_12') })
  }

  /**
   * 菜单子项
   * @param titleName
   * @param icon
   * @param url
   */
  @Builder
  drawMenuItemBuilder(index: number, titleName: Resource, icon?: ResourceStr, url?: string) {
    Column() {
      Image(icon)
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
      Text(titleName)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
        .margin({ top: $r('app.float.vp_8') })
    }
    .width('25%')
    .onClick(() => {
      if (url) {
        RouterModule.push({ url: url, param: index })
      }
    })
  }
}

@Builder
export function HomePageBuilder() {
  HomePage();
}