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
export class CourseMessageModel {
  @Trace id: string
  @Trace icon: ResourceStr
  @Trace messageType: string
  @Trace courseTitle: string
  @Trace courseSubtitle: string
  @Trace time: string
  @Trace maxLines: number;

  constructor(id: string, icon: ResourceStr, messageType: string,
    courseTitle: string, courseSubtitle: string, time: string,
    maxLines: number) {
    this.id = id
    this.icon = icon
    this.messageType = messageType
    this.courseTitle = courseTitle
    this.courseSubtitle = courseSubtitle
    this.time = time
    this.maxLines = maxLines;
  }
}

@ObservedV2
export class SystemMessageModel {
  @Trace id: string
  @Trace icon: ResourceStr
  @Trace messageType: string
  @Trace title: string
  @Trace subtitle: string
  @Trace time: string
  @Trace maxLines: number;

  constructor(id: string, icon: ResourceStr, messageType: string,
    title: string, subtitle: string, time: string,
    maxLines: number) {
    this.id = id
    this.icon = icon
    this.messageType = messageType
    this.title = title
    this.subtitle = subtitle
    this.time = time
    this.maxLines = maxLines;
  }
}

// 存储消息中心数据
@ObservedV2
export class SystemMessageObj {
  @Trace listArr: SystemMessageModel[] = [
    new SystemMessageModel('11', $r('app.media.icon_envelope'), '系统消息', '618热门活动来啦！',
      '这是正文内容，默认展示三行，超出三行部分省略展示，点击全文展示全部内容。这是正文内容', '2小时前', 3),
    new SystemMessageModel('22', $r('app.media.icon_envelope'), '系统消息', '用户协议及隐私政策更新通知 ',
      ' XX是（功能介绍）。华为非常重视您的个人信息和隐私保护，我们将会按照法律要求和业界成熟的安全标准，为您的个人信息提供相应的快放开放',
      '昨天', 3
    ),
    new SystemMessageModel('33', $r('app.media.icon_envelope'), '系统消息',
      '用户协议及隐私政策更新通知 ',
      'XX是（功能介绍）。华为非常重视您的个人信息和隐私保护，我们将会按照法律要求和业界成熟的安全标准，' +
        '为您的个人信息提供相应的保护措施,   1、 我们如何收集和使用您的个人信息 ...... 4、对儿童的保护 5、与第三方共享（共享） ' +
        '6、管理您的数据 7、如何联系我们 华为将始终遵照我们的隐私政策来收集和使用您的信息',
      '6-27', 3),
  ]
}

// 存储课程消息
@ObservedV2
export class CourseMessageObj {
  @Trace listArr: CourseMessageModel[] = [
    new CourseMessageModel('11', $r('app.media.icon_course_updates_message'), '课程动态', '课程内容更新',
      '一级建造师精华题库更新啦，更新范围包括：快来学习吧~', '刚刚', 3),
    new CourseMessageModel('22', $r('app.media.icon_course_updates_message'), '课程动态', '一级建造师精华题库更新啦~ ',
      '这是正文内容，默认展示三行，超出三行部分省略展示，点击全文展示全部内容。这是正文内容，默认展示三行，超出三行部分省略展示',
      '2小时前', 3
    ),
    new CourseMessageModel('33', $r('app.media.icon_course_updates_message'), '课程动态',
      '2025年最新CPA题库更新 ',
      '这是正文内容，默认展示三行，超出三行部分省略展示，点击全文展示全部内容.   这是正文内容默认展示三行，超出三行部分省略展示,这是正文  默认展示三行，' +
        '超出三行部分省略展示，点击全文展示全部内容。这是正文内容，默认展示三行，超出三行部分省略展示',
      '6-24', 3),
  ]
}