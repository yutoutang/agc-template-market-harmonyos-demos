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

@ObservedV2
export class CollectionModel {
  id: string = '';
  // 课程标题
  courseTitle?: string;
  // 课程时长
  courseDuration?: number;
  // 学习进度
  learnProgress?: number;
  // 课程封面
  cover?: ResourceStr;
  // 标题
  topicTitle?: string;
  // 题目来源
  topicSource?: string;
  // 收藏时间
  time: number = 0;
  // 是否删除
  @Trace isDelete: boolean = false;
}

@ObservedV2
export class CollectionRouter {
  static singleton: CollectionRouter;

  static instance() {
    if (!CollectionRouter.singleton) {
      CollectionRouter.singleton = new CollectionRouter();
    }
    ;
    return CollectionRouter.singleton;
  }

  @Trace routerTitle: string = ''
  @Trace isCollection: boolean = true;
  @Trace isAnswerUpdate: boolean = false;
  @Trace topicSource: string = '';
}