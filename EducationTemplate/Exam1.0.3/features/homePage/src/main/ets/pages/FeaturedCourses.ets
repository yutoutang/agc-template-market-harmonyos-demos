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

import { TopTabsBuilder } from 'commonlib'
import { Course } from '../model/Course';
import { CourseComponent } from '../components/CourseComponent';

// 精选课程页面
@ComponentV2
export struct FeaturedCourses {
  @Local textInput: string = ''
  controller: TextInputController = new TextInputController();
  @Local coursesSource: Course[] = [new Course('111', '华为用户', '一级建造师精华题库中级班', 423, 288),
    new Course('222', '华为用户', '一级建造师精华题库中级班', 423, 288)]
  @Local courses: Course[] = []
  @Local enterTypes: Array<EnterKeyType> =
    [EnterKeyType.Go, EnterKeyType.Search, EnterKeyType.Send, EnterKeyType.Done, EnterKeyType.Next,
      EnterKeyType.PREVIOUS, EnterKeyType.NEW_LINE];
  @Local index: number = 0;

  aboutToAppear(): void {
    this.courses = this.coursesSource
  }

  build() {
    Column() {
      Column() {
        TopTabsBuilder({ title: '精选课程', bgColor: $r('sys.color.background_primary'), showBackButton: true })
          .margin({ bottom: '8vp' })
          .padding({ left: '16vp', right: '16vp' })

        Divider().width('100%')
        // 资料列表
        this.courseListBuilder()
      }
      .width('100%')
      .height('100%')
    }
  }

  /**
   * 资料列表
   */
  @Builder
  courseListBuilder() {
    Column() {
      ForEach(this.courses, (item: Course, index: number) => {
        CourseComponent({ course: item })
          .width('100%')
          .margin({ bottom: index === 0 ? '8vp' : '0vp' })
      }, (item: Course, index: number) => item.courseName + index)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%')
    .padding({ left: '16vp', right: '16vp', top: '12vp' })
  }
}

@Builder
export function FeaturedCoursesBuilder() {
  FeaturedCourses()
}