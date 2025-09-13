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
import { CourseClass, CourseModel, queryLearnedCourseData } from 'http';

@ObservedV2
export class CourseVM {
  @Trace courseData: CourseClass = AppStorageV2.connect(CourseClass, () => new CourseClass())!;
  // 已学习的课程列表
  @Trace learnedCourseList: CourseModel[] = []
  // 课程总数
  @Trace learnedCourseTotal: number = 0
  // 是否请求数据成功
  @Trace isSuccess: boolean = false
  private static courseInstance: CourseVM;

  public static get instance() {
    if (!CourseVM.courseInstance) {
      CourseVM.courseInstance = new CourseVM();
    }
    return CourseVM.courseInstance;
  }

  queryLearnedCourse() {
    queryLearnedCourseData().then(res => {
      if (res.status === 200) {
        let learnedCourseList: CourseModel[] =
          this.courseData.courseList.filter((course: CourseModel) => course.isStudy === true)
        learnedCourseList.sort((a, b) => b.studyTime - a.studyTime)
        learnedCourseList.forEach((course: CourseModel) => {
          course.isDelete = false
        })
        this.learnedCourseList = learnedCourseList
        this.learnedCourseTotal = learnedCourseList.length
        this.isSuccess = true
      }
    })
  }
}