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

import { emitter } from '@kit.BasicServicesKit'
import { AppStorageV2 } from '@kit.ArkUI'
import { RouterModule, RouterMap, UserInfo, NoData } from 'commonlib'
import { CourseModel } from 'http'
import { CourseStudyComponent } from '../component/CourseStudyComponent'
import { CourseVM } from '../viewModels/CourseVM'

@ComponentV2
export struct MyLearnPage {
  @Local titleName: ResourceStr = ''
  @Local searchValue: string = ''
  // 搜索后的课程列表
  @Local searchCourseList: CourseModel[] = []
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  model: CourseVM = CourseVM.instance

  @Monitor('searchValue')
  searchValueChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      this.model.learnedCourseTotal = this.searchCourseList.length
    } else {
      this.model.learnedCourseTotal = this.model.learnedCourseList.length
    }
  }

  build() {
    Column() {
      // 学习---导航标题
      this.titleBuilder()
      // 未登录显示
      this.notLoginBuilder()
      Column() {
        // 搜索已学习课程
        this.searchLearnedCourseBuilder()
        LoadingProgress()
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .visibility(this.model.isSuccess ? Visibility.None : Visibility.Visible)
        NoData({ text: '当前暂无已学习课程。' })
          .visibility(this.model.isSuccess && this.model.learnedCourseList.length === 0 ?
          Visibility.Visible : Visibility.None)
        // 已学习课程总数
        this.learnedCourseTotalBuilder()
        // 已学习课程列表
        this.learnedCourseListBuilder()
      }
      .layoutWeight(1)
      .visibility(this.loginUser.isLogin ? Visibility.Visible : Visibility.None)
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .width('100%')
  }

  /**
   * 未登录显示
   */
  @Builder
  notLoginBuilder() {
    Column() {
      Image($r('app.media.ic_not_login'))
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Fill)
        .width($r('app.float.vp_120'))
        .height($r('app.float.vp_120'))
        .clip(true)
      Text('登录后享受更多服务\n\n点击登录')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_tertiary'))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .onClick(()=>{
          RouterModule.push({ url: RouterMap.LOGIN_PAGE })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .visibility(this.loginUser.isLogin ? Visibility.None : Visibility.Visible)
  }

  /**
   * 学习---导航标题
   */
  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.my_learn'))
        .width('100%')
        .height($r('app.float.vp_56'))
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .align(Alignment.Start)
    }.onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean) => {
      if (isExpanding) {
        this.model.queryLearnedCourse()
        emitter.on('queryCourse', (event: emitter.EventData) => {
          let isRefresh = event.data!.refresh as boolean
          if (isRefresh) {
            this.model.queryLearnedCourse()
          }
        })
      } else {
        this.model.learnedCourseList = []
        this.model.isSuccess = false
      }
    })
  }

  /**
   * 已学习课程总数
   */
  @Builder
  learnedCourseTotalBuilder() {
    Text(`共${this.model.learnedCourseTotal}门课`)
      .width('100%')
      .fontSize($r('sys.float.Caption_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .margin({ top: $r('app.float.vp_8') })
      .visibility(this.model.learnedCourseList.length > 0 ? Visibility.Visible : Visibility.None)
      .align(Alignment.Start)
  }

  /**
   * 已学习课程列表
   */
  @Builder
  learnedCourseListBuilder() {
    List() {
      ForEach(this.searchValue ? this.searchCourseList : this.model.learnedCourseList, ((course: CourseModel) => {
        ListItem() {
          // 课程列表子项
          CourseStudyComponent({
            courseCover: course.cover,
            courseTitle: course.courseTitle,
            learnProgress: course.isStudyEnd ? 100 : course.learnProgress,
          }).onClick(() => {
            RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: course.id })
          })
        }
      }), (course: CourseModel, index: number) => course.id + index)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .padding({ bottom: $r('app.float.vp_8') })
    .width('100%')
    .height('auto')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  /**
   * 搜索已学习课程
   */
  @Builder
  searchLearnedCourseBuilder() {
    Search({ placeholder: '搜索', value: this.searchValue })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .width('100%')
      .height($r('app.float.vp_40'))
      .onChange((value: string) => {
        this.searchCourseChange(value)
      })
  }

  /**
   * 搜索输入框文字变化时执行
   * @param value
   */
  searchCourseChange(value: string) {
    this.searchValue = value.replace(/^\s+|\s+$/g, '');
    let temp: CourseModel[] = [];
    this.model.learnedCourseList.forEach((course: CourseModel) => {
      if (course.courseTitle.indexOf(this.searchValue) !== -1) {
        temp.push(course)
      }
    })
    this.searchCourseList = temp;
  }
}

@Builder
export function MyLearnPageBuilder() {
  MyLearnPage()
}