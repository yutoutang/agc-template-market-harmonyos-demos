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
export class HomeMenuModel {
  @Trace titleName: Resource = $r('app.string.premium_courses')
  @Trace icon?: ResourceStr
  @Trace url?: string
}

export const MENU_DATA: HomeMenuModel[] = [
  {
    titleName: $r('app.string.premium_courses'),
    icon: $r('app.media.ic_home_menu_icon1'),
    url: RouterMap.COURSE_LIST_PAGE
  },
  {
    titleName: $r('app.string.live_streaming_courses'),
    icon: $r('app.media.ic_home_menu_icon2'),
    url: RouterMap.LIVE_STREAMING_LIST_PAGE
  },
  {
    titleName: $r('app.string.free_courses'),
    icon: $r('app.media.ic_home_menu_icon3'),
    url: RouterMap.COURSE_LIST_PAGE
  },
  {
    titleName: $r('app.string.mentor_courses'),
    icon: $r('app.media.ic_home_menu_icon4'),
    url: RouterMap.COURSE_LIST_PAGE
  },
]