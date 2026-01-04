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

import { RouterMap, RouterModule } from 'router_module';
import { ChapterContent } from '../model/ChapterPractice'

@ComponentV2
export struct ChapterPractice {
  @Local isStrongShow: boolean = false
  @Local isBasicShow: boolean = false
  @Local basicAllNum: number = 0
  @Local strongAllNum: number = 0
  @Local strongList: ChapterContent[] = [new ChapterContent('第一章', '设备更新分析', 10),
    new ChapterContent('第二章', '价值工程', 10)]
  @Local basicList: ChapterContent[] = [new ChapterContent('第一章', '资金时间价值计算及应用', 10),
    new ChapterContent('第二章', '经济效果评价', 10),
    new ChapterContent('第三章', '不确定性分析', 10)]

  aboutToAppear(): void {
    this.basicAllNum = this.basicList.reduce((sum, it: ChapterContent) => sum + it.num, 0);
    this.strongAllNum = this.strongList.reduce((sum, it: ChapterContent) => sum + it.num, 0);
  }

  @Builder
  topBuilder(str: string) {
    Row() {
      Image($r('app.media.ic_backward'))
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_40'))
        .margin({ right: $r('app.float.vp_8') })
        .onClick(() => {
          RouterModule.pop()
        })
      Text(str)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Medium)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_8'),
      bottom: $r('app.float.vp_8')
    })
  }

  @Builder
  practiseListBuilder(item: ChapterContent) {
    Row() {
      Row() {
        Text(item.text).margin({ right: $r('app.float.vp_8') })
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
        Text(item.subtext)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
      }

      Text(`(共${item.num}题)`).margin({ right: $r('app.float.vp_8') })
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .borderRadius(8)
    .padding({
      left: $r('app.float.vp_12'),
      right: $r('app.float.vp_12'),
      top: $r('app.float.vp_8'),
      bottom: $r('app.float.vp_8')
    })
    .margin({ bottom: $r('app.float.vp_12') })
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onClick(() => {
      RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE })
    })
  }

  build() {
    Column() {
      this.topBuilder('章节练习')
      Divider().color($r('sys.color.comp_divider'))
      Column() {
        // 基础练习题
        this.basePractiseBuilder()
        // 强化练习题
        this.strengthenPractiseBuilder()
      }.padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 强化练习题
   */
  @Builder
  strengthenPractiseBuilder() {
    Row() {
      Row() {
        Text('强化练习题')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary')).margin({ right: $r('app.float.vp_10') })
        if (!this.isStrongShow) {
          Text(`(共${this.strongAllNum}题)`)
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
      }

      Image(this.isStrongShow ? $r('app.media.chevron_Upward') : $r('app.media.chevron_Downward'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
        .onClick(() => {
          this.isStrongShow = !this.isStrongShow
        })
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') })

    Column() {
      ForEach(this.strongList, (item: ChapterContent) => {
        this.practiseListBuilder(item)
      }, (item: ChapterContent, index: number) => item.text + index)
    }
    .visibility(this.isStrongShow ? Visibility.Visible : Visibility.None)
  }

  /**
   * 基础练习题
   */
  @Builder
  basePractiseBuilder() {
    Row() {
      Row() {
        Text('基础练习题')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary')).margin({ right: $r('app.float.vp_10') })
        if (!this.isBasicShow) {
          Text(`(共${this.basicAllNum}题)`)
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
      }

      Image(this.isBasicShow ? $r('app.media.chevron_Upward') : $r('app.media.chevron_Downward'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
        .onClick(() => {
          this.isBasicShow = !this.isBasicShow
        })
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') })

    Column() {
      ForEach(this.basicList, (item: ChapterContent) => {
        this.practiseListBuilder(item)
      }, (item: ChapterContent, index: number) => item.text + index)
    }
    .visibility(this.isBasicShow ? Visibility.Visible : Visibility.None)
  }
}

@Builder
export function ChapterPracticeBuilder() {
  ChapterPractice()
}
