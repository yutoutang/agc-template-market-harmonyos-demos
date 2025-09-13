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

import { AppStorageV2 } from '@kit.ArkUI';
import { Logger } from 'commonlib';
import {
  Course,
  queryPremiumCourseData,
  queryFreeCourseData,
  queryMentorCourseData,
  queryHomeHotCourseData,
  queryHomeHotLiveData,
  queryHomeHotTeacherData,
  queryCourseCatalogList,
  CourseCatalog,
  queryHighlightsCourseData,
  queryLiveBroadcastCourseData,
  CourseClass,
} from 'http';

const TAG = '[HomeVM]';

@ObservedV2
export class HomeVM {
  @Trace courseData: CourseClass = AppStorageV2.connect(CourseClass, () => new CourseClass())!;
  @Trace popularCourseList: Course[] = []
  @Trace popularLiveList: Course[] = []
  @Trace popularTeacherList: Course[] = []
  // 课程数据
  @Trace courseList: Course[] = []
  // 课程总数
  @Trace courseTotal: number = 0
  // 课程目录
  @Trace catalogList: CourseCatalog[] = []
  // 正在直播课程数据
  @Trace liveBroadcastCourseList: Course[] = []
  // 精彩回顾课程数据
  @Trace highlightsCourseList: Course[] = []
  private static homeInstance: HomeVM;

  public static get instance() {
    if (!HomeVM.homeInstance) {
      HomeVM.homeInstance = new HomeVM();
    }
    return HomeVM.homeInstance;
  }

  /**
   * 获取首页热门课程数据列表
   * @returns
   */
  queryHomeHotCourseList() {
    queryHomeHotCourseData().then(res => {
      if (res.status === 200) {
        this.popularCourseList = res.data
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }

  /**
   * 获取首页热门直播数据列表
   * @returns
   */
  queryHomeHotLiveList() {
    queryHomeHotLiveData().then(res => {
      if (res.status === 200) {
        this.popularLiveList = res.data
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }

  /**
   * 获取首页热门名师数据列表
   * @returns
   */
  queryHomeHotTeacherList() {
    queryHomeHotTeacherData().then(res => {
      if (res.status === 200) {
        this.popularTeacherList = res.data
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }

  /**
   * 获取精品课程数据列表
   * @returns
   */
  getPremiumCourseList() {
    queryPremiumCourseData().then(res => {
      if (res.status === 200) {
        this.courseList = res.data
        this.courseTotal = res.data.length
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }

  /**
   * 获取免费课程数据列表
   * @returns
   */
  getFreeCourseList() {
    queryFreeCourseData().then(res => {
      if (res.status === 200) {
        this.courseList = res.data
        this.courseTotal = res.data.length
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }

  /**
   * 获取导师课程数据列表
   * @returns
   */
  getMentorCourseList() {
    queryMentorCourseData().then(res => {
      if (res.status === 200) {
        this.courseList = res.data
        this.courseTotal = res.data.length
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }

  /**
   * 获取正在直播课程数据列表
   * @returns
   */
  getLiveBroadcastCourseList() {
    queryLiveBroadcastCourseData().then(res => {
      if (res.status === 200) {
        this.liveBroadcastCourseList = res.data
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }

  /**
   * 获取精彩回顾课程数据列表
   * @returns
   */
  getHighlightsCourseList() {
    queryHighlightsCourseData().then(res => {
      if (res.status === 200) {
        this.highlightsCourseList = res.data
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }

  /**
   * 获取课程目录列表
   * @returns
   */
  queryCourseCatalogData() {
    queryCourseCatalogList().then(res => {
      if (res.status === 200) {
        this.catalogList = res.data
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }
}