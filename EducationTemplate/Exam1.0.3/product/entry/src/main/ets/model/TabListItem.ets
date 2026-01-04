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

import { HomePageBuilder } from 'homepage';
import { MinePageBuilder } from 'minepage';
import { CourseHomePageBuilder } from 'topicpage';

export interface TabListItem {
  label: string;
  icon: Resource;
  iconChecked: Resource;
  component: WrappedBuilder<[]>;
}

export const TAB_CONFIG: TabListItem[] = [
  {
    label: '练习',
    icon: $r('app.media.ic_public_brush_off'),
    iconChecked: $r('app.media.ic_public_brush_on'),
    component: wrapBuilder(HomePageBuilder),
  },
  {
    label: '课程',
    icon: $r('app.media.icon_Question_off'),
    iconChecked: $r('app.media.icon_Question_on'),
    component: wrapBuilder(CourseHomePageBuilder),
  },
  {
    label: '我的',
    icon: $r('app.media.icon_My_off'),
    iconChecked: $r('app.media.icon_My_on'),
    component: wrapBuilder(MinePageBuilder),
  },
];
