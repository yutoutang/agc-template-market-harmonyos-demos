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

import { HttpStatusCode } from '@ohos/axios';
import { axiosInstance } from '../apis/HttpRequest';
import { Course } from '../types/Course';
import { AxiosMock } from './AxiosMock';
import { COURSE_CATALOG, COURSE_DATA } from './Data/CourseData';

const mock: AxiosMock = new AxiosMock(axiosInstance, {
  delayResponse: 500,
});

// 查询总表课程数据
mock.onGet('/course/data').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: COURSE_DATA,
  };
})

// 查询首页热门课程数据列表
mock.onGet('/home/hotCourseData').reply(async () => {
  let hotCourseData: Course[] = COURSE_DATA.filter((item: Course) => item.category === 1)
  // 按照学习人数有多到少排序
  hotCourseData.sort((a, b) => b.learnNumber! - a.learnNumber!)
  hotCourseData = hotCourseData.filter((_item: Course, index: number) => index < 3)
  return {
    status: HttpStatusCode.Ok,
    data: hotCourseData,
  };
})

// 查询首页热门直播数据列表
mock.onGet('/home/hotLiveData').reply(async () => {
  let hotLiveData: Course[] = COURSE_DATA.filter((item: Course) => item.category === 2)
  // 按照在线人数有多到少排序
  hotLiveData.sort((a, b) => b.liveNumber! - a.liveNumber!)
  hotLiveData = hotLiveData.filter((_item: Course, index: number) => index < 4)
  return {
    status: HttpStatusCode.Ok,
    data: hotLiveData,
  };
})

// 查询首页热门名师数据列表
mock.onGet('/home/hotTeacherData').reply(async () => {
  let hotTeacherData: Course[] = COURSE_DATA.filter((item: Course) => item.category === 3)
  // 按照学习人数有多到少排序
  hotTeacherData.sort((a, b) => b.learnNumber! - a.learnNumber!)
  hotTeacherData = hotTeacherData.filter((_item: Course, index: number) => index < 2)
  return {
    status: HttpStatusCode.Ok,
    data: hotTeacherData,
  };
})

// 查询课程目录
mock.onGet('/catalog/list').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: COURSE_CATALOG,
  };
})

// 查询精品课程数据
mock.onGet('/home/premiumCourseData').reply(async () => {
  let premiumCourseData: Course[] = COURSE_DATA.filter((item: Course) => item.category === 1 && !item.isFree)
  return {
    status: HttpStatusCode.Ok,
    data: premiumCourseData,
  };
})

// 查询正在直播课程数据
mock.onGet('/home/liveBroadcastCourseData').reply(async () => {
  let liveBroadcastCourseData: Course[] =
    COURSE_DATA.filter((item: Course) => item.category === 2 && (item.liveState === 1 || item.liveState === 2))
  liveBroadcastCourseData.sort((a, b) => b.liveNumber! - a.liveNumber!)
  return {
    status: HttpStatusCode.Ok,
    data: liveBroadcastCourseData,
  };
})

// 查询精彩回顾课程数据
mock.onGet('/home/highlightsCourseData').reply(async () => {
  let highlightsCourseData: Course[] =
    COURSE_DATA.filter((item: Course) => item.category === 2 && item.liveState === 0)
  highlightsCourseData.sort((a, b) => b.liveNumber! - a.liveNumber!)
  return {
    status: HttpStatusCode.Ok,
    data: highlightsCourseData,
  };
})

// 查询免费课程数据
mock.onGet('/home/freeCourseData').reply(async () => {
  let freeCourseData: Course[] = COURSE_DATA.filter((item: Course) => item.category === 1 && item.isFree)
  return {
    status: HttpStatusCode.Ok,
    data: freeCourseData,
  };
})

// 查询导师课程数据
mock.onGet('/home/mentorCourseData').reply(async () => {
  let mentorCourseData: Course[] = COURSE_DATA.filter((item: Course) => item.category === 3)
  return {
    status: HttpStatusCode.Ok,
    data: mentorCourseData,
  };
})

// 查询已学习的课程数据
mock.onGet('/course/learnedCourseData').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: [],
  };
})

// 查询观看记录
mock.onGet('/course/history').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: [],
  };
})

// 查询评论记录
mock.onGet('/course/comments').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: [],
  };
})
