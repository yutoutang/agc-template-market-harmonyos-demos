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
import {
  CommentModel,
  CourseCatalogModel,
  CourseClass,
  CourseModel,
  queryCommentsData,
  queryCourseHistory
} from 'http';

@ObservedV2
export class MyVM {
  @Trace courseData: CourseClass = AppStorageV2.connect(CourseClass, () => new CourseClass())!;
  @Trace historyList: CourseModel[] = []
  @Trace commentsList: CommentModel[] = []
  private static _instance: MyVM;

  public static get instance() {
    if (!MyVM._instance) {
      MyVM._instance = new MyVM();
    }
    return MyVM._instance;
  }

  /**
   * 获取观看记录
   * @returns
   */
  queryCourseHistoryList() {
    queryCourseHistory().then(res => {
      if (res.status === 200) {
        let historyList: CourseModel[] =
          this.courseData.courseList.filter((course: CourseModel) => course.isWatch === true)
        historyList.sort((a, b) => b.watchTime - a.watchTime)
        historyList.forEach((course: CourseModel) => {
          course.isDelete = false
        })
        this.historyList = historyList
      }
    })
  }

  /**
   * 获取评论记录
   * @returns
   */
  queryCommentsDataList() {
    queryCommentsData().then(res => {
      if (res.status === 200) {
        let courseList: CourseModel[] =
          this.courseData.courseList.filter((course: CourseModel) => course.isComments === true)
        let commentsList: CommentModel[] = []
        courseList.forEach((course: CourseModel) => {
          course.courseCatalog.forEach((catalog: CourseCatalogModel) => {
            commentsList.push(...catalog.comments)
          })
        })
        commentsList.sort((a, b) => b.time - a.time)
        this.commentsList = commentsList
      }
    })
  }
}