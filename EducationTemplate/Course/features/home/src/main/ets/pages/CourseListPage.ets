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

import { TopBar, CourseItemComponent, RouterModule, RouterMap, } from 'commonlib'
import { Course } from 'http'
import { HomeVM } from '../viewModels/HomeVM'

@ComponentV2
export struct CourseListPage {
  @Local titleName: ResourceStr = ''
  @Local searchValue: string = ''
  // 搜索后的课程列表
  @Local searchCourseList: Course[] = []
  model: HomeVM = HomeVM.instance

  @Monitor('searchValue')
  searchValueChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      this.model.courseTotal = this.searchCourseList.length
    } else {
      this.model.courseTotal = this.model.courseList.length
    }
  }

  aboutToAppear(): void {
    // 课程数据初始化
    this.initCourseData()
  }

  aboutToDisappear(): void {
    this.model.courseList = []
  }

  build() {
    Column() {
      TopBar({ title: this.titleName })
      // 搜索
      this.searchBuilder()
      LoadingProgress()
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .visibility(this.model.courseList.length === 0 ? Visibility.Visible : Visibility.None)
      // 课程总数
      this.courseTotalBuilder()
      // 课程列表
      this.courseListBuilder()
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 课程总数
   */
  @Builder
  courseTotalBuilder() {
    Text(`共${this.model.courseTotal}门课`)
      .margin({ top: $r('app.float.vp_8') })
      .fontSize($r('sys.float.Caption_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .visibility(this.model.courseList.length > 0 ? Visibility.Visible : Visibility.None)
  }

  /**
   * 课程列表
   */
  @Builder
  courseListBuilder() {
    List() {
      ForEach(this.searchValue ? this.searchCourseList : this.model.courseList, ((item: Course) => {
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
            RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: item.id })
          })
        }
      }), (item: Course, index: number) => item.id + index)
    }
    .width('100%')
    .height('auto')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .layoutWeight(1)
    .padding({ bottom: $r('app.float.vp_8') })
  }

  /**
   * 搜索
   */
  @Builder
  searchBuilder() {
    Search({ placeholder: '搜索', value: this.searchValue })
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onChange((value: string) => {
        this.searchCourse(value)
      })
  }

  /**
   * 搜索课程
   * @param value
   */
  searchCourse(value: string) {
    this.searchValue = value.replace(/^\s+|\s+$/g, '');
    let tmp: Course[] = [];
    this.model.courseList.forEach((item: Course) => {
      if (item.courseTitle.indexOf(this.searchValue) !== -1) {
        tmp.push(item)
      }
    })
    this.searchCourseList = tmp;
  }

  initCourseData() {
    let temp: number = RouterModule.getNavParam({ url: RouterMap.COURSE_LIST_PAGE })!
    switch (temp) {
      case 0:
        this.titleName = $r('app.string.premium_courses')
        this.model.getPremiumCourseList()
        break
      case 2:
        this.titleName = $r('app.string.free_courses')
        this.model.getFreeCourseList()
        break
      case 3:
        this.titleName = $r('app.string.mentor_courses')
        this.model.getMentorCourseList()
        break
      default:
    }
  }
}

@Builder
export function CourseListPageBuilder() {
  CourseListPage()
}