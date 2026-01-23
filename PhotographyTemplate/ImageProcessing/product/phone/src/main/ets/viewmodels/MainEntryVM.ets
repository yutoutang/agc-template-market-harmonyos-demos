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

import { HomePageBuilder } from 'home';

import { MinePageBuilder } from 'mine';
import { TabListItem } from '../models/Types';

const TAG = '[MainEntryVM]';

@ObservedV2
export class MainEntryVM {
  @Trace curIndex: number = 0;
  public controller: TabsController = new TabsController();
  public tabList: TabListItem[] = [
    {
      label: '首页',
      icon: $r('app.media.icon_house_fill_off'),
      iconChecked: $r('app.media.icon_house_fill_on'),
      component: wrapBuilder(HomePageBuilder),
    },
    {
      label: '我的',
      icon: $r('app.media.icon_person_fill_off'),
      iconChecked: $r('app.media.icon_person_fill_on'),
      component: wrapBuilder(MinePageBuilder),
    },
  ];
  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }


}
