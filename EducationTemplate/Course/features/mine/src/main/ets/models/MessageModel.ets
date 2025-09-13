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
export class MessageItem {
  @Trace id: string
  @Trace icon: ResourceStr
  @Trace title: string
  @Trace subtitle: string
  @Trace time: string
  @Trace isClearMessage: boolean
  @Trace unreadMessageCount: number

  constructor(id: string, icon: ResourceStr, title: string, subtitle: string, time: string, isClearMessage: boolean,
    unreadMessageCount: number) {
    this.id = id
    this.icon = icon
    this.title = title
    this.subtitle = subtitle
    this.time = time
    this.isClearMessage = isClearMessage
    this.unreadMessageCount = unreadMessageCount
  }
}

// 存储消息中心数据
@ObservedV2
export class NumbObj {
  @Trace listArr: MessageItem[] = [
    new MessageItem('1111', $r('app.media.icon_system_message'), '系统消息',
      '亲爱的用户您好~2025.06.26 24:00:00进行安全升级，部分私信功能将无法使用，给您带来不便万分抱歉！感谢您的理解和支持！',
      '刚刚',false, 3),
    new MessageItem('22', $r('app.media.icon_course_updates'), '课程动态', '一级建造师精华题库更新啦，', '07-10',false, 3)
  ];
}

@ObservedV2
export class VersionModel {
  @Trace isLatestVersion: boolean = false;
}