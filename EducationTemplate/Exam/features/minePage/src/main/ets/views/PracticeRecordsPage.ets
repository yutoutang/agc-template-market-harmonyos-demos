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
import { PracticeModel, PracticeRecordModel, PRACTICE_RECORD_DATA, TopBar } from 'commonlib';
import dayjs from 'dayjs';

/**
 * 练习记录页面
 */
@ComponentV2
export struct PracticeRecordsPage {
  practiceModels: PracticeModel[] = []
  practiceRecordModels: PracticeRecordModel[] = [];
  todayPracticeRecord: PracticeRecordModel = new PracticeRecordModel();

  aboutToAppear(): void {
    // 练习记录测试数据
    this.practiceModels = PRACTICE_RECORD_DATA;
    // 初始化数据
    this.initData();
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder()
      Divider().color($r('sys.color.comp_divider'))
      Column() {
        // 当天练习
        this.todayPracticeBuilder()
        // 练习明细
        this.practiceDetailsBuilder()
        // 明细表
        this.tableBuilder()
      }
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  tableCell(text: Resource | string) {
    Text(text)
      .textAlign(TextAlign.Center)
      .width($r('app.float.vp_82'))
      .fontSize($r('sys.float.Caption_L'))
      .fontColor($r('sys.color.font_secondary'))
      .fontWeight(FontWeight.Regular)
  }

  @Builder
  tableBuilder() {
    Column() {
      Row() {
        this.tableCell($r('app.string.practice_date'))
        this.tableCell($r('app.string.practice_duration'))
        this.tableCell($r('app.string.practice_count'))
        this.tableCell($r('app.string.correct_rate'))
      }
      .height($r('app.float.vp_40'))
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'))

      Column() {
        ForEach(this.practiceRecordModels,
          (item: PracticeRecordModel, index: number) => {
            Row() {
              this.tableCell(item.date)
              this.tableCell(item.practiceDuration ?? '-')
              this.tableCell(item.practiceCount ?? '-')
              this.tableCell(item.correctRate ?? '-')
            }
            .width('100%')
            .height($r('app.float.vp_40'))
            .backgroundColor(index % 2 === 0 ? $r('sys.color.background_primary') :
            $r('sys.color.background_secondary'))
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              if (item.practiceCount) {
                RouterModule.push({ url: RouterMap.DAY_PRACTICE_DETAILS_PAGE, param: item })
              } else {
                this.getUIContext().getPromptAction().showToast({
                  message: item.date + '无练习记录'
                })
              }
            })
          }, (item: PracticeRecordModel, index: number) => item.date + index)
      }
    }
  }

  /**
   * 练习明细
   */
  @Builder
  practiceDetailsBuilder() {
    Row() {
      Text($r('app.string.practice_details'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Row() {
        Text($r('app.string.more'))
          .fontSize($r('sys.float.Caption_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
        Image($r('app.media.icon_right'))
          .width($r('app.float.vp_16'))
          .height($r('app.float.vp_16'))
          .margin({ left: $r('app.float.vp_4') })
      }
      .onClick(() => {
        RouterModule.push({ url: RouterMap.PRACTICE_DETAILS_PAGE })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: $r('app.float.vp_16'), bottom: $r('app.float.vp_28') })
  }

  /**
   * 当天练习
   */
  @Builder
  todayPracticeBuilder() {
    Row() {
      Text($r('app.string.today_practice'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') })
      Text('(模拟数据：设定当天为2025-5-29)')
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_secondary'))
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)

    Row() {
      Column() {
        Text(this.todayPracticeRecord.practiceDuration ?? '-')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
        Text($r('app.string.practice_duration'))
          .margin({ top: $r('app.float.vp_4') })
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_secondary'))
      }
      .height($r('app.float.vp_56'))
      .width($r('app.float.vp_80'))
      .justifyContent(FlexAlign.Center)
      .borderRadius(12)
      .backgroundColor($r('sys.color.background_primary'))

      Column() {
        Text(this.todayPracticeRecord.practiceCount ?? '-')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
        Text($r('app.string.practice_count'))
          .fontSize($r('sys.float.Caption_L'))
          .margin({ top: $r('app.float.vp_4') })
          .fontColor($r('sys.color.font_secondary'))
      }
      .height($r('app.float.vp_56'))
      .width($r('app.float.vp_80'))
      .justifyContent(FlexAlign.Center)
      .borderRadius(12)
      .backgroundColor($r('sys.color.background_primary'))

      Column() {
        Text(this.todayPracticeRecord.correctRate ?? '-')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
        Text($r('app.string.correct_rate'))
          .margin({ top: $r('app.float.vp_4') })
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_secondary'))
      }
      .height($r('app.float.vp_56'))
      .width($r('app.float.vp_80'))
      .justifyContent(FlexAlign.Center)
      .borderRadius(12)
      .backgroundColor($r('sys.color.background_primary'))
    }
    .height($r('app.float.vp_80'))
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius($r('app.float.vp_16'))
    .padding({ left: $r('app.float.vp_24'), right: $r('app.float.vp_24') })
    .onClick(() => {
      if (this.todayPracticeRecord.practiceCount) {
        RouterModule.push({ url: RouterMap.DAY_PRACTICE_DETAILS_PAGE, param: this.todayPracticeRecord })
      } else {
        this.getUIContext().getPromptAction().showToast({
          message: this.todayPracticeRecord.date + '无练习记录'
        })
      }
    })
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      // 练习记录
      TopBar({
        onClickBack: () => {
          RouterModule.pop()
        },
        title: $r('app.string.practice_records')
      })
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }

  /**
   * 初始化数据
   */
  initData() {
    for (let index = 0; index < 7; index++) {
      let date: string = dayjs('2025/5/29').subtract(index, 'day').format('YYYY-MM-DD')
      let record: PracticeRecordModel = new PracticeRecordModel();
      let practiceDuration: number = 0;
      let topicCount: number = 0;
      let rightCount: number = 0;
      let onDayPracticeModels: PracticeModel[] = []
      let practiceCount: number = 0;
      this.practiceModels.forEach((item: PracticeModel) => {
        if (date === item.date) {
          practiceCount++;
          rightCount += item.rightCount;
          topicCount += item.topicCount;
          practiceDuration += item.practiceDuration;
          onDayPracticeModels.push(item);
        }
      })
      record.date = date;
      if (practiceCount > 0) {
        let h = Math.floor(practiceDuration / 3600) < 10 ? '0' + Math.floor(practiceDuration / 3600) :
        Math.floor(practiceDuration / 3600)
        let m = Math.floor(practiceDuration % 3600 / 60) < 10 ? '0' + Math.floor(practiceDuration % 3600 / 60) :
        Math.floor(practiceDuration % 3600 / 60)
        let s = (practiceDuration % 60) < 10 ? '0' + (practiceDuration % 60) : (practiceDuration % 60)
        record.practiceDuration = h + ':' + m + ':' + s;
        record.practiceCount = practiceCount.toString();
        record.correctRate = (rightCount / topicCount * 100).toFixed(2) + '%';
        record.practiceModels = onDayPracticeModels;
      }
      this.practiceRecordModels.push(record);
      if (index === 0) {
        this.todayPracticeRecord = record;
      }
    }
  }
}

@Builder
export function PracticeRecordsBuilder() {
  PracticeRecordsPage()
}