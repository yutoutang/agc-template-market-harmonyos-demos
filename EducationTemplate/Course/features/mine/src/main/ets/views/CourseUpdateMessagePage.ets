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

import { AppStorageV2 } from '@kit.ArkUI';
import display from '@ohos.display'
import { TopBar, MyScrollModifier } from 'commonlib';
import { CourseMessageModel, CourseMessageObj } from '../models/SystemMessageModel';
import { MessageItem, NumbObj } from '../models/MessageModel';
import { MultiLineText } from '../views/MultiLineText';

@ComponentV2
export struct CourseUpdateMessagePage {
  @Local isSelectDelete: boolean = false;
  @Local swiperCourseLeft: boolean = false
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  @Local courseNumbObj: CourseMessageObj = AppStorageV2.connect(CourseMessageObj, () => new CourseMessageObj())!;

  build() {
    Column() {
      TopBar({ title: $r('app.string.course_update') })
      Scroll() {
        Column() {
          List({ space: 12 }) {
            ForEach(this.courseNumbObj.listArr, ((item: CourseMessageModel, index: number) => {
              ListItem() {
                CourseMessageItem({ courseInfo: item })
              }
              .swipeAction({
                edgeEffect: SwipeEdgeEffect.None,
                end: {
                  builder: () => {
                    this.courseItemEnd(index)
                  },
                  actionAreaDistance: 26,
                  onStateChange: (state: SwipeActionState) => {
                    if (state === SwipeActionState.EXPANDED) {
                      this.swiperCourseLeft = true
                      this.isSelectDelete = false
                    } else if (state === SwipeActionState.COLLAPSED) {
                      this.swiperCourseLeft = false
                    }
                  },
                }
              })
            }), (item: CourseMessageModel, index: number) => item.id + index)
          }
          .width('100%')
          .height('auto')
        }
        .margin({ top: $r('app.float.vp_12') })
        .width('100%')
      }
      .attributeModifier(this.scrollModifier)
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
  }
  //更新角标
  refreshData() {
    let propNumbObj = AppStorageV2.connect(NumbObj, () => new NumbObj())!;
    propNumbObj.listArr.forEach((item: MessageItem) => {
      if (item.title === '课程动态') {
        item.unreadMessageCount = this.courseNumbObj.listArr.length
      }
    })
  }
  @Builder
  courseItemEnd(index: number) {
    Row() {
      Image($r('app.media.icon_envelope_delete'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.courseNumbObj.listArr.splice(index, 1)
          this.refreshData()
        })
    }.padding($r('app.float.vp_4')).justifyContent(FlexAlign.SpaceEvenly)
  }
}

@ComponentV2
struct CourseMessageItem {
  @Param courseInfo: CourseMessageModel = new CourseMessageModel('', '', '', '', '', '', 3)
  @Param screenWidth: number = display.getDefaultDisplaySync().width / display.getDefaultDisplaySync().scaledDensity;

  build() {
    Column() {
      Row() {
        Row() {
          Image(this.courseInfo.icon)
            .width($r('app.float.vp_16'))
            .height($r('app.float.vp_16'))
            .margin({ left: $r('app.float.vp_12') })
          Text(this.courseInfo.messageType)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: $r('app.float.vp_4') })
        }

        Text(this.courseInfo.time)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .margin({ right: $r('app.float.vp_12') })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .margin({ top: $r('app.float.vp_16') })

      Text(this.courseInfo.courseTitle)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({ left: $r('app.float.vp_12'), top: $r('app.float.vp_12') })
      // 多行内容
      Column() {
        MultiLineText({
          content: this.courseInfo.courseSubtitle.toString(),
          fontSize: $r('sys.float.Body_M'),
          lineHeight: $r('app.float.vp_19'),
          fontColor: $r('sys.color.font_secondary'),
          widthRatio: 0.9,
        })
      }
      .width(this.screenWidth - 32)
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
    .borderRadius($r('app.float.vp_16'))
  }
}

@Builder
export function CourseUpdateMessageBuilder() {
  CourseUpdateMessagePage()
}