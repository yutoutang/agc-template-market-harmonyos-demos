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

import { JSON } from '@kit.ArkTS';
import { AppStorageV2 } from '@kit.ArkUI';
import { RouterMap, RouterModule } from 'router_module';
import { TopTabsBuilder } from 'commonlib';
import { MockObj, MockItem } from '../viewModel/CourseHomeModel'

@ComponentV2
struct MockItemComponent {
  @Require @Param item: MockItem

  build() {
    Row() {
      // 试卷详情
      this.examDetailsBuilder()

      Image($r('app.media.chevron_right'))
        .height($r('app.float.vp_16'))
        .width($r('app.float.vp_16'))
        .margin({ top: $r('app.float.vp_3') })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Top)
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
    .padding($r('app.float.vp_12'))
    .borderRadius($r('app.float.vp_16'))
    .margin({ bottom: $r('app.float.vp_12') })
  }

  /**
   * 试卷详情
   */
  @Builder
  examDetailsBuilder() {
    Row() {
      Image(this.item.imageSrc)
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_40'))
        .margin({ right: $r('app.float.vp_8') })
      Column() {
        Text(this.item.text)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .lineHeight($r('app.float.vp_19'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: $r('app.float.vp_4') })
        Text(`已有 ${this.item.num}人 做过`)
          .fontColor($r('sys.color.font_tertiary'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
      }.width('65%').alignItems(HorizontalAlign.Start)
    }
  }
}

@ComponentV2
export struct MockTestPage {
  @Local mockTestList: MockItem[] = []
  @Local navType: number = 1
  @Local prop: MockObj = AppStorageV2.connect(MockObj, () => new MockObj())!;

  aboutToAppear(): void {
    this.mockTestList = this.prop.mockList
    this.navType = RouterModule.getNavParam({ url: RouterMap.Mock_PAGE }) as number
  }

  build() {
    Column() {
      TopTabsBuilder({
        title: this.navType === 1 ? '模拟试卷' : '全真试卷',
        showBackButton: true,
        bgColor: $r('sys.color.background_primary'),
      }).padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      // 试卷列表
      this.examListBuilder()
    }
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 试卷列表
   */
  @Builder
  examListBuilder() {
    Column() {
      ForEach(this.mockTestList, (item: MockItem) => {
        //模拟试卷子项
        MockItemComponent({ item: item })
          .onClick(() => {
            // 跳转项的num+1
            this.prop = AppStorageV2.connect(MockObj, () => new MockObj())!;
            this.prop.mockList.forEach((it: MockItem) => {
              if (it.id === item.id) {
                it.num = it.num + 1
              }
            })
            RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_TWO_PAGE });
          })
      }, (item: MockItem ,index: number) => item.id + index)
    }
    .width('100%')
    .height('100%')
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_12'),
      bottom: $r('app.float.vp_12')
    })
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}

@Builder
export function MockTestPageBuilder() {
  MockTestPage()
}


