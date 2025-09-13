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
import { RouterMap } from 'commonlib'

@ObservedV2
class ServiceModel {
  @Trace titleName: Resource = $r('app.string.my_course')
  @Trace icon?: ResourceStr
  @Trace url?: string
}

const MENU_DATA: ServiceModel[] = [
  {
    titleName: $r('app.string.my_course'),
    icon: $r('app.media.icon_me_course'),
    url: RouterMap.MY_COURSE_PAGE
  },
  {
    titleName: $r('app.string.my_collection'),
    icon: $r('app.media.icon_me_collection'),
    url: RouterMap.MY_COLLECTION_PAGE
  },
  {
    titleName: $r('app.string.my_download'),
    icon: $r('app.media.icon_me_download'),
    url: RouterMap.MY_DOWNLOAD_PAGE
  },
  {
    titleName: $r('app.string.my_wrong_question'),
    icon: $r('app.media.icon_me_wrong_question'),
    url: RouterMap.MY_WRONG_QUESTION_PAGE
  },
]

const FIRST_SERVICE_DATA: ServiceModel[] = [
  {
    titleName: $r('app.string.my_order'),
    icon: $r('app.media.icon_me_order'),
    url: RouterMap.MY_ORDER_PAGE
  },
  {
    titleName: $r('app.string.message_notice'),
    icon: $r('app.media.icon_me_notification'),
    url: RouterMap.MESSAGE_PAGE
  },
  {
    titleName: $r('app.string.watch_history'),
    icon: $r('app.media.icon_me_history'),
    url: RouterMap.MY_COURSE_HISTORY_PAGE
  },
  {
    titleName: $r('app.string.my_comment'),
    icon: $r('app.media.icon_me_comment'),
    url: RouterMap.MY_COURSE_COMMENTS_PAGE
  },
]

const SECOND_SERVICE_DATA: ServiceModel[] = [
  {
    titleName: $r('app.string.opinion_and_feedback'),
    icon: $r('app.media.icon_me_feedback'),
    url: RouterMap.FEEDBACK_PAGE
  },
  {
    titleName: $r('app.string.online_customer_service'),
    icon: $r('app.media.icon_me_support'),
    url: ''
  },
  {
    titleName: $r('app.string.setting'),
    icon: $r('app.media.icon_me_setting'),
    url: RouterMap.SETUP_PAGE
  }
]

export { ServiceModel, MENU_DATA, FIRST_SERVICE_DATA, SECOND_SERVICE_DATA }
