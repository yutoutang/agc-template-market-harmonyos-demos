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

@ObservedV2
export class CourseBook {
  @Trace bookName: string = '一级建造师精华题库'
  @Trace bookTag: string = '三色速记手册'
  @Trace visitors: number = 423
  @Trace type: string = 'pdf'
  @Trace downloadTimes: number = 23

  constructor(bookName: string, bookTag: string, visitors: number, type: string, downloadTimes: number) {
    this.bookName = bookName
    this.bookTag = bookTag
    this.visitors = visitors
    this.type = type
    this.downloadTimes = downloadTimes
  }
}
