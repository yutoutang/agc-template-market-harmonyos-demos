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

import { AxiosResponse } from '@ohos/axios';
import { Course, CourseCatalog } from '../types/Course';
import { axiosInstance } from './HttpRequest';
import '../mocks/RequestMock';

// 查询总表课程数据
export const queryCourseData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/course/data';
  return axiosInstance.get(url);
};

// 查询首页热门课程数据列表
export const queryHomeHotCourseData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/home/hotCourseData';
  return axiosInstance.get(url);
};

// 查询首页热门直播数据列表
export const queryHomeHotLiveData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/home/hotLiveData';
  return axiosInstance.get(url);
};

// 查询首页热门名师数据列表
export const queryHomeHotTeacherData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/home/hotTeacherData';
  return axiosInstance.get(url);
};

// 查询精品课程数据
export const queryPremiumCourseData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/home/premiumCourseData';
  return axiosInstance.get(url);
};

// 查询免费课程数据
export const queryFreeCourseData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/home/freeCourseData';
  return axiosInstance.get(url);
};

// 查询导师课程数据
export const queryMentorCourseData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/home/mentorCourseData';
  return axiosInstance.get(url);
};

// 查询正在直播课程数据
export const queryLiveBroadcastCourseData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/home/liveBroadcastCourseData';
  return axiosInstance.get(url);
};

// 查询精彩回顾课程数据
export const queryHighlightsCourseData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/home/highlightsCourseData';
  return axiosInstance.get(url);
};

// 查询已学习的课程数据
export const queryLearnedCourseData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/course/learnedCourseData';
  return axiosInstance.get(url);
};

// 查询课程目录
export const queryCourseCatalogList = (): Promise<AxiosResponse<Array<CourseCatalog>, void>> => {
  const url = '/catalog/list';
  return axiosInstance.get(url);
};

// 查询观看记录
export const queryCourseHistory = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/course/history';
  return axiosInstance.get(url);
};

// 查询评论记录
export const queryCommentsData = (): Promise<AxiosResponse<Course[], void>> => {
  const url = '/course/comments';
  return axiosInstance.get(url);
};