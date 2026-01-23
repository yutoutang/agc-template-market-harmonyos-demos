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

import { display } from '@kit.ArkUI';
import dayjs from 'dayjs'
import { MyScrollModifier, NoData, PreferConstant, PreferenceUtil, TopBar } from 'commonlib';
import { FeedbackModel } from 'feed_back';

@ComponentV2
export struct FeedbackRecordsPage {
  @Local feedbackList: FeedbackModel[] = []
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  @Local imageSize: number = 96
  @Local foldStatus: number = display.getFoldStatus()

  regDisplayListener(): void {
    try {
      display.on('foldStatusChange', async (curFoldStatus: display.FoldStatus) => {
        // 同一个状态重复触发不做处理
        if (this.foldStatus === curFoldStatus) {
          return;
        }
        this.foldStatus = curFoldStatus;
        this.setCurFoldImageSize()
      })
    } catch (e) {
      console.error(`Failed to foldStatusChange. error: ${JSON.stringify(e)}`)
    }
  }

  setCurFoldImageSize() {
    if (this.foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.imageSize = 92
    } else if (this.foldStatus === 1) {
      this.imageSize = 100
    } else {
      this.imageSize = 96
    }
  }

  aboutToAppear(): void {
    this.regDisplayListener()
    this.setCurFoldImageSize()
    this.initData()
  }

  build() {
    NavDestination(){
      Column() {
        TopBar({ title: $r('app.string.feedback_records') })
        Scroll() {
          Column() {
            // 有数据时显示反馈记录列表
            this.feedbackListBuilder()
            // 无数据时显示
            NoData({ text: $r('app.string.feedback_no_data') })
              .visibility(this.feedbackList.length === 0 ? Visibility.Visible : Visibility.None)
          }
          .width('100%')
          .backgroundColor($r('sys.color.background_secondary'))
          .padding({ top: $r('app.float.vp_8') })
        }
        .attributeModifier(this.scrollModifier)
      }
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .height('100%')
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }.backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);

  }

  /**
   * 反馈记录
   */
  @Builder
  feedbackListBuilder() {
    List({ space: 12 }) {
      ForEach(this.feedbackList, (item: FeedbackModel) => {
        ListItem() {
          Column() {
            Text(dayjs().year() === dayjs(item.time).year() ? dayjs(item.time).format('MM/DD HH:mm') :
              dayjs(item.time).format('YYYY/MM/DD HH:mm'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
            Text($r('app.string.problem_desc'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_8') })
            Text(item.description)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
            Text($r('app.string.problem_screenshot'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: $r('app.float.vp_12') })
            Grid() {
              ForEach(item.uploadPictureUris, (item: string) => {
                GridItem() {
                  Image(item ? item : $r('app.media.upload_picture'))
                    .width(this.imageSize)
                    .height(this.imageSize)
                    .borderRadius(16)
                }
              }, (item: string, index: number) => item + index)
            }
            .columnsTemplate(`repeat(auto-stretch, ${this.imageSize})`)
            .rowsGap($r('app.float.vp_8'))
            .scrollBar(BarState.Off)
            .height(this.foldStatus !== 1 && item.uploadPictureUris.length > 3 ? this.imageSize * 2 + 8 :
              this.imageSize)
            .margin({ top: $r('app.float.vp_12') })
            .visibility(item.uploadPictureUris.length > 0 ? Visibility.Visible : Visibility.None)
          }
          .backgroundColor($r('sys.color.background_primary'))
          .padding($r('app.float.vp_12'))
          .width('100%')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start)
        }
      }, (item: FeedbackModel) => JSON.stringify(item))
    }
    .width('100%')
    .height('auto')
    .scrollBar(BarState.Off)
    .visibility(this.feedbackList.length > 0 ? Visibility.Visible : Visibility.None)
  }

  /**
   * 数据初始化
   */
  initData() {
    // 获意见与反馈全部持久化缓存数据
    let value = PreferenceUtil.getInstance(PreferConstant.FEEDBACK_RECORDS).getAllSync()
    if (value) {
      this.feedbackList = Object.values(value) as FeedbackModel[];
    }
    // 按照时间顺序由近及远
    this.feedbackList.sort((a, b) => b.time - a.time)
  }
}

@Builder
export function FeedbackRecordsPageBuilder() {
  FeedbackRecordsPage();
}