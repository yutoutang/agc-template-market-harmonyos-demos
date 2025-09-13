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

import { SearchPage } from 'search';
import { RouterMap, RouterModule, UserInfo } from 'commonlib'
import { Course, COURSE_DATA } from 'http';
import { MyScrollModifier } from 'commonlib';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct HomeSearch {
  // 模拟后端数据源
  @Local searchSourceData: string[] = []
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  @Local searchCourse: Course[] = []
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!

  aboutToAppear(): void {
    // 搜索数据源数据
    this.searchCourse = COURSE_DATA.filter((item: Course) => item.category !== 2)
    this.searchSourceData = this.searchCourse.map((item: Course) => {
      return item.courseTitle;
    })
  }

  build() {
    Scroll() {
      Column() {
        SearchPage({
          searchSourceData: this.searchSourceData,
          clickSearchResult: (searchData) => {
            if (this.loginUser.isLogin) {
              let item = this.searchCourse.find(course => course.courseTitle === searchData)
              RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: item?.id })
            } else {
              RouterModule.push({ url: RouterMap.LOGIN_PAGE })
            }
          },
          back: () => {
            RouterModule.pop()
          },
        })
      }
      .width('100%')
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    }
    .attributeModifier(this.scrollModifier)
    .backgroundColor($r('sys.color.background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

  }
}

@Builder
export function SearchPageBuilder() {
  HomeSearch();
}