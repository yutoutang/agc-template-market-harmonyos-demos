/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import dayjs from 'dayjs'

export class BrowsingHistoryModel {
  // 记录ID
  keyID: string = ''
  // 浏览时间
  browseTime: number = 0
  // 课程路由
  routerRouter: string = ''
  // 课程名称
  courseName: string = ''
}

export const BROWSING_HISTORY_DATA: BrowsingHistoryModel[] = [
  {
    keyID: '1',
    browseTime: dayjs('2025-5-30').valueOf(),
    routerRouter: 'GoodCourseDetailPage',
    courseName: '一级建造师精华题库中级班'
  },
  {
    keyID: '2',
    browseTime: dayjs('2025-5-25').valueOf(),
    routerRouter: 'GoodCourseDetailPage',
    courseName: '一级建造师精华题库高级班'
  },
  {
    keyID: '3',
    browseTime: dayjs('2025-5-28').valueOf(),
    routerRouter: 'GoodCourseDetailPage',
    courseName: '一级建造师精华题库初级班'
  }
]
