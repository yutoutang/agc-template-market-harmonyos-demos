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

import { GlobalContextUtils, PracticeModel, PracticeRecordModel, PRACTICE_RECORD_DATA, TopBar } from 'commonlib';
import { RouterMap, RouterModule } from 'commonlib';
import dayjs from 'dayjs';

/**
 * 练习明细页面
 */
@ComponentV2
export struct PracticeDetailsPage {
  @Local practiceRecordModels: PracticeRecordModel[] = [];
  practiceModels: PracticeModel[] = [];
  // 默认时间降序
  @Local descOrder: boolean = true;

  aboutToAppear(): void {
    // 练习记录测试数据
    this.practiceModels = PRACTICE_RECORD_DATA;
    // 初始化数据
    this.initData();
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      Divider().color($r('sys.color.comp_divider'));
      Column() {
        // 时间
        this.timeBuilder();
        // 明细表
        this.tableBuilder();
      }
      .layoutWeight(1)
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /**
   * 表格单元格样式
   */
  @Builder
  tableCellStyle(text: Resource | string) {
    Text(text)
      .width($r('app.float.vp_70'))
      .textAlign(TextAlign.Center)
      .fontSize($r('sys.float.Caption_L'))
      .fontWeight(FontWeight.Regular)
      .fontColor($r('sys.color.font_secondary'));
  }

  /**
   * 明细表
   */
  @Builder
  tableBuilder() {
    Column() {
      Row() {
        this.tableCellStyle($r('app.string.practice_date'));
        this.tableCellStyle($r('app.string.practice_duration'));
        this.tableCellStyle($r('app.string.practice_count'));
        this.tableCellStyle($r('app.string.correct_rate'));
      }
      .width('100%')
      .height($r('app.float.vp_40'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .justifyContent(FlexAlign.SpaceBetween);

      List() {
        ForEach(this.practiceRecordModels,
          (item: PracticeRecordModel, index: number) => {
            ListItem() {
              Row() {
                this.tableCellStyle(item.date);
                this.tableCellStyle(item.practiceDuration ?? '-');
                this.tableCellStyle(item.practiceCount ?? '-');
                this.tableCellStyle(item.correctRate ?? '-');
              }
              .width('100%')
              .height($r('app.float.vp_40'))
              .backgroundColor(index % 2 === 0 ? $r('sys.color.comp_background_primary') :
                $r('sys.color.comp_background_tertiary'))
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                if (item.practiceCount) {
                  RouterModule.push({ url: RouterMap.DAY_PRACTICE_DETAILS_PAGE, param: item });
                } else {
                  GlobalContextUtils.showToast({ message: '无练习记录' });
                }
              });
            };
          }, (item: PracticeRecordModel, index: number) => item.date + index);
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });
    }
    .layoutWeight(1);
  }

  /**
   * 时间
   */
  @Builder
  timeBuilder() {
    Row() {
      Row() {
        Text($r('app.string.time'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: $r('app.float.vp_8') });
        Image($r('app.media.arrow_bottom_filled'))
          .width($r('app.float.vp_20'))
          .height($r('app.float.vp_20'))
          .rotate({ angle: this.descOrder ? 0 : 180 });
      }
      .width($r('app.float.vp_58'))
      .height($r('app.float.vp_28'))
      .backgroundColor($r('app.color.time_btn'))
      .borderRadius(8)
      .onClick(() => {
        this.descOrder = !this.descOrder;
        if (this.descOrder) {
          this.practiceRecordModels.sort((a, b) => dayjs(b.date).valueOf() - dayjs(a.date).valueOf());
        } else {
          this.practiceRecordModels.sort((a, b) => dayjs(a.date).valueOf() - dayjs(b.date).valueOf());
        }
      });

      Text($r('app.string.recent_30_days_practice'))
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'));
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') });
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      // 练习明细
      TopBar({
        onClickBack: () => {
          RouterModule.pop();
        },
        title: $r('app.string.practice_details')
      });
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
  }

  /**
   * 初始化数据
   */
  initData() {
    for (let index = 0; index < 30; index++) {
      let record: PracticeRecordModel = new PracticeRecordModel();
      let date: string = dayjs('2025/5/29').subtract(index, 'day').format('YYYY-MM-DD');
      let practiceDuration: number = 0;
      let rightCount: number = 0;
      let topicCount: number = 0;
      let practiceCount: number = 0;
      let onDayPracticeModels: PracticeModel[] = [];
      this.practiceModels.forEach((item: PracticeModel) => {
        if (date === item.date) {
          practiceDuration += item.practiceDuration;
          rightCount += item.rightCount;
          topicCount += item.topicCount;
          practiceCount++;
          onDayPracticeModels.push(item);
        }
      });
      record.date = date;
      let h = Math.floor(practiceDuration / 3600) < 10 ? '0' + Math.floor(practiceDuration / 3600) :
        Math.floor(practiceDuration / 3600);
      let m = Math.floor(practiceDuration % 3600 / 60) < 10 ? '0' + Math.floor(practiceDuration % 3600 / 60) :
        Math.floor(practiceDuration % 3600 / 60);
      let s = (practiceDuration % 60) < 10 ? '0' + (practiceDuration % 60) : (practiceDuration % 60);
      if (practiceCount > 0) {
        record.practiceDuration = h + ':' + m + ':' + s;
        record.practiceCount = practiceCount.toString();
        record.correctRate = (rightCount / topicCount * 100).toFixed(2) + '%';
        record.practiceModels = onDayPracticeModels;
      }
      this.practiceRecordModels.push(record);
    }
  }
}

@Builder
export function PracticeDetailsBuilder() {
  PracticeDetailsPage();
}