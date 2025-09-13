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

import { MainEntryVM } from '../viewmodels/MainEntryVM';
import { TabListItem } from '../models/Types';
import { window } from '@kit.ArkUI';
import { CourseVM } from 'course';

@Builder
export function MainEntryBuilder() {
  MainEntry()
}

@ComponentV2
struct MainEntry {
  @Local vm: MainEntryVM = MainEntryVM.instance;
  @Local courseVM: CourseVM = CourseVM.instance;

  aboutToAppear(): void {
    this.vm.initCourseData()
    window.getLastWindow(getContext(this)).then((windowClass: window.Window) => {
      windowClass.setWindowLayoutFullScreen(false)
    });
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column({ space: 2 }) {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(TabStyle.ICON_SIZE)
        .height(TabStyle.ICON_SIZE)
      Text(item.label)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor(this.vm.curIndex === index ?
        $r('app.color.icon_bg_blue') : $r('sys.color.icon_secondary'))
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(TabStyle.BAR_HEIGHT)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: $$this.vm.curIndex, controller: this.vm.controller }) {
        ForEach(this.vm.tabList, (item: TabListItem, index: number) => {
          TabContent() {
            item.component.builder();
          }
          .tabBar(this.tabBarBuilder(item, index))
        }, (item: TabListItem, index) => JSON.stringify(item) + '_' + index)
      }
      .scrollable(false)
      .animationDuration(TabStyle.ANIMATION_DURATION)
      .barMode(BarMode.Fixed)
      .barHeight(TabStyle.BAR_HEIGHT)
      .height('100%')
      .width('100%')
      .onChange((index: number) => {
        if (index === 1) {
          this.courseVM.queryLearnedCourse()
        }
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

export class TabStyle {
  static readonly BAR_HEIGHT = 48;
  static readonly ANIMATION_DURATION = 0;
  static readonly ICON_SIZE = 24;
}