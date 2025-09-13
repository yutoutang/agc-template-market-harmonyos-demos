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
import { CourseCatalogModel, CourseModel } from '../model/CourseModel'
import { Course, CourseCatalog } from '../types/Course'

export class ConvertTool {
  static convertCourseModel(course: Course): CourseModel {
    let courseModel: CourseModel = new CourseModel()
    courseModel.id = course.id
    courseModel.courseTitle = course.courseTitle
    courseModel.description = course.description
    courseModel.category = course.category
    courseModel.isFree = course.isFree
    courseModel.isPay = course.isPay
    courseModel.lecturer = course.lecturer
    courseModel.videoUrl = course.videoUrl
    courseModel.cover = course.cover
    courseModel.courseDuration = course.courseDuration
    courseModel.learnProgress = 0
    courseModel.learnNumber = course.learnNumber
    courseModel.reservationTime = course.reservationTime
    courseModel.liveNumber = course.liveNumber
    courseModel.liveState = course.liveState
    courseModel.time = course.time
    if (course.courseCatalog) {
      courseModel.courseCatalog = ConvertTool.convertCatalogModel(course.courseCatalog, courseModel.id)
    }
    return courseModel
  }

  static convertCatalogModel(courseCatalog: CourseCatalog[], courseId: string): CourseCatalogModel[] {
    let arr: CourseCatalogModel[] = []
    courseCatalog.forEach((item: CourseCatalog) => {
      let model: CourseCatalogModel = new CourseCatalogModel()
      model.id = item.id
      model.courseId = courseId
      model.catalogTitle = item.catalogTitle
      model.learnProgress = 0
      model.videoUrl = item.videoUrl
      model.comments = []
      arr.push(model)
    })
    return arr
  }
}